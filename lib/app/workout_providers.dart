import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout/workout_queries.dart';
import '../data/workout/workout_repository.dart';
import '../domain/active_workout.dart';
import '../domain/week.dart';
import 'profile_controller.dart';
import 'providers.dart';
import 'today_provider.dart';

// UI katmanı veri katmanını içe aktaramaz; sorgu modelleri buradan açılır.
export '../data/workout/workout_queries.dart'
    show ExerciseOption, RecentWorkout, WeeklyBodyMap, WorkoutQueries;
export '../data/workout/workout_repository.dart'
    show DiscardedEmpty, Saved, WorkoutFinish, WorkoutRepository;

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(databaseProvider), ref.watch(outboxProvider)),
);

final workoutQueriesProvider = Provider<WorkoutQueries>(
  (ref) => WorkoutQueries(ref.watch(databaseProvider)),
);

/// Bu haftanın maketi: profilin hafta başlangıcı ve saat dilimine göre, günün tarihiyle yenilenir.
final weeklyBodyMapProvider = StreamProvider<WeeklyBodyMap>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(WeeklyBodyMap.empty);
  final weekStartsOn =
      ref.watch(profileProvider.select((p) => p.value?.weekStartsOn)) ?? WeekStartsOn.monday;
  final today = ref.watch(todayProvider.select((t) => t.date));
  return ref
      .watch(workoutQueriesProvider)
      .watchWeek(userId, weekWindowForDate(today, weekStartsOn));
});

/// Son 3 tamamlanan antrenman. Bitirme/silme sonrası `ref.invalidate` ile yenilenir.
final recentWorkoutsProvider = FutureProvider<List<RecentWorkout>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(workoutQueriesProvider).recent(userId);
});

/// Hareketin adı, takip tipi, ekipmanı ve bölgesi (odak modu şeridi ve başlığı).
final exerciseInfoProvider = FutureProvider.family<ExerciseOption?, String>(
  (ref, exerciseId) async =>
      (await ref.watch(workoutQueriesProvider).exercisesByIds([exerciseId]))[exerciseId],
);

/// Hareketin son tamamlanan antrenmandaki setleri (ön doldurma ve "Geçen sefer").
final lastSessionSetsProvider = FutureProvider.family<List<LoggedSet>, String>((ref, exerciseId) {
  final userId = ref.watch(signedInUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(workoutQueriesProvider).lastSessionSets(userId, exerciseId);
});
