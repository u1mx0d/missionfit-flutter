import 'package:material_ui/material_ui.dart';

import '../../domain/calories.dart';
import '../../domain/format.dart';
import '../components/dot_grid.dart';
import '../components/mf_card.dart';
import 'onboarding_widgets.dart';

class CaloriePreviewStep extends StatelessWidget {
  const CaloriePreviewStep({required this.result, super.key});
  final CalorieTargetResult? result;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final r = result;
    return StepShell(
      title: 'Kalori hedefin',
      subtitle: 'Verdiğin bilgilerle hesapladık.',
      children: [
        if (r != null)
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük kalori hedefi önizlemesi',
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatInt(r.target),
                      key: const Key('calorie-target'),
                      style: TextStyle(
                        fontFamily: t.numberFont,
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: t.kcal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'kcal / gün (tahmini)',
                          style: TextStyle(color: t.textMuted, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bazal (BMR): ${formatInt(r.bmr)} kcal',
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
                Text(
                  'Günlük harcama: ${formatInt(r.tdee)} kcal',
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
                if (r.clampedToFloor) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Hesaplanan değer, güvenli kabul edilen ${formatInt(r.floor)} kcal alt '
                    'sınırının altında kaldığı için hedefin bu sınıra ayarlandı. Daha düşük bir '
                    'hedef için bir sağlık profesyoneline danışmanı öneririz.',
                    style: TextStyle(color: t.warning, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "Mifflin-St Jeor formülü ve aktivite katsayısıyla hesaplanır. Hedefini Profil'den "
                  'elle de değiştirebileceksin.',
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
