import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';

/// Yoğunluk ölçeği: işaret + sayı aralığı (bilgi yalnızca renkle verilmez).
class BodyMapLegend extends StatelessWidget {
  const BodyMapLegend({this.scope = 'haftalık', super.key});

  /// Ekran okuyucu için ölçeğin kapsamı ("haftalık", "bu antrenmanda").
  final String scope;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = t.bodyMapStyle == BodyMapStyle.dots;
    const labels = ['0', '0,5–3,5', '4–9,5', '10+'];
    Widget mark(int level) {
      if (mono) {
        final size = const [4.0, 5.0, 7.0, 9.0][level];
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: level == 0 ? t.textMuted : t.accent,
          ),
        );
      }
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: level == 0
              ? t.surfaceMuted
              : t.accent.withValues(alpha: const [0.0, 0.45, 0.75, 1.0][level]),
          border: level == 0 ? Border.all(color: t.textMuted) : null,
        ),
      );
    }

    final style = TextStyle(color: t.textMuted, fontSize: 12);
    return Semantics(
      label: 'Ölçek, $scope ağırlıklı set: ${labels.join(', ')}',
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: [
          Text('Set', style: style),
          for (var i = 0; i < 4; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10, height: 10, child: Center(child: mark(i))),
                const SizedBox(width: 4),
                Text(labels[i], style: style),
              ],
            ),
        ],
      ),
    );
  }
}
