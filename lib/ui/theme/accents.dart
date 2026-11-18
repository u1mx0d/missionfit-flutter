/// Vurgu renkleri: kullanıcı yalnızca vurguyu değiştirir (zemin/yazı temada sabit).
/// Her renk için açık tema tonu (beyaz yazıyla ve açık zeminde yazı olarak ≥ 4.5:1) ve
/// koyu tema tonu (koyu zeminde yazı olarak ≥ 4.5:1, üstünde koyu yazı).
library;

import 'dart:ui';

enum AccentColor {
  kirmizi('Kırmızı', Color(0xFFC8161D), Color(0xFFFF5A5C)),
  yesil('Yeşil', Color(0xFF15803D), Color(0xFF1ED760)),
  mavi('Mavi', Color(0xFF1D4ED8), Color(0xFF60A5FA)),
  indigo('İndigo', Color(0xFF4F46E5), Color(0xFF818CF8)),
  mor('Mor', Color(0xFF7C3AED), Color(0xFFA78BFA)),
  pembe('Pembe', Color(0xFFBE185D), Color(0xFFF472B6)),
  turuncu('Turuncu', Color(0xFFC2410C), Color(0xFFFB923C)),
  sari('Sarı', Color(0xFF8A5300), Color(0xFFFACC15)),
  turkuaz('Turkuaz', Color(0xFF0F766E), Color(0xFF2DD4BF)),
  grafit('Grafit', Color(0xFF3F3F46), Color(0xFFD4D4D8));

  const AccentColor(this.label, this.lightTone, this.darkTone);

  /// Türkçe ad (vurgu seçicide)
  final String label;
  final Color lightTone;
  final Color darkTone;
}

/// Sunucudaki `accent_color` değeri; bilinmeyen/boş → yeşil (Canlı varsayılanı).
AccentColor accentFromString(String? value) {
  for (final a in AccentColor.values) {
    if (a.name == value) return a;
  }
  return AccentColor.yesil;
}
