import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/home.dart';
import 'package:missionfit/domain/muscle_coverage.dart';
import 'package:missionfit/domain/nutrition.dart';
import 'package:missionfit/domain/tasks.dart';
import 'package:missionfit/domain/week.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

DateTime utc(String iso) => DateTime.parse(iso).toUtc();

HomeSummary run({
  DateTime? now,
  int? calorieTarget = 2200,
  List<NutritionEntry> food = const [],
  List<HomeSessionInput> sessions = const [],
  ActiveSessionInput? active,
  Coverage? coverage,
  List<TaskDef> tasks = const [],
  List<TaskCompletion> completions = const [],
}) => homeSummary(
  HomeSummaryInput(
    now: now ?? utc('2026-11-04T10:00:00Z'), // Çarşamba 13:00 İstanbul
    timeZone: 'Europe/Istanbul',
    weekStartsOn: WeekStartsOn.monday,
    calorieTarget: calorieTarget,
    foodEntriesToday: food,
    weekSessions: sessions,
    activeSession: active,
    weekCoverage: coverage,
    tasks: tasks,
    completions: completions,
  ),
);

NutritionEntry kcal(Meal meal, double k, [double p = 0, double c = 0, double f = 0]) =>
    NutritionEntry(meal: meal, kcal: k, protein: p, carb: c, fat: f);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('homeSummary', () {
    test('boş gün: davet eden metin, haftalık kart', () {
      final s = run();
      expect(s.today, '2026-11-04');
      expect(s.week.weekKey, '2026-11-02');
      expect(s.summaryText, 'Bugün henüz kayıt yok. Güne güzel bir başlangıç yapabilirsin.');
      expect(
        s.workout,
        const WeeklyWorkoutCard(sessionsThisWeek: 0, trainedRegions: [], untrainedRegions: []),
      );
    });

    test('spec örneği: "Bugün 1.850 kcal aldın, 420 kcal tahmini yaktın."', () {
      final s = run(
        food: [kcal(Meal.lunch, 1850, 80, 200, 60)],
        sessions: const [
          HomeSessionInput('2026-11-04', SessionStatus.completed, 420),
          HomeSessionInput('2026-11-03', SessionStatus.completed, 300),
        ],
      );
      expect(
        s.summaryText,
        'Bugün 1.850 kcal aldın, 420 kcal tahmini yaktın. Hedefine 350 kcal var.',
      );
      expect(s.burnedKcal, 420);
      expect((s.workout as WeeklyWorkoutCard).sessionsThisWeek, 2);
    });

    test('hedef aşımı nötr dille', () {
      final s = run(food: [kcal(Meal.dinner, 2500)]);
      expect(s.summaryText, 'Bugün 2.500 kcal aldın. Günlük hedefinin 300 kcal üzerindesin.');
    });

    test('aktif oturum: süre başlangıçtan, canlı kalori yakılana eklenir', () {
      final s = run(
        active: ActiveSessionInput(
          startedAt: utc('2026-11-04T09:20:00Z'),
          name: 'Bacak',
          currentExerciseName: 'Squat',
          liveKcal: 150,
        ),
      );
      expect(
        s.workout,
        const ActiveWorkoutCard(
          name: 'Bacak',
          elapsedSeconds: 2400,
          currentExerciseName: 'Squat',
          liveKcal: 150,
        ),
      );
      expect(s.burnedKcal, 150);
      expect(s.summaryText, 'Bugün 150 kcal tahmini yaktın.');
    });

    test('haftalık kart: geçen haftanın oturumu sayılmaz, bölgeler kapsamdan', () {
      final coverage = muscleCoverage(
        sets: const [CoverageSet('squat', '2026-11-03')],
        exerciseMuscles: const [ExerciseMuscle('squat', 'quads', MuscleRole.primary)],
        muscles: const [
          MuscleInfo('quads', BodyRegion.legs),
          MuscleInfo('chest', BodyRegion.chest),
        ],
        window: weekWindowForDate('2026-11-04', WeekStartsOn.monday),
      );
      final s = run(
        coverage: coverage,
        sessions: const [
          HomeSessionInput('2026-11-01', SessionStatus.completed, 200),
          HomeSessionInput('2026-11-03', SessionStatus.completed, 200),
          HomeSessionInput('2026-11-03', SessionStatus.abandoned, null),
        ],
      );
      final w = s.workout as WeeklyWorkoutCard;
      expect(w.sessionsThisWeek, 1);
      expect(w.trainedRegions, [BodyRegion.legs]);
      expect(w.untrainedRegions, contains(BodyRegion.chest));
    });

    test('görevler: saat sırası, geciken ve tamamlanan sayıları', () {
      TaskDef t(String id, String? time) => TaskDef(
        id: id,
        title: id,
        time: time,
        repeatRule: const Daily(),
        startDate: '2026-11-01',
        isActive: true,
      );
      final s = run(
        tasks: [t('aksam', '20:00'), t('sabah', '08:00'), t('ogle', '12:30'), t('saatsiz', null)],
        completions: const [TaskCompletion('ogle', '2026-11-04')],
      );
      expect(s.tasks.map((x) => x.taskId).toList(), ['sabah', 'ogle', 'aksam', 'saatsiz']);
      expect(s.tasksDone, 1);
      expect(s.tasksOverdue, 1);
    });

    test('gece yarısı sonrası yeni gün: dünün kayıtları bugüne sayılmaz', () {
      final s = run(
        now: utc('2026-11-04T21:05:00Z'),
        sessions: const [HomeSessionInput('2026-11-04', SessionStatus.completed, 300)],
      );
      expect(s.today, '2026-11-05');
      expect(s.burnedKcal, 0);
    });

    test('hedef yok: kalan metni eklenmez', () {
      final s = run(calorieTarget: null, food: [kcal(Meal.snack, 300)]);
      expect(s.summaryText, 'Bugün 300 kcal aldın.');
    });
  });
}
