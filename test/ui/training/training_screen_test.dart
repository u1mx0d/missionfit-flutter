import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/active_workout_controller.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/body_map.dart';
import 'package:missionfit/domain/date_labels.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/week.dart';
import 'package:missionfit/ui/components/body_map/body_map.dart';
import 'package:missionfit/ui/components/body_map/body_map_frames.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/training/start_workout_screen.dart';
import 'package:missionfit/ui/training/training_routes.dart';
import 'package:missionfit/ui/training/training_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;

const _muscleNames = {
  'chest': 'Göğüs kası',
  'shoulders': 'Omuz kası',
  'biceps': 'Biseps',
  'triceps': 'Triseps',
  'forearms': 'Ön kol',
  'abs': 'Karın kası',
  'obliques': 'Yan karın',
  'traps': 'Trapez',
  'lats': 'Kanat',
  'lower_back': 'Bel',
  'glutes': 'Kalça',
  'quads': 'Ön bacak',
  'hamstrings': 'Arka bacak',
  'calves': 'Baldır',
};

BodyRegion _regionOf(String m) => switch (m) {
  'chest' => BodyRegion.chest,
  'shoulders' => BodyRegion.shoulders,
  'biceps' || 'triceps' || 'forearms' => BodyRegion.arms,
  'abs' || 'obliques' => BodyRegion.core,
  'traps' || 'lats' || 'lower_back' => BodyRegion.back,
  _ => BodyRegion.legs,
};

WeeklyBodyMap _week() {
  final sets = {
    for (final m in bodyMapMuscles) m: 0.0,
    'chest': 6.0,
    'triceps': 3.0,
    'shoulders': 3.0,
    'quads': 4.5,
  };
  return WeeklyBodyMap(
    muscleSets: sets,
    levels: {for (final e in sets.entries) e.key: bodyMapLevel(e.value)},
    lastWorked: {
      for (final m in bodyMapMuscles) m: null,
      'chest': '2026-11-18',
      'shoulders': '2026-11-18',
      'triceps': '2026-11-19',
      'quads': '2026-11-20',
    },
    musclesWorked: 4,
    totalSets: 13,
  );
}

ExerciseOption _ex(String id, String name, {DateTime? last, String tracking = 'weight_reps'}) =>
    ExerciseOption(
      id: id,
      nameTr: name,
      tracking: tracking,
      equipment: tracking == 'reps' ? 'bodyweight' : 'barbell',
      lastDoneAt: last,
    );

final _catalog = {
  'bench': _ex('bench', 'Bench Press', last: DateTime.utc(2026, 11, 18)),
  'pushup': _ex('pushup', 'Şınav', last: DateTime.utc(2026, 11, 10), tracking: 'reps'),
  'fly': _ex('fly', 'Fly'),
  'pecdeck': _ex('pecdeck', 'Pec Deck'),
  'dips': _ex('dips', 'Dips', tracking: 'reps'),
  'squat': _ex('squat', 'Squat'),
};

final _groups = [
  for (final m in bodyMapMuscles)
    MuscleGroupOption(slug: m, nameTr: _muscleNames[m]!, region: _regionOf(m)),
];

final _templates = [
  for (var i = 1; i <= 10; i++)
    TemplateOption(
      id: 't$i',
      nameTr: 'Program $i',
      description: 'Açıklama $i',
      level: i.isEven ? 'intermediate' : 'beginner',
      exerciseCount: 4,
    ),
];

const _templatePlan = [
  PlannedExercise(
    exerciseId: 'squat',
    tracking: 'weight_reps',
    equipment: 'barbell',
    targetSets: 5,
    restSeconds: 120,
  ),
];

final _recents = [
  RecentWorkout(
    sessionId: 'r1',
    name: 'Göğüs günü',
    startedAt: DateTime.utc(2026, 11, 18, 10),
    exerciseIds: const ['bench', 'dips'],
    setCount: 7,
  ),
  RecentWorkout(
    sessionId: 'r2',
    name: 'Bacak günü',
    startedAt: DateTime.utc(2026, 11, 16, 10),
    exerciseIds: const ['squat'],
    setCount: 5,
  ),
  RecentWorkout(
    sessionId: 'r3',
    name: 'Antrenman',
    startedAt: DateTime.utc(2026, 11, 14, 10),
    exerciseIds: const ['pushup'],
    setCount: 3,
  ),
];

class _StartCall {
  _StartCall(this.plan, this.templateId, this.name);
  final List<PlannedExercise> plan;
  final String? templateId;
  final String name;
}

class _FakeRepo extends Fake implements WorkoutRepository {
  _FakeRepo(this.active);
  ActiveWorkout? active;
  final starts = <_StartCall>[];

  @override
  Future<ActiveWorkout?> loadActive(String userId) async => active;

  @override
  Future<ActiveWorkout> start({
    required String userId,
    required List<PlannedExercise> plan,
    String? templateId,
    String name = 'Antrenman',
    required String timeZone,
    required WeekStartsOn weekStartsOn,
  }) async {
    starts.add(_StartCall(plan, templateId, name));
    return active = ActiveWorkout(
      sessionId: 'new',
      startedAt: DateTime.utc(2026, 11, 20, 10),
      plan: plan,
      sets: const [],
      currentExerciseId: plan.isEmpty ? null : plan.first.exerciseId,
    );
  }
}

class _FakeQueries extends Fake implements WorkoutQueries {
  final regionCalls = <BodyRegion>[];
  final searches = <String>[];

  /// Verilirse katalog akışları bunlardan gelir (senkron/hata senaryoları).
  Stream<List<MuscleGroupOption>> Function()? groupsStream;
  Stream<List<TemplateOption>> Function()? templatesStream;
  int templateSubscriptions = 0;

  @override
  Stream<List<MuscleGroupOption>> watchMuscleGroups() =>
      groupsStream?.call() ?? Stream.value(_groups);

  @override
  Stream<List<TemplateOption>> watchTemplates() {
    templateSubscriptions++;
    return templatesStream?.call() ?? Stream.value(_templates);
  }

  @override
  Future<List<PlannedExercise>> templatePlan(String templateId) async => _templatePlan;

  @override
  Future<List<ExerciseOption>> exercisesForRegion(String userId, BodyRegion region) async {
    regionCalls.add(region);
    return switch (region) {
      BodyRegion.chest => [
        _catalog['bench']!,
        _catalog['pushup']!,
        _catalog['fly']!,
        _catalog['pecdeck']!,
      ],
      BodyRegion.legs => [_catalog['squat']!],
      _ => const [],
    };
  }

  @override
  Future<List<ExerciseOption>> searchExercises(String query) async {
    searches.add(query);
    return [
      for (final e in _catalog.values)
        if (e.nameTr.toLowerCase().contains(query.trim().toLowerCase())) e,
    ];
  }

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
  }) async => exerciseId == 'bench'
      ? [
          for (var i = 1; i <= 4; i++)
            LoggedSet(
              id: 'b$i',
              exerciseId: 'bench',
              exerciseOrder: 0,
              setIndex: i,
              reps: 8,
              weightKg: 60,
              completedAt: DateTime.utc(2026, 11, 18),
            ),
        ]
      : const [];
}

class _FixedToday extends TodayNotifier {
  @override
  Today build() => const Today(date: '2026-11-20', minutes: 600);
}

class _Ctx {
  _Ctx(this.repo, this.queries, this.router, this.container);
  final _FakeRepo repo;
  final _FakeQueries queries;
  final GoRouter router;
  final ProviderContainer container;
  String get location => router.routerDelegate.currentConfiguration.last.matchedLocation;
}

Future<_Ctx> _pump(
  WidgetTester tester, {
  ThemeFamily family = ThemeFamily.canli,
  ActiveWorkout? active,
  List<RecentWorkout>? recents,
  Future<List<RecentWorkout>>? recentsFuture,
  String initial = '/antrenman',
  double textScale = 1,
  Brightness brightness = Brightness.dark,
  Size size = const Size(400, 900),
  Stream<WeeklyBodyMap>? weekStream,
  void Function(_FakeQueries q)? setupQueries,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _FakeRepo(active);
  final queries = _FakeQueries();
  setupQueries?.call(queries);
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/antrenman', builder: (_, _) => const TrainingScreen()),
      // Odak modunun kendisi Görev 7'de test edilir; burada yalnızca açıldığı görülür.
      GoRoute(
        path: '/antrenman/odak',
        builder: (_, _) => const Scaffold(body: Text('ODAK')),
      ),
      ...trainingRoutes.where((r) => r is GoRoute && r.path != '/antrenman/odak'),
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
      workoutRepositoryProvider.overrideWithValue(repo),
      workoutQueriesProvider.overrideWithValue(queries),
      weeklyBodyMapProvider.overrideWith((ref) => weekStream ?? Stream.value(_week())),
      recentWorkoutsProvider.overrideWith(
        (ref) => recentsFuture ?? Future.value(recents ?? _recents),
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
  return _Ctx(repo, queries, router, c);
}

Finder _row(String region) => find.byKey(Key('region-$region'));

Future<void> _scrollTo(WidgetTester t, Finder f) async {
  await t.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('formatDayRange', () {
    expect(formatDayRange('2026-11-16', '2026-11-22'), '16–22 Kasım');
    expect(formatDayRange('2026-11-30', '2026-12-06'), '30 Kasım – 6 Aralık');
  });

  test('daysAgoLabel', () {
    expect(daysAgoLabel('2026-11-20', '2026-11-20'), 'bugün');
    expect(daysAgoLabel('2026-11-19', '2026-11-20'), 'dün');
    expect(daysAgoLabel('2026-11-18', '2026-11-20'), '2 gün önce');
  });

  test('rotalar', () {
    final paths = [for (final r in trainingRoutes) (r as GoRoute).path];
    expect(
      paths,
      containsAll(['/antrenman/odak', '/antrenman/basla', '/antrenman/ozet/:sessionId']),
    );
  });

  group('Sekme: Bu hafta', () {
    testWidgets('başlık, çalışılan kas sayısı /14, 6 bölge sayılarla', (t) async {
      await _pump(t);
      expect(find.text('Bu hafta'), findsOneWidget);
      expect(find.text('· 16–22 Kasım'), findsOneWidget);
      expect(find.text('4/14'), findsOneWidget);
      expect(find.textContaining('13 set'), findsOneWidget);
      expect(find.byType(BodyMap), findsOneWidget);
      final expected = {
        'chest': ('Göğüs', '6'),
        'back': ('Sırt', '0'),
        'shoulders': ('Omuz', '3'),
        'arms': ('Kol', '3'),
        'core': ('Karın', '0'),
        'legs': ('Bacak', '4,5'),
      };
      for (final e in expected.entries) {
        expect(_row(e.key), findsOneWidget, reason: e.key);
        expect(find.descendant(of: _row(e.key), matching: find.text(e.value.$1)), findsOneWidget);
        expect(find.descendant(of: _row(e.key), matching: find.text(e.value.$2)), findsOneWidget);
      }
    });

    testWidgets('Mono temada başlık büyük harf', (t) async {
      await _pump(t, family: ThemeFamily.mono);
      expect(find.text('BU HAFTA'), findsOneWidget);
      expect(find.text('4/14'), findsOneWidget);
    });

    testWidgets('satıra dokununca kaslar ve son çalışma açılır, tekrar dokununca kapanır', (
      t,
    ) async {
      await _pump(t);
      expect(find.textContaining('Son çalışma'), findsNothing);
      await t.tap(_row('chest'));
      await t.pumpAndSettle();
      expect(find.text('Son çalışma: 2 gün önce'), findsOneWidget);
      expect(find.text('Göğüs kası'), findsOneWidget);
      await t.tap(_row('arms'));
      await t.pumpAndSettle();
      expect(find.text('Son çalışma: dün'), findsOneWidget);
      expect(find.text('Biseps'), findsOneWidget);
      expect(find.text('Triseps'), findsOneWidget);
      expect(find.text('Göğüs kası'), findsNothing);
      await t.tap(_row('arms'));
      await t.pumpAndSettle();
      expect(find.textContaining('Son çalışma'), findsNothing);
    });

    testWidgets('çalışılmamış bölge: "Bu hafta çalışılmadı"', (t) async {
      await _pump(t);
      await t.tap(_row('back'));
      await t.pumpAndSettle();
      expect(find.text('Bu hafta çalışılmadı'), findsOneWidget);
    });

    testWidgets('maketteki kasa dokununca bölgesi açılır', (t) async {
      await _pump(t);
      t.widget<BodyMap>(find.byType(BodyMap)).onRegionTap!('quads');
      await t.pumpAndSettle();
      expect(find.text('Son çalışma: bugün'), findsOneWidget);
      expect(find.text('Ön bacak'), findsOneWidget);
    });
  });

  group('Sekme: yükleme ve senkron', () {
    testWidgets('hafta yüklenirken düzen yerinde, sayılar "–", boş hafta gösterilmez', (t) async {
      await _pump(t, weekStream: const Stream.empty());
      expect(find.text('–/14'), findsOneWidget);
      expect(find.text('0/14'), findsNothing);
      for (final r in BodyRegion.values) {
        expect(find.descendant(of: _row(r.name), matching: find.text('–')), findsOneWidget);
      }
      // Yüklenirken satır açılmaz.
      await t.tap(_row('chest'));
      await t.pumpAndSettle();
      expect(find.textContaining('Son çalışma'), findsNothing);
    });

    testWidgets('katalog ilk açılıştan sonra gelince sekme yenilenir', (t) async {
      // İlk açılışta katalog boş (senkron henüz bitmedi).
      final groups = StreamController<List<MuscleGroupOption>>()..add(const []);
      final templates = StreamController<List<TemplateOption>>()..add(const []);
      addTearDown(groups.close);
      addTearDown(templates.close);
      await _pump(
        t,
        setupQueries: (q) {
          q.groupsStream = () => groups.stream;
          q.templatesStream = () => templates.stream;
        },
      );
      expect(find.descendant(of: _row('chest'), matching: find.text('0')), findsOneWidget);
      await _scrollTo(t, find.text('Hazır programlar internete bağlanınca gelir.'));

      // Senkron katalog satırlarını yazar; akışlar yeniden yayar.
      groups.add(_groups);
      templates.add(_templates);
      await t.pumpAndSettle();
      expect(find.text('Hazır programlar internete bağlanınca gelir.'), findsNothing);
      expect(find.text('Program 1', skipOffstage: false), findsOneWidget);
      await t.scrollUntilVisible(_row('chest'), -200, scrollable: find.byType(Scrollable).first);
      expect(find.descendant(of: _row('chest'), matching: find.text('6')), findsOneWidget);
    });

    testWidgets('şablonlar hata verirse "Tekrar dene" yeniden yükler', (t) async {
      var fail = true;
      final c = await _pump(
        t,
        setupQueries: (q) =>
            q.templatesStream = () =>
                fail ? Stream.error(StateError('disk')) : Stream.value(_templates),
      );
      await _scrollTo(t, find.text('Hazır programlar yüklenemedi.'));
      expect(find.text('Hazır programlar internete bağlanınca gelir.'), findsNothing);
      fail = false;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(c.queries.templateSubscriptions, 2);
      expect(find.text('Program 1', skipOffstage: false), findsOneWidget);
    });
  });

  group('Sekme: başlama', () {
    testWidgets('Antrenmana başla → liste kurma', (t) async {
      final c = await _pump(t);
      await t.tap(find.text('Antrenmana başla'));
      await t.pumpAndSettle();
      expect(c.location, '/antrenman/basla');
      expect(find.byType(StartWorkoutScreen), findsOneWidget);
    });

    testWidgets('Tekrarla: son 3 antrenman; aynı hareketlerle odak modu', (t) async {
      final c = await _pump(t);
      await _scrollTo(t, find.text('Göğüs günü'));
      expect(find.text('Göğüs günü'), findsOneWidget);
      expect(find.text('Bacak günü'), findsOneWidget);
      expect(find.text('2 gün önce · 2 hareket · 7 set'), findsOneWidget);
      expect(find.text('Tekrarla'), findsNWidgets(3));
      await t.tap(find.bySemanticsLabel('Göğüs günü antrenmanını tekrarla'));
      await t.pumpAndSettle();
      expect(c.repo.starts, hasLength(1));
      final s = c.repo.starts.single;
      expect(s.plan.map((p) => p.exerciseId), ['bench', 'dips']);
      expect(s.plan.first.targetSets, 4); // geçen sefer 4 set
      expect(s.plan.last.targetSets, 3);
      expect(s.name, 'Göğüs günü');
      expect(c.location, '/antrenman/odak');
    });

    testWidgets('son antrenman yoksa boş durum metni', (t) async {
      await _pump(t, recents: const []);
      await _scrollTo(t, find.text('Henüz tamamlanan antrenman yok.'));
      expect(find.text('Tekrarla'), findsNothing);
    });

    testWidgets('Hazır programlar: 10 şablon, dokununca şablon planıyla başlar', (t) async {
      final c = await _pump(t);
      await _scrollTo(t, find.text('Hazır programlar'));
      await _scrollTo(t, find.text('Program 10'));
      for (var i = 1; i <= 10; i++) {
        expect(find.text('Program $i', skipOffstage: false), findsOneWidget);
      }
      await t.tap(find.text('Program 10'));
      await t.pumpAndSettle();
      final s = c.repo.starts.single;
      expect(s.plan, _templatePlan);
      expect(s.templateId, 't10');
      expect(s.name, 'Program 10');
      expect(c.location, '/antrenman/odak');
    });

    testWidgets('aktif antrenman varsa en üstte Devam et kartı', (t) async {
      final c = await _pump(
        t,
        active: ActiveWorkout(
          sessionId: 's1',
          startedAt: DateTime.utc(2026, 11, 20, 9),
          plan: _templatePlan,
          sets: const [],
          currentExerciseId: 'squat',
        ),
      );
      final card = find.byKey(const Key('resume-card'));
      expect(card, findsOneWidget);
      expect(t.getTopLeft(card).dy, lessThan(t.getTopLeft(find.text('Bu hafta')).dy));
      await t.tap(find.text('Devam et'));
      await t.pumpAndSettle();
      expect(c.location, '/antrenman/odak');
      expect(c.repo.starts, isEmpty);
    });

    testWidgets('aktif antrenman varken Tekrarla ikinci antrenman açmaz', (t) async {
      final c = await _pump(
        t,
        active: ActiveWorkout(
          sessionId: 's1',
          startedAt: DateTime.utc(2026, 11, 20, 9),
          plan: _templatePlan,
          sets: const [],
          currentExerciseId: 'squat',
        ),
      );
      await _scrollTo(t, find.bySemanticsLabel('Bacak günü antrenmanını tekrarla'));
      await t.tap(find.bySemanticsLabel('Bacak günü antrenmanını tekrarla'));
      await t.pumpAndSettle();
      expect(c.repo.starts, isEmpty);
      expect(c.location, '/antrenman/odak');
    });

    testWidgets('büyük yazıda taşma yok', (t) async {
      await _pump(t, textScale: 2, family: ThemeFamily.mono);
      expect(t.takeException(), isNull);
      await _scrollTo(t, find.text('Program 10'));
      expect(t.takeException(), isNull);
    });

    testWidgets('açık Mono, dar ekran ve yatay: taşma yok', (t) async {
      await _pump(
        t,
        family: ThemeFamily.mono,
        brightness: Brightness.light,
        size: const Size(360, 740),
      );
      expect(t.takeException(), isNull);
      t.view.physicalSize = const Size(800, 360);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    testWidgets('dokunma alanları ≥ 48 dp', (t) async {
      await _pump(t);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    });
  });

  group('Başlama ekranı', () {
    testWidgets('bölge çipi: yaptıkların önce; iki hareket → odak ilk hareketle', (t) async {
      final c = await _pump(t, initial: '/antrenman/basla');
      expect(find.text('Bir bölge seç ya da hareket ara.'), findsOneWidget);
      await t.tap(find.widgetWithText(ChoiceChip, 'Göğüs'));
      await t.pumpAndSettle();
      expect(c.queries.regionCalls, [BodyRegion.chest]);
      expect(find.text('Yaptıkların'), findsOneWidget);
      expect(find.text('Katalog'), findsOneWidget);
      double y(String s) => t.getTopLeft(find.text(s)).dy;
      expect(y('Bench Press'), lessThan(y('Şınav')));
      expect(y('Şınav'), lessThan(y('Katalog')));
      expect(y('Katalog'), lessThan(y('Fly')));
      expect(find.text('Son: 2 gün önce'), findsOneWidget);

      // Başla düğmesi seçim yokken pasif.
      final startBtn = find.descendant(
        of: find.byKey(const Key('start-selected')),
        matching: find.byType(FilledButton),
      );
      expect(t.widget<FilledButton>(startBtn).onPressed, isNull);

      await t.tap(find.text('Fly'));
      await t.pump();
      await t.tap(find.text('Bench Press'));
      await t.pumpAndSettle();
      expect(find.text('2 hareketle başla'), findsOneWidget);
      await t.tap(find.text('2 hareketle başla'));
      await t.pumpAndSettle();
      final s = c.repo.starts.single;
      // Seçim sırası korunur: ilk işaretlenen ilk hareket.
      expect(s.plan.map((p) => p.exerciseId), ['fly', 'bench']);
      expect(c.location, '/antrenman/odak');
      expect(c.container.read(activeWorkoutControllerProvider).value!.currentExerciseId, 'fly');
    });

    testWidgets('işaret kaldırılır; seçim bölge değişince korunur', (t) async {
      await _pump(t, initial: '/antrenman/basla');
      await t.tap(find.widgetWithText(ChoiceChip, 'Göğüs'));
      await t.pumpAndSettle();
      await t.tap(find.text('Fly'));
      await t.tap(find.text('Pec Deck'));
      await t.pump();
      await t.tap(find.text('Pec Deck'));
      await t.pump();
      expect(find.text('1 hareketle başla'), findsOneWidget);
      await t.tap(find.widgetWithText(ChoiceChip, 'Bacak'));
      await t.pumpAndSettle();
      await t.tap(find.text('Squat'));
      await t.pump();
      expect(find.text('2 hareketle başla'), findsOneWidget);
    });

    testWidgets('arama çalışır', (t) async {
      await _pump(t, initial: '/antrenman/basla');
      await t.enterText(find.byType(TextField), 'fly');
      await t.pumpAndSettle();
      expect(find.text('Fly'), findsOneWidget);
      // Sonuç gelince arama alanı yeniden kurulmaz: metin ve odak yerinde.
      final field = t.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, 'fly');
      expect(field.focusNode.hasFocus, isTrue);
      expect(find.text('Bench Press'), findsNothing);
      await t.enterText(find.byType(TextField), 'zzz');
      await t.pumpAndSettle();
      expect(find.text('Hareket bulunamadı.'), findsOneWidget);
    });

    testWidgets('Boş başla planı boş başlatır', (t) async {
      final c = await _pump(t, initial: '/antrenman/basla');
      await t.tap(find.text('Boş başla'));
      await t.pumpAndSettle();
      expect(c.repo.starts.single.plan, isEmpty);
      expect(c.location, '/antrenman/odak');
    });

    testWidgets('aktif antrenman varken başlamak devam ettirir', (t) async {
      final c = await _pump(
        t,
        initial: '/antrenman/basla',
        active: ActiveWorkout(
          sessionId: 's1',
          startedAt: DateTime.utc(2026, 11, 20, 9),
          plan: _templatePlan,
          sets: const [],
          currentExerciseId: 'squat',
        ),
      );
      await t.tap(find.text('Boş başla'));
      await t.pumpAndSettle();
      expect(c.repo.starts, isEmpty);
      expect(c.location, '/antrenman/odak');
    });

    testWidgets('dokunma alanları ≥ 48 dp, büyük yazıda taşma yok', (t) async {
      await _pump(t, initial: '/antrenman/basla', textScale: 2);
      await t.tap(find.widgetWithText(ChoiceChip, 'Göğüs'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('yatayda büyük yazıyla taşma yok', (t) async {
      await _pump(
        t,
        initial: '/antrenman/basla',
        textScale: 2,
        size: const Size(800, 360),
        brightness: Brightness.light,
      );
      await t.tap(find.widgetWithText(ChoiceChip, 'Göğüs'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });
}
