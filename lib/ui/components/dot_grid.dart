import 'package:material_ui/material_ui.dart';

import '../theme/mf_theme.dart';

MfTheme mf(BuildContext context) => Theme.of(context).extension<MfTheme>()!;

class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.color, this.spacing = 18, this.radius = 1});
  final Color color;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) =>
      old.color != color || old.spacing != spacing || old.radius != radius;
}

/// Tema zemini: Mono'da noktalı ızgara, Canlı'da üstten gradyan.
class MfBackground extends StatelessWidget {
  const MfBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    Widget bg = ColoredBox(color: t.background, child: const SizedBox.expand());
    if (t.dotGridBackground) {
      bg = Stack(
        children: [
          bg,
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: DotGridPainter(color: t.dot)),
            ),
          ),
        ],
      );
    } else if (t.gradientTop != null) {
      bg = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.gradientTop!, t.background],
            stops: const [0, 0.45],
          ),
        ),
        child: const SizedBox.expand(),
      );
    }
    return Stack(fit: StackFit.expand, children: [bg, child]);
  }
}
