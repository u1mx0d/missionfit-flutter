import 'package:material_ui/material_ui.dart';

import '../../domain/calories.dart';
import '../../domain/units.dart';
import '../components/dot_grid.dart';
import 'onboarding_widgets.dart';

class BodyStep extends StatelessWidget {
  const BodyStep({
    required this.sex,
    required this.onSex,
    required this.height,
    required this.weight,
    required this.units,
    required this.onUnits,
    required this.errors,
    required this.onChanged,
    super.key,
  });
  final Sex? sex;
  final ValueChanged<Sex> onSex;
  final TextEditingController height;
  final TextEditingController weight;
  final WeightUnit units;
  final ValueChanged<WeightUnit> onUnits;
  final Map<String, String> errors;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final kg = units == WeightUnit.kg;
    return StepShell(
      title: 'Vücut bilgilerin',
      subtitle: "İstediğin zaman Profil'den güncelleyebilirsin.",
      children: [
        Text(
          'Biyolojik cinsiyet',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Kalori formülü (Mifflin-St Jeor) erkek ve kadın için farklı sabit kullanır.',
          style: TextStyle(color: t.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OptionCard(
                key: const Key('sex-female'),
                title: 'Kadın',
                selected: sex == Sex.female,
                onTap: () => onSex(Sex.female),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionCard(
                key: const Key('sex-male'),
                title: 'Erkek',
                selected: sex == Sex.male,
                onTap: () => onSex(Sex.male),
              ),
            ),
          ],
        ),
        StepError(errors['sex']),
        const SizedBox(height: 20),
        TextField(
          key: const Key('height'),
          controller: height,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 5,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Boy (cm)',
            hintText: '175',
            counterText: '',
            errorText: errors['height'],
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<WeightUnit>(
          key: const Key('units'),
          segments: const [
            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
            ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
          ],
          selected: {units},
          onSelectionChanged: (s) => onUnits(s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('weight'),
          controller: weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 5,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: kg ? 'Kilo (kg)' : 'Kilo (lb)',
            hintText: kg ? '72,5' : '160',
            counterText: '',
            errorText: errors['weight'],
          ),
        ),
      ],
    );
  }
}
