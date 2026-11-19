import 'package:material_ui/material_ui.dart';

import '../../domain/training_style.dart';
import '../components/dot_grid.dart';
import '../training/training_style_picker.dart';
import 'onboarding_widgets.dart';

/// "Tarzın": ana tarz (+ isteğe bağlı yan tarzlar) ve seviye; ikisi de zorunlu.
class StyleStep extends StatelessWidget {
  const StyleStep({
    required this.style,
    required this.level,
    required this.onStyle,
    required this.onLevel,
    required this.errors,
    super.key,
  });
  final StyleSelection style;
  final TrainingLevel? level;
  final ValueChanged<StyleSelection> onStyle;
  final ValueChanged<TrainingLevel> onLevel;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) => StepShell(
    title: 'Nasıl antrenman yapıyorsun?',
    subtitle: 'Önce ana tarzını seç. Uygulama seninle buna göre konuşur.',
    children: [
      StyleGrid(value: style, onChanged: onStyle),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'İlk seçtiğin ana tarzın olur, sonrakiler yan tarz. '
          'Bir yan tarzı ana yapmak için kartına uzun bas.',
          style: TextStyle(color: mf(context).textMuted, fontSize: 13),
        ),
      ),
      StepError(errors['style']),
      const PickerLabel('Seviyen'),
      LevelSelector(value: level, onChanged: onLevel),
      StepError(errors['level']),
    ],
  );
}
