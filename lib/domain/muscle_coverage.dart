/// Haftalık kas kapsamı (algoritma 4). RN `src/domain/muscleCoverage.ts` karşılığı.
///
/// Kas başına "ağırlıklı set": birincil 1.0, ikincil 0.5. Durum: none (0), low, adequate
/// (≥ adequateSets, varsayılan 4). Yalnızca penceredeki local_date'e sahip setler sayılır.
library;

import 'dates.dart';
import 'week.dart';

enum BodyRegion { chest, back, shoulders, arms, core, legs }

const bodyRegions = BodyRegion.values;

enum MuscleRole { primary, secondary }

enum CoverageStatus { none, low, adequate }

class MuscleInfo {
  const MuscleInfo(this.slug, this.region);
  final String slug;
  final BodyRegion region;
}

class ExerciseMuscle {
  const ExerciseMuscle(this.exerciseId, this.muscle, this.role);
  final String exerciseId;
  final String muscle;
  final MuscleRole role;
}

class CoverageSet {
  const CoverageSet(this.exerciseId, this.localDate);
  final String exerciseId;
  final LocalDate localDate;
}

class CoverageThresholds {
  const CoverageThresholds({
    this.primaryWeight = 1,
    this.secondaryWeight = 0.5,
    this.adequateSets = 4,
  });
  final double primaryWeight;
  final double secondaryWeight;
  final double adequateSets;
}

const defaultThresholds = CoverageThresholds();

typedef CoverageEntry = ({double sets, CoverageStatus status});

class Coverage {
  const Coverage({required this.muscles, required this.regions, required this.totalSets});
  final Map<String, CoverageEntry> muscles;
  final Map<BodyRegion, CoverageEntry> regions;

  /// Penceredeki toplam (ağırlıksız) set sayısı
  final int totalSets;
}

CoverageStatus statusFor(double sets, double adequateSets) {
  if (sets <= 0) return CoverageStatus.none;
  return sets >= adequateSets ? CoverageStatus.adequate : CoverageStatus.low;
}

Map<String, List<ExerciseMuscle>> indexExerciseMuscles(List<ExerciseMuscle> rows) {
  final map = <String, List<ExerciseMuscle>>{};
  for (final row in rows) {
    (map[row.exerciseId] ??= []).add(row);
  }
  return map;
}

Coverage muscleCoverage({
  required List<CoverageSet> sets,
  required List<ExerciseMuscle> exerciseMuscles,
  required List<MuscleInfo> muscles,
  required DateRange window,
  CoverageThresholds? thresholds,
}) {
  final t = thresholds ?? defaultThresholds;
  final byExercise = indexExerciseMuscles(exerciseMuscles);
  final muscleSets = {for (final m in muscles) m.slug: 0.0};

  var totalSets = 0;
  for (final set in sets) {
    if (!isInWindow(set.localDate, window)) continue;
    totalSets += 1;
    for (final e in byExercise[set.exerciseId] ?? const <ExerciseMuscle>[]) {
      if (!muscleSets.containsKey(e.muscle)) continue; // bilinmeyen kas: yok say
      final w = e.role == MuscleRole.primary ? t.primaryWeight : t.secondaryWeight;
      muscleSets[e.muscle] = muscleSets[e.muscle]! + w;
    }
  }

  final result = <String, CoverageEntry>{};
  final regionSets = {for (final r in bodyRegions) r: 0.0};
  for (final m in muscles) {
    final s = muscleSets[m.slug] ?? 0;
    result[m.slug] = (sets: s, status: statusFor(s, t.adequateSets));
    regionSets[m.region] = regionSets[m.region]! + s;
  }
  return Coverage(
    muscles: result,
    regions: {
      for (final r in bodyRegions)
        r: (sets: regionSets[r]!, status: statusFor(regionSets[r]!, t.adequateSets)),
    },
    totalSets: totalSets,
  );
}

/// 5 seviyeli silüet: 0 Çalışılmadı, 1 Çok az, 2 Az, 3 Yeterli, 4 Yüksek.
typedef IntensityLevel = int;

class IntensitySteps {
  const IntensitySteps({required this.low, required this.adequate, required this.high});
  final double low;
  final double adequate;
  final double high;
}

const weeklyIntensity = IntensitySteps(low: 2, adequate: 4, high: 10);
const sessionIntensity = IntensitySteps(low: 1, adequate: 2, high: 4);

IntensityLevel intensityLevel(double sets, [IntensitySteps steps = weeklyIntensity]) {
  if (!(sets > 0)) return 0; // NaN da buraya düşer
  if (sets < steps.low) return 1;
  if (sets < steps.adequate) return 2;
  if (sets < steps.high) return 3;
  return 4;
}

Map<String, IntensityLevel> intensityByMuscle(
  Coverage coverage, [
  IntensitySteps steps = weeklyIntensity,
]) => {for (final e in coverage.muscles.entries) e.key: intensityLevel(e.value.sets, steps)};
