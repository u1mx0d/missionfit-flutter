import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/feedback.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/week.dart';
import 'package:missionfit/domain/workout_kcal.dart';

const muscles = [
  MuscleInfo('chest', BodyRegion.chest),
  MuscleInfo('triceps', BodyRegion.arms),
  MuscleInfo('biceps', BodyRegion.arms),
  MuscleInfo('shoulders', BodyRegion.shoulders),
  MuscleInfo('lats', BodyRegion.back),
  MuscleInfo('traps', BodyRegion.back),
  MuscleInfo('abs', BodyRegion.core),
  MuscleInfo('quads', BodyRegion.legs),
  MuscleInfo('glutes', BodyRegion.legs),
];

const em = [
  ExerciseMuscle('bench', 'chest', MuscleRole.primary),
  ExerciseMuscle('bench', 'triceps', MuscleRole.secondary),
  ExerciseMuscle('bench', 'shoulders', MuscleRole.secondary),
  ExerciseMuscle('row', 'lats', MuscleRole.primary),
  ExerciseMuscle('row', 'biceps', MuscleRole.secondary),
  ExerciseMuscle('squat', 'quads', MuscleRole.primary),
  ExerciseMuscle('squat', 'glutes', MuscleRole.primary),
  ExerciseMuscle('plank', 'abs', MuscleRole.primary),
  ExerciseMuscle('press', 'shoulders', MuscleRole.primary),
];

final week = weekWindowForDate('2026-11-04', WeekStartsOn.monday); // 02.11 – 08.11

List<CoverageSet> sets(String exerciseId, int n, [String localDate = '2026-11-03']) =>
    List.generate(n, (_) => CoverageSet(exerciseId, localDate));

DateTime utc(String iso) => DateTime.parse(iso).toUtc();

Coverage cover(List<CoverageSet> s, {CoverageThresholds? thresholds, List<ExerciseMuscle>? ems}) =>
    muscleCoverage(
      sets: s,
      exerciseMuscles: ems ?? em,
      muscles: muscles,
      window: week,
      thresholds: thresholds,
    );

const templates = [
  TemplateForSuggestion(
    id: 't-push',
    nameTr: 'Göğüs - Triceps',
    level: Level.intermediate,
    exercises: [(exerciseId: 'bench', sets: 4)],
  ),
  TemplateForSuggestion(
    id: 't-legs',
    nameTr: 'Bacak',
    level: Level.intermediate,
    exercises: [(exerciseId: 'squat', sets: 4)],
  ),
  TemplateForSuggestion(
    id: 't-full',
    nameTr: 'Full Body (Başlangıç)',
    level: Level.beginner,
    exercises: [
      (exerciseId: 'squat', sets: 2),
      (exerciseId: 'row', sets: 2),
      (exerciseId: 'plank', sets: 2),
    ],
  ),
  TemplateForSuggestion(
    id: 't-adv',
    nameTr: 'Kuvvet (İleri)',
    level: Level.advanced,
    exercises: [(exerciseId: 'squat', sets: 5), (exerciseId: 'row', sets: 5)],
  ),
];

void main() {
  group('estimateWorkoutKcal', () {
    final start = utc('2026-11-02T18:00:00Z');

    test('MET × kg × saat, set ağırlıklı ortalama MET', () {
      final r = estimateWorkoutKcal(
        startedAt: start,
        endedAt: utc('2026-11-02T19:00:00Z'),
        weightKg: 80,
        completedSetMets: [...List.filled(6, 5.0), ...List.filled(3, 3.5)],
      );
      expect(
        r,
        const KcalOk(kcal: 360, averageMet: 4.5, durationSeconds: 3600, durationCapped: false),
      );
    });

    test('sıfır set → 0 kcal', () {
      final r = estimateWorkoutKcal(
        startedAt: start,
        endedAt: utc('2026-11-02T19:00:00Z'),
        weightKg: 80,
        completedSetMets: [],
      );
      expect((r as KcalOk).kcal, 0);
    });

    test('tek set', () {
      final r = estimateWorkoutKcal(
        startedAt: start,
        endedAt: utc('2026-11-02T18:15:00Z'),
        weightKg: 70,
        completedSetMets: [6],
      );
      expect((r as KcalOk).kcal, 105);
    });

    test('kilo eksik → tahmin yok', () {
      expect(
        estimateWorkoutKcal(
          startedAt: start,
          endedAt: start,
          weightKg: null,
          completedSetMets: [5],
        ),
        const KcalMissingWeight(),
      );
    });

    test('unutulan oturum 4 saatle sınırlanır', () {
      final r = estimateWorkoutKcal(
        startedAt: start,
        endedAt: utc('2026-11-03T08:00:00Z'),
        weightKg: 80,
        completedSetMets: [4],
      ) as KcalOk;
      expect(r.durationCapped, isTrue);
      expect(r.kcal, 4 * 80 * 4);
    });

    test('gece yarısını geçen oturum normal hesaplanır', () {
      final r = estimateWorkoutKcal(
        startedAt: utc('2026-11-02T20:30:00Z'),
        endedAt: utc('2026-11-02T21:30:00Z'),
        weightKg: 60,
        completedSetMets: [5],
      ) as KcalOk;
      expect(r.kcal, 300);
    });

    test('saat geri giderse süre negatif olmaz', () {
      expect(elapsedSeconds(utc('2026-11-02T10:00:00Z'), utc('2026-11-02T09:59:00Z')), 0);
    });
  });

  group('muscleCoverage', () {
    test('birincil 1, ikincil 0.5 ağırlık; durumlar', () {
      final c = cover(sets('bench', 4));
      expect(c.muscles['chest'], (sets: 4.0, status: CoverageStatus.adequate));
      expect(c.muscles['triceps'], (sets: 2.0, status: CoverageStatus.low));
      expect(c.muscles['lats'], (sets: 0.0, status: CoverageStatus.none));
      expect(c.regions[BodyRegion.chest]!.status, CoverageStatus.adequate);
      expect(c.regions[BodyRegion.legs]!.status, CoverageStatus.none);
      expect(c.totalSets, 4);
    });

    test('pencere dışındaki setler sayılmaz (haftalık reset veri silmez)', () {
      final c = cover([
        ...sets('squat', 5, '2026-11-01'),
        ...sets('squat', 2, '2026-11-09'),
        ...sets('squat', 1, '2026-11-08'),
      ]);
      expect(c.totalSets, 1);
      expect(c.muscles['quads']!.sets, 1);
    });

    test('sıfır set: her şey none', () {
      final c = cover([]);
      expect(c.regions.values.every((r) => r.status == CoverageStatus.none), isTrue);
    });

    test('eşik yapılandırılabilir', () {
      final c = cover(sets('bench', 4), thresholds: const CoverageThresholds(adequateSets: 8));
      expect(c.muscles['chest']!.status, CoverageStatus.low);
    });

    test('eşlemesi olmayan egzersiz ve bilinmeyen kas çökertmez', () {
      final c = cover(
        sets('unknown', 3),
        ems: [...em, const ExerciseMuscle('unknown', 'neck', MuscleRole.primary)],
      );
      expect(c.totalSets, 3);
      expect(c.regions[BodyRegion.chest]!.sets, 0);
    });
  });

  group('buildFeedback', () {
    Feedback fb(Coverage c, [Level? level]) => buildFeedback(
      coverage: c,
      templates: templates,
      exerciseMuscles: em,
      muscles: muscles,
      userLevel: level,
    );
    Suggestion? sg(Coverage c, [Level? level]) => suggestTemplate(
      coverage: c,
      templates: templates,
      exerciseMuscles: em,
      muscles: muscles,
      userLevel: level,
    );

    test('tekil ve çoklu bölge metni', () {
      final allButLegs = cover([
        ...sets('bench', 4),
        ...sets('row', 8),
        ...sets('plank', 4),
        ...sets('press', 4),
      ]);
      final f = fb(allButLegs, Level.intermediate);
      expect(f.untrainedRegions, [BodyRegion.legs]);
      expect(f.message, 'Bu hafta henüz bacak çalışmadın.');
      expect(f.suggestion?.templateId, 't-legs');
      expect(f.suggestion?.message, '"Bacak" antrenmanı bacak bölgesini çalıştırır.');

      final f2 = fb(cover(sets('bench', 4)));
      expect(f2.message, 'Bu hafta henüz sırt, karın ve bacak çalışmadın.');
    });

    test('kapsamı en çok artıran şablon; seviye filtresi', () {
      final onlyChest = cover(sets('bench', 4));
      expect(sg(onlyChest)?.templateId, 't-adv');
      final s = sg(onlyChest, Level.beginner);
      expect(s?.templateId, 't-full');
      expect(s?.coversRegions, [BodyRegion.back, BodyRegion.core, BodyRegion.legs]);
      expect(
        s?.message,
        '"Full Body (Başlangıç)" antrenmanı sırt, karın ve bacak bölgelerini çalıştırır.',
      );
    });

    test('hiç antrenman yoksa davet eden metin', () {
      final f = fb(cover([]), Level.beginner);
      expect(f.message, contains('henüz antrenman kaydın yok'));
      expect(f.suggestion?.templateId, 't-full');
    });

    test('tüm bölgeler çalışıldıysa öneri yok', () {
      final f = fb(
        cover([
          ...sets('bench', 4),
          ...sets('row', 4),
          ...sets('plank', 4),
          ...sets('press', 4),
          ...sets('squat', 4),
        ]),
      );
      expect(f.untrainedRegions, isEmpty);
      expect(f.suggestion, isNull);
      expect(f.message, contains('tüm bölgeleri'));
    });

    test('suçlayıcı dil içermez', () {
      final f = fb(cover(sets('bench', 1)));
      expect(
        f.message,
        isNot(matches(RegExp('başarısız|maalesef|yetersiz|tembel|açığın', caseSensitive: false))),
      );
    });
  });
}
