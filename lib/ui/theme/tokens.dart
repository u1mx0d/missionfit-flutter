/// Tema belirteçleri: Mono (Nothing esintili) ve Canlı (Spotify esintili) aileleri, açık ve koyu.
/// Değerler `.superpowers/brainstorm/.../tema-yonleri.html` taslağından türetildi.
/// Kontrast `test/ui/theme/contrast_test.dart` ile korunur; renk değiştirirken o test geçmeli.
library;

import 'dart:math' as math;
import 'dart:ui';

/// WCAG kontrast oranı (1..21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Bir aile + parlaklık için zemin ve yazı renkleri.
class Palette {
  const Palette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.kcal,
    required this.dot,
    this.gradientTop,
  });
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final Color kcal;

  /// Noktalı zemin deseninin nokta rengi
  final Color dot;

  /// Canlı temada sayfa üstündeki degradenin başlangıç rengi
  final Color? gradientTop;
}

const _darkStatus = (
  success: Color(0xFF4ADE80),
  warning: Color(0xFFFBBF24),
  danger: Color(0xFFF87171),
  kcal: Color(0xFFFB923C),
);
const _lightStatus = (
  success: Color(0xFF15803D),
  warning: Color(0xFF8A5300),
  danger: Color(0xFFB91C1C),
  kcal: Color(0xFFC2410C),
);

final monoDark = Palette(
  background: const Color(0xFF0B0B0B),
  surface: const Color(0xFF141414),
  surfaceMuted: const Color(0xFF1C1C1C),
  border: const Color(0xFF262626),
  text: const Color(0xFFEEEEEE),
  textMuted: const Color(0xFF9A9A9A),
  success: _darkStatus.success,
  warning: _darkStatus.warning,
  danger: _darkStatus.danger,
  kcal: _darkStatus.kcal,
  dot: const Color(0xFF2A2A2A),
);

final monoLight = Palette(
  background: const Color(0xFFF6F3EE),
  surface: const Color(0xFFFBFAF7),
  surfaceMuted: const Color(0xFFEFEBE4),
  border: const Color(0xFFD9D1C7),
  text: const Color(0xFF1D1B19),
  textMuted: const Color(0xFF5F5953),
  success: _lightStatus.success,
  warning: _lightStatus.warning,
  danger: _lightStatus.danger,
  kcal: _lightStatus.kcal,
  dot: const Color(0xFFD9D1C7),
);

final canliDark = Palette(
  background: const Color(0xFF121212),
  surface: const Color(0xFF1E1E1E),
  surfaceMuted: const Color(0xFF2A2A2A),
  border: const Color(0xFF2A2A2A),
  text: const Color(0xFFFFFFFF),
  textMuted: const Color(0xFFB3B3B3),
  success: _darkStatus.success,
  warning: _darkStatus.warning,
  danger: _darkStatus.danger,
  kcal: _darkStatus.kcal,
  dot: const Color(0xFF2A2A2A),
  gradientTop: const Color(0xFF1F4A35),
);

final canliLight = Palette(
  background: const Color(0xFFF7F7F7),
  surface: const Color(0xFFFFFFFF),
  surfaceMuted: const Color(0xFFEDEDED),
  border: const Color(0xFFDDDDDD),
  text: const Color(0xFF121212),
  textMuted: const Color(0xFF5E5E5E),
  success: _lightStatus.success,
  warning: _lightStatus.warning,
  danger: _lightStatus.danger,
  kcal: _lightStatus.kcal,
  dot: const Color(0xFFDDDDDD),
  gradientTop: const Color(0xFFD7F5E3),
);

/// Yazı aileleri (assets/fonts, OFL).
const fontDoto = 'Doto';
const fontSpaceGrotesk = 'SpaceGrotesk';
const fontInter = 'Inter';
