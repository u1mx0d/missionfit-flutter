import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/active_workout.dart';
import '../domain/week.dart';
import 'profile_controller.dart';
import 'providers.dart' show notificationServiceProvider;
import 'rest_timer.dart';
import 'today_provider.dart' show defaultTimeZone;
import 'workout_providers.dart';

export 'workout_providers.dart' show DiscardedEmpty, Saved, WorkoutFinish;

/// Süren bir antrenman varken yenisi başlatılmak istendi; süren antrenman taşınır.
/// Arayüz bunu "Devam et"e çevirir; canlı oturum sessizce terk edilmez.
class WorkoutAlreadyActive implements Exception {
  const WorkoutAlreadyActive(this.workout);
  final ActiveWorkout workout;

  @override
  String toString() => 'WorkoutAlreadyActive(${workout.sessionId})';
}

/// Süren antrenman: bellekteki durum + her değişiklik anında diske (yerel + outbox).
/// İşlemler sırayla çalışır; hızlı iki dokunuş aynı set indeksini üretemez.
class ActiveWorkoutController extends AsyncNotifier<ActiveWorkout?> {
  Future<void> _queue = Future.value();

  @override
  Future<ActiveWorkout?> build() async {
    final userId = ref.watch(signedInUserIdProvider);
    // `start`/`finish` profilin geleceğini bekler; Riverpod 3'te dinleyicisi olmayan sağlayıcı
    // duraklar ve gelecek hiç tamamlanmaz. Bu dinleme profili controller yaşadıkça canlı tutar.
    ref.listen(profileProvider, (_, _) {});
    if (userId == null) return null;
    return ref.read(workoutRepositoryProvider).loadActive(userId);
  }

  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  String get _userId {
    final id = ref.read(signedInUserIdProvider);
    if (id == null) throw StateError('Oturum yok');
    return id;
  }

  Future<T> _serial<T>(Future<T> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  Future<ActiveWorkout> _current() async {
    final w = await future;
    if (w == null) throw StateError('Süren antrenman yok');
    return w;
  }

  void _clearDrafts() => ref.read(focusDraftsProvider.notifier).clearAll();

  /// Antrenman kapanınca dinlenme bildirimi ve bitiş alarmı kesin kalkar (dinlenme sayacı
  /// hiç kurulmamış olsa da: ör. soğuk açılış → ana sayfa → bitir).
  Future<void> _cancelRest() async {
    try {
      await ref.read(notificationServiceProvider).cancelRest();
    } catch (e) {
      debugPrint('Dinlenme bildirimi kaldırılamadı: $e');
    }
  }

  /// Yeni antrenman açar. Süren antrenman varsa [WorkoutAlreadyActive] fırlatır.
  Future<void> start(List<PlannedExercise> plan, {String? templateId, String? name}) =>
      _serial(() async {
        final current = await future;
        if (current != null) throw WorkoutAlreadyActive(current);
        final profile = await ref.read(profileProvider.future);
        final w = await _repo.start(
          userId: _userId,
          plan: plan,
          templateId: templateId,
          name: name ?? 'Antrenman',
          timeZone: profile?.timezone ?? defaultTimeZone,
          weekStartsOn: profile?.weekStartsOn ?? WeekStartsOn.monday,
        );
        _clearDrafts();
        state = AsyncData(w);
      });

  Future<void> _savePlan(ActiveWorkout w) async {
    state = AsyncData(w);
    await _repo.savePlan(w);
  }

  Future<void> select(String exerciseId) =>
      _serial(() async => _savePlan((await _current()).select(exerciseId)));

  Future<void> addExercise(PlannedExercise e) =>
      _serial(() async => _savePlan((await _current()).addExercise(e)));

  /// "+ Set": hedefi bir artırır (hedef bir sınır değildir).
  Future<void> addTargetSet(String exerciseId) => _serial(() async {
    final w = await _current();
    await _savePlan(
      ActiveWorkout(
        sessionId: w.sessionId,
        startedAt: w.startedAt,
        sets: w.sets,
        currentExerciseId: w.currentExerciseId,
        plan: [
          for (final p in w.plan)
            p.exerciseId == exerciseId
                ? PlannedExercise(
                    exerciseId: p.exerciseId,
                    tracking: p.tracking,
                    equipment: p.equipment,
                    targetSets: p.targetSets + 1,
                    restSeconds: p.restSeconds,
                  )
                : p,
        ],
      ),
    );
  });

  /// Yazım hata verirse bellekteki durum eskimiş olabilir (ör. yerel benzersizlik ihlali):
  /// durum diskten yeniden yüklenir, hata yine fırlatılır; "Tekrar dene" doğru indeksle yazar.
  Future<T> _resyncOnError<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (_) {
      try {
        state = AsyncData(await _repo.loadActive(_userId));
      } catch (_) {}
      rethrow;
    }
  }

  LoggedSet? _lastCompleted;

  /// Seçili hareketin sıradaki setini yazar.
  Future<LoggedSet> completeSet(SetValues v) => _serial(
    () => _resyncOnError(() async {
      final w = await _current();
      final exerciseId = w.currentExerciseId;
      if (exerciseId == null) throw StateError('Seçili hareket yok');
      final s = await _repo.completeSet(w, exerciseId, v);
      state = AsyncData(w.logSet(s));
      _lastCompleted = s;
      ref.read(focusDraftsProvider.notifier).remove(exerciseId);
      return s;
    }),
  );

  /// "Geri al": verilen seti (kimliğiyle) siler; set artık yoksa hiçbir şey yapmaz.
  Future<void> undo(LoggedSet s) => _serial(
    () => _resyncOnError(() async {
      final w = await _current();
      if (!w.sets.any((x) => x.id == s.id)) return;
      await _repo.deleteSet(s);
      state = AsyncData(w.removeSet(s.id));
    }),
  );

  /// Son tamamlanan seti geri alır (o set silinmişse hiçbir şey yapmaz).
  Future<void> undoLast() async {
    final s = _lastCompleted;
    if (s != null) await undo(s);
  }

  Future<void> editSet(LoggedSet s) => _serial(
    () => _resyncOnError(() async {
      final w = await _current();
      await _repo.updateSet(s);
      state = AsyncData(w.replaceSet(s));
    }),
  );

  Future<void> deleteSet(LoggedSet s) => _serial(
    () => _resyncOnError(() async {
      final w = await _current();
      await _repo.deleteSet(s);
      state = AsyncData(w.removeSet(s.id));
    }),
  );

  /// Antrenmanı bitirir; set yoksa oturum silinir ([DiscardedEmpty]).
  Future<WorkoutFinish> finish() => _serial(() async {
    final w = await _current();
    final profile = await ref.read(profileProvider.future);
    final r = await _repo.finish(w, bodyWeightKg: profile?.weightKg);
    _clearDrafts();
    await _cancelRest();
    // Sonraki antrenmanın "geçen sefer"i ve son antrenmanlar listesi yenilensin.
    ref.invalidate(lastSessionSetsProvider);
    ref.invalidate(recentWorkoutsProvider);
    state = const AsyncData(null);
    return r;
  });

  Future<void> discard() => _serial(() async {
    final w = await _current();
    await _repo.discard(w.sessionId);
    _clearDrafts();
    await _cancelRest();
    state = const AsyncData(null);
  });
}

final activeWorkoutControllerProvider =
    AsyncNotifierProvider<ActiveWorkoutController, ActiveWorkout?>(ActiveWorkoutController.new);

/// Set tamamlanınca odak modu çağırır: dinlenme o hareketin süresiyle başlar
/// (dinlenme ekranı odak modunun üstünde açılır).
final onSetCompletedProvider = Provider<void Function(String exerciseId)>(
  (ref) =>
      (exerciseId) => unawaited(ref.read(restTimerProvider.notifier).startFor(exerciseId)),
);

/// Odak modunda düzenlenen, henüz tamamlanmamış değerler. Ağırlık KULLANICININ BİRİMİNDE
/// (kg ya da lb) ve adım ızgarasında tutulur; kg'ye yalnızca set yazılırken çevrilir.
/// Böylece lb'de her "+" kg yuvarlamasıyla kaymaz.
class FocusDraft {
  const FocusDraft({this.weight, this.reps, this.durationSeconds});
  final double? weight;
  final int? reps;
  final int? durationSeconds;

  @override
  bool operator ==(Object other) =>
      other is FocusDraft &&
      other.weight == weight &&
      other.reps == reps &&
      other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(weight, reps, durationSeconds);
}

/// Hareket başına –/+ ile değiştirilmiş ama henüz tamamlanmamış değerler (yalnızca bellekte).
/// Harekete geri dönünce bu değerler korunur.
class FocusDrafts extends Notifier<Map<String, FocusDraft>> {
  @override
  Map<String, FocusDraft> build() => const {};

  void put(String exerciseId, FocusDraft v) => state = {...state, exerciseId: v};

  void remove(String exerciseId) {
    if (!state.containsKey(exerciseId)) return;
    state = {...state}..remove(exerciseId);
  }

  void clearAll() => state = const {};
}

final focusDraftsProvider = NotifierProvider<FocusDrafts, Map<String, FocusDraft>>(FocusDrafts.new);
