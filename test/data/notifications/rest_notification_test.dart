import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse, NotificationResponseType;
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/notifications/notification_service.dart';
import 'package:missionfit/data/notifications/rest_actions.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/workout/workout_repository.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/week.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Eklentiye giden çağrıları kaydeden sahte platform.
class FakePlatform implements NotificationsPlatform {
  final calls = <String>[];
  final channels = <({String id, String name, Int64List vibration})>[];
  final countdowns = <CountdownNotification>[];
  final alarms = <ScheduledAlert>[];
  final cancelled = <int>[];

  @override
  Future<void> initialize(String smallIcon) async => calls.add('initialize');
  @override
  Future<void> createChannel({
    required String id,
    required String name,
    required Importance importance,
  }) async => calls.add('channel:$id');
  @override
  Future<void> createAlertChannel({
    required String id,
    required String name,
    required Int64List vibrationPattern,
  }) async => channels.add((id: id, name: name, vibration: vibrationPattern));
  @override
  Future<bool?> areEnabled() async => true;
  @override
  Future<bool?> requestPermission() async => true;
  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async => calls.add('show:$id');
  @override
  Future<void> showCountdown(CountdownNotification n) async => countdowns.add(n);
  @override
  Future<void> scheduleExact(ScheduledAlert n) async => alarms.add(n);
  @override
  Future<void> cancel(int id) async => cancelled.add(id);
  @override
  Future<void> cancelAll() async => calls.add('cancelAll');
  @override
  Future<String?> launchPayload() async => null;
  @override
  Stream<String?> get tappedPayloads => const Stream.empty();
}

class _BrokenRepo extends Fake implements WorkoutRepository {
  @override
  Future<DateTime?> restEndFor(String sessionId) => Future.error(StateError('disk kilitli'));
  @override
  Future<void> setRestEnd(String sessionId, DateTime? endsAt) =>
      Future.error(StateError('disk kilitli'));
}

NotificationResponse _response(String actionId, RestPayload p) => NotificationResponse(
  notificationResponseType: NotificationResponseType.selectedNotificationAction,
  id: restNotificationId,
  actionId: actionId,
  payload: p.encode(),
);

const _bench = PlannedExercise(
  exerciseId: 'bench',
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 90,
);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final t0 = DateTime.utc(2026, 11, 19, 10);

  group('LocalNotificationService · dinlenme', () {
    late FakePlatform platform;
    late LocalNotificationService service;
    late DateTime now;

    setUp(() {
      platform = FakePlatform();
      now = t0;
      service = LocalNotificationService(platform, clock: () => now);
    });

    test('init "Dinlenme" kanalını titreşim deseniyle kurar', () async {
      await service.init();
      expect(platform.channels, hasLength(1));
      expect(platform.channels.single.name, 'Dinlenme');
      expect(platform.channels.single.id, restChannelId);
      expect(platform.channels.single.vibration.length, greaterThan(2));
    });

    test('showRest: sürekli, geri sayan kronometre, when = endsAt, +15 sn / Atla', () async {
      final endsAt = t0.add(const Duration(seconds: 90));
      await service.showRest(
        endsAt: endsAt,
        nextLabel: 'Sıradaki: Bench Press · 60 × 8',
        payload: 'p',
      );

      final n = platform.countdowns.single;
      expect(n.id, restNotificationId);
      expect(n.channelId, restChannelId);
      expect(n.channelName, 'Dinlenme');
      expect(n.endsAt, endsAt);
      expect(n.body, 'Sıradaki: Bench Press · 60 × 8');
      expect(n.payload, 'p');
      expect(n.timeoutAfter, greaterThanOrEqualTo(const Duration(seconds: 90)));
      expect([for (final a in n.actions) a.label], ['+15 sn', 'Atla']);
      expect([for (final a in n.actions) a.id], [restActionPlus15, restActionSkip]);
      // "+15 sn" bildirimi kapatmaz; "Atla" kapatır.
      expect([for (final a in n.actions) a.cancelsNotification], [false, true]);
    });

    test('scheduleRestEnd: bitişte titreşimli tam zamanlı alarm', () async {
      final endsAt = t0.add(const Duration(seconds: 90));
      await service.scheduleRestEnd(endsAt, nextLabel: 'Sıradaki: Dips', payload: 'yük');

      final a = platform.alarms.single;
      expect(a.id, restNotificationId);
      expect(a.at, endsAt);
      expect(a.channelName, 'Dinlenme');
      expect(a.title, 'Dinlenme bitti');
      expect(a.body, 'Sıradaki: Dips');
      expect(a.vibrationPattern, restVibrationPattern);
      // "Dinlenme bitti"ye dokununca da antrenmana dönülür.
      expect(a.payload, 'yük');
    });

    test('cancelRest bildirimi ve alarmı birlikte iptal eder', () async {
      await service.cancelRest();
      expect(platform.cancelled, [restNotificationId]);
    });
  });

  group('RestPayload', () {
    test('kodlanıp çözülür; bozuk yük null', () {
      const p = RestPayload(
        sessionId: 's1',
        userId: 'u1',
        exerciseId: 'bench',
        totalSeconds: 90,
        nextLabel: 'Sıradaki: Dips',
      );
      expect(RestPayload.tryDecode(p.encode()), p);
      expect(RestPayload.tryDecode(null), isNull);
      expect(RestPayload.tryDecode('{bozuk'), isNull);
      expect(RestAction.fromId(restActionPlus15), RestAction.plus15);
      expect(RestAction.fromId(restActionSkip), RestAction.skip);
      expect(RestAction.fromId(null), isNull);
    });
  });

  group('Bildirim eylemi (uygulama arka plandayken)', () {
    late AppDatabase db;
    late WorkoutRepository repo;
    late FakePlatform platform;
    late LocalNotificationService service;
    late DateTime now;
    late String sessionId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              userId: 'u1',
              createdAt: 'x',
              updatedAt: 'x',
              timezone: const Value('Europe/Istanbul'),
            ),
          );
      now = t0;
      repo = WorkoutRepository(db, OutboxRepository(db), clock: () => now);
      platform = FakePlatform();
      service = LocalNotificationService(platform, clock: () => now);
      final w = await repo.start(
        userId: 'u1',
        plan: const [_bench],
        timeZone: 'Europe/Istanbul',
        weekStartsOn: WeekStartsOn.monday,
      );
      sessionId = w.sessionId;
      await repo.setRestEnd(sessionId, t0.add(const Duration(seconds: 90)));
      now = t0.add(const Duration(seconds: 30));
    });

    tearDown(() => db.close());

    RestPayload payload() => RestPayload(
      sessionId: sessionId,
      userId: 'u1',
      exerciseId: 'bench',
      totalSeconds: 90,
      nextLabel: 'Sıradaki: Bench Press · Set 2/3',
    );

    test('"+15 sn" bitişi diskte uzatır, alarmı yeniden zamanlar, bildirimi günceller', () async {
      await applyRestAction(
        RestAction.plus15,
        payload(),
        repo: repo,
        notifications: service,
        now: now,
      );

      final newEnd = t0.add(const Duration(seconds: 105));
      expect(await repo.restEndFor(sessionId), newEnd);
      expect(platform.alarms.single.at, newEnd);
      final n = platform.countdowns.single;
      expect(n.endsAt, newEnd);
      expect(n.body, 'Sıradaki: Bench Press · Set 2/3');
      // Sonraki dokunuş güncel toplamı bilir; süre hareket için hatırlanır.
      expect(RestPayload.tryDecode(n.payload)!.totalSeconds, 105);
      expect(await repo.restSecondsFor('u1', 'bench'), 105);
    });

    test('"Atla" bitişi siler, bildirimi ve alarmı iptal eder', () async {
      await applyRestAction(
        RestAction.skip,
        payload(),
        repo: repo,
        notifications: service,
        now: now,
      );

      expect(await repo.restEndFor(sessionId), isNull);
      expect(platform.cancelled, [restNotificationId]);
      expect(platform.alarms, isEmpty);
    });

    test('dinlenme zaten bitmişse "+15 sn" yeniden başlatmaz, bildirimi kapatır', () async {
      now = t0.add(const Duration(seconds: 120));
      await applyRestAction(
        RestAction.plus15,
        payload(),
        repo: repo,
        notifications: service,
        now: now,
      );

      expect(platform.alarms, isEmpty);
      expect(platform.countdowns, isEmpty);
      expect(platform.cancelled, [restNotificationId]);
      expect(await repo.restEndFor(sessionId), isNull);
    });

    test('ana isolate açıksa eylem oraya iletilir, alındı gelince disk açılmaz', () async {
      final port = ReceivePort();
      addTearDown(port.close);
      final received = <RestActionMessage>[];
      port.listen((m) {
        received.add(RestActionMessage.fromPort(m)!);
        ackRestMessage(m);
      });
      final applied = <RestActionMessage>[];
      var stale = 0;

      await handleRestResponse(
        _response(restActionPlus15, payload()),
        mainPort: () => port.sendPort,
        applyInBackground: applied.add,
        onStalePort: () => stale++,
      );

      expect(received.single.action, RestAction.plus15);
      expect(received.single.payload, payload());
      expect(applied, isEmpty);
      expect(stale, 0);
    });

    test(
      'kayıtlı kapı ölü (alındı gelmiyor) → kayıt silinir, eylem arka planda uygulanır',
      () async {
        // Mesajı alan ama hiç yanıt vermeyen kapı: ölmüş isolate'ın kaydı gibi.
        final dead = ReceivePort();
        addTearDown(dead.close);
        final applied = <RestActionMessage>[];
        var stale = 0;

        await handleRestResponse(
          _response(restActionSkip, payload()),
          mainPort: () => dead.sendPort,
          applyInBackground: applied.add,
          onStalePort: () => stale++,
          ackTimeout: const Duration(milliseconds: 50),
        );

        expect(stale, 1);
        expect(applied.single.action, RestAction.skip);
        expect(applied.single.payload, payload());
      },
    );

    test('"Atla": disk hata verse de bildirim ve alarm iptal edilir', () async {
      await applyRestAction(
        RestAction.skip,
        payload(),
        repo: _BrokenRepo(),
        notifications: service,
        now: now,
      );
      expect(platform.cancelled, [restNotificationId]);
    });

    test('uygulama kapalıysa eylem arka planda uygulanır', () async {
      final applied = <RestActionMessage>[];
      final r = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        id: restNotificationId,
        actionId: restActionSkip,
        payload: payload().encode(),
      );

      await handleRestResponse(r, mainPort: () => null, applyInBackground: applied.add);

      expect(applied.single.action, RestAction.skip);
      expect(applied.single.payload, payload());
    });

    test('dinlenmeyle ilgisiz yanıt yok sayılır', () async {
      final applied = <RestActionMessage>[];
      await handleRestResponse(
        const NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          id: 1,
        ),
        mainPort: () => null,
        applyInBackground: applied.add,
      );
      expect(applied, isEmpty);
    });
  });
}
