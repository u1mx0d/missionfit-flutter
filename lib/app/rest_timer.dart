import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui' show IsolateNameServer;

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/rest_actions.dart';
import '../domain/active_workout.dart';
import '../domain/format.dart';
import '../domain/units.dart';
import '../domain/weight_step.dart';
import 'active_workout_controller.dart';
import 'profile_controller.dart';
import 'providers.dart';
import 'today_provider.dart' show clockProvider;
import 'workout_providers.dart';

/// Süren dinlenme. Bitiş anı diske de yazılır (uygulama kapanıp açılınca sürer).
class RestState {
  const RestState({required this.endsAt, required this.totalSeconds, required this.exerciseId});

  final DateTime endsAt;
  final int totalSeconds;

  /// Dinlenmeyi başlatan (seti biten) hareket; süre bu hareket için hatırlanır.
  final String exerciseId;

  Duration remaining(DateTime now) {
    final d = endsAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  @override
  bool operator ==(Object other) =>
      other is RestState &&
      other.endsAt == endsAt &&
      other.totalSeconds == totalSeconds &&
      other.exerciseId == exerciseId;

  @override
  int get hashCode => Object.hash(endsAt, totalSeconds, exerciseId);
}

/// Dinlenme ekranında ve bildirimde "sıradaki": `nextUp()`'tan gelir.
class RestNext {
  const RestNext({
    required this.exerciseId,
    required this.name,
    required this.setNumber,
    required this.targetSets,
    this.values,
  });

  final String exerciseId;
  final String name;
  final int setNumber;
  final int targetSets;

  /// "62,5 × 8", "8 tekrar", "0:45"; değer bilinmiyorsa null.
  final String? values;

  String get label => values == null ? name : '$name · $values';

  /// Bildirim gövdesi: "Sıradaki: Bench Press · 62,5 × 8 (Set 3/4)".
  String get notificationText => 'Sıradaki: $label (Set $setNumber/$targetSets)';
}

const restMinSeconds = 15;
const restDefaultSeconds = 90;

/// Dinlenme ekranının ve bildirimin "sıradaki" satırı; hepsi hedefteyse null.
final restNextProvider = FutureProvider<RestNext?>((ref) async {
  final w = ref.watch(activeWorkoutControllerProvider).value;
  if (w == null) return null;
  final ({String exerciseId, int setIndex})? up;
  try {
    up = w.nextUp();
  } on StateError {
    // 50 set sınırı: o harekette sıradaki set yok.
    return null;
  }
  if (up == null) return null;
  final plan = w.plan.firstWhere((p) => p.exerciseId == up!.exerciseId);
  final info = await ref.watch(exerciseInfoProvider(plan.exerciseId).future);
  final last = await ref.watch(lastSessionSetsProvider(plan.exerciseId).future);
  final unit = ref.watch(profileProvider.select((p) => p.value?.units)) ?? WeightUnit.kg;
  return RestNext(
    exerciseId: plan.exerciseId,
    name: info?.nameTr ?? '…',
    setNumber: w.doneSets(plan.exerciseId) + 1,
    targetSets: math.max(plan.targetSets, w.doneSets(plan.exerciseId) + 1),
    values: _describe(prefill(plan.exerciseId, w, last), plan, unit),
  );
});

String? _describe(SetValues v, PlannedExercise p, WeightUnit unit) {
  if (p.tracking == 'duration') {
    return v.durationSeconds == null ? null : formatSeconds(v.durationSeconds!);
  }
  if (v.reps == null) return null;
  if (tracksWeight(p.tracking, p.equipment) && v.weightKg != null) {
    return '${formatAmount(shownWeight(v.weightKg!, p.equipment, unit))} × ${v.reps}';
  }
  return '${v.reps} tekrar';
}

/// Bildirimdeki "+15 sn"/"Atla" ana isolate'a bu akıştan gelir. Arka plan isolate'ı kapıyı
/// adıyla bulur; kapı yoksa (uygulama kapalı) eylemi kendisi uygular.
final restActionsProvider = Provider<Stream<RestActionMessage>>((ref) {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(restActionPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, restActionPortName);
  ref.onDispose(() {
    IsolateNameServer.removePortNameMapping(restActionPortName);
    port.close();
  });
  return port
      .map((msg) {
        ackRestMessage(msg);
        return RestActionMessage.fromPort(msg);
      })
      .where((m) => m != null)
      .cast<RestActionMessage>();
});

/// Dinlenme bitince uygulama öndeyse güçlü titreşim (bildirim de titrer).
final restEndFeedbackProvider = Provider<void Function()>(
  (ref) => () {
    final s = WidgetsBinding.instance.lifecycleState;
    if (s == null || s == AppLifecycleState.resumed) unawaited(HapticFeedback.heavyImpact());
  },
);

/// Dinlenme sayacı. Bitiş anı tek doğru kaynaktır: bellekte, diskte (`restEndsAt`) ve
/// bildirimde aynı tutulur. İşlemler sırayla çalışır.
class RestTimer extends Notifier<RestState?> {
  Future<void> _queue = Future.value();
  String? _sessionId;

  @override
  RestState? build() {
    final sub = ref.read(restActionsProvider).listen(_onAction);
    ref.onDispose(sub.cancel);
    // Antrenman bitti ya da silindi: süren dinlenme ve bildirimi kalkar.
    ref.listen(activeWorkoutControllerProvider, (_, next) {
      if (next is! AsyncData<ActiveWorkout?>) return;
      final id = next.value?.sessionId;
      if (state != null && _sessionId != null && id != _sessionId) unawaited(skip());
    });
    return null;
  }

  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);
  NotificationService get _notifications => ref.read(notificationServiceProvider);
  DateTime _now() => ref.read(clockProvider)();

  Future<void> _serial(Future<void> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  /// Bildirim ve disk hataları sayacı durdurmaz; yalnızca kaydedilir.
  Future<void> _safe(String what, Future<void> Function() op) async {
    try {
      await op();
    } catch (e, st) {
      debugPrint('Dinlenme ($what) başarısız: $e\n$st');
    }
  }

  void _set(RestState? s) {
    if (ref.mounted) state = s;
  }

  /// Seti biten hareket için: hatırlanan süre, yoksa plandaki (şablon) süre, yoksa 90 sn.
  Future<void> startFor(String exerciseId) async {
    final w = ref.read(activeWorkoutControllerProvider).value;
    final userId = ref.read(signedInUserIdProvider);
    if (w == null || userId == null) return;
    int? remembered;
    await _safe('hafıza', () async => remembered = await _repo.restSecondsFor(userId, exerciseId));
    final planned = w.plan.where((p) => p.exerciseId == exerciseId).firstOrNull?.restSeconds;
    await start(exerciseId, remembered ?? planned ?? restDefaultSeconds);
  }

  Future<void> start(String exerciseId, int seconds) => _serial(() async {
    final w = ref.read(activeWorkoutControllerProvider).value;
    if (w == null) return;
    final total = math.max(restMinSeconds, seconds);
    _sessionId = w.sessionId;
    final s = RestState(
      endsAt: _now().add(Duration(seconds: total)),
      totalSeconds: total,
      exerciseId: exerciseId,
    );
    _set(s);
    await _publish(s);
  });

  /// ±15 sn. Toplam en az 15 sn; yeni süre o hareket için hatırlanır.
  Future<void> adjust(int deltaSeconds) => _serial(() => _adjust(deltaSeconds));

  Future<void> _adjust(int delta) async {
    final s = state;
    final sessionId = _sessionId;
    if (s == null || sessionId == null) return;
    final total = math.max(restMinSeconds, s.totalSeconds + delta);
    final next = RestState(
      endsAt: s.endsAt.add(Duration(seconds: total - s.totalSeconds)),
      totalSeconds: total,
      exerciseId: s.exerciseId,
    );
    final userId = ref.read(signedInUserIdProvider);
    if (userId != null) {
      await _safe('hafıza', () => _repo.rememberRest(userId, s.exerciseId, total));
    }
    if (!next.endsAt.isAfter(_now())) {
      // Kısaltınca süre geçmişte kaldı: dinlenme bitti.
      await _clear(cancelNotification: true);
      return;
    }
    _set(next);
    await _publish(next);
  }

  Future<void> skip() => _serial(() => _clear(cancelNotification: true));

  /// Süre dolduysa dinlenmeyi kapatır. Bitiş bildirimi alarmla gelir; iptal edilmez.
  Future<void> finishIfDue() => _serial(() async {
    final s = state;
    if (s == null || s.endsAt.isAfter(_now())) return;
    await _clear(cancelNotification: false);
    ref.read(restEndFeedbackProvider)();
  });

  /// Açılışta ve uygulama öne gelince: diskteki bitişten devam eder. Bitiş geçmişteyse
  /// dinlenme bitmiş sayılır, bildirim kaldırılır.
  Future<void> restoreFrom(ActiveWorkout w) => _serial(() async {
    DateTime? endsAt;
    await _safe('okuma', () async => endsAt = await _repo.restEndFor(w.sessionId));
    final end = endsAt;
    if (end == null) {
      if (_sessionId == w.sessionId) _set(null);
      return;
    }
    _sessionId = w.sessionId;
    final now = _now();
    if (!end.isAfter(now)) {
      await _clear(cancelNotification: true);
      return;
    }
    final cur = state;
    final RestState s;
    if (cur != null && cur.endsAt == end) {
      s = cur;
    } else {
      final last = _lastSet(w);
      final exerciseId = cur?.exerciseId ?? last?.exerciseId ?? w.currentExerciseId;
      if (exerciseId == null) return;
      final left = end.difference(now).inSeconds;
      final sinceSet = last == null ? 0 : end.difference(last.completedAt).inSeconds;
      s = RestState(
        endsAt: end,
        totalSeconds: math.max(restMinSeconds, math.max(left, sinceSet)),
        exerciseId: exerciseId,
      );
      _set(s);
    }
    // Bildirim ve alarm yeniden kurulur (aynı kimlik, zararsız): "zorla durdur" ikisini de
    // silmiş olabilir.
    await _publish(s);
  });

  LoggedSet? _lastSet(ActiveWorkout w) {
    LoggedSet? best;
    for (final s in w.sets) {
      if (best == null || s.completedAt.isAfter(best.completedAt)) best = s;
    }
    return best;
  }

  Future<void> _clear({required bool cancelNotification}) async {
    final sessionId = _sessionId;
    _set(null);
    if (sessionId != null) await _safe('silme', () => _repo.setRestEnd(sessionId, null));
    if (cancelNotification) await _safe('iptal', _notifications.cancelRest);
  }

  Future<void> _publish(RestState s) async {
    final sessionId = _sessionId!;
    await _safe('kayıt', () => _repo.setRestEnd(sessionId, s.endsAt));
    RestNext? next;
    await _safe('sıradaki', () async => next = await ref.read(restNextProvider.future));
    final label = next?.notificationText ?? 'Hedeflenen setler tamam.';
    final payload = RestPayload(
      sessionId: sessionId,
      userId: ref.read(signedInUserIdProvider) ?? '',
      exerciseId: s.exerciseId,
      totalSeconds: s.totalSeconds,
      nextLabel: label,
    );
    await _safe('bildirim', () async {
      await _notifications.showRest(endsAt: s.endsAt, nextLabel: label, payload: payload.encode());
      await _notifications.scheduleRestEnd(s.endsAt, nextLabel: label);
    });
  }

  /// Bildirim eylemi ana isolate'a geldi: bellekteki sayaç bu oturumunsa onu değiştirir;
  /// değilse disk üzerinden uygular.
  void _onAction(RestActionMessage m) => unawaited(
    _serial(() async {
      if (state != null && _sessionId == m.payload.sessionId) {
        if (m.action == RestAction.plus15) return _adjust(15);
        return _clear(cancelNotification: true);
      }
      await _safe(
        'eylem',
        () => applyRestAction(
          m.action,
          m.payload,
          repo: _repo,
          notifications: _notifications,
          now: _now(),
        ),
      );
    }),
  );
}

final restTimerProvider = NotifierProvider<RestTimer, RestState?>(RestTimer.new);
