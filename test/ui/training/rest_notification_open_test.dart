import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/rest_timer.dart';
import 'package:missionfit/app/screen_awake.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/notifications/rest_actions.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/env.dart';
import 'package:missionfit/ui/router.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/training/rest_notification_open.dart';
import 'package:missionfit/ui/training/rest_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/identity_fakes.dart';

final _now = DateTime.utc(2026, 11, 18, 7, 0, 30);

const _bench = PlannedExercise(
  exerciseId: 'bench',
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 90,
);

ActiveWorkout _workout(DateTime startedAt) => ActiveWorkout(
  sessionId: 's1',
  startedAt: startedAt,
  plan: const [_bench],
  sets: [
    LoggedSet(
      id: 'set-1',
      exerciseId: 'bench',
      exerciseOrder: 0,
      setIndex: 1,
      reps: 8,
      weightKg: 60,
      completedAt: _now.subtract(const Duration(seconds: 30)),
    ),
  ],
  currentExerciseId: 'bench',
);

final _payload = const RestPayload(
  sessionId: 's1',
  userId: 'u1',
  exerciseId: 'bench',
  totalSeconds: 90,
  nextLabel: 'Sıradaki: Bench Press',
).encode();

class _FakeSession extends Fake implements Session {}

class _FakeNotifications extends Fake implements NotificationService {
  _FakeNotifications(this.launch);
  final String? launch;
  final taps = StreamController<String?>.broadcast();

  @override
  Future<String?> launchPayload() async => launch;
  @override
  Stream<String?> get tappedPayloads => taps.stream;
  @override
  Future<void> showRest({
    required DateTime endsAt,
    required String nextLabel,
    String? payload,
  }) async {}
  @override
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel, String? payload}) async {}
  @override
  Future<void> cancelRest() async {}
}

class _FakeRepo extends Fake implements WorkoutRepository {
  _FakeRepo(this.active, this.restEnd);
  final ActiveWorkout? active;
  DateTime? restEnd;

  @override
  Future<ActiveWorkout?> loadActive(String userId) async => active;
  @override
  Future<DateTime?> restEndFor(String sessionId) async => restEnd;
  @override
  Future<void> setRestEnd(String sessionId, DateTime? endsAt) async => restEnd = endsAt;
}

class _FakeQueries extends Fake implements WorkoutQueries {
  @override
  Future<Map<String, ExerciseOption>> exercisesByIds(Iterable<String> ids) async => {
    for (final id in ids)
      id: const ExerciseOption(
        id: 'bench',
        nameTr: 'Bench Press',
        tracking: 'weight_reps',
        equipment: 'barbell',
        region: BodyRegion.chest,
      ),
  };

  @override
  Future<List<LoggedSet>> lastSessionSets(
    String userId,
    String exerciseId, {
    String? excludingSessionId,
  }) async => const [];
}

class _Awake implements ScreenAwake {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

class _App extends ConsumerWidget {
  const _App();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);
    ref.watch(restNotificationOpenProvider);
    return MaterialApp.router(
      routerConfig: router,
      theme: buildThemeData(MfTheme.build(sel.family, Brightness.dark, sel.accent)),
    );
  }
}

/// Uygulamayı gerçek yönlendiriciyle (açılış `/bugun`, kimlik yönlendirmeleri) açar.
Future<(GoRouter, _FakeNotifications, _FakeRepo)> _open(
  WidgetTester tester, {
  String? launch,
  ActiveWorkout? active,
  DateTime? restEnd,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await db
      .into(db.profiles)
      .insert(ProfilesCompanion.insert(userId: 'u1', createdAt: 'x', updatedAt: 'x'));
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final notifications = _FakeNotifications(launch);
  addTearDown(notifications.taps.close);
  final repo = _FakeRepo(active, restEnd);
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      envProvider.overrideWithValue(
        const Env(
          supabaseUrl: 'https://x.supabase.co',
          supabasePublishableKey: 'k',
          googleWebClientId: '',
        ),
      ),
      sharedPreferencesProvider.overrideWithValue(sp),
      authStateProvider.overrideWithValue(AsyncData<Session?>(_FakeSession())),
      signedInUserIdProvider.overrideWithValue('u1'),
      onboardedProvider.overrideWithValue(true),
      googleProfileProvider.overrideWithValue(null),
      profileIdentityRepositoryProvider.overrideWithValue(FakeIdentityRepo(db)),
      hasPasswordIdentityProvider.overrideWithValue(true),
      currentUserEmailProvider.overrideWithValue('a@b.com'),
      clockProvider.overrideWithValue(() => _now),
      awaitingFirstPullProvider.overrideWithValue(false),
      startupProblemProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWith((ref) => throw UnimplementedError()),
      sessionRetryProvider.overrideWithValue(() async {}),
      notificationServiceProvider.overrideWithValue(notifications),
      restActionsProvider.overrideWithValue(const Stream<RestActionMessage>.empty()),
      workoutRepositoryProvider.overrideWithValue(repo),
      workoutQueriesProvider.overrideWithValue(_FakeQueries()),
      screenAwakeProvider.overrideWithValue(_Awake()),
    ],
  );
  addTearDown(c.dispose);
  final router = c.read(routerProvider);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const _App()));
  // Dinlenme ekranının halkası sürekli akar; pumpAndSettle yerine sabit adımlar.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (router, notifications, repo);
}

String _loc(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('bildirimle açılış + süren antrenman → odak modu, dinlenme ekranı', (t) async {
    final (router, _, _) = await _open(
      t,
      launch: _payload,
      active: _workout(_now.subtract(const Duration(hours: 1))),
      restEnd: _now.add(const Duration(seconds: 60)),
    );
    expect(_loc(router), '/antrenman/odak');
    expect(find.byType(RestScreen), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
  });

  testWidgets('bildirimle açılış ama süren antrenman yok → /bugun', (t) async {
    final (router, _, _) = await _open(t, launch: _payload);
    expect(_loc(router), '/bugun');
  });

  testWidgets('bildirimle açılış ama antrenman 24 saatten eski → /bugun (soru sorulur)', (t) async {
    final (router, _, _) = await _open(
      t,
      launch: _payload,
      active: _workout(_now.subtract(const Duration(hours: 25))),
    );
    expect(_loc(router), '/bugun');
    expect(find.text('Bitir mi, sil mi?'), findsOneWidget);
  });

  testWidgets('bildirimsiz açılış: süren antrenman olsa da /bugun', (t) async {
    final (router, _, _) = await _open(
      t,
      active: _workout(_now.subtract(const Duration(hours: 1))),
    );
    expect(_loc(router), '/bugun');
  });

  testWidgets('uygulama açıkken bildirime dokunulunca odak moduna gidilir', (t) async {
    final (router, notifications, _) = await _open(
      t,
      active: _workout(_now.subtract(const Duration(hours: 1))),
    );
    expect(_loc(router), '/bugun');
    notifications.taps.add(_payload);
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(_loc(router), '/antrenman/odak');
    // Dinlenme bitmiş: odak modu dinlenme ekranı olmadan açılır.
    expect(find.byType(RestScreen), findsNothing);
    expect(find.text('Seti tamamla'), findsOneWidget);
  });

  testWidgets('başka kullanıcının bildirimi yok sayılır', (t) async {
    final other = const RestPayload(
      sessionId: 's9',
      userId: 'u9',
      exerciseId: 'bench',
      totalSeconds: 90,
      nextLabel: '',
    ).encode();
    final (router, _, _) = await _open(
      t,
      launch: other,
      active: _workout(_now.subtract(const Duration(hours: 1))),
    );
    expect(_loc(router), '/bugun');
  });
}
