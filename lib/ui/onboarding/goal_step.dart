import 'package:material_ui/material_ui.dart';

import '../../domain/calories.dart';
import 'onboarding_widgets.dart';

const activityOptions = <(ActivityLevel, String, String)>[
  (ActivityLevel.sedentary, 'Hareketsiz', 'Masa başı iş, egzersiz yok veya çok az'),
  (ActivityLevel.light, 'Hafif aktif', 'Haftada 1-3 gün hafif egzersiz'),
  (ActivityLevel.moderate, 'Orta aktif', 'Haftada 3-5 gün egzersiz'),
  (ActivityLevel.active, 'Çok aktif', 'Haftada 6-7 gün yoğun egzersiz'),
  (ActivityLevel.veryActive, 'Aşırı aktif', 'Günde iki antrenman veya fiziksel iş'),
];

const goalOptions = <(Goal, String, String, IconData)>[
  (Goal.lose, 'Kilo vermek', 'Ilımlı bir kalori azaltımıyla', Icons.trending_down),
  (Goal.maintain, 'Kilomu korumak', 'Dengede kalmak', Icons.remove),
  (Goal.gain, 'Kilo almak', 'Kas kazanımını desteklemek', Icons.trending_up),
];

String _activityKey(ActivityLevel a) => switch (a) {
  ActivityLevel.veryActive => 'very-active',
  _ => a.name,
};

class GoalStep extends StatelessWidget {
  const GoalStep({
    required this.activity,
    required this.goal,
    required this.onActivity,
    required this.onGoal,
    required this.errors,
    super.key,
  });
  final ActivityLevel? activity;
  final Goal? goal;
  final ValueChanged<ActivityLevel> onActivity;
  final ValueChanged<Goal> onGoal;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) => StepShell(
    title: 'Hareketin ve hedefin',
    subtitle: 'Ortalama bir haftanı düşün. Hedefini dilediğin zaman değiştirebilirsin.',
    children: [
      for (final (value, title, description) in activityOptions)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OptionCard(
            key: Key('activity-${_activityKey(value)}'),
            title: title,
            description: description,
            selected: activity == value,
            onTap: () => onActivity(value),
          ),
        ),
      StepError(errors['activity']),
      const SizedBox(height: 12),
      for (final (value, title, description, icon) in goalOptions)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OptionCard(
            key: Key('goal-${value.name}'),
            title: title,
            description: description,
            icon: icon,
            selected: goal == value,
            onTap: () => onGoal(value),
          ),
        ),
      StepError(errors['goal']),
    ],
  );
}
