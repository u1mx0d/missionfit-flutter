import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/rest_timer.dart';
import 'package:missionfit/app/screen_awake.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/theme/tokens.dart' show contrastRatio;
import 'package:missionfit/ui/training/rest_screen.dart';
import 'package:missionfit/ui/training/training_routes.dart';

const _bench = PlannedExercise(
  exerciseId: 'bench',
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 4,
  restSeconds: 90,
);
const _dips = PlannedExercise(
  exerciseId: 'dips',
  tracking: 'reps',
  equipment: 'bodyweight',
  targetSets: 3,
  restSeconds: 60,
);

const _catalog = {
  'bench': ExerciseOption(
    id: 'bench',
    nameTr: 'Bench Press',
    tracking: 'weight_reps',
    equipment: 'barbell',
    region: BodyRegion.chest,
  ),
  'dips': ExerciseOption(
    id: 'dips',
    nameTr: 'Dips',
    tracking: 'reps',
    equipment: 'bodyweight',
    region: BodyRegion.arms,
  ),
};

final _t0 = DateTime.utc(2026, 11, 19, 10);

LoggedSet _done(String ex, int idx, {double kg = 62.5, int reps = 8}) => LoggedSet(
  id: 'done-$ex-$idx',
  exerciseId: ex,
  exerciseOrder: 0,
  setIndex: idx,
  reps: reps,
  weightKg: kg,
  completedAt: _t0.add(Duration(minutes: idx)),
);

class _FakeRepo extends Fake implements WorkoutRepository {
  _FakeRepo(this.active);
  ActiveWorkout? active;
  DateTime? restEnd;
  final memory = <String, int>{};
  final calls = <String>[];
  int _ids = 0;

  @override
  Future<ActiveWorkout?> loadActive(String userId) async => active;
  @override
  Future<void> savePlan(ActiveWorkout w) async => active = w;
  @override
  Future<LoggedSet> completeSet(ActiveWorkout w, String exerciseId, SetValues v) async {
    final s = LoggedSet(
      id: 'new-${++_ids}',
      exerciseId: exerciseId,
      exerciseOrder: w.orderFor(exerciseId),
      setIndex: w.nextSetIndex(exerciseId),
      reps: v.reps,
      weightKg: v.weightKg,
      completedAt: _t0.add(const Duration(hours: 1)),
    );
    active = w.logSet(s);
    return s;
  }

  @override
  Future<void> updateSet(LoggedSet s) async {
    active = active!.replaceSet(s);
    calls.add('update');
  }

  @override
  Future<void> deleteSet(LoggedSet s) async {
    active = active!.removeSet(s.id);
    calls.add('delete');
  }

  @override
  Future<void> setRestEnd(String sessionId, DateTime? endsAt) async => restEnd = endsAt;
  @override
  Future<DateTime?> restEndFor(String sessionId) async => restEnd;
  @override
  Future<int?> restSecondsFor(String userId, String exerciseId) async => memory[exerciseId];
  @override
  Future<void> rememberRest(String userId, String exerciseId, int seconds) async =>
      memory[exerciseId] = seconds;
}

class _FakeQueries extends Fake implements WorkoutQueries {
  @override
  Future<Map<String, ExerciseOption>> exercisesByIds(Iterable<String> ids) async => {
    for (final id in ids)
      if (_catalog[id] != null) id: _catalog[id]!,
  };

  @override
  Future<List<LoggedSet>> lastSessionSets(
    String userId,
    String exerciseId, {
    String? excludingSessionId,
  }) async => const [];
}

class _FakeAwake implements ScreenAwake {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

class _FakeNotifications implements NotificationService {
  final log = <String>[];
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
  }) async => log.add('show $nextLabel');
  @override
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel, String? payload}) async =>
      log.add('schedule');
  @override
  Future<void> cancelRest() async => log.add('cancel');
  @override
  Future<String?> launchPayload() async => null;
  @override
  Stream<String?> get tappedPayloads => const Stream.empty();
}

class _Ctx {
  _Ctx(this.container, this.repo, this.notifications, this.clock, this.haptics);
  final ProviderContainer container;
  final _FakeRepo repo;
  final _FakeNotifications notifications;
  final List<DateTime> clock;
  final List<String> haptics;

  set now(DateTime v) => clock[0] = v;
  DateTime get now => clock[0];
  RestState? get rest => container.read(restTimerProvider);
}

/// Odak modunu açar, bench'in [done] seti bitmiş; dinlenme `start` ile başlatılır.
Future<_Ctx> _pump(
  WidgetTester tester, {
  int done = 2,
  ThemeFamily family = ThemeFamily.canli,
  bool reduceMotion = false,
  List<PlannedExercise> plan = const [_bench, _dips],
  Size size = const Size(400, 900),
  Brightness brightness = Brightness.dark,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _FakeRepo(
    ActiveWorkout(
      sessionId: 's1',
      startedAt: _t0,
      plan: plan,
      sets: [for (var i = 1; i <= done; i++) _done('bench', i)],
      currentExerciseId: 'bench',
    ),
  );
  final notifications = _FakeNotifications();
  final clock = [_t0.add(const Duration(hours: 1))];
  final haptics = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
    call,
  ) async {
    if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
    return null;
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  final actions = StreamController<Never>();
  addTearDown(actions.close);
  final router = GoRouter(
    initialLocation: '/antrenman/odak',
    routes: [
      GoRoute(
        path: '/antrenman',
        builder: (_, _) => const Scaffold(body: Text('ANTRENMAN')),
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
      workoutRepositoryProvider.overrideWithValue(repo),
      workoutQueriesProvider.overrideWithValue(_FakeQueries()),
      screenAwakeProvider.overrideWithValue(_FakeAwake()),
      clockProvider.overrideWithValue(() => clock[0]),
      notificationServiceProvider.overrideWithValue(notifications),
      restActionsProvider.overrideWithValue(actions.stream),
    ],
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reduceMotion, textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        theme: buildThemeData(
          MfTheme.build(
            family,
            brightness,
            family == ThemeFamily.mono ? AccentColor.kirmizi : AccentColor.yesil,
          ),
        ),
      ),
    ),
  );
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
  return _Ctx(c, repo, notifications, clock, haptics);
}

Future<void> _startRest(WidgetTester t, _Ctx ctx, [int seconds = 90]) async {
  final f = ctx.container.read(restTimerProvider.notifier).start('bench', seconds);
  await t.pump();
  await t.pump();
  await f;
  await t.pump();
}

Finder _text(String s) => find.text(s);

void main() {
  testWidgets('dinlenme odak modunun üstünde tam ekran açılır; sayaç ve toplam', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);
    ctx.now = ctx.now.add(const Duration(seconds: 18));
    await t.pump(const Duration(seconds: 1));

    expect(find.byType(RestScreen), findsOneWidget);
    expect(_text('1:12'), findsOneWidget);
    expect(_text('KALAN · 1:30'), findsOneWidget);
    expect(find.bySemanticsLabel('kalan 1 dakika 12 saniye'), findsOneWidget);
    expect(_text('Set 2/4 bitti'), findsOneWidget);
    // Odak modunun düğmesi dinlenme sırasında görünmez.
    expect(find.text('Seti tamamla'), findsNothing);
  });

  testWidgets('Mono: başlıklar büyük harf, sayılar Doto', (t) async {
    final ctx = await _pump(t, family: ThemeFamily.mono);
    await _startRest(t, ctx);
    await t.pump(const Duration(seconds: 1));

    expect(_text('DİNLENME'), findsOneWidget);
    expect(_text('SET 2/4 BİTTİ'), findsOneWidget);
    expect(_text('–15 SN'), findsOneWidget);
    expect(_text('+15 SN'), findsOneWidget);
    expect(_text('ATLA'), findsOneWidget);
    expect(t.widget<Text>(_text('1:30')).style!.fontFamily, 'Doto');
  });

  testWidgets('sıradaki set nextUp()\'tan; motivasyon satırının yeri boş', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);

    expect(_text('Sıradaki · Set 3/4'), findsOneWidget);
    expect(_text('Bench Press · 62,5 × 8'), findsOneWidget);
    final moti = find.byKey(const Key('rest-motivation'));
    expect(moti, findsOneWidget);
    expect(find.descendant(of: moti, matching: find.byType(Text)), findsNothing);
  });

  testWidgets('hedef dolunca sıradaki hareket gösterilir', (t) async {
    final ctx = await _pump(t, done: 4);
    await _startRest(t, ctx);

    expect(_text('Sıradaki · Set 1/3'), findsOneWidget);
    expect(_text('Dips'), findsOneWidget);
  });

  testWidgets('50 sette nextUp hata vermez', (t) async {
    final ctx = await _pump(
      t,
      done: 50,
      plan: const [
        PlannedExercise(
          exerciseId: 'bench',
          tracking: 'weight_reps',
          equipment: 'barbell',
          targetSets: 51,
          restSeconds: 90,
        ),
      ],
    );
    await _startRest(t, ctx);
    expect(find.byType(RestScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  group('Geri al', () {
    Future<void> completeSet(WidgetTester t) async {
      await t.tap(find.widgetWithText(FilledButton, 'Seti tamamla'));
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
    }

    Finder atla() => find.ancestor(of: _text('Atla'), matching: find.byType(FilledButton));

    testWidgets('seti geri alınca dinlenme de biter, bildirim kalkar', (t) async {
      final ctx = await _pump(t);
      await completeSet(t);
      expect(ctx.rest, isNotNull);
      expect(find.byType(RestScreen), findsOneWidget);
      expect(ctx.repo.active!.sets, hasLength(3));
      ctx.notifications.log.clear();

      await t.tap(find.text('Geri al'));
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));

      expect(ctx.repo.active!.sets, hasLength(2));
      expect(ctx.rest, isNull);
      expect(ctx.repo.restEnd, isNull);
      expect(ctx.notifications.log, contains('cancel'));
      expect(find.byType(RestScreen), findsNothing);
    });

    testWidgets('snackbar Atla\'yı ve Seti tamamla\'yı örtmez', (t) async {
      final ctx = await _pump(t);
      await completeSet(t);
      expect(ctx.rest, isNotNull);
      // SnackBar'ın kendi alanı kenar boşluğunu da kapsar; görünen yüzey Material'dır.
      final bar = find.descendant(of: find.byType(SnackBar), matching: find.byType(Material)).first;
      expect(find.text('Geri al'), findsOneWidget);
      expect(t.getRect(bar).bottom, lessThanOrEqualTo(t.getRect(atla()).top));
      expect(t.getSize(atla()).height, greaterThanOrEqualTo(60));

      // Dinlenme atlanınca odak modunun ana düğmesi de açıkta kalır.
      await t.tap(atla());
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byType(RestScreen), findsNothing);
      expect(find.text('Geri al'), findsOneWidget);
      final cta = find.widgetWithText(FilledButton, 'Seti tamamla');
      expect(t.getRect(bar).bottom, lessThanOrEqualTo(t.getRect(cta).top));
    });
  });

  testWidgets('–15 sn / +15 sn / Atla çalışır', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);

    await t.tap(_text('+15 sn'));
    await t.pump();
    await t.pump();
    expect(_text('1:45'), findsOneWidget);
    expect(ctx.repo.memory['bench'], 105);

    await t.tap(_text('–15 sn'));
    await t.pump();
    await t.pump();
    expect(_text('1:30'), findsWidgets);

    await t.tap(_text('Atla'));
    await t.pump();
    await t.pump();
    expect(ctx.rest, isNull);
    expect(find.byType(RestScreen), findsNothing);
    expect(ctx.notifications.log.last, 'cancel');
    expect(find.text('Seti tamamla'), findsOneWidget);
  });

  testWidgets('–/+ ve Atla en az 48 dp, Atla 60 dp', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);
    for (final label in ['–15 sn', '+15 sn', 'Son seti düzenle']) {
      final size = t.getSize(
        find.ancestor(of: _text(label), matching: find.bySubtype<ButtonStyleButton>()).first,
      );
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }
    final skip = t.getSize(find.ancestor(of: _text('Atla'), matching: find.byType(FilledButton)));
    expect(skip.height, greaterThanOrEqualTo(60));
  });

  testWidgets('"Son seti düzenle" sayacı durdurup son seti açar', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);

    await t.tap(_text('Son seti düzenle'));
    await t.pumpAndSettle();

    expect(ctx.rest, isNull);
    expect(ctx.notifications.log, contains('cancel'));
    expect(find.byType(RestScreen), findsNothing);
    expect(_text('Set 2'), findsOneWidget);
    expect(_text('Kaydet'), findsOneWidget);
  });

  testWidgets('süre dolunca dinlenme kapanır ve güçlü titreşim olur', (t) async {
    final ctx = await _pump(t);
    await _startRest(t, ctx);
    ctx.now = ctx.now.add(const Duration(seconds: 91));
    await t.pump(const Duration(seconds: 1));
    await t.pump();
    await t.pump();

    expect(ctx.rest, isNull);
    expect(find.byType(RestScreen), findsNothing);
    expect(ctx.haptics, contains('HapticFeedbackType.heavyImpact'));
  });

  testWidgets('seti tamamlayınca dinlenme hatırlanan süreyle başlar', (t) async {
    final ctx = await _pump(t);
    ctx.repo.memory['bench'] = 120;
    await t.tap(find.widgetWithText(FilledButton, 'Seti tamamla'));
    await t.pump();
    await t.pump();
    await t.pump();

    expect(ctx.rest!.totalSeconds, 120);
    expect(find.byType(RestScreen), findsOneWidget);
    expect(_text('2:00'), findsOneWidget);
  });

  testWidgets('yeniden açılışta kayıtlı dinlenme sürer', (t) async {
    final ctx = await _pump(t);
    expect(find.byType(RestScreen), findsNothing);
    // Diskte süren dinlenme var; uygulama öne gelince okunur.
    ctx.repo.restEnd = ctx.now.add(const Duration(seconds: 40));
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pump();
    await t.pump();
    await t.pump();

    expect(find.byType(RestScreen), findsOneWidget);
    expect(_text('0:40'), findsOneWidget);
  });

  group('Hareketi azalt', () {
    double progress(WidgetTester t) => t.widget<RestRing>(find.byType(RestRing)).progress;

    testWidgets('halka akmaz, saniyede bir adım atar', (t) async {
      final ctx = await _pump(t, reduceMotion: true);
      await _startRest(t, ctx);
      await t.pump(const Duration(seconds: 1));
      final p0 = progress(t);
      expect(p0, 1.0);
      // Kare istenmiyor: sürekli animasyon yok.
      expect(t.binding.hasScheduledFrame, isFalse);

      ctx.now = ctx.now.add(const Duration(milliseconds: 500));
      await t.pump(const Duration(milliseconds: 100));
      expect(progress(t), p0);

      ctx.now = ctx.now.add(const Duration(milliseconds: 500));
      await t.pump(const Duration(seconds: 1));
      expect(progress(t), closeTo(89 / 90, 1e-9));
    });

    testWidgets('normalde halka saniye arasında da akar', (t) async {
      final ctx = await _pump(t);
      await _startRest(t, ctx);
      await t.pump(const Duration(milliseconds: 16));
      ctx.now = ctx.now.add(const Duration(milliseconds: 500));
      await t.pump(const Duration(milliseconds: 16));
      expect(t.binding.hasScheduledFrame, isTrue);
      expect(progress(t), closeTo(89.5 / 90, 1e-6));
    });
  });

  group('Yerleşim', () {
    for (final family in ThemeFamily.values) {
      for (final brightness in Brightness.values) {
        for (final (name, size, scale) in [
          ('küçük telefon', const Size(320, 568), 1.0),
          ('yatay', const Size(800, 380), 1.0),
          ('büyük yazı', const Size(375, 812), 2.0),
        ]) {
          testWidgets('${family.name}/${brightness.name}: $name taşmaz', (t) async {
            final ctx = await _pump(
              t,
              family: family,
              brightness: brightness,
              size: size,
              textScale: scale,
            );
            await _startRest(t, ctx);
            await t.pump(const Duration(seconds: 1));
            expect(t.takeException(), isNull);
            expect(find.byType(RestScreen), findsOneWidget);
          });
        }
      }
    }
  });

  test('Canlı degrade zemininde soluk yazı ve ters "Atla" okunur (≥ 4,5:1)', () {
    for (final b in Brightness.values) {
      final th = MfTheme.build(ThemeFamily.canli, b, AccentColor.yesil);
      expect(contrastRatio(th.textMuted, th.gradientTop!), greaterThanOrEqualTo(4.5), reason: '$b');
      expect(contrastRatio(th.text, th.gradientTop!), greaterThanOrEqualTo(4.5), reason: '$b');
      expect(contrastRatio(th.background, th.text), greaterThanOrEqualTo(4.5), reason: '$b');
    }
    for (final b in Brightness.values) {
      final th = MfTheme.build(ThemeFamily.mono, b, AccentColor.kirmizi);
      expect(contrastRatio(th.textMuted, th.background), greaterThanOrEqualTo(4.5), reason: '$b');
      expect(contrastRatio(th.background, th.text), greaterThanOrEqualTo(4.5), reason: '$b');
      // Halkanın yanık noktaları sönüklerden ayrışır (renk + boyut).
      expect(contrastRatio(th.accent, th.background), greaterThanOrEqualTo(3), reason: '$b');
    }
  });
}
