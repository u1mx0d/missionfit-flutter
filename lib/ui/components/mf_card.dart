import 'package:material_ui/material_ui.dart';

import '../theme/mf_theme.dart';
import 'dot_grid.dart';

/// Mono: düz yüzey + kenarlık. Canlı: yüzeyden hafif gradyan.
class MfCard extends StatelessWidget {
  const MfCard({required this.child, this.padding = const EdgeInsets.all(16), super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final flat = t.cardStyle == CardStyle.flat;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: flat ? t.surface : null,
        gradient: flat
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.surface, t.surfaceMuted],
              ),
        borderRadius: BorderRadius.circular(t.radius),
        border: flat ? Border.all(color: t.border) : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
