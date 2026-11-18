import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calories.dart';
import '../domain/dates.dart' show isValidTimeZone;
import '../domain/notification_settings.dart';
import '../domain/units.dart';
import '../ui/theme/accents.dart';
import '../ui/theme/mf_theme.dart';
import 'profile_controller.dart';
import 'providers.dart';
import 'today_provider.dart';

/// Onboarding sonunda profile yazılacak değerler (kilo her zaman kg).
class OnboardingData {
  const OnboardingData({
    required this.birthYear,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.units,
    required this.activityLevel,
    required this.goal,
    required this.calorieTarget,
    required this.themeFamily,
    required this.themeMode,
    required this.accent,
    required this.notificationSettings,
  });
  final int birthYear;
  final Sex sex;
  final double heightCm;
  final double weightKg;
  final WeightUnit units;
  final ActivityLevel activityLevel;
  final Goal goal;
  final int calorieTarget;
  final ThemeFamily themeFamily;
  final ThemeModeChoice themeMode;
  final AccentColor accent;
  final NotificationSettings notificationSettings;
}

typedef OnboardingSaver = Future<void> Function(OnboardingData data);

/// Tüm onboarding verisini (cihaz saat dilimi dahil) TEK profil güncellemesiyle yazar, ardından yerel
/// `onboarded.<userId>` bayrağını tutar. Profil yüklenmediyse `ProfileNotReadyException` fırlar
/// (bayrak yazılmaz).
final onboardingSaverProvider = Provider<OnboardingSaver>((ref) {
  return (data) async {
    final userId = ref.read(signedInUserIdProvider);
    if (userId == null) throw StateError('Oturum yok');
    final consentedAt = ref.read(clockProvider)().toUtc().toIso8601String();
    // Cihaz saat dilimi geçerliyse yazılır; değilse profildeki (varsayılan Europe/Istanbul) kalır.
    String? device;
    try {
      device = await ref.read(deviceTimezoneProvider.future);
    } catch (_) {
      device = null;
    }
    final zone = device != null && isValidTimeZone(device) ? device : null;
    await ref
        .read(profileRepositoryProvider)
        .update(
          userId,
          (p) => p.copyWith(
            birthYear: data.birthYear,
            sex: data.sex,
            heightCm: data.heightCm,
            weightKg: data.weightKg,
            units: data.units,
            activityLevel: data.activityLevel,
            goal: data.goal,
            calorieTarget: data.calorieTarget,
            calorieTargetIsManual: false,
            consentedAt: consentedAt,
            onboardingCompleted: true,
            theme: data.themeMode,
            themeFamily: data.themeFamily,
            accentColor: data.accent,
            notificationSettings: data.notificationSettings,
            timezone: zone ?? p.timezone,
          ),
        );
    await ref.read(sharedPreferencesProvider).setBool(onboardedFlagKey(userId), true);
    ref.invalidate(onboardedProvider);
  };
});
