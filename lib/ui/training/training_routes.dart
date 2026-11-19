import 'package:go_router/go_router.dart';

import 'focus_screen.dart';

/// Antrenman akışının kabuk dışındaki tam ekran sayfaları (alt bar gizli).
final trainingRoutes = <RouteBase>[
  GoRoute(path: '/antrenman/odak', builder: (_, _) => const FocusScreen()),
];
