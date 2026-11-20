import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/units.dart';
import 'package:missionfit/domain/value_input.dart';

void main() {
  group('parseWeightInput', () {
    test('virgül ve nokta ondalık; 0,1e yuvarlar, ızgaraya oturtmaz', () {
      expect(parseWeightInput('102,5', WeightUnit.kg).value, 102.5);
      expect(parseWeightInput(' 102.5 ', WeightUnit.kg).value, 102.5);
      expect(parseWeightInput('61,23', WeightUnit.kg).value, 61.2);
      expect(parseWeightInput('0', WeightUnit.kg).value, 0);
      expect(parseWeightInput('137,3', WeightUnit.lb).value, 137.3);
    });

    test('geçersiz ve sınır dışı hata verir', () {
      expect(parseWeightInput('abc', WeightUnit.kg).error, isNotNull);
      expect(parseWeightInput('', WeightUnit.kg).error, isNotNull);
      expect(parseWeightInput('-5', WeightUnit.kg).error, isNotNull);
      expect(parseWeightInput('1,2,3', WeightUnit.kg).error, isNotNull);
      expect(parseWeightInput('2000', WeightUnit.kg).error, 'En fazla 1000 kg.');
      expect(parseWeightInput('1000', WeightUnit.kg).value, 1000);
      // lb'de sınır 1000 kg karşılığı.
      expect(parseWeightInput('2000', WeightUnit.lb).value, 2000);
      expect(parseWeightInput('2300', WeightUnit.lb).error, contains('lb'));
    });
  });

  test('parseRepsInput: 1–500 tam sayı', () {
    expect(parseRepsInput('12').value, 12);
    expect(parseRepsInput('0').error, isNotNull);
    expect(parseRepsInput('501').error, isNotNull);
    expect(parseRepsInput('8,5').error, isNotNull);
    expect(parseRepsInput('abc').error, isNotNull);
  });

  test('parseDurationInput: dk:sn, sa:dk:sn ya da saniye', () {
    expect(parseDurationInput('1:30').value, 90);
    expect(parseDurationInput('0:45').value, 45);
    expect(parseDurationInput('1:02:05').value, 3725);
    expect(parseDurationInput('75').value, 75);
    expect(parseDurationInput('24:00:00').value, 86400);
    expect(parseDurationInput('24:00:01').error, isNotNull);
    expect(parseDurationInput('0:00').error, isNotNull);
    expect(parseDurationInput('1:75').error, isNotNull);
    expect(parseDurationInput('1,5').error, isNotNull);
    expect(parseDurationInput('').error, isNotNull);
  });
}
