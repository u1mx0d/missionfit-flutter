import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart' hide ExerciseMuscle;
import 'package:missionfit/data/workout/workout_queries.dart';
import 'package:missionfit/domain/body_map.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/week.dart';

const uid = 'u1';
const ts = '2026-01-01T00:00:00Z';

void main() {
  late AppDatabase db;
  late WorkoutQueries q;
  // Pazartesi 2026-11-16 haftası.
  final window = weekWindowForDate('2026-11-18', WeekStartsOn.monday);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    q = WorkoutQueries(db);
    for (final (i, m) in bodyMapMuscles.indexed) {
      final region = switch (m) {
        'chest' => 'chest',
        'shoulders' => 'shoulders',
        'biceps' || 'triceps' || 'forearms' => 'arms',
        'abs' || 'obliques' => 'core',
        'traps' || 'lats' || 'lower_back' => 'back',
        _ => 'legs',
      };
      await db
          .into(db.muscleGroups)
          .insert(
            MuscleGroupsCompanion.insert(
              id: 'm-$m',
              slug: m,
              nameTr: m,
              bodyRegion: region,
              view: 'front',
              createdAt: ts,
              sortOrder: Value(i),
            ),
          );
    }
    Future<void> ex(
      String id,
      String name,
      String tracking,
      String equip,
      List<(String, String)> muscles,
    ) async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: id,
              slug: id,
              nameTr: name,
              nameEn: id,
              equipment: equip,
              type: 'strength',
              tracking: tracking,
              metValue: 5,
              createdAt: ts,
            ),
          );
      for (final (m, role) in muscles) {
        await db
            .into(db.exerciseMuscles)
            .insert(
              ExerciseMusclesCompanion.insert(exerciseId: id, muscleGroupId: 'm-$m', role: role),
            );
      }
    }

    await ex('bench', 'Bench Press', 'weight_reps', 'barbell', [
      ('chest', 'primary'),
      ('triceps', 'secondary'),
      ('shoulders', 'secondary'),
    ]);
    await ex('dips', 'Dips', 'reps', 'bodyweight', [
      ('chest', 'primary'),
      ('triceps', 'secondary'),
    ]);
    await ex('fly', 'Fly', 'weight_reps', 'cable', [('chest', 'primary')]);
    await ex('pushup', 'Şınav', 'reps', 'bodyweight', [('chest', 'primary')]);
    await ex('squat', 'Squat', 'weight_reps', 'barbell', [('quads', 'primary')]);
  });
  tearDown(() => db.close());

  Future<void> session(
    String id,
    String date,
    String status, {
    String start = '10:00',
    String name = 'Antrenman',
  }) async {
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            userId: uid,
            name: Value(name),
            startedAt: '${date}T$start:00Z',
            endedAt: Value(status == 'active' ? null : '${date}T11:00:00Z'),
            localDate: date,
            weekKey: '2026-11-16',
            status: Value(status),
            createdAt: ts,
            updatedAt: ts,
          ),
        );
  }

  Future<void> set(
    String sid,
    String ex,
    int order,
    int idx, {
    int reps = 8,
    double? kg = 50,
    String at = '10:05',
  }) async {
    final date = (await (db.select(
      db.workoutSessions,
    )..where((t) => t.id.equals(sid))).getSingle()).localDate;
    await db
        .into(db.sessionSets)
        .insert(
          SessionSetsCompanion.insert(
            id: '$sid-$ex-$idx',
            sessionId: sid,
            userId: uid,
            exerciseId: ex,
            exerciseOrder: order,
            setIndex: idx,
            reps: Value(reps),
            weightKg: Value(kg),
            completedAt: '${date}T$at:00Z',
            updatedAt: ts,
          ),
        );
  }

  group('watchWeek', () {
    test('bench 4 set: göğüs 4, triceps 2, seviye 2, son gün', () async {
      await session('s1', '2026-11-16', 'completed');
      for (var i = 1; i <= 4; i++) {
        await set('s1', 'bench', 0, i);
      }
      final m = await q.watchWeek(uid, window).first;
      expect(m.muscleSets['chest'], 4);
      expect(m.muscleSets['triceps'], 2);
      expect(m.muscleSets['shoulders'], 2);
      expect(m.levels['chest'], 2);
      expect(m.levels['triceps'], 1);
      expect(m.levels['quads'], 0);
      expect(m.lastWorked['chest'], '2026-11-16');
      expect(m.lastWorked['quads'], isNull);
      expect(m.totalSets, 4);
      expect(m.regionsWorked, 3); // göğüs, omuz, kol
    });

    test('önceki hafta ve abandoned sayılmaz, active sayılır', () async {
      await session('old', '2026-11-10', 'completed');
      await set('old', 'bench', 0, 1);
      await session('ab', '2026-11-17', 'abandoned');
      await set('ab', 'bench', 0, 1);
      await session('act', '2026-11-18', 'active');
      await set('act', 'squat', 0, 1);
      final m = await q.watchWeek(uid, window).first;
      expect(m.muscleSets['chest'], 0);
      expect(m.muscleSets['quads'], 1);
      expect(m.totalSets, 1);
    });

    test('yeni set gelince akış yeniden yayar', () async {
      await session('s1', '2026-11-16', 'completed');
      final it = q.watchWeek(uid, window).map((m) => m.totalSets);
      final expectation = expectLater(it, emitsInOrder([0, 1]));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await set('s1', 'bench', 0, 1);
      await expectation;
    });
  });

  group('lastSessionSets', () {
    test('en son tamamlanan oturum, setIndex sırasıyla, UTC', () async {
      await session('a', '2026-11-10', 'completed');
      await set('a', 'bench', 0, 1, reps: 5);
      await session('b', '2026-11-12', 'completed');
      await set('b', 'bench', 0, 2, reps: 7);
      await set('b', 'bench', 0, 1, reps: 6);
      await session('c', '2026-11-18', 'active');
      await set('c', 'bench', 0, 1, reps: 9);
      final sets = await q.lastSessionSets(uid, 'bench');
      expect(sets.map((s) => s.setIndex), [1, 2]);
      expect(sets.map((s) => s.reps), [6, 7]);
      expect(sets.first.completedAt.isUtc, isTrue);
      expect(sets.first.completedAt, DateTime.utc(2026, 11, 12, 10, 5));
      final ex = await q.lastSessionSets(uid, 'bench', excludingSessionId: 'b');
      expect(ex.map((s) => s.reps), [5]);
      expect(await q.lastSessionSets(uid, 'squat'), isEmpty);
    });
  });

  group('recent', () {
    test('tamamlananlar yeniden eskiye, hareket ve set sayısı', () async {
      await session('a', '2026-11-10', 'completed', name: 'A');
      await set('a', 'bench', 0, 1);
      await session('b', '2026-11-12', 'completed', name: 'B');
      await set('b', 'squat', 0, 1);
      await set('b', 'bench', 1, 1);
      await set('b', 'bench', 1, 2);
      await session('c', '2026-11-18', 'active', name: 'C');
      final r = await q.recent(uid, limit: 3);
      expect(r.map((e) => e.sessionId), ['b', 'a']);
      expect(r.first.exerciseIds, ['squat', 'bench']);
      expect(r.first.setCount, 3);
      expect(r.first.name, 'B');
      expect(r.first.startedAt, DateTime.utc(2026, 11, 12, 10));
      expect((await q.recent(uid, limit: 1)).length, 1);
    });
  });

  group('exercisesForRegion', () {
    test('yapılanlar önce (son yapılan başta), sonra katalog ada göre', () async {
      await session('a', '2026-11-10', 'completed');
      await set('a', 'bench', 0, 1);
      await session('b', '2026-11-12', 'completed');
      await set('b', 'dips', 0, 1);
      final r = await q.exercisesForRegion(uid, BodyRegion.chest);
      expect(r.map((e) => e.id), ['dips', 'bench', 'fly', 'pushup']);
      expect(r.first.lastDoneAt, DateTime.utc(2026, 11, 12, 10, 5));
      expect(r.last.lastDoneAt, isNull);
      expect(r.first.tracking, 'reps');
      expect(r.first.equipment, 'bodyweight');
    });
  });

  group('searchExercises', () {
    test('Türkçe büyük/küçük harf duyarsız', () async {
      final a = await q.searchExercises('şınav');
      final b = await q.searchExercises('ŞINAV');
      expect(a.map((e) => e.id), ['pushup']);
      expect(b.map((e) => e.id), ['pushup']);
      expect((await q.searchExercises('  ')).length, 5);
    });
  });

  group('templatePlan', () {
    test('targetSets ve restSeconds şablondan', () async {
      await db
          .into(db.workoutTemplates)
          .insert(
            WorkoutTemplatesCompanion.insert(
              id: 't',
              slug: 't',
              nameTr: 'T',
              level: 'beginner',
              createdAt: ts,
            ),
          );
      await db
          .into(db.workoutTemplateExercises)
          .insert(
            WorkoutTemplateExercisesCompanion.insert(
              id: 'te2',
              templateId: 't',
              exerciseId: 'squat',
              orderIndex: 1,
              sets: 5,
              restSeconds: const Value(120),
            ),
          );
      await db
          .into(db.workoutTemplateExercises)
          .insert(
            WorkoutTemplateExercisesCompanion.insert(
              id: 'te1',
              templateId: 't',
              exerciseId: 'bench',
              orderIndex: 0,
              sets: 4,
              restSeconds: const Value(60),
            ),
          );
      final p = await q.templatePlan('t');
      expect(p, hasLength(2));
      expect(p[0].exerciseId, 'bench');
      expect(p[0].targetSets, 4);
      expect(p[0].restSeconds, 60);
      expect(p[0].tracking, 'weight_reps');
      expect(p[0].equipment, 'barbell');
      expect(p[1].targetSets, 5);
      expect(p[1].restSeconds, 120);
    });
  });
}
