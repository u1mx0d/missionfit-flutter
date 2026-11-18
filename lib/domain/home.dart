/// Ana sayfa özeti (algoritma 10). RN `src/domain/home.ts` karşılığı.
///
/// Diğer algoritmaların bugüne/bu haftaya göre birleşimi ve tek cümlelik özet metni.
/// Dil nötrdür: hedef aşımında suçlayıcı ifade yok.
library;

import 'dates.dart';
import 'format.dart';
import 'js_math.dart';
import 'muscle_coverage.dart';
import 'nutrition.dart';
import 'tasks.dart';
import 'week.dart';
import 'workout_kcal.dart';

enum SessionStatus { active, completed, abandoned }

class HomeSessionInput {
  const HomeSessionInput(this.localDate, this.status, this.estimatedKcal);
  final LocalDate localDate;
  final SessionStatus status;
  final double? estimatedKcal;
}

class ActiveSessionInput {
  const ActiveSessionInput({
    required this.startedAt,
    required this.name,
    required this.currentExerciseName,
    required this.liveKcal,
  });
  final DateTime startedAt;
  final String name;
  final String? currentExerciseName;

  /// estimateWorkoutKcal ile şimdiye kadar hesaplanan canlı tahmin
  final double? liveKcal;
}

class HomeSummaryInput {
  const HomeSummaryInput({
    required this.now,
    required this.timeZone,
    required this.weekStartsOn,
    required this.calorieTarget,
    required this.foodEntriesToday,
    required this.weekSessions,
    required this.activeSession,
    required this.weekCoverage,
    required this.tasks,
    required this.completions,
  });
  final DateTime now;
  final String timeZone;
  final WeekStartsOn weekStartsOn;
  final int? calorieTarget;
  final List<NutritionEntry> foodEntriesToday;
  final List<HomeSessionInput> weekSessions;
  final ActiveSessionInput? activeSession;
  final Coverage? weekCoverage;
  final List<TaskDef> tasks;
  final List<TaskCompletion> completions;
}

sealed class WorkoutCard {
  const WorkoutCard();
}

final class ActiveWorkoutCard extends WorkoutCard {
  const ActiveWorkoutCard({
    required this.name,
    required this.elapsedSeconds,
    required this.currentExerciseName,
    required this.liveKcal,
  });
  final String name;
  final int elapsedSeconds;
  final String? currentExerciseName;
  final double? liveKcal;

  @override
  bool operator ==(Object other) =>
      other is ActiveWorkoutCard &&
      other.name == name &&
      other.elapsedSeconds == elapsedSeconds &&
      other.currentExerciseName == currentExerciseName &&
      other.liveKcal == liveKcal;
  @override
  int get hashCode => Object.hash(name, elapsedSeconds, currentExerciseName, liveKcal);
}

final class WeeklyWorkoutCard extends WorkoutCard {
  const WeeklyWorkoutCard({
    required this.sessionsThisWeek,
    required this.trainedRegions,
    required this.untrainedRegions,
  });
  final int sessionsThisWeek;
  final List<BodyRegion> trainedRegions;
  final List<BodyRegion> untrainedRegions;

  @override
  bool operator ==(Object other) =>
      other is WeeklyWorkoutCard &&
      other.sessionsThisWeek == sessionsThisWeek &&
      other.trainedRegions.join() == trainedRegions.join() &&
      other.untrainedRegions.join() == untrainedRegions.join();
  @override
  int get hashCode => Object.hash(sessionsThisWeek, trainedRegions.join(), untrainedRegions.join());
}

class HomeSummary {
  const HomeSummary({
    required this.today,
    required this.week,
    required this.nutrition,
    required this.burnedKcal,
    required this.workout,
    required this.tasks,
    required this.tasksDone,
    required this.tasksOverdue,
    required this.summaryText,
  });
  final LocalDate today;
  final WeekWindow week;
  final DailyNutritionSummary nutrition;
  final int burnedKcal;
  final WorkoutCard workout;
  final List<TaskOccurrence> tasks;
  final int tasksDone;
  final int tasksOverdue;
  final String summaryText;
}

String buildSummaryText(double consumed, double burned, DailyNutritionSummary nutrition) {
  final c = jsRound(consumed), b = jsRound(burned);
  if (c <= 0 && b <= 0) return 'Bugün henüz kayıt yok. Güne güzel bir başlangıç yapabilirsin.';

  final parts = <String>[];
  if (c > 0 && b > 0) {
    parts.add('Bugün ${formatInt(c)} kcal aldın, ${formatInt(b)} kcal tahmini yaktın.');
  } else if (c > 0) {
    parts.add('Bugün ${formatInt(c)} kcal aldın.');
  } else {
    parts.add('Bugün ${formatInt(b)} kcal tahmini yaktın.');
  }

  if (c > 0 && nutrition.target != null) {
    final remaining = nutrition.remaining;
    if (nutrition.over > 0) {
      parts.add('Günlük hedefinin ${formatInt(nutrition.over)} kcal üzerindesin.');
    } else if (remaining != null && remaining > 0) {
      parts.add('Hedefine ${formatInt(remaining)} kcal var.');
    } else {
      parts.add('Günlük hedefine ulaştın.');
    }
  }
  return parts.join(' ');
}

double _nonNeg(double? v) => v == null || v < 0 ? 0 : v;

HomeSummary homeSummary(HomeSummaryInput input) {
  final today = localDateInZone(input.now, input.timeZone);
  final week = weekWindow(input.now, input.weekStartsOn, input.timeZone);
  final nutrition = dailyNutritionSummary(input.foodEntriesToday, input.calorieTarget);

  final burnedCompleted = input.weekSessions
      .where((s) => s.status == SessionStatus.completed && s.localDate == today)
      .fold<double>(0, (sum, s) => sum + _nonNeg(s.estimatedKcal));
  final active = input.activeSession;
  final burnedKcal = jsRound(burnedCompleted + _nonNeg(active?.liveKcal));

  final WorkoutCard workout;
  if (active != null) {
    workout = ActiveWorkoutCard(
      name: active.name,
      elapsedSeconds: elapsedSeconds(active.startedAt, input.now),
      currentExerciseName: active.currentExerciseName,
      liveKcal: active.liveKcal,
    );
  } else {
    final regions = input.weekCoverage?.regions;
    workout = WeeklyWorkoutCard(
      sessionsThisWeek: input.weekSessions
          .where((s) => s.status == SessionStatus.completed && isInWindow(s.localDate, week))
          .length,
      trainedRegions: regions == null
          ? const []
          : [
              for (final r in bodyRegions)
                if (regions[r]?.status != CoverageStatus.none) r,
            ],
      untrainedRegions: regions == null
          ? const []
          : [
              for (final r in bodyRegions)
                if (regions[r]?.status == CoverageStatus.none) r,
            ],
    );
  }

  final tasks = tasksForDate(
    input.tasks,
    input.completions,
    today,
    nowInZone(input.now, input.timeZone),
  );

  return HomeSummary(
    today: today,
    week: week,
    nutrition: nutrition,
    burnedKcal: burnedKcal,
    workout: workout,
    tasks: tasks,
    tasksDone: tasks.where((t) => t.completed).length,
    tasksOverdue: tasks.where((t) => t.overdue).length,
    summaryText: buildSummaryText(nutrition.totals.kcal, burnedKcal.toDouble(), nutrition),
  );
}
