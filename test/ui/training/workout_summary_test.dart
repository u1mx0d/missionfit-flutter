import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/domain/body_map.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/units.dart';
import 'package:missionfit/domain/workout_summary.dart';
import 'package:missionfit/ui/components/body_map/body_map.dart';
import 'package:missionfit/ui/components/body_map/body_map_frames.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/theme/tokens.dart' show fontDoto;
import 'package:missionfit/ui/training/training_routes.dart';

final _start = DateTime.utc(2026, 11, 20, 10);

SessionSummaryData _data({int? kcal = 210}) => SessionSummaryData(
  sessionId: 's1',
  name: 'Göğüs günü',
  startedAt: _start,
  endedAt: _start.add(const Duration(minutes: 45)),
  estimatedKcal: kcal,
  sets: [
    for (var i = 0; i < 3; i++)
      const SummarySet(exerciseId: 'bench', met: 5, reps: 8, weightKg: 60),
    for (var i = 0; i < 2; i++) const SummarySet(exerciseId: 'dips', met: 4, reps: 10),
  ],
);

/// Bu oturum: göğüs 4 (birincil 3 + ikincil 1), triceps 3,5. Haftalık ölçekte göğüs 2.
final _sessionSets = {
  for (final m in bodyMapMuscles) m: 0.0,
  'chest': 4.0,
  'triceps': 3.5,
  'shoulders': 1.5,
};

WeeklyBodyMap _map(Map<String, double> sets) => WeeklyBodyMap(
  muscleSets: sets,
  levels: {for (final e in sets.entries) e.key: bodyMapLevel(e.value)},
  lastWorked: {for (final m in bodyMapMuscles) m: null},
  musclesWorked: sets.values.where((v) => v > 0).length,
  totalSets: 5,
);

const _names = {'chest': 'Göğüs kası', 'triceps': 'Triseps', 'shoulders': 'Omuz kası'};

class _FakeQueries extends Fake implements WorkoutQueries {
  _FakeQueries(this.data);
  final SessionSummaryData? data;
  final asked = <String>[];

  @override
  Future<SessionSummaryData?> sessionSummary(String sessionId) async {
    asked.add(sessionId);
    return data;
  }

  @override
  Future<WeeklyBodyMap> sessionBodyMap(String sessionId) async => _map(_sessionSets);

  @override
  Stream<List<MuscleGroupOption>> watchMuscleGroups() => Stream.value([
    for (final m in bodyMapMuscles)
      MuscleGroupOption(slug: m, nameTr: _names[m] ?? m, region: BodyRegion.chest),
  ]);
}

class _Ctx {
  _Ctx(this.router, this.queries);
  final GoRouter router;
  final _FakeQueries queries;
  String get location => router.routerDelegate.currentConfiguration.last.matchedLocation;
}

Future<_Ctx> _pump(
  WidgetTester tester, {
  SessionSummaryData? data,
  bool missing = false,
  WeightUnit units = WeightUnit.kg,
  ThemeFamily family = ThemeFamily.canli,
  Brightness brightness = Brightness.dark,
  double textScale = 1,
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final queries = _FakeQueries(missing ? null : (data ?? _data()));
  final router = GoRouter(
    initialLocation: '/antrenman/ozet/s1',
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
        (ref) => Stream.value(Profile(userId: 'u1', createdAt: 'x', updatedAt: 'x', units: units)),
      ),
      workoutQueriesProvider.overrideWithValue(queries),
      // Haftalık maket özetle karışmamalı: tamamen farklı bir hafta.
      weeklyBodyMapProvider.overrideWith(
        (ref) => Stream.value(_map({for (final m in bodyMapMuscles) m: 12.0})),
      ),
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
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
  await tester.pumpAndSettle();
  return _Ctx(router, queries);
}

Future<void> _scrollTo(WidgetTester t, Finder f) async {
  await t.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('süre, set, hacim (kg), kalori ve bu oturumun maketi', (t) async {
    final ctx = await _pump(t);
    expect(ctx.queries.asked, contains('s1'));
    expect(find.text('Göğüs günü'), findsOneWidget);
    expect(find.text('45:00'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // set
    expect(find.text('1.440'), findsOneWidget); // 3 × 60 × 8
    expect(find.text('kg hacim'), findsOneWidget);
    expect(find.text('210'), findsOneWidget);
    expect(find.text('kcal'), findsOneWidget);
    expect(find.text('2 hareket'), findsOneWidget);

    await _scrollTo(t, find.byType(BodyMap));
    final map = t.widget<BodyMap>(find.byType(BodyMap));
    // Global kademeler: 4 → 2, 3,5 → 1 (oturum ölçeği olsaydı 4 ve 3 olurdu).
    expect(map.levels['chest'], 2);
    expect(map.levels['triceps'], 1);
    expect(map.levels['shoulders'], 1);
    expect(map.levels['quads'], 0); // haftalık maket (her yer 12) kullanılmadı
    expect(find.text('Bu antrenman'), findsOneWidget);
  });

  testWidgets('çalışılan kaslar metinle de listelenir (yalnızca renk değil)', (t) async {
    await _pump(t);
    await _scrollTo(t, find.text('Göğüs kası'));
    expect(find.text('Göğüs kası'), findsOneWidget);
    expect(find.text('4 set'), findsOneWidget);
    expect(find.text('Triseps'), findsOneWidget);
    expect(find.text('3,5 set'), findsOneWidget);
    expect(find.text('Omuz kası'), findsOneWidget);
  });

  testWidgets('hacim kullanıcının biriminde (lb)', (t) async {
    await _pump(t, units: WeightUnit.lb);
    expect(find.text('3.175'), findsOneWidget); // 1440 kg ≈ 3174,6 lb
    expect(find.text('lb hacim'), findsOneWidget);
  });

  testWidgets('kilo bilinmiyorsa kalori gösterilmez (0 kcal değil)', (t) async {
    await _pump(t, data: _data(kcal: null));
    expect(find.text('kcal'), findsNothing);
    expect(find.text('45:00'), findsOneWidget);
  });

  testWidgets('Mono: sayılar Doto, etiketler büyük harf', (t) async {
    await _pump(t, family: ThemeFamily.mono);
    final number = t.widget<Text>(find.text('1.440'));
    expect(number.style?.fontFamily, fontDoto);
    expect(find.text('KG HACİM'), findsOneWidget);
  });

  testWidgets('Tamam ve geri tuşu antrenman sekmesine döner', (t) async {
    final ctx = await _pump(t);
    await _scrollTo(t, find.text('Tamam'));
    await t.tap(find.text('Tamam'));
    await t.pumpAndSettle();
    expect(ctx.location, '/antrenman');

    ctx.router.go('/antrenman/ozet/s1');
    await t.pumpAndSettle();
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(ctx.location, '/antrenman');
  });

  testWidgets('oturum bulunamazsa açıklama ve dönüş', (t) async {
    await _pump(t, missing: true);
    expect(find.text('Antrenman bulunamadı.'), findsOneWidget);
    expect(find.text('Tamam'), findsOneWidget);
  });

  testWidgets('büyük yazı, açık Mono ve dar ekranda taşma yok; dokunma ≥ 48 dp', (t) async {
    await _pump(t, textScale: 2, size: const Size(320, 640));
    expect(t.takeException(), isNull);
    await _pump(
      t,
      family: ThemeFamily.mono,
      brightness: Brightness.light,
      textScale: 1.6,
      size: const Size(800, 400),
    );
    expect(t.takeException(), isNull);
    await _scrollTo(t, find.text('Tamam'));
    expect(t.getSize(find.widgetWithText(FilledButton, 'Tamam')).height, greaterThanOrEqualTo(48));
  });
}
