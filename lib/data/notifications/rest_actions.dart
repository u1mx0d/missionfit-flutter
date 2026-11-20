import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui' show DartPluginRegistrant, IsolateNameServer;

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;

import '../db/database.dart';
import '../sync/outbox.dart';
import '../workout/workout_repository.dart';
import 'notification_service.dart';

/// Dinlenme bildirimindeki eylemler ("+15 sn", "Atla"). Uygulama açıksa ana isolate'a
/// iletilir (sayaç durumu orada); kapalıysa arka plan isolate'ında doğrudan diske yazılır.
/// İki taraf da dinlenme bitişini `active_workout_plans.rest_ends_at`'ten okur.

enum RestAction {
  plus15,
  skip;

  static RestAction? fromId(String? id) => switch (id) {
    restActionPlus15 => RestAction.plus15,
    restActionSkip => RestAction.skip,
    _ => null,
  };
}

/// Bildirimin taşıdığı bağlam: eylem uygulama kapalıyken de uygulanabilsin.
class RestPayload {
  const RestPayload({
    required this.sessionId,
    required this.userId,
    required this.exerciseId,
    required this.totalSeconds,
    required this.nextLabel,
  });

  final String sessionId;
  final String userId;
  final String exerciseId;

  /// Dinlenmenin toplam süresi (hatırlanacak süre bundan türer).
  final int totalSeconds;

  /// Bildirim metni ("Sıradaki: …"); yeniden gösterirken aynen kullanılır.
  final String nextLabel;

  RestPayload withTotal(int seconds) => RestPayload(
    sessionId: sessionId,
    userId: userId,
    exerciseId: exerciseId,
    totalSeconds: seconds,
    nextLabel: nextLabel,
  );

  String encode() =>
      jsonEncode({'s': sessionId, 'u': userId, 'e': exerciseId, 't': totalSeconds, 'n': nextLabel});

  static RestPayload? tryDecode(String? raw) {
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return null;
      final s = j['s'], u = j['u'], e = j['e'], t = j['t'], n = j['n'];
      if (s is! String || u is! String || e is! String || t is! int || n is! String) {
        return null;
      }
      return RestPayload(sessionId: s, userId: u, exerciseId: e, totalSeconds: t, nextLabel: n);
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RestPayload &&
      other.sessionId == sessionId &&
      other.userId == userId &&
      other.exerciseId == exerciseId &&
      other.totalSeconds == totalSeconds &&
      other.nextLabel == nextLabel;

  @override
  int get hashCode => Object.hash(sessionId, userId, exerciseId, totalSeconds, nextLabel);
}

/// Isolate'lar arasında taşınan eylem.
class RestActionMessage {
  const RestActionMessage(this.action, this.payload);
  final RestAction action;
  final RestPayload payload;

  /// `SendPort` yalnızca basit değerler taşır. [reply] verilirse alan taraf alındığını
  /// (`true`) oraya bildirir.
  List<Object> toPort([SendPort? reply]) => [action.name, payload.encode(), ?reply];

  static RestActionMessage? fromPort(Object? msg) {
    if (msg is! List || msg.length < 2) return null;
    final a = RestAction.values.where((x) => x.name == msg[0]).firstOrNull;
    final p = RestPayload.tryDecode(msg[1] is String ? msg[1] as String : null);
    return a == null || p == null ? null : RestActionMessage(a, p);
  }
}

/// Ana isolate'ın eylemleri dinlediği kapının adı ([IsolateNameServer]).
const restActionPortName = 'missionfit.rest_actions';

/// Ana isolate gelen mesajın alındığını bildirir (mesajda yanıt kapısı varsa).
void ackRestMessage(Object? msg) {
  if (msg is List && msg.length >= 3 && msg[2] is SendPort) (msg[2] as SendPort).send(true);
}

const _plus = Duration(seconds: 15);

/// Eylemi yalnızca disk ve bildirimler üzerinden uygular (bellekte sayaç yokken).
/// Dinlenme bitmişse ya da yoksa eylem ne olursa olsun bildirim kaldırılır.
Future<void> applyRestAction(
  RestAction action,
  RestPayload p, {
  required WorkoutRepository repo,
  required NotificationService notifications,
  required DateTime now,
}) async {
  if (action == RestAction.skip) {
    // Önce bildirim ve alarm: disk hata verse de dinlenme kesin kapanır.
    await notifications.cancelRest();
    try {
      await repo.setRestEnd(p.sessionId, null);
    } catch (e, st) {
      debugPrint('Dinlenme bitişi silinemedi: $e\n$st');
    }
    return;
  }
  final endsAt = await repo.restEndFor(p.sessionId);
  if (endsAt == null || !endsAt.isAfter(now)) {
    await notifications.cancelRest();
    if (endsAt != null) await repo.setRestEnd(p.sessionId, null);
    return;
  }
  final next = endsAt.add(_plus);
  final updated = p.withTotal(p.totalSeconds + _plus.inSeconds);
  await repo.setRestEnd(p.sessionId, next);
  await repo.rememberRest(p.userId, p.exerciseId, updated.totalSeconds);
  await notifications.showRest(endsAt: next, nextLabel: p.nextLabel, payload: updated.encode());
  await notifications.scheduleRestEnd(next, nextLabel: p.nextLabel);
}

/// Bildirim yanıtını yönlendirir: ana isolate açıksa ona iletir, değilse burada uygular.
/// Kayıtlı kapı ölmüş bir isolate'a ait olabilir (`send` sessizce kaybolur); bu yüzden
/// [ackTimeout] içinde alındı bilgisi gelmezse kapı kaydı silinir ve eylem burada uygulanır.
Future<void> handleRestResponse(
  NotificationResponse r, {
  required SendPort? Function() mainPort,
  required FutureOr<void> Function(RestActionMessage) applyInBackground,
  void Function()? onStalePort,
  Duration ackTimeout = const Duration(seconds: 1),
}) async {
  final action = RestAction.fromId(r.actionId);
  final payload = RestPayload.tryDecode(r.payload);
  if (action == null || payload == null) return;
  final msg = RestActionMessage(action, payload);
  final port = mainPort();
  if (port != null) {
    final reply = ReceivePort();
    try {
      port.send(msg.toPort(reply.sendPort));
      final acked = await reply.first.timeout(ackTimeout, onTimeout: () => false);
      if (acked == true) return;
    } finally {
      reply.close();
    }
    onStalePort?.call();
  }
  await applyInBackground(msg);
}

/// Eklentinin arka plan isolate'ında çağrılır (uygulama arka planda ya da kapalı).
@pragma('vm:entry-point')
Future<void> restNotificationBackgroundHandler(NotificationResponse r) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await handleRestResponse(
      r,
      mainPort: () => IsolateNameServer.lookupPortByName(restActionPortName),
      onStalePort: () => IsolateNameServer.removePortNameMapping(restActionPortName),
      applyInBackground: (m) async {
        final db = AppDatabase.open();
        try {
          await applyRestAction(
            m.action,
            m.payload,
            repo: WorkoutRepository(db, OutboxRepository(db)),
            notifications: LocalNotificationService(PluginNotificationsPlatform()),
            now: DateTime.now(),
          );
        } finally {
          await db.close();
        }
      },
    );
  } catch (e, st) {
    debugPrint('Dinlenme eylemi uygulanamadı: $e\n$st');
  }
}
