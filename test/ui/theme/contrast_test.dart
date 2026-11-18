import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:missionfit/ui/theme/tokens.dart';

/// WCAG AA: normal yazı ≥ 4.5:1, büyük (≥ 44 px) yazı ≥ 3:1.
/// RN `src/theme/contrast.test.ts` karşılığı; 2 aile × 2 parlaklık × 10 vurgu.
void main() {
  const aa = 4.5;
  final combos = [
    for (final f in ThemeFamily.values)
      for (final b in Brightness.values)
        for (final a in AccentColor.values) (f: f, b: b, a: a),
  ];

  String name(({ThemeFamily f, Brightness b, AccentColor a}) c) =>
      '${c.f.name}/${c.b.name}/${c.a.name}';

  test('yazı renkleri tüm zeminlerde ≥ 4.5', () {
    for (final c in combos) {
      final t = MfTheme.build(c.f, c.b, c.a);
      for (final fg in [t.text, t.textMuted, t.warning, t.danger]) {
        for (final bg in [t.background, t.surface, t.surfaceMuted]) {
          expect(contrastRatio(fg, bg), greaterThanOrEqualTo(aa), reason: '${name(c)} $fg/$bg');
        }
      }
    }
  });

  test('vurgu yazı olarak background ve surface üzerinde ≥ 4.5', () {
    for (final c in combos) {
      final t = MfTheme.build(c.f, c.b, c.a);
      for (final bg in [t.background, t.surface]) {
        expect(contrastRatio(t.accent, bg), greaterThanOrEqualTo(aa), reason: name(c));
      }
    }
  });

  test('vurgu üstündeki yazı (onAccent) ≥ 4.5', () {
    for (final c in combos) {
      final t = MfTheme.build(c.f, c.b, c.a);
      expect(contrastRatio(t.onAccent, t.accent), greaterThanOrEqualTo(aa), reason: name(c));
    }
  });

  test('kalori rakamı (büyük yazı) ≥ 3', () {
    for (final c in combos) {
      final t = MfTheme.build(c.f, c.b, c.a);
      for (final bg in [t.background, t.surface]) {
        expect(contrastRatio(t.kcal, bg), greaterThanOrEqualTo(3), reason: name(c));
      }
    }
  });

  test('success rengi zeminlerde ≥ 3 (simge/grafik)', () {
    for (final c in combos) {
      final t = MfTheme.build(c.f, c.b, c.a);
      expect(contrastRatio(t.success, t.surface), greaterThanOrEqualTo(3), reason: name(c));
    }
  });
}
