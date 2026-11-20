import 'dart:async';
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/active_workout_controller.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/rest_timer.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/notifications/rest_actions.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const bench = PlannedExercise(
  exerciseId: 'bench',
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 90,
);
const dips = PlannedExercise(
  exerciseId: 'dips',
  tracking: 'reps',
  equipment: 'bodyweight',
  targetSets: 3,
  restSeconds: 60,
);

/// Dinlenme bildirimi çağrılarını kaydeden sahte servis.
class FakeNotifications implements NotificationService {
  final log = <String>[];
  final shown = <({DateTime endsAt, String nextLabel, String? payload})>[];
  final scheduled = <DateTime>[];
  final scheduledPayloads = <String?>[];
  int cancels = 0;

  @override
  Future<void> init() async {}
  @override
  Future<PermissionState> permission() async => PermissionState.granted;
  @override
  Future<PermissionState> requestPermission() async => PermissionState.granted;
  @override
  Future<void> showTest() async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> showRest({
    required DateTime endsAt,
    required String nextLabel,
    String? payload,
  }) async {
    log.add('show');
    shown.add((endsAt: endsAt, nextLabel: nextLabel, payload: payload));
  }

  @override
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel, String? payload}) async {
    log.add('schedule');
    scheduled.add(endsAt);
    scheduledPayloads.add(payload);
  }

  @override
  Future<void> cancelRest() async {
    log.add('cancel');
    cancels++;
  }

  @override
  Future<String?> launchPayload() async => null;
  @override
  Stream<String?> get tappedPayloads => const Stream.empty();
}

Future<void> _seedExercise(AppDatabase db, String id, String name) => db
    .into(db.exercises)
    .insert(
      ExercisesCompanion.insert(
        id: id,
        slug: id,
        nameTr: name,
        nameEn: name,
        equipment: 'barbell',
        type: 'strength',
        tracking: 'weight_reps',
        metValue: 5,
        createdAt: 'x',
      ),
    );

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final t0 = DateTime.utc(2026, 11, 19, 10);
  late AppDatabase db;
  late SharedPreferences sp;
  late DateTime now;
  late FakeNotifications notifications;
  late StreamController<RestActionMessage> actions;
  late int endFeedback;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            createdAt: 'x',
            updatedAt: 'x',
            weightKg: const Value(80),
            timezone: const Value('Europe/Istanbul'),
          ),
        );
    await _seedExercise(db, 'bench', 'Bench Press');
    await _seedExercise(db, 'dips', 'Dips');
    SharedPreferences.setMockInitialValues({});
    sp = await SharedPreferences.getInstance();
    now = t0;
    endFeedback = 0;
  });

  tearDown(() => db.close());

  /// Yeni bir uygulama açılışı gibi: her çağrı yeni kapsayıcı (bellek boş, disk aynı).
  ProviderContainer open() {
    notifications = FakeNotifications();
    actions = StreamController<RestActionMessage>();
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(sp),
        signedInUserIdProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(() => now),
        workoutRepositoryProvider.overrideWithValue(
          WorkoutRepository(db, OutboxRepository(db), clock: () => now),
        ),
        notificationServiceProvider.overrideWithValue(notifications),
        restActionsProvider.overrideWithValue(actions.stream),
        restEndFeedbackProvider.overrideWithValue(() => endFeedback++),
      ],
    );
    c.listen(profileProvider, (_, _) {});
    c.listen(restTimerProvider, (_, _) {});
    addTearDown(c.dispose);
    addTearDown(actions.close);
    return c;
  }

  Future<ActiveWorkout> startWorkout(ProviderContainer c, [List<PlannedExercise>? plan]) async {
    await c.read(activeWorkoutControllerProvider.future);
    await c.read(activeWorkoutControllerProvider.notifier).start(plan ?? const [bench, dips]);
    return c.read(activeWorkoutControllerProvider).value!;
  }

  RestTimer rest(ProviderContainer c) => c.read(restTimerProvider.notifier);
  RestState? state(ProviderContainer c) => c.read(restTimerProvider);

  group('Zaman', () {
    test('start(bench, 90) → 18 sn sonra 72 sn; +15 → 87', () async {
      final c = open();
      await startWorkout(c);
      await rest(c).start('bench', 90);

      expect(state(c)!.exerciseId, 'bench');
      expect(state(c)!.totalSeconds, 90);
      expect(state(c)!.remaining(t0.add(const Duration(seconds: 18))), const Duration(seconds: 72));

      now = t0.add(const Duration(seconds: 18));
      await rest(c).adjust(15);
      expect(state(c)!.remaining(now), const Duration(seconds: 87));
      expect(state(c)!.totalSeconds, 105);
    });

    test('adjust(-200) toplamı en az 15 sn yapar', () async {
      final c = open();
      await startWorkout(c);
      await rest(c).start('bench', 90);
      await rest(c).adjust(-200);

      expect(state(c)!.totalSeconds, 15);
      expect(state(c)!.remaining(now), const Duration(seconds: 15));
    });

    test('kısaltınca süre geçmişte kalırsa dinlenme biter', () async {
      final c = open();
      await startWorkout(c);
      await rest(c).start('bench', 90);
      now = t0.add(const Duration(seconds: 80));
      await rest(c).adjust(-15);

      expect(state(c), isNull);
      expect(notifications.cancels, 1);
    });

    test('remaining süre bitince sıfırda durur', () {
      final s = RestState(endsAt: t0, totalSeconds: 90, exerciseId: 'bench');
      expect(s.remaining(t0.add(const Duration(seconds: 5))), Duration.zero);
    });

    test('süre dolunca finishIfDue dinlenmeyi kapatır, güçlü titreşim, bildirim kalır', () async {
      final c = open();
      final w = await startWorkout(c);
      await rest(c).start('bench', 90);

      now = t0.add(const Duration(seconds: 60));
      await rest(c).finishIfDue();
      expect(state(c), isNotNull);
      expect(endFeedback, 0);

      now = t0.add(const Duration(seconds: 90));
      await rest(c).finishIfDue();
      expect(state(c), isNull);
      expect(endFeedback, 1);
      // Bitiş bildirimi alarmla gelir; iptal edilmez.
      expect(notifications.cancels, 0);
      expect(await c.read(workoutRepositoryProvider).restEndFor(w.sessionId), isNull);
    });
  });

  group('Bildirim çağrıları', () {
    test('start → showRest + scheduleRestEnd doğru zamanla, bitiş diske yazılır', () async {
      final c = open();
      final w = await startWorkout(c);
      await rest(c).start('bench', 90);

      final end = t0.add(const Duration(seconds: 90));
      expect(notifications.shown.single.endsAt, end);
      expect(notifications.scheduled, [end]);
      expect(await c.read(workoutRepositoryProvider).restEndFor(w.sessionId), end);
      // Sıradaki set aynı harekette (1/3 bitti değil: henüz set yok → Set 1/3).
      expect(notifications.shown.single.nextLabel, startsWith('Sıradaki: Bench Press'));
      final p = RestPayload.tryDecode(notifications.shown.single.payload)!;
      expect(p.sessionId, w.sessionId);
      expect(p.userId, 'u1');
      expect(p.exerciseId, 'bench');
      expect(p.totalSeconds, 90);
      // "Dinlenme bitti" de aynı yükü taşır: dokununca antrenmana dönülür.
      expect(RestPayload.tryDecode(notifications.scheduledPayloads.single)!.sessionId, w.sessionId);
    });

    test('adjust → bildirim ve alarm yeni bitişle', () async {
      final c = open();
      await startWorkout(c);
      await rest(c).start('bench', 90);
      await rest(c).adjust(15);

      final end = t0.add(const Duration(seconds: 105));
      expect(notifications.shown.last.endsAt, end);
      expect(notifications.scheduled.last, end);
    });

    test('skip → cancelRest, bitiş diskten silinir', () async {
      final c = open();
      final w = await startWorkout(c);
      await rest(c).start('bench', 90);
      await rest(c).skip();

      expect(state(c), isNull);
      expect(notifications.cancels, 1);
      expect(await c.read(workoutRepositoryProvider).restEndFor(w.sessionId), isNull);
    });

    test('sıradaki set yoksa sıradaki hareket gösterilir', () async {
      final c = open();
      await startWorkout(c, const [
        PlannedExercise(
          exerciseId: 'bench',
          tracking: 'weight_reps',
          equipment: 'barbell',
          targetSets: 1,
          restSeconds: 90,
        ),
        dips,
      ]);
      await c
          .read(activeWorkoutControllerProvider.notifier)
          .completeSet(const SetValues(weightKg: 60, reps: 8));
      await rest(c).start('bench', 90);

      expect(notifications.shown.single.nextLabel, startsWith('Sıradaki: Dips'));
    });
  });

  group('Yeniden açılış', () {
    test('bitiş gelecekteyse sayaç kalan süreden sürer', () async {
      final c1 = open();
      final w = await startWorkout(c1);
      await c1
          .read(activeWorkoutControllerProvider.notifier)
          .completeSet(const SetValues(weightKg: 60, reps: 8));
      await rest(c1).start('bench', 90);
      c1.dispose();

      now = t0.add(const Duration(seconds: 30));
      final c2 = open();
      final loaded = (await c2.read(activeWorkoutControllerProvider.future))!;
      expect(loaded.sessionId, w.sessionId);
      await rest(c2).restoreFrom(loaded);

      expect(state(c2)!.exerciseId, 'bench');
      expect(state(c2)!.endsAt, t0.add(const Duration(seconds: 90)));
      expect(state(c2)!.totalSeconds, 90);
      expect(state(c2)!.remaining(now), const Duration(seconds: 60));
      expect(notifications.cancels, 0);
      // "Zorla durdur" bildirimi ve alarmı silmiş olabilir: ikisi de yeniden kurulur.
      final end = t0.add(const Duration(seconds: 90));
      expect(notifications.shown.single.endsAt, end);
      expect(notifications.scheduled, [end]);
    });

    test('bitiş geçmişteyse dinlenme bitmiş sayılır, bildirim iptal edilir', () async {
      final c1 = open();
      final w = await startWorkout(c1);
      await rest(c1).start('bench', 90);
      c1.dispose();

      now = t0.add(const Duration(minutes: 5));
      final c2 = open();
      final loaded = (await c2.read(activeWorkoutControllerProvider.future))!;
      await rest(c2).restoreFrom(loaded);

      expect(state(c2), isNull);
      expect(notifications.cancels, 1);
      expect(await c2.read(workoutRepositoryProvider).restEndFor(w.sessionId), isNull);
    });

    test('kayıtlı dinlenme yoksa hiçbir şey yapılmaz', () async {
      final c = open();
      final w = await startWorkout(c);
      await rest(c).restoreFrom(w);
      expect(state(c), isNull);
      expect(notifications.log, isEmpty);
    });
  });

  group('Süre hafızası', () {
    test('ilk dinlenme plandaki süreyle; "+15 sn" sonraki dinlenmeye taşınır', () async {
      final c = open();
      await startWorkout(c);
      final ctl = c.read(activeWorkoutControllerProvider.notifier);

      await ctl.completeSet(const SetValues(weightKg: 60, reps: 8));
      await rest(c).startFor('bench');
      expect(state(c)!.totalSeconds, 90);

      await rest(c).adjust(15);
      await rest(c).skip();
      expect(await c.read(workoutRepositoryProvider).restSecondsFor('u1', 'bench'), 105);

      await ctl.completeSet(const SetValues(weightKg: 60, reps: 8));
      await rest(c).startFor('bench');
      expect(state(c)!.totalSeconds, 105);
    });

    test('hafıza yoksa plandaki (şablon) süre kullanılır', () async {
      final c = open();
      await startWorkout(c, const [dips]);
      await rest(c).startFor('dips');
      expect(state(c)!.totalSeconds, 60);
    });

    test('set tamamlanınca (onSetCompleted) dinlenme başlar', () async {
      final c = open();
      await startWorkout(c);
      await c
          .read(activeWorkoutControllerProvider.notifier)
          .completeSet(const SetValues(weightKg: 60, reps: 8));
      c.read(onSetCompletedProvider)('bench');
      await pumpEventQueue();

      expect(state(c)!.exerciseId, 'bench');
      expect(state(c)!.totalSeconds, 90);
    });
  });

  group('Bildirim eylemi (uygulama açıkken)', () {
    test('"+15 sn" ana isolate\'a gelince sayaç uzar ve süre hatırlanır', () async {
      final c = open();
      final w = await startWorkout(c);
      await rest(c).start('bench', 90);
      final payload = RestPayload.tryDecode(notifications.shown.single.payload)!;

      actions.add(RestActionMessage(RestAction.plus15, payload));
      await pumpEventQueue();

      expect(state(c)!.totalSeconds, 105);
      expect(notifications.scheduled.last, t0.add(const Duration(seconds: 105)));
      expect(
        await c.read(workoutRepositoryProvider).restEndFor(w.sessionId),
        notifications.scheduled.last,
      );
      expect(await c.read(workoutRepositoryProvider).restSecondsFor('u1', 'bench'), 105);
    });

    test('"Atla" ana isolate\'a gelince dinlenme kapanır', () async {
      final c = open();
      await startWorkout(c);
      await rest(c).start('bench', 90);
      final payload = RestPayload.tryDecode(notifications.shown.single.payload)!;

      actions.add(RestActionMessage(RestAction.skip, payload));
      await pumpEventQueue();

      expect(state(c), isNull);
      expect(notifications.cancels, 1);
    });
  });

  test('ana isolate kapısı gelen eylemi alındı diye yanıtlar', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final received = <RestActionMessage>[];
    final sub = c.read(restActionsProvider).listen(received.add);
    addTearDown(sub.cancel);
    final port = IsolateNameServer.lookupPortByName(restActionPortName)!;
    final reply = ReceivePort();
    addTearDown(reply.close);
    const p = RestPayload(
      sessionId: 's1',
      userId: 'u1',
      exerciseId: 'bench',
      totalSeconds: 90,
      nextLabel: 'x',
    );

    port.send(const RestActionMessage(RestAction.plus15, p).toPort(reply.sendPort));

    expect(await reply.first.timeout(const Duration(seconds: 2)), isTrue);
    expect(received.single.payload, p);
  });
}
