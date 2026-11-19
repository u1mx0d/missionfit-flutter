import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/workout/workout_repository.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/week.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const uid = '00000000-0000-0000-0000-000000000001';
const bench = 'ex-bench';
const squat = 'ex-squat';

const benchPlan = PlannedExercise(
  exerciseId: bench,
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 90,
);
const squatPlan = PlannedExercise(
  exerciseId: squat,
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 120,
);

Future<void> seedExercise(AppDatabase db, String id, double met) => db
    .into(db.exercises)
    .insert(
      ExercisesCompanion.insert(
        id: id,
        slug: id,
        nameTr: id,
        nameEn: id,
        equipment: 'barbell',
        type: 'strength',
        tracking: 'weight_reps',
        metValue: met,
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppDatabase db;
  late OutboxRepository outbox;
  late WorkoutRepository repo;
  late DateTime now;
  late int ids;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    outbox = OutboxRepository(db);
    // Çarşamba 2026-11-18 23:30 UTC = İstanbul'da Perşembe 2026-11-19 02:30.
    now = DateTime.utc(2026, 11, 18, 23, 30);
    ids = 0;
    repo = WorkoutRepository(db, outbox, clock: () => now, newId: () => 'id-${++ids}');
  });
  tearDown(() => db.close());

  Future<ActiveWorkout> startDefault({WeekStartsOn ws = WeekStartsOn.monday}) => repo.start(
    userId: uid,
    plan: const [benchPlan, squatPlan],
    timeZone: 'Europe/Istanbul',
    weekStartsOn: ws,
  );

  group('start', () {
    test('oturumu active yazar, week_key profilin hafta başlangıcına göre', () async {
      final w = await startDefault(ws: WeekStartsOn.sunday);
      final row = await db.select(db.workoutSessions).getSingle();
      expect(row.id, w.sessionId);
      expect(row.status, 'active');
      expect(row.endedAt, isNull);
      expect(row.localDate, '2026-11-19');
      expect(row.weekKey, '2026-11-15'); // pazar başlangıçlı hafta
      expect(row.name, 'Antrenman');

      final ops = await outbox.pending();
      expect(ops, hasLength(1));
      expect(ops.single.type, 'workout_sessions.upsert');
      expect(ops.single.key, 'workout_sessions:${w.sessionId}');
      expect(ops.single.payload['status'], 'active');
      expect(ops.single.payload['week_key'], '2026-11-15');
      expect(ops.single.payload['local_date'], '2026-11-19');
      expect(ops.single.payload['user_id'], uid);
      expect(ops.single.payload['started_at'], '2026-11-18T23:30:00.000Z');
      expect(ops.single.payload.containsKey('updated_at'), isFalse);
      expect(w.plan, const [benchPlan, squatPlan]);
      expect(w.currentExerciseId, bench);
      expect(w.sets, isEmpty);
    });

    test('pazartesi başlangıçlı week_key', () async {
      await startDefault();
      final row = await db.select(db.workoutSessions).getSingle();
      expect(row.weekKey, '2026-11-16');
    });

    test('eski active oturum önce abandoned olur ve outbox\'ta yeniden önce durur', () async {
      // Başka telefondan senkronla gelmiş aktif oturum (outbox'ta işlemi yok).
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'old',
              userId: uid,
              startedAt: '2026-11-18T08:00:00.000Z',
              localDate: '2026-11-18',
              weekKey: '2026-11-16',
              createdAt: '2026-11-18T08:00:00.000Z',
              updatedAt: '2026-11-18T08:00:00.000Z',
            ),
          );
      final w = await startDefault();

      final old = await (db.select(
        db.workoutSessions,
      )..where((t) => t.id.equals('old'))).getSingle();
      expect(old.status, 'abandoned');
      expect(old.endedAt, '2026-11-18T23:30:00.000Z');

      final ops = await outbox.pending();
      expect(ops.map((o) => o.key), ['workout_sessions:old', 'workout_sessions:${w.sessionId}']);
      expect(ops.first.payload['status'], 'abandoned');
      expect(ops.first.payload['ended_at'], '2026-11-18T23:30:00.000Z');
      expect(ops.first.payload['started_at'], '2026-11-18T08:00:00.000Z');

      final actives = await (db.select(
        db.workoutSessions,
      )..where((t) => t.status.equals('active'))).get();
      expect(actives.map((r) => r.id), [w.sessionId]);
    });
  });

  group('completeSet', () {
    test('session_sets.upsert yazar; sıra, indeks ve 0,1 yuvarlama doğru', () async {
      var w = await startDefault();
      final s1 = await repo.completeSet(w, squat, const SetValues(weightKg: 60.04, reps: 8));
      w = w.logSet(s1);
      final s2 = await repo.completeSet(w, bench, const SetValues(weightKg: 42.46, reps: 10));
      w = w.logSet(s2);
      final s3 = await repo.completeSet(w, squat, const SetValues(weightKg: 60, reps: 8));

      expect((s1.exerciseOrder, s1.setIndex), (0, 1));
      expect((s2.exerciseOrder, s2.setIndex), (1, 1));
      expect((s3.exerciseOrder, s3.setIndex), (0, 2));
      expect(s1.weightKg, 60.0);
      expect(s2.weightKg, 42.5);

      final ops = (await outbox.pending()).where((o) => o.type == 'session_sets.upsert').toList();
      expect(ops, hasLength(3));
      final p = ops[1].payload;
      expect(ops[1].key, 'session_sets:${s2.id}');
      expect(p['id'], s2.id);
      expect(p['session_id'], w.sessionId);
      expect(p['user_id'], uid);
      expect(p['exercise_id'], bench);
      expect(p['exercise_order'], 1);
      expect(p['set_index'], 1);
      expect(p['weight_kg'], 42.5);
      expect(p['reps'], 10);
      expect(p['duration_seconds'], isNull);
      expect(p['completed_at'], '2026-11-18T23:30:00.000Z');
      expect(p.containsKey('updated_at'), isFalse);
      expect(ops[2].payload['set_index'], 2);
      expect(ops[2].payload['exercise_order'], 0);
    });

    test('ne tekrar ne süre varsa hata verir', () async {
      final w = await startDefault();
      expect(() => repo.completeSet(w, bench, const SetValues(weightKg: 40)), throwsArgumentError);
      expect(await outbox.pending(), hasLength(1));
    });

    test('silip yeniden ekleyince indeks yeniden kullanılır, silme yazmadan önce durur', () async {
      var w = await startDefault();
      for (var i = 0; i < 3; i++) {
        w = w.logSet(await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10)));
      }
      final third = w.sets.last;
      expect(third.setIndex, 3);
      await repo.deleteSet(third);
      w = w.removeSet(third.id);
      final again = await repo.completeSet(w, bench, const SetValues(weightKg: 45, reps: 8));
      expect(again.setIndex, 3);
      expect(again.id, isNot(third.id));

      final ops = await outbox.pending();
      final del = ops.indexWhere(
        (o) => o.type == 'session_sets.delete' && o.key == 'session_sets:${third.id}',
      );
      final up = ops.indexWhere(
        (o) => o.type == 'session_sets.upsert' && o.key == 'session_sets:${again.id}',
      );
      expect(del, isNonNegative);
      expect(up, greaterThan(del));
      expect(ops[del].payload['id'], third.id);

      final rows = await db.select(db.sessionSets).get();
      expect(rows.map((r) => r.id), isNot(contains(third.id)));
      expect(rows, hasLength(3));
    });
  });

  test('updateSet aynı id ile upsert eder; outbox\'ta tek işlem kalır', () async {
    final w = await startDefault();
    final s = await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10));
    final changed = LoggedSet(
      id: s.id,
      exerciseId: s.exerciseId,
      exerciseOrder: s.exerciseOrder,
      setIndex: s.setIndex,
      reps: 12,
      weightKg: 42.54,
      completedAt: s.completedAt,
    );
    await repo.updateSet(changed);

    final ops = (await outbox.pending()).where((o) => o.key == 'session_sets:${s.id}').toList();
    expect(ops, hasLength(1));
    expect(ops.single.type, 'session_sets.upsert');
    expect(ops.single.payload['reps'], 12);
    expect(ops.single.payload['weight_kg'], 42.5);
    final row = await db.select(db.sessionSets).getSingle();
    expect(row.reps, 12);
  });

  group('finish', () {
    test('setliyken completed, ended_at ve estimated_kcal yazılır', () async {
      await seedExercise(db, bench, 5);
      var w = await startDefault();
      w = w.logSet(await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10)));
      now = now.add(const Duration(hours: 1));
      final r = await repo.finish(w, bodyWeightKg: 80);

      // 5 MET × 80 kg × 1 sa = 400
      expect(r, isA<Saved>());
      expect((r as Saved).kcal, 400);
      final row = await db.select(db.workoutSessions).getSingle();
      expect(row.status, 'completed');
      expect(row.endedAt, '2026-11-19T00:30:00.000Z');
      expect(row.estimatedKcal, 400);

      final op = (await outbox.pending()).firstWhere((o) => o.type == 'workout_sessions.upsert');
      expect(op.payload['status'], 'completed');
      expect(op.payload['ended_at'], '2026-11-19T00:30:00.000Z');
      expect(op.payload['estimated_kcal'], 400);
      expect(await db.select(db.activeWorkoutPlans).get(), isEmpty);
      expect(await repo.loadActive(uid), isNull);
    });

    test('kilo bilinmiyorsa Saved(null) ve estimated_kcal null', () async {
      await seedExercise(db, bench, 5);
      var w = await startDefault();
      w = w.logSet(await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10)));
      final r = await repo.finish(w, bodyWeightKg: null);
      expect(r, const Saved(null));
      final row = await db.select(db.workoutSessions).getSingle();
      expect(row.status, 'completed');
      expect(row.estimatedKcal, isNull);
      final op = (await outbox.pending()).firstWhere((o) => o.type == 'workout_sessions.upsert');
      expect(op.payload['estimated_kcal'], isNull);
    });

    test('setsizken oturum silinir ve DiscardedEmpty döner', () async {
      final w = await startDefault();
      final r = await repo.finish(w, bodyWeightKg: 80);
      expect(r, isA<DiscardedEmpty>());
      expect(await db.select(db.workoutSessions).get(), isEmpty);
      expect(await db.select(db.activeWorkoutPlans).get(), isEmpty);
      final ops = await outbox.pending();
      expect(ops.single.type, 'workout_sessions.delete');
      expect(ops.single.payload['id'], w.sessionId);
    });
  });

  test('discard oturumu, setleri ve bekleyen set işlemlerini siler; tek delete kalır', () async {
    var w = await startDefault();
    w = w.logSet(await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10)));
    final s2 = await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10));
    await repo.deleteSet(s2);
    await repo.discard(w.sessionId);

    expect(await db.select(db.workoutSessions).get(), isEmpty);
    expect(await db.select(db.sessionSets).get(), isEmpty);
    expect(await db.select(db.activeWorkoutPlans).get(), isEmpty);
    final ops = await outbox.pending();
    expect(ops, hasLength(1));
    expect(ops.single.type, 'workout_sessions.delete');
    expect(ops.single.key, 'workout_sessions:${w.sessionId}');
  });

  test('loadActive plan ve setlerle geri gelir; restEndsAt korunur', () async {
    var w = await startDefault();
    w = w.logSet(await repo.completeSet(w, bench, const SetValues(weightKg: 40, reps: 10)));
    w = w.logSet(await repo.completeSet(w, squat, const SetValues(weightKg: 60, reps: 5)));
    w = w.select(squat);
    await repo.savePlan(w);
    final ends = DateTime.utc(2026, 11, 18, 23, 32);
    await repo.setRestEnd(w.sessionId, ends);

    final loaded = await repo.loadActive(uid);
    expect(loaded, w);
    expect(loaded!.startedAt.isUtc, isTrue);
    expect(loaded.sets.every((s) => s.completedAt.isUtc), isTrue);
    expect(await repo.restEndFor(w.sessionId), ends);

    await repo.setRestEnd(w.sessionId, null);
    expect(await repo.restEndFor(w.sessionId), isNull);
  });

  test('loadActive başka kullanıcının oturumunu döndürmez', () async {
    await startDefault();
    expect(await repo.loadActive('baska'), isNull);
  });

  test(
    'loadActive plan satırı olmayan (senkronla gelen) aktif oturumu boş planla döndürür',
    () async {
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'remote',
              userId: uid,
              startedAt: '2026-11-18T08:00:00+00:00',
              localDate: '2026-11-18',
              weekKey: '2026-11-16',
              createdAt: '2026-11-18T08:00:00Z',
              updatedAt: '2026-11-18T08:00:00Z',
              status: const Value('active'),
            ),
          );
      final w = await repo.loadActive(uid);
      expect(w!.sessionId, 'remote');
      expect(w.plan, isEmpty);
      expect(w.startedAt, DateTime.utc(2026, 11, 18, 8));
    },
  );

  test('rememberRest / restSecondsFor gidiş-dönüş', () async {
    expect(await repo.restSecondsFor(uid, bench), isNull);
    await repo.rememberRest(uid, bench, 120);
    expect(await repo.restSecondsFor(uid, bench), 120);
    await repo.rememberRest(uid, bench, 75);
    expect(await repo.restSecondsFor(uid, bench), 75);
    expect(await repo.restSecondsFor('baska', bench), isNull);
  });
}
