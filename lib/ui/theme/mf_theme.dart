/// MissionFit tema tanımı. Ekranlar yalnızca bunu okur (`Theme.of(context).extension<MfTheme>()`).
/// Renkler, yazı tipleri, köşe yuvarlaklığı, kart stili ve görünüm seçenekleri tek yerde.
library;

import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import 'accents.dart';
import 'tokens.dart';

enum ThemeFamily { mono, canli }

/// Sunucudaki `profiles.theme` değerleri.
enum ThemeModeChoice { system, light, dark }

enum CardStyle { flat, gradient }

/// Kalori özeti: Canlı'da halka, Mono'da büyük nokta-matris sayı + çubuk.
enum CalorieView { ring, bigNumberBar }

ThemeFamily familyFromString(String? value) =>
    value == 'mono' ? ThemeFamily.mono : ThemeFamily.canli;

ThemeModeChoice modeFromString(String? value) => switch (value) {
  'light' => ThemeModeChoice.light,
  'dark' => ThemeModeChoice.dark,
  _ => ThemeModeChoice.system,
};

AccentColor defaultAccentFor(ThemeFamily f) =>
    f == ThemeFamily.mono ? AccentColor.kirmizi : AccentColor.yesil;

class MfTheme extends ThemeExtension<MfTheme> {
  const MfTheme({
    required this.family,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.kcal,
    required this.dot,
    required this.gradientTop,
    required this.displayFont,
    required this.bodyFont,
    required this.numberFont,
    required this.radius,
    required this.cardStyle,
    required this.dotGridBackground,
    required this.calorieView,
  });

  final ThemeFamily family;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color danger;
  final Color kcal;
  final Color dot;
  final Color? gradientTop;
  final String displayFont;
  final String bodyFont;

  /// Büyük rakamlar için (Mono: nokta-matris Doto)
  final String numberFont;
  final double radius;
  final CardStyle cardStyle;
  final bool dotGridBackground;
  final CalorieView calorieView;

  static MfTheme build(ThemeFamily family, Brightness brightness, AccentColor accent) {
    final dark = brightness == Brightness.dark;
    final p = switch (family) {
      ThemeFamily.mono => dark ? monoDark : monoLight,
      ThemeFamily.canli => dark ? canliDark : canliLight,
    };
    final mono = family == ThemeFamily.mono;
    return MfTheme(
      family: family,
      brightness: brightness,
      background: p.background,
      surface: p.surface,
      surfaceMuted: p.surfaceMuted,
      border: p.border,
      text: p.text,
      textMuted: p.textMuted,
      accent: dark ? accent.darkTone : accent.lightTone,
      onAccent: dark ? const Color(0xFF0B0B0B) : const Color(0xFFFFFFFF),
      success: p.success,
      warning: p.warning,
      danger: p.danger,
      kcal: p.kcal,
      dot: p.dot,
      // Degrade vurgu renginden türetilir; vurgu değişince zemin de ona uyar.
      gradientTop: p.gradientTop == null
          ? null
          // Açık temada da canlı ton (darkTone) kullanılır; koyu ton beyaz zeminde neredeyse görünmez.
          : Color.lerp(p.background, accent.darkTone, dark ? 0.28 : 0.32),
      displayFont: mono ? fontSpaceGrotesk : fontInter,
      bodyFont: mono ? fontSpaceGrotesk : fontInter,
      numberFont: mono ? fontDoto : fontInter,
      radius: mono ? 20 : 14,
      cardStyle: mono ? CardStyle.flat : CardStyle.gradient,
      dotGridBackground: mono,
      calorieView: mono ? CalorieView.bigNumberBar : CalorieView.ring,
    );
  }

  @override
  MfTheme copyWith({Color? accent, Color? onAccent}) => MfTheme(
    family: family,
    brightness: brightness,
    background: background,
    surface: surface,
    surfaceMuted: surfaceMuted,
    border: border,
    text: text,
    textMuted: textMuted,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    success: success,
    warning: warning,
    danger: danger,
    kcal: kcal,
    dot: dot,
    gradientTop: gradientTop,
    displayFont: displayFont,
    bodyFont: bodyFont,
    numberFont: numberFont,
    radius: radius,
    cardStyle: cardStyle,
    dotGridBackground: dotGridBackground,
    calorieView: calorieView,
  );

  /// Renkler ve yuvarlaklık yumuşak geçer; ayrık değerler (font, stil) yarıda değişir.
  @override
  MfTheme lerp(covariant MfTheme? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    final half = t < 0.5;
    return MfTheme(
      family: half ? family : other.family,
      brightness: half ? brightness : other.brightness,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      border: c(border, other.border),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      kcal: c(kcal, other.kcal),
      dot: c(dot, other.dot),
      gradientTop: Color.lerp(gradientTop, other.gradientTop, t),
      displayFont: half ? displayFont : other.displayFont,
      bodyFont: half ? bodyFont : other.bodyFont,
      numberFont: half ? numberFont : other.numberFont,
      radius: lerpDouble(radius, other.radius, t)!,
      cardStyle: half ? cardStyle : other.cardStyle,
      dotGridBackground: half ? dotGridBackground : other.dotGridBackground,
      calorieView: half ? calorieView : other.calorieView,
    );
  }
}
