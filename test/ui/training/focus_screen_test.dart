import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/active_workout_controller.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/screen_awake.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/app/workout_providers.dart';
import 'package:missionfit/domain/active_workout.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/units.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/training/training_routes.dart';

const _bench = PlannedExercise(
  exerciseId: 'bench',
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: 3,
  restSeconds: 90,
);
const _dips = PlannedExercise(
  exerciseId: 'dips',
  tracking: 'reps',
  equipment: 'bodyweight',
  targetSets: 3,
  restSeconds: 90,
);
const _plank = PlannedExercise(
  exerciseId: 'plank',
  tracking: 'duration',
  equipment: 'bodyweight',
  targetSets: 3,
  restSeconds: 60,
);
const _fly = PlannedExercise(
  exerciseId: 'fly',
  tracking: 'weight_reps',
  equipment: 'cable',
  targetSets: 3,
  restSeconds: 90,
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
  'plank': ExerciseOption(
    id: 'plank',
    nameTr: 'Plank',
    tracking: 'duration',
    equipment: 'bodyweight',
    region: BodyRegion.core,
  ),
  'fly': ExerciseOption(
    id: 'fly',
    nameTr: 'Fly',
    tracking: 'weight_reps',
    equipment: 'cable',
    region: BodyRegion.chest,
  ),
};

final _t0 = DateTime.utc(2026, 11, 19, 10);

LoggedSet _set(String ex, int idx, {double? kg = 60, int? reps = 8, int order = 0}) => LoggedSet(
  id: 'old-$ex-$idx',
  exerciseId: ex,
  exerciseOrder: order,
  setIndex: idx,
  reps: reps,
  weightKg: kg,
  completedAt: _t0.subtract(const Duration(days: 3)),
);

final _benchLast = [_set('bench', 1), _set('bench', 2), _set('bench', 3, reps: 7)];

class _FakeRepo extends Fake implements WorkoutRepository {
  _FakeRepo(this.active);
  ActiveWorkout? active;
  int _ids = 0;
  final calls = <String>[];
  WorkoutFinish finishResult = const DiscardedEmpty();

  bool failNextComplete = false;
  bool failNextSelect = false;

  @override
  Future<ActiveWorkout?> loadActive(String userId) async {
    calls.add('load');
    return active;
  }

  @override
  Future<void> savePlan(ActiveWorkout w) async {
    if (failNextSelect) {
      failNextSelect = false;
      throw StateError('disk hatası');
    }
    calls.add('savePlan');
    active = w;
  }

  @override
  Future<LoggedSet> completeSet(ActiveWorkout w, String exerciseId, SetValues v) async {
    if (failNextComplete) {
      failNextComplete = false;
      throw StateError('UNIQUE constraint failed');
    }
    final s = LoggedSet(
      id: 'new-${++_ids}',
      exerciseId: exerciseId,
      exerciseOrder: w.orderFor(exerciseId),
      setIndex: w.nextSetIndex(exerciseId),
      reps: v.reps,
      durationSeconds: v.durationSeconds,
      weightKg: v.weightKg,
      completedAt: _t0,
    );
    active = w.logSet(s);
    calls.add('complete');
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
  Future<DateTime?> restEndFor(String sessionId) async => null;

  @override
  Future<WorkoutFinish> finish(ActiveWorkout w, {required double? bodyWeightKg}) async {
    calls.add('finish');
    active = null;
    return finishResult;
  }
}

class _FakeQueries extends Fake implements WorkoutQueries {
  _FakeQueries(this.benchLast);
  final List<LoggedSet> benchLast;

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
  }) async => exerciseId == 'bench' ? benchLast : const [];

  @override
  Future<List<ExerciseOption>> searchExercises(String query) async => [
    for (final e in _catalog.values)
      if (e.nameTr.toLowerCase().contains(query.trim().toLowerCase())) e,
  ];
}

class _FakeAwake implements ScreenAwake {
  final log = <String>[];
  @override
  Future<void> enable() async => log.add('on');
  @override
  Future<void> disable() async => log.add('off');
}

class _Ctx {
  _Ctx(this.repo, this.awake, this.completed, this.haptics, this.router, this.clock);
  final _FakeRepo repo;
  final _FakeAwake awake;
  final List<String> completed;
  final List<String> haptics;
  final GoRouter router;
  final List<DateTime> clock;
}

Future<_Ctx> _pump(
  WidgetTester tester, {
  List<PlannedExercise> plan = const [_bench, _dips, _plank],
  List<LoggedSet> sets = const [],
  ThemeFamily family = ThemeFamily.mono,
  Brightness brightness = Brightness.dark,
  Size size = const Size(400, 900),
  WeightUnit units = WeightUnit.kg,
  List<LoggedSet>? benchLast,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _FakeRepo(
    ActiveWorkout(
      sessionId: 's1',
      startedAt: _t0,
      plan: plan,
      sets: sets,
      currentExerciseId: plan.first.exerciseId,
    ),
  );
  final awake = _FakeAwake();
  final completed = <String>[];
  final haptics = <String>[];
  final clock = [_t0.add(const Duration(minutes: 24, seconds: 18))];
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
        (ref) => Stream.value(Profile(userId: 'u1', createdAt: 'x', updatedAt: 'x', units: units)),
      ),
      workoutRepositoryProvider.overrideWithValue(repo),
      workoutQueriesProvider.overrideWithValue(_FakeQueries(benchLast ?? _benchLast)),
      screenAwakeProvider.overrideWithValue(awake),
      onSetCompletedProvider.overrideWithValue(completed.add),
      clockProvider.overrideWithValue(() => clock.first),
    ],
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        routerConfig: router,
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
  return _Ctx(repo, awake, completed, haptics, router, clock);
}

String _value(WidgetTester t, String field) =>
    t.widget<Text>(find.byKey(Key('value-$field'))).data!;

Finder _btn(String label) => find.bySemanticsLabel(label);

Finder get _complete => find.widgetWithText(FilledButton, 'Seti tamamla');

bool _enabled(WidgetTester t) => t.widget<FilledButton>(_complete).onPressed != null;

void main() {
  group('Açılış', () {
    testWidgets('ilk hareket, değerler geçen seferden', (t) async {
      await _pump(t);
      expect(find.text('BENCH PRESS'), findsOneWidget);
      expect(find.textContaining('HAREKET 1/3'), findsOneWidget);
      expect(_value(t, 'weight'), '60');
      expect(_value(t, 'reps'), '8');
      expect(find.text('Geçen sefer: 60 × 8 · 60 × 8 · 60 × 7'), findsOneWidget);
      expect(_enabled(t), isTrue);
    });

    testWidgets('Canlı temada başlık olduğu gibi', (t) async {
      await _pump(t, family: ThemeFamily.canli);
      expect(t.widget<Text>(find.byKey(const Key('exercise-title'))).data, 'Bench Press');
      expect(find.textContaining('Hareket 1/3 · Göğüs'), findsOneWidget);
    });

    testWidgets('ilk kez yapılan harekette alanlar boş, Seti tamamla pasif', (t) async {
      await _pump(t, plan: const [_fly]);
      expect(_value(t, 'weight'), '–');
      expect(_value(t, 'reps'), '–');
      expect(_enabled(t), isFalse);
      await t.tap(_btn('ağırlığı artır'));
      await t.tap(_btn('tekrarı artır'));
      await t.pump();
      expect(_value(t, 'weight'), '5'); // kablo adımı
      expect(_value(t, 'reps'), '1');
      expect(_enabled(t), isTrue);
    });
  });

  group('–/+', () {
    testWidgets('+ ekipman adımıyla artırır; basılı tutunca tekrarlar', (t) async {
      await _pump(t);
      await t.tap(_btn('ağırlığı artır'));
      await t.pump();
      expect(_value(t, 'weight'), '62,5');

      final g = await t.startGesture(t.getCenter(_btn('ağırlığı artır')));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      await g.up();
      await t.pump();
      final v = double.parse(_value(t, 'weight').replaceAll(',', '.'));
      expect(v, greaterThanOrEqualTo(70)); // birden çok adım
      final after = _value(t, 'weight');
      await t.pump(const Duration(seconds: 1));
      expect(_value(t, 'weight'), after); // bırakınca durur
    });

    testWidgets('tekrar 1in altına inmez', (t) async {
      await _pump(t);
      for (var i = 0; i < 10; i++) {
        await t.tap(_btn('tekrarı azalt'));
      }
      await t.pump();
      expect(_value(t, 'reps'), '1');
    });
  });

  group('Seti tamamla', () {
    testWidgets('set yazılır, titreşim, kanca; Geri al seti siler', (t) async {
      final ctx = await _pump(t);
      await t.tap(_btn('ağırlığı artır'));
      await t.pump();
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets.single.weightKg, 62.5);
      expect(ctx.repo.active!.sets.single.reps, 8);
      expect(ctx.haptics, ['HapticFeedbackType.lightImpact']);
      expect(ctx.completed, ['bench']);
      expect(find.textContaining('SET 2/3'), findsOneWidget);

      expect(find.text('Geri al'), findsOneWidget);
      await t.tap(find.text('Geri al'));
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets, isEmpty);
      expect(find.textContaining('SET 1/3'), findsOneWidget);
    });

    testWidgets('Geri al 5 sn sonra kaybolur', (t) async {
      await _pump(t);
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(find.text('Geri al'), findsOneWidget);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
      expect(find.text('Geri al'), findsNothing);
    });
  });

  group('Set noktası', () {
    testWidgets('dokununca düzenlenir; Kaydet günceller, Seti sil onaylı siler', (t) async {
      final ctx = await _pump(t, sets: [_set('bench', 1, reps: 8)]);
      await t.tap(_btn('Set 1, tamamlandı, düzenle'));
      await t.pumpAndSettle();
      final sheet = find.byType(BottomSheet);
      expect(sheet, findsOneWidget);
      await t.tap(find.descendant(of: sheet, matching: _btn('tekrarı artır')));
      await t.pump();
      await t.tap(find.descendant(of: sheet, matching: find.text('Kaydet')));
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets.single.reps, 9);
      expect(ctx.repo.calls, contains('update'));

      await t.tap(_btn('Set 1, tamamlandı, düzenle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Seti sil'));
      await t.pumpAndSettle();
      expect(find.text('Set silinsin mi?'), findsOneWidget);
      await t.tap(find.widgetWithText(TextButton, 'Sil'));
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets, isEmpty);
    });
  });

  group('Şerit', () {
    testWidgets('harekete geçilir; tamamlanmamış değişiklik geri dönünce korunur', (t) async {
      await _pump(t);
      await t.tap(_btn('ağırlığı artır'));
      await t.tap(_btn('ağırlığı artır'));
      await t.pump();
      expect(_value(t, 'weight'), '65');

      await t.ensureVisible(find.byKey(const Key('rail-dips')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('rail-dips')));
      await t.pumpAndSettle();
      expect(find.text('DİPS'), findsOneWidget);
      expect(find.byKey(const Key('value-weight')), findsNothing);

      await t.ensureVisible(find.byKey(const Key('rail-bench')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('rail-bench')));
      await t.pumpAndSettle();
      expect(_value(t, 'weight'), '65');
    });

    testWidgets('+ Ekle aramadan hareket ekler; sonda ve seçili', (t) async {
      final ctx = await _pump(t);
      await t.tap(find.byKey(const Key('rail-add')));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'fly');
      await t.pumpAndSettle();
      await t.tap(find.text('Fly'));
      await t.pumpAndSettle();
      expect(ctx.repo.active!.plan.last.exerciseId, 'fly');
      expect(ctx.repo.active!.currentExerciseId, 'fly');
      expect(find.text('FLY'), findsOneWidget);
      double x(String k) => t.getTopLeft(find.byKey(Key(k))).dx;
      expect(x('rail-plank'), lessThan(x('rail-fly')));
      expect(x('rail-fly'), lessThan(x('rail-add')));
    });
  });

  testWidgets('hedef dolunca + Set görünür ve hedefi artırır', (t) async {
    final ctx = await _pump(t, sets: [_set('bench', 1), _set('bench', 2), _set('bench', 3)]);
    expect(find.text('+ Set'), findsOneWidget);
    await t.tap(find.text('+ Set'));
    await t.pumpAndSettle();
    expect(ctx.repo.active!.plan.first.targetSets, 4);
    expect(find.textContaining('SET 4/4'), findsOneWidget);
    expect(_enabled(t), isTrue);
  });

  testWidgets('50. setten sonra + Set gizlenir', (t) async {
    await _pump(t, sets: [for (var i = 1; i <= 50; i++) _set('bench', i)]);
    expect(find.text('+ Set'), findsNothing);
  });

  group('Takip tipine göre', () {
    testWidgets('vücut ağırlığında ağırlık alanı yok', (t) async {
      await _pump(t, plan: const [_dips]);
      expect(_btn('ağırlığı artır'), findsNothing);
      expect(_btn('tekrarı artır'), findsOneWidget);
    });

    testWidgets('süre –/+ 5 sn; Başlat sayar, Durdur alana yazar', (t) async {
      final ctx = await _pump(t, plan: const [_plank]);
      expect(_btn('tekrarı artır'), findsNothing);
      await t.tap(_btn('süreyi artır'));
      await t.pump();
      expect(_value(t, 'duration'), '0:05');
      await t.tap(_btn('süreyi artır'));
      await t.tap(_btn('süreyi azalt'));
      await t.pump();
      expect(_value(t, 'duration'), '0:05');

      await t.tap(find.text('Başlat'));
      await t.pump();
      ctx.clock[0] = ctx.clock[0].add(const Duration(seconds: 42));
      await t.pump(const Duration(seconds: 1));
      expect(_value(t, 'duration'), '0:42');
      await t.tap(find.text('Durdur'));
      await t.pump();
      ctx.clock[0] = ctx.clock[0].add(const Duration(seconds: 10));
      await t.pump(const Duration(seconds: 1));
      expect(_value(t, 'duration'), '0:42');
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets.single.durationSeconds, 42);
      expect(ctx.repo.active!.sets.single.reps, isNull);
    });
  });

  group('Geri tuşu', () {
    testWidgets('Antrenmanı bitir / devam sorar', (t) async {
      final ctx = await _pump(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Antrenmanı bitir?'), findsOneWidget);
      await t.tap(find.text('Devam et'));
      await t.pumpAndSettle();
      expect(find.text('BENCH PRESS'), findsOneWidget);
      expect(ctx.repo.calls, isNot(contains('finish')));
    });

    testWidgets('Bitir: set yoksa kaydedilmedi mesajı, antrenman sekmesine döner', (t) async {
      final ctx = await _pump(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Bitir'));
      await t.pumpAndSettle();
      expect(ctx.repo.calls, contains('finish'));
      expect(find.text('ANTRENMAN'), findsOneWidget);
      expect(find.text('Hiç set yok, antrenman kaydedilmedi.'), findsOneWidget);
    });
  });

  testWidgets('ekran açık kalır; çıkınca kapanır', (t) async {
    final ctx = await _pump(t);
    expect(ctx.awake.log, ['on']);
    ctx.router.go('/antrenman');
    await t.pumpAndSettle();
    expect(ctx.awake.log, ['on', 'off']);
  });

  testWidgets('–/+ semantik adları ve boyutları ≥ 60 dp', (t) async {
    await _pump(t);
    for (final label in ['ağırlığı azalt', 'ağırlığı artır', 'tekrarı azalt', 'tekrarı artır']) {
      final size = t.getSize(_btn(label));
      expect(size.width, greaterThanOrEqualTo(60), reason: label);
      expect(size.height, greaterThanOrEqualTo(60), reason: label);
    }
    expect(t.getSize(_complete).height, greaterThanOrEqualTo(60));
    expect(find.text('00:24:18'), findsOneWidget);
  });

  testWidgets('büyük yazıda taşma yok, rakamlar küçülmez', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(t);
    expect(t.takeException(), isNull);
    final style = t.widget<Text>(find.byKey(const Key('value-weight'))).style!;
    expect(style.fontSize, 44);
    expect(style.fontFamily, 'Doto');
  });

  for (final size in const [Size(360, 640), Size(800, 400), Size(1024, 1366)]) {
    for (final family in ThemeFamily.values) {
      for (final b in Brightness.values) {
        testWidgets('$size ${family.name} ${b.name}: taşma yok', (t) async {
          await _pump(t, size: size, family: family, brightness: b);
          expect(t.takeException(), isNull);
          expect(_complete, findsOneWidget);
        });
      }
    }
  }

  group('Fix 1: lb', () {
    testWidgets('boştan + ile 5, 10, 15, 20 (kayma yok)', (t) async {
      await _pump(t, plan: const [_fly], units: WeightUnit.lb);
      final seen = <String>[];
      for (var i = 0; i < 4; i++) {
        await t.tap(_btn('ağırlığı artır'));
        await t.pump();
        seen.add(_value(t, 'weight'));
      }
      // kablo lb adımı 10; barbell'i aşağıda deneriz
      expect(seen, ['10', '20', '30', '40']);
    });

    testWidgets('135 lb ön dolum (61,2 kg) 135 gösterir; + 140; tamamlanınca kg yazılır', (
      t,
    ) async {
      final ctx = await _pump(
        t,
        units: WeightUnit.lb,
        benchLast: [_set('bench', 1, kg: 61.2), _set('bench', 2, kg: 61.2)],
      );
      expect(_value(t, 'weight'), '135');
      expect(find.text('LB'), findsOneWidget);
      expect(find.text('Geçen sefer: 135 × 8 · 135 × 8'), findsOneWidget);
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets.single.weightKg, 61.2);
      await t.tap(_btn('ağırlığı artır'));
      await t.pump();
      expect(_value(t, 'weight'), '140');
      for (var i = 0; i < 4; i++) {
        await t.tap(_btn('ağırlığı artır'));
      }
      await t.pump();
      expect(_value(t, 'weight'), '160');
    });

    testWidgets('barbell lb: boştan 5, 10, 15, 20', (t) async {
      await _pump(t, units: WeightUnit.lb, benchLast: const []);
      final seen = <String>[];
      for (var i = 0; i < 4; i++) {
        await t.tap(_btn('ağırlığı artır'));
        await t.pump();
        seen.add(_value(t, 'weight'));
      }
      expect(seen, ['5', '10', '15', '20']);
    });
  });

  testWidgets('Fix 2: tamamlanan set noktasından silinip Geri al basılırsa önceki set kalır', (
    t,
  ) async {
    final ctx = await _pump(t, sets: [_set('bench', 1)]);
    await t.tap(_complete);
    await t.pumpAndSettle();
    expect(ctx.repo.active!.sets, hasLength(2));
    await t.tap(_btn('Set 2, tamamlandı, düzenle'));
    await t.pumpAndSettle();
    await t.tap(find.text('Seti sil'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Sil'));
    await t.pumpAndSettle();
    expect(ctx.repo.active!.sets.map((s) => s.id), ['old-bench-1']);
    expect(find.text('Geri al'), findsOneWidget);
    await t.tap(find.text('Geri al'));
    await t.pumpAndSettle();
    expect(ctx.repo.active!.sets.map((s) => s.id), ['old-bench-1']);
  });

  group('Fix 3: hata kurtarma', () {
    testWidgets('completeSet bir kez hata verir: mesaj, durum yenilenir, ikinci dokunuş yazar', (
      t,
    ) async {
      final ctx = await _pump(t);
      // Bellekteki durum eskidi: diskte zaten bir set var.
      ctx.repo.active = ctx.repo.active!.logSet(_set('bench', 1));
      ctx.repo.failNextComplete = true;
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(find.text('Set kaydedilemedi. Tekrar dene.'), findsOneWidget);
      expect(ctx.repo.calls.where((c) => c == 'load'), hasLength(2));
      expect(find.textContaining('SET 2/3'), findsOneWidget);
      await t.tap(_complete);
      await t.pumpAndSettle();
      expect(ctx.repo.active!.sets.map((s) => s.setIndex), [1, 2]);
      expect(t.takeException(), isNull);
    });

    testWidgets('şeritte geçiş hatası yakalanır ve gösterilir', (t) async {
      final ctx = await _pump(t);
      ctx.repo.failNextSelect = true;
      await t.ensureVisible(find.byKey(const Key('rail-dips')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('rail-dips')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('İşlem yapılamadı. Tekrar dene.'), findsOneWidget);
    });
  });
}
