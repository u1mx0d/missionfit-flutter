import 'package:material_ui/material_ui.dart';

import '../../domain/training_style.dart';
import '../training/training_style_picker.dart';
import 'onboarding_widgets.dart';

/// "Hedeflerin": hedef hareketler ve geliştirilecek alanlar (atlanabilir).
class GoalsStep extends StatelessWidget {
  const GoalsStep({
    required this.options,
    required this.goals,
    required this.areas,
    required this.onGoals,
    required this.onAreas,
    super.key,
  });
  final List<String> options;
  final Set<String> goals;
  final Set<FocusArea> areas;
  final ValueChanged<Set<String>> onGoals;
  final ValueChanged<Set<FocusArea>> onAreas;

  @override
  Widget build(BuildContext context) => StepShell(
    title: 'Neye ulaşmak istiyorsun?',
    subtitle: "İstersen seç; önerilerimizi buna göre yaparız. Sonra Profil'den değiştirebilirsin.",
    children: [
      GoalChips(options: options, goals: goals, areas: areas, onGoals: onGoals, onAreas: onAreas),
    ],
  );
}
