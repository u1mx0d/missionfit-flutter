import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'dot_grid.dart' show mf;

/// Logodaki "M" harfini oluşturan 12 nokta (col, row); orta nokta hariç.
const List<(int col, int row)> mLogoCells = [
  (0, 0),
  (0, 1),
  (0, 2),
  (0, 3),
  (0, 4),
  (1, 1),
  (3, 1),
  (4, 0),
  (4, 1),
  (4, 2),
  (4, 3),
  (4, 4),
];

/// 5x5 nokta-matris logo (assets/icon/icon_fg.png ile aynı çizim).
/// [progress] 0..1: M noktaları tohumlu rastgele konumlardan yerine kayar,
/// orta nokta 0.85'ten sonra belirir. 1 = son hal.
class MfLogo extends StatelessWidget {
  const MfLogo({this.size = 128, this.progress = 1, super.key});
  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Semantics(
      label: 'MissionFit',
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: _MfLogoPainter(
            text: t.text,
            accent: t.accent,
            progress: progress.clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }
}

class _MfLogoPainter extends CustomPainter {
  _MfLogoPainter({required this.text, required this.accent, required this.progress});
  final Color text;
  final Color accent;
  final double progress;

  static const _centerStart = 0.85;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 5;
    final r = cell * 0.3;
    Offset at(num col, num row) => Offset((col + 0.5) * cell, (row + 0.5) * cell);

    // Silik arka plan noktaları: M ve orta nokta dışındaki 12 hücre.
    final faint = Paint()..color = text.withValues(alpha: 0.08);
    final used = {...mLogoCells, (2, 2)};
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        if (!used.contains((col, row))) canvas.drawCircle(at(col, row), r, faint);
      }
    }

    final rng = Random(7);
    final e = Curves.easeOutCubic.transform(progress);
    final paint = Paint()..color = text;
    for (final (col, row) in mLogoCells) {
      final sc = rng.nextInt(5);
      final sr = rng.nextInt(5);
      canvas.drawCircle(Offset.lerp(at(sc, sr), at(col, row), e)!, r, paint);
    }

    if (progress >= _centerStart) {
      canvas.drawCircle(at(2, 2), r, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(_MfLogoPainter old) =>
      old.text != text || old.accent != accent || old.progress != progress;
}
