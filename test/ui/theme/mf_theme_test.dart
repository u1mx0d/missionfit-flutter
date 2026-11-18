import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

void main() {
  // Review Focus #5: sunucudan bilinmeyen değer gelirse çökmez, varsayılana döner.
  test("familyFromString('xyz') == canli", () {
    expect(familyFromString('xyz'), ThemeFamily.canli);
    expect(familyFromString(null), ThemeFamily.canli);
    expect(familyFromString('mono'), ThemeFamily.mono);
  });

  test('accentFromString(null) == yesil', () {
    expect(accentFromString(null), AccentColor.yesil);
    expect(accentFromString('bilinmeyen'), AccentColor.yesil);
    expect(accentFromString('mor'), AccentColor.mor);
  });

  test('ThemeModeChoice bilinmeyen değerde system', () {
    expect(modeFromString('xyz'), ThemeModeChoice.system);
    expect(modeFromString('dark'), ThemeModeChoice.dark);
  });

  test('ailenin varsayılan vurgusu', () {
    expect(defaultAccentFor(ThemeFamily.mono), AccentColor.kirmizi);
    expect(defaultAccentFor(ThemeFamily.canli), AccentColor.yesil);
  });

  test('mono açık temada calorieView bigNumberBar', () {
    final t = MfTheme.build(ThemeFamily.mono, Brightness.light, AccentColor.kirmizi);
    expect(t.calorieView, CalorieView.bigNumberBar);
    expect(t.dotGridBackground, isTrue);
    expect(t.cardStyle, CardStyle.flat);
  });

  test('canlı temada halka ve degrade kart', () {
    final t = MfTheme.build(ThemeFamily.canli, Brightness.dark, AccentColor.yesil);
    expect(t.calorieView, CalorieView.ring);
    expect(t.cardStyle, CardStyle.gradient);
    expect(t.dotGridBackground, isFalse);
  });

  test('vurgu rengi tema parlaklığına göre ton seçer', () {
    final light = MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.mavi);
    final dark = MfTheme.build(ThemeFamily.canli, Brightness.dark, AccentColor.mavi);
    expect(light.accent, AccentColor.mavi.lightTone);
    expect(dark.accent, AccentColor.mavi.darkTone);
  });

  test('lerp geçişte çökmez', () {
    final a = MfTheme.build(ThemeFamily.mono, Brightness.dark, AccentColor.kirmizi);
    final b = MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.yesil);
    final mid = a.lerp(b, 0.5);
    expect(mid.background, isNot(a.background));
    expect(a.lerp(null, 0.5), same(a));
  });

  test('her vurgunun Türkçe adı var', () {
    expect(AccentColor.values.map((a) => a.label).toList(), [
      'Kırmızı',
      'Yeşil',
      'Mavi',
      'İndigo',
      'Mor',
      'Pembe',
      'Turuncu',
      'Sarı',
      'Turkuaz',
      'Grafit',
    ]);
  });

  test('buildThemeData MfTheme uzantısını ve yazı ailesini taşır', () {
    final t = MfTheme.build(ThemeFamily.mono, Brightness.dark, AccentColor.kirmizi);
    final data = buildThemeData(t);
    expect(data.extension<MfTheme>(), same(t));
    expect(data.brightness, Brightness.dark);
    expect(data.colorScheme.primary, t.accent);
    expect(data.scaffoldBackgroundColor, t.background);
    expect(data.textTheme.bodyMedium?.fontFamily, 'SpaceGrotesk');
  });
}
