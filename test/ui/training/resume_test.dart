import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/screen_awake.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/ui/components/body_map/body_map_frames.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/training/stale_workout.dart';
import 'package:missionfit/ui/training/training_routes.dart';
import 'package:missionfit/ui/training/training_screen.dart';

final _now = DateTime.utc(2026, 11, 20, 12);

const _plan = [
  PlannedExercise(
    exerciseId: 'bench',
    tracking: 'weight_reps',
    equipment: 'barbell',
    targetSets: 3,
    restSeconds: 90,
  ),
  PlannedExercise(
    exerciseId: 'squat',
    tracking: 'weight_reps',
    equipment: 'barbell',
    targetSets: 4,
    restSeconds: 120,
  ),
];

LoggedSet _set(String ex, int order, int idx) => LoggedSet(
  id: '$ex-$idx',
  exerciseId: ex,
  exerciseOrder: order,
  setIndex: idx,
  reps: 8,
  weightKg: 60,
  completedAt: _now.subtract(const Duration(minutes: 10)),
);

/// Bench bitti, squat'ta 1 set yapıldı; kalınan yer squat, set 2.
ActiveWorkout _active(DateTime startedAt) => ActiveWorkout(
  sessionId: 's1',
  startedAt: startedAt,
  plan: _plan,
  sets: [_set('bench', 0, 1), _set('bench', 0, 2), _set('bench', 0, 3), _set('squat', 1, 1)],
  currentExerciseId: 'squat',
);

/// Diskteki durum: her "uygulama açılışı" yeni bir sağlayıcı kabıyla buradan yüklenir.
class _Disk {
  ActiveWorkout? active;
  final calls = <String>[];
}

class _FakeRepo extends Fake implements WorkoutRepository {
  _FakeRepo(this.disk);
  final _Disk disk;

  @override
  Future<ActiveWorkout?> loadActive(String userId) async => disk.active;

  @override
  Future<DateTime?> restEndFor(String sessionId) async => null;

  @override
  Future<WorkoutFinish> finish(ActiveWorkout w, {required double? bodyWeightKg}) async {
    disk.calls.add('finish');
    disk.active = null;
    return const Saved(300);
  }

  @override
  Future<void> discard(String sessionId) async {
    disk.calls.add('discard:$sessionId');
    disk.active = null;
  }
}

class _FakeQueries extends Fake implements WorkoutQueries {
  @override
  Future<Map<String, ExerciseOption>> exercisesByIds(Iterable<String> ids) async => {
    for (final id in ids)
      id: ExerciseOption(
        id: id,
        nameTr: id == 'bench' ? 'Bench Press' : 'Squat',
        tracking: 'weight_reps',
        equipment: 'barbell',
        region: id == 'bench' ? BodyRegion.chest : BodyRegion.legs,
      ),
  };

  @override
  Future<List<LoggedSet>> lastSessionSets(
    String userId,
    String exerciseId, {
    String? excludingSessionId,
  }) async => const [];

  @override
  Stream<List<MuscleGroupOption>> watchMuscleGroups() => Stream.value(const []);

  @override
  Stream<List<TemplateOption>> watchTemplates() => Stream.value(const []);

  @override
  Future<SessionSummaryData?> sessionSummary(String sessionId) async => null;

  @override
  Future<WeeklyBodyMap> sessionBodyMap(String sessionId) async => WeeklyBodyMap.empty;
}

class _Awake implements ScreenAwake {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

class _FixedToday extends TodayNotifier {
  @override
  Today build() => const Today(date: '2026-11-20', minutes: 720);
}

class _App {
  _App(this.router, this.container);
  final GoRouter router;
  final ProviderContainer container;
  String get location => router.routerDelegate.currentConfiguration.last.matchedLocation;
}

/// Uygulamayı açar: her çağrı yeni sağlayıcı kabı ve yönlendirici (soğuk açılış).
Future<_App> _open(WidgetTester tester, _Disk disk, {String initial = '/antrenman'}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      // Uygulamada kabuk (`router.dart`) aynı sarmalayıcıyı kullanır.
      GoRoute(
        path: '/antrenman',
        builder: (_, _) => const StaleWorkoutWatcher(child: TrainingScreen()),
      ),
      GoRoute(
        path: '/bugun',
        builder: (_, _) => const StaleWorkoutWatcher(child: Scaffold(body: Text('BUGÜN'))),
      ),
      ...trainingRoutes,
    ],
  );
  addTearDown(router.dispose);
  final c = ProviderContainer(
    overrides: [
      signedInUserIdProvider.overrideWithValue('u1'),
      profileProvider.overrideWith(
        (ref) => Stream.value(Profile(userId: 'u1', createdAt: 'x', updatedAt: 'x')),
      ),
      todayProvider.overrideWith(_FixedToday.new),
      clockProvider.overrideWithValue(() => _now),
      workoutRepositoryProvider.overrideWithValue(_FakeRepo(disk)),
      workoutQueriesProvider.overrideWithValue(_FakeQueries()),
      weeklyBodyMapProvider.overrideWith((ref) => Stream.value(WeeklyBodyMap.empty)),
      recentWorkoutsProvider.overrideWith((ref) async => const []),
      screenAwakeProvider.overrideWithValue(_Awake()),
      bodyMapFramesProvider.overrideWith((ref) => Completer<BodyMapFrames>().future),
      bodyMapProgramProvider.overrideWith((ref) async => null),
    ],
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        routerConfig: router,
        theme: buildThemeData(MfTheme.build(ThemeFamily.canli, Brightness.dark, AccentColor.yesil)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _App(router, c);
}

Finder get _resume => find.widgetWithText(FilledButton, 'Devam et');
Finder get _staleDialog => find.text('Bitir mi, sil mi?');

void main() {
  testWidgets('yeniden açılışta Devam et; odak kalınan hareket ve setle açılır', (t) async {
    final disk = _Disk()..active = _active(_now.subtract(const Duration(hours: 1)));
    // İlk açılış, sonra uygulama kapanır (kap atılır) ve yeniden açılır.
    await _open(t, disk);
    await t.pumpWidget(const SizedBox());
    final app = await _open(t, disk);

    expect(_staleDialog, findsNothing);
    expect(find.byKey(const Key('resume-card')), findsOneWidget);
    await t.tap(_resume);
    await t.pumpAndSettle();
    expect(app.location, '/antrenman/odak');
    expect(find.text('Hareket 2/2 · Bacak'), findsOneWidget);
    expect(find.text('Set 2/4'), findsOneWidget);
  });

  testWidgets('24 saatten eski: açılışta bir kez "Bitir mi, sil mi?"; Sil oturumu siler', (
    t,
  ) async {
    final disk = _Disk()..active = _active(_now.subtract(const Duration(hours: 25)));
    final app = await _open(t, disk);
    expect(_staleDialog, findsOneWidget);
    await t.tap(find.widgetWithText(TextButton, 'Sil'));
    await t.pumpAndSettle();
    expect(disk.calls, ['discard:s1']);
    expect(_staleDialog, findsNothing);
    expect(find.byKey(const Key('resume-card')), findsNothing);
    expect(app.location, '/antrenman');
  });

  testWidgets('24 saatten eski: Bitir kaydeder ve özete gider', (t) async {
    final disk = _Disk()..active = _active(_now.subtract(const Duration(days: 2)));
    final app = await _open(t, disk);
    await t.tap(find.widgetWithText(FilledButton, 'Bitir'));
    await t.pumpAndSettle();
    expect(disk.calls, ['finish']);
    expect(app.location, '/antrenman/ozet/s1');
  });

  testWidgets('kapatılırsa kendiliğinden yeniden sorulmaz; Devam et yine sorar', (t) async {
    final disk = _Disk()..active = _active(_now.subtract(const Duration(hours: 30)));
    final app = await _open(t, disk);
    expect(_staleDialog, findsOneWidget);
    await t.binding.handlePopRoute(); // geri tuşu diyaloğu kapatır
    await t.pumpAndSettle();
    expect(_staleDialog, findsNothing);

    // Sekmeler arasında gidip gelmek ve yeniden çizim diyaloğu tekrar açmaz.
    app.router.go('/bugun');
    await t.pumpAndSettle();
    app.router.go('/antrenman');
    await t.pumpAndSettle();
    expect(_staleDialog, findsNothing);
    expect(disk.calls, isEmpty);

    // Antrenmanı açmak ister: yeniden sorulur, odak modu açılmaz.
    await t.tap(_resume);
    await t.pumpAndSettle();
    expect(_staleDialog, findsOneWidget);
    expect(app.location, '/antrenman');
    // Üst üste dokunuş ikinci diyalog açmaz.
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('uygulama başka sekmede açılsa da sorulur', (t) async {
    final disk = _Disk()..active = _active(_now.subtract(const Duration(hours: 25)));
    await _open(t, disk, initial: '/bugun');
    expect(find.text('BUGÜN'), findsOneWidget);
    expect(_staleDialog, findsOneWidget);
  });
}
