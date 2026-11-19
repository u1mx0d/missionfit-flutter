import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/active_workout_controller.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/db/database.dart';
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
  restSeconds: 90,
);

Future<void> _seedExercise(AppDatabase db, String id) => db
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
        metValue: 5,
        createdAt: 'x',
      ),
    );

class _FlakyRepo extends WorkoutRepository {
  _FlakyRepo(AppDatabase db) : super(db, OutboxRepository(db));
  bool failNext = false;

  @override
  Future<LoggedSet> completeSet(ActiveWorkout w, String exerciseId, SetValues v) {
    if (failNext) {
      failNext = false;
      throw StateError('benzersizlik ihlali');
    }
    return super.completeSet(w, exerciseId, v);
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppDatabase db;
  late ProviderContainer c;

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
    await _seedExercise(db, 'bench');
    await _seedExercise(db, 'dips');
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(sp),
        signedInUserIdProvider.overrideWithValue('u1'),
      ],
    );
    c.listen(profileProvider, (_, _) {});
    c.listen(activeWorkoutControllerProvider, (_, _) {});
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  ActiveWorkoutController ctl() => c.read(activeWorkoutControllerProvider.notifier);
  ActiveWorkout? state() => c.read(activeWorkoutControllerProvider).value;

  test('aktif antrenman yoksa null', () async {
    expect(await c.read(activeWorkoutControllerProvider.future), isNull);
  });

  test('start oturumu açar, ilk hareket seçili; yeniden kurulunca diskten yüklenir', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench, dips], name: 'Göğüs');
    expect(state()!.currentExerciseId, 'bench');
    final row = await db.select(db.workoutSessions).getSingle();
    expect(row.name, 'Göğüs');
    expect(row.status, 'active');

    c.invalidate(activeWorkoutControllerProvider);
    final again = await c.read(activeWorkoutControllerProvider.future);
    expect(again!.sessionId, row.id);
    expect(again.plan, [bench, dips]);
  });

  test('select ve addExercise planı kaydeder', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    await ctl().addExercise(dips);
    expect(state()!.currentExerciseId, 'dips');
    await ctl().select('bench');
    c.invalidate(activeWorkoutControllerProvider);
    final again = await c.read(activeWorkoutControllerProvider.future);
    expect(again!.plan, [bench, dips]);
    expect(again.currentExerciseId, 'bench');
  });

  test('completeSet seçili harekete yazar ve taslağı temizler', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench, dips]);
    c.read(focusDraftsProvider.notifier).put('bench', const FocusDraft(weight: 65, reps: 8));
    final s = await ctl().completeSet(const SetValues(weightKg: 65, reps: 8));
    expect(s.exerciseId, 'bench');
    expect(s.setIndex, 1);
    expect(state()!.sets, [s]);
    expect(c.read(focusDraftsProvider), isEmpty);
    expect(await db.select(db.sessionSets).get(), hasLength(1));
  });

  test('aynı anda iki completeSet sırayla işlenir (indeks çakışmaz)', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    final both = await Future.wait([
      ctl().completeSet(const SetValues(weightKg: 60, reps: 8)),
      ctl().completeSet(const SetValues(weightKg: 60, reps: 8)),
    ]);
    expect(both.map((s) => s.setIndex), [1, 2]);
  });

  test('undo yalnızca verilen seti siler; set zaten silinmişse hiçbir şey yapmaz', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    final a = await ctl().completeSet(const SetValues(weightKg: 60, reps: 8));
    final b = await ctl().completeSet(const SetValues(weightKg: 60, reps: 7));
    await ctl().deleteSet(b);
    await ctl().undo(b);
    expect(state()!.sets, [a]);
    await ctl().undoLast(); // son tamamlanan (b) zaten yok
    expect(state()!.sets, [a]);
    expect((await db.select(db.sessionSets).get()).map((r) => r.id), [a.id]);
  });

  test(
    'completeSet hata verirse durum diskten yeniden yüklenir, sonraki deneme başarılı',
    () async {
      final flaky = _FlakyRepo(db);
      final c2 = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(c.read(sharedPreferencesProvider)),
          signedInUserIdProvider.overrideWithValue('u1'),
          workoutRepositoryProvider.overrideWithValue(flaky),
        ],
      );
      c2.listen(profileProvider, (_, _) {});
      addTearDown(c2.dispose);
      c2.listen(activeWorkoutControllerProvider, (_, _) {});
      final n = c2.read(activeWorkoutControllerProvider.notifier);
      await c2.read(activeWorkoutControllerProvider.future);
      await n.start(const [bench]);
      // Bellekteki durum eskir: set başka yoldan (ör. önceki sürüm) diske yazılmış.
      final w = c2.read(activeWorkoutControllerProvider).value!;
      await flaky.completeSet(w, 'bench', const SetValues(weightKg: 60, reps: 8));
      flaky.failNext = true;
      await expectLater(n.completeSet(const SetValues(weightKg: 60, reps: 8)), throwsStateError);
      expect(c2.read(activeWorkoutControllerProvider).value!.sets, hasLength(1));
      final s = await n.completeSet(const SetValues(weightKg: 60, reps: 8));
      expect(s.setIndex, 2);
    },
  );

  test('undoLast son seti siler', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    final a = await ctl().completeSet(const SetValues(weightKg: 60, reps: 8));
    await ctl().completeSet(const SetValues(weightKg: 60, reps: 7));
    await ctl().undoLast();
    expect(state()!.sets, [a]);
    expect((await db.select(db.sessionSets).get()).map((r) => r.id), [a.id]);
  });

  test('editSet ve deleteSet', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    final a = await ctl().completeSet(const SetValues(weightKg: 60, reps: 8));
    final edited = LoggedSet(
      id: a.id,
      exerciseId: a.exerciseId,
      exerciseOrder: a.exerciseOrder,
      setIndex: a.setIndex,
      reps: 10,
      weightKg: 62.5,
      completedAt: a.completedAt,
    );
    await ctl().editSet(edited);
    expect(state()!.sets.single.reps, 10);
    expect((await db.select(db.sessionSets).getSingle()).weightKg, 62.5);

    await ctl().deleteSet(edited);
    expect(state()!.sets, isEmpty);
    expect(await db.select(db.sessionSets).get(), isEmpty);
  });

  test('addTargetSet hedefi bir artırır ve kaydeder', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    await ctl().addTargetSet('bench');
    expect(state()!.plan.single.targetSets, 4);
    c.invalidate(activeWorkoutControllerProvider);
    final again = await c.read(activeWorkoutControllerProvider.future);
    expect(again!.plan.single.targetSets, 4);
  });

  test('finish set varsa Saved döner, durum null olur', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    await ctl().completeSet(const SetValues(weightKg: 60, reps: 8));
    final r = await ctl().finish();
    expect(r, isA<Saved>());
    expect(state(), isNull);
    expect((await db.select(db.workoutSessions).getSingle()).status, 'completed');
  });

  test('finish set yoksa DiscardedEmpty', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    expect(await ctl().finish(), const DiscardedEmpty());
    expect(state(), isNull);
  });

  test('discard oturumu siler', () async {
    await c.read(activeWorkoutControllerProvider.future);
    await ctl().start(const [bench]);
    c.read(focusDraftsProvider.notifier).put('bench', const FocusDraft(reps: 3));
    await ctl().discard();
    expect(state(), isNull);
    expect(c.read(focusDraftsProvider), isEmpty);
    expect(await db.select(db.workoutSessions).get(), isEmpty);
  });
}
