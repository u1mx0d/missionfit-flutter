/// Antrenman özeti. RN `src/domain/workoutSummary.ts` karşılığı.
/// Hacim = Σ kg × tekrar (yalnızca ikisi de girilmiş setler).
library;

import 'js_math.dart';
import 'workout_kcal.dart';

class SummarySet {
  const SummarySet({
    required this.exerciseId,
    required this.met,
    this.reps,
    this.weightKg,
    this.durationSeconds,
  });
  final String exerciseId;
  final double met;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
}

class WorkoutSummary {
  const WorkoutSummary({
    required this.durationSeconds,
    required this.durationCapped,
    required this.kcal,
    required this.volumeKg,
    required this.setCount,
    required this.exerciseCount,
  });
  final int durationSeconds;
  final bool durationCapped;
  final int? kcal;
  final double volumeKg;
  final int setCount;
  final int exerciseCount;

  @override
  bool operator ==(Object o) =>
      o is WorkoutSummary &&
      o.durationSeconds == durationSeconds &&
      o.durationCapped == durationCapped &&
      o.kcal == kcal &&
      o.volumeKg == volumeKg &&
      o.setCount == setCount &&
      o.exerciseCount == exerciseCount;
  @override
  int get hashCode =>
      Object.hash(durationSeconds, durationCapped, kcal, volumeKg, setCount, exerciseCount);
}

double volumeKg(Iterable<({int? reps, double? weightKg})> sets) {
  var total = 0.0;
  for (final s in sets) {
    final r = s.reps, w = s.weightKg;
    if (r != null && r > 0 && w != null && w > 0) total += w * r;
  }
  return jsRound(total * 10) / 10;
}

WorkoutSummary summarizeWorkout({
  required DateTime startedAt,
  required DateTime endedAt,
  required double? weightKg,
  required List<SummarySet> sets,
}) {
  final kcal = estimateWorkoutKcal(
    startedAt: startedAt,
    endedAt: endedAt,
    weightKg: weightKg,
    completedSetMets: [for (final s in sets) s.met],
  );
  final duration = elapsedSeconds(startedAt, endedAt);
  const max = maxSessionHours * 3600;
  return WorkoutSummary(
    durationSeconds: kcal is KcalOk ? kcal.durationSeconds : (duration < max ? duration : max),
    durationCapped: kcal is KcalOk ? kcal.durationCapped : duration > max,
    kcal: kcal is KcalOk ? kcal.kcal : null,
    volumeKg: volumeKg([for (final s in sets) (reps: s.reps, weightKg: s.weightKg)]),
    setCount: sets.length,
    exerciseCount: {for (final s in sets) s.exerciseId}.length,
  );
}
