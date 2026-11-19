import 'package:material_ui/material_ui.dart';

import '../../domain/calories.dart';
import '../../domain/onboarding_rules.dart';
import '../../domain/training_style.dart';
import '../../domain/units.dart';
import '../theme/mf_theme.dart';
import '../../app/providers.dart' show PermissionState;
import '../profile/edit_profile_screen.dart' show AvatarChange;

/// Onboarding sırasında girilen değerler; adımlar arası gezinirken korunur.
class OnboardingDraft {
  bool consentKvkk = false;
  bool consentHealth = false;
  final displayName = TextEditingController();
  final username = TextEditingController();
  AvatarChange? avatar;

  /// Bu onboarding'de sunucuda alınmış kullanıcı adı (geri dönülüp değiştirilmediyse tekrar alınmaz).
  String? claimedUsername;
  StyleSelection style = const StyleSelection();
  TrainingLevel? level;

  /// Seçilen hedef hareketler / alanlar (seçim sırası korunur).
  Set<String> goalMoves = {};
  Set<FocusArea> focusAreas = {};
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
    for (final c in [displayName, username, day, month, year, height, weight]) {
      c.dispose();
    }
  }

  /// Hedef seçenekleri: ana + yan tarzların listesi; listeden düşen seçili hedefler sonda kalır.
  List<String> get goalOptions => goalOptionsFor(style, keep: goalMoves);

  /// Kaydedilecek hedefler, ekrandaki sırayla.
  List<String> get orderedGoalMoves => [
    for (final key in goalOptions)
      if (goalMoves.contains(key)) key,
  ];

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
