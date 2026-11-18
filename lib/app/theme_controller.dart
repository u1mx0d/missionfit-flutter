import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile/profile_repository.dart';
import '../ui/theme/accents.dart';
import '../ui/theme/mf_theme.dart';
import 'profile_controller.dart';

class ThemeSelection {
  const ThemeSelection({required this.family, required this.mode, required this.accent});
  final ThemeFamily family;
  final ThemeModeChoice mode;
  final AccentColor accent;

  ThemeSelection copyWith({ThemeFamily? family, ThemeModeChoice? mode, AccentColor? accent}) =>
      ThemeSelection(
        family: family ?? this.family,
        mode: mode ?? this.mode,
        accent: accent ?? this.accent,
      );

  @override
  bool operator ==(Object other) =>
      other is ThemeSelection &&
      other.family == family &&
      other.mode == mode &&
      other.accent == accent;
  @override
  int get hashCode => Object.hash(family, mode, accent);
}

const themeFamilyKey = 'theme_family';
const themeModeKey = 'theme_mode';
const themeAccentKey = 'theme_accent';
const accentCustomizedKey = 'accent_customized';

class ThemeController extends Notifier<ThemeSelection> {
  @override
  ThemeSelection build() {
    // Sunucu değeri farklıysa kazanır; yerel satır sunucudan çekilenle aynı kaynaktır.
    ref.listen(profileProvider, (_, next) {
      final p = next.value;
      if (p != null) _adoptProfile(p);
    });
    final p = ref.read(profileProvider).value;
    if (p != null) {
      _noteCustomized(p);
      return _fromProfile(p);
    }
    // Açılışta önce yereldeki seçim; ağ ya da veritabanı beklenmez.
    return _readCache();
  }

  ThemeSelection _fromProfile(Profile p) =>
      ThemeSelection(family: p.themeFamily, mode: p.theme, accent: p.accentColor);

  void _noteCustomized(Profile p) {
    if (p.accentColor != defaultAccentFor(p.themeFamily)) {
      ref.read(sharedPreferencesProvider).setBool(accentCustomizedKey, true);
    }
  }

  void _adoptProfile(Profile p) {
    _noteCustomized(p);
    final server = _fromProfile(p);
    if (server != state) state = server;
    _cache(server);
  }

  ThemeSelection _readCache() {
    final prefs = ref.read(sharedPreferencesProvider);
    final family = familyFromString(prefs.getString(themeFamilyKey));
    return ThemeSelection(
      family: family,
      mode: modeFromString(prefs.getString(themeModeKey)),
      accent: prefs.containsKey(themeAccentKey)
          ? accentFromString(prefs.getString(themeAccentKey))
          : defaultAccentFor(family),
    );
  }

  void _cache(ThemeSelection s) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(themeFamilyKey, s.family.name);
    prefs.setString(themeModeKey, s.mode.name);
    prefs.setString(themeAccentKey, s.accent.name);
  }

  Future<void> _apply(ThemeSelection s) async {
    state = s;
    _cache(s);
    final userId = ref.read(signedInUserIdProvider);
    if (userId == null) return;
    await ref
        .read(profileRepositoryProvider)
        .update(
          userId,
          (p) => p.copyWith(themeFamily: s.family, theme: s.mode, accentColor: s.accent),
        );
  }

  Future<void> setMode(ThemeModeChoice mode) => _apply(state.copyWith(mode: mode));

  Future<void> setAccent(AccentColor accent) async {
    await ref.read(sharedPreferencesProvider).setBool(accentCustomizedKey, true);
    await _apply(state.copyWith(accent: accent));
  }

  /// Vurgu hiç değiştirilmediyse ailenin varsayılan vurgusuna geçer.
  Future<void> setFamily(ThemeFamily family) {
    final customized = ref.read(sharedPreferencesProvider).getBool(accentCustomizedKey) ?? false;
    return _apply(
      state.copyWith(family: family, accent: customized ? state.accent : defaultAccentFor(family)),
    );
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeSelection>(
  ThemeController.new,
);
