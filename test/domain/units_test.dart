import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/units.dart';

void main() {
  group('ağırlık birimleri', () {
    test('kg ↔ lb', () {
      expect(kgToLb(1), closeTo(2.20462, 0.00005));
      expect(toKg(160, WeightUnit.lb), 72.6);
      expect(fromKg(72.5, WeightUnit.lb), 159.8);
      expect(toKg(72.5, WeightUnit.kg), 72.5);
    });

    test('gidiş-dönüş kaybı en çok 0.1', () {
      for (final kg in [30.0, 55.5, 72.5, 100.0, 350.0]) {
        expect((toKg(fromKg(kg, WeightUnit.lb), WeightUnit.lb) - kg).abs(), lessThanOrEqualTo(0.1));
      }
    });

    test('Türkçe biçim', () {
      expect(formatWeight(72.5, WeightUnit.kg), '72,5 kg');
      expect(formatWeight(80, WeightUnit.kg), '80 kg');
      expect(formatWeight(72.5, WeightUnit.lb), '159,8 lb');
    });
  });
}
