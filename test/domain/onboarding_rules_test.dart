import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/age.dart';
import 'package:missionfit/domain/onboarding_rules.dart';
import 'package:missionfit/domain/units.dart';

void main() {
  const today = BirthDate(year: 2026, month: 11, day: 2);

  group('parseDecimal', () {
    test('virgül ve nokta', () {
      expect(parseDecimal('72,5'), 72.5);
      expect(parseDecimal(' 72.5 '), 72.5);
      expect(parseDecimal('180'), 180);
    });

    test('geçersiz', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
      expect(parseDecimal('-5'), isNull);
      expect(parseDecimal('1,2,3'), isNull);
    });
  });

  group('boy / kilo', () {
    test('sınırlar dahil', () {
      expect(validateHeight('100'), isNull);
      expect(validateHeight('250'), isNull);
      expect(validateWeight('30'), isNull);
      expect(validateWeight('350'), isNull);
    });

    test('sınır dışı ve boş', () {
      expect(validateHeight('99'), contains('100-250'));
      expect(validateWeight('351'), contains('30-350'));
      expect(validateHeight(''), contains('santimetre'));
    });
  });

  group('validateBirthDate', () {
    test('18 yaşında', () {
      final r = validateBirthDate(day: '2', month: '11', year: '2008', today: today);
      expect(r, isA<BirthDateInputOk>());
      final ok = r as BirthDateInputOk;
      expect((ok.birth.year, ok.birth.month, ok.birth.day, ok.age), (2008, 11, 2, 18));
    });

    test('18 altı: suçlayıcı olmayan net mesaj', () {
      final r = validateBirthDate(day: '3', month: '11', year: '2008', today: today);
      expect(
        (r as BirthDateInputError).message,
        'MissionFit 18 yaş ve üzeri kullanıcılar içindir.',
      );
    });

    test('eksik / 2 haneli yıl', () {
      expect(
        validateBirthDate(day: '1', month: '1', year: '', today: today),
        isA<BirthDateInputError>(),
      );
      expect(
        validateBirthDate(day: '1', month: '1', year: '90', today: today),
        isA<BirthDateInputError>(),
      );
    });

    test('takvimde olmayan gün', () {
      expect(
        validateBirthDate(day: '31', month: '4', year: '1990', today: today),
        isA<BirthDateInputError>(),
      );
    });
  });

  group('localToday', () {
    test('yerel takvim günü (gece yarısına yakın)', () {
      final a = localToday(DateTime(2026, 1, 1, 0, 0, 1));
      expect((a.year, a.month, a.day), (2026, 1, 1));
      final b = localToday(DateTime(2025, 12, 31, 23, 59, 59));
      expect((b.year, b.month, b.day), (2025, 12, 31));
    });
  });

  group('parseWeightInUnit', () {
    test('kg ve lb', () {
      expect(parseWeightInUnit('72,5', WeightUnit.kg), (kg: 72.5, message: null));
      expect(parseWeightInUnit('160', WeightUnit.lb), (kg: 72.6, message: null));
    });

    test('aralık dışı', () {
      expect(parseWeightInUnit('60', WeightUnit.lb).kg, isNull);
      expect(parseWeightInUnit('abc', WeightUnit.lb).kg, isNull);
    });
  });

  group('validateBirthYear', () {
    test('18+ yıl kuralı', () {
      expect(validateBirthYear('2008', 2026), (year: 2008, message: null));
      expect(validateBirthYear('2009', 2026).year, isNull);
      expect(validateBirthYear('95', 2026).year, isNull);
    });
  });
}
