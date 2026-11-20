import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import 'focus_screen.dart';
import 'start_workout_screen.dart';

/// Antrenman akışının kabuk dışındaki tam ekran sayfaları (alt bar gizli).
final trainingRoutes = <RouteBase>[
  GoRoute(path: '/antrenman/basla', builder: (_, _) => const StartWorkoutScreen()),
  GoRoute(path: '/antrenman/odak', builder: (_, _) => const FocusScreen()),
  GoRoute(
    path: '/antrenman/ozet/:sessionId',
    builder: (_, s) => _SummaryPlaceholder(sessionId: s.pathParameters['sessionId']!),
  ),
];

/// Özet ekranı Görev 10'da dolar; şimdilik yalnızca sekmeye dönüş.
class _SummaryPlaceholder extends StatelessWidget {
  const _SummaryPlaceholder({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet'),
        backgroundColor: t.background,
        foregroundColor: t.text,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Antrenman kaydedildi.', style: TextStyle(color: t.text, fontSize: 16)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/antrenman'),
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                child: const Text('Antrenman'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
