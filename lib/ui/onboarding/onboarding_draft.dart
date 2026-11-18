import 'package:material_ui/material_ui.dart';

import '../../domain/calories.dart';
import '../../domain/onboarding_rules.dart';
import '../../domain/units.dart';
import '../theme/mf_theme.dart';
import '../../app/providers.dart' show PermissionState;

/// Onboarding sırasında girilen değerler; adımlar arası gezinirken korunur.
class OnboardingDraft {
  bool consentKvkk = false;
  bool consentHealth = false;
  final day = TextEditingController();
  final month = TextEditingController();
  final year = TextEditingController();
  Sex? sex;
  final height = TextEditingController();
  final weight = TextEditingController();
  WeightUnit units = WeightUnit.kg;
  ActivityLevel? activity;
  Goal? goal;
  PermissionState? permission;
  ThemeFamily family = ThemeFamily.canli;
  ThemeModeChoice mode = ThemeModeChoice.system;

  void dispose() {
    for (final c in [day, month, year, height, weight]) {
      c.dispose();
    }
  }

  int? get birthYear => parseIntStrict(year.text);

  double? get heightCm => parseDecimal(height.text);

  /// Kullanıcı birimindeki kilodan kg (1 ondalık); geçersizse null.
  double? get weightKg => parseWeightInUnit(weight.text, units).kg;

  CalorieTargetResult? preview(int currentYear) => calorieTargetForProfile(
    ProfileForTarget(
      sex: sex,
      birthYear: birthYear,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activity,
      goal: goal,
    ),
    currentYear,
  );
}
