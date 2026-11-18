import 'package:material_ui/material_ui.dart';

import 'dot_grid.dart';

class MfEmptyState extends StatelessWidget {
  const MfEmptyState({required this.icon, required this.title, this.message, super.key});
  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: t.textMuted),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
