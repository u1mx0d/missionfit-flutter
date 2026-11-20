import 'package:go_router/go_router.dart';

import 'focus_screen.dart';
import 'start_workout_screen.dart';
import 'workout_summary_screen.dart';

/// Antrenman akışının kabuk dışındaki tam ekran sayfaları (alt bar gizli).
final trainingRoutes = <RouteBase>[
  GoRoute(path: '/antrenman/basla', builder: (_, _) => const StartWorkoutScreen()),
  GoRoute(path: '/antrenman/odak', builder: (_, _) => const FocusScreen()),
  GoRoute(
    path: '/antrenman/ozet/:sessionId',
    builder: (_, s) => WorkoutSummaryScreen(sessionId: s.pathParameters['sessionId']!),
  ),
];
