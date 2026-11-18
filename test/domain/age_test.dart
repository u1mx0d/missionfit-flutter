import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/age.dart';

void main() {
  const today = BirthDate(year: 2026, month: 11, day: 2);

  group('isValidDate', () {
    test('geçerli günleri kabul eder', () {
      expect(isValidDate(const BirthDate(year: 2000, month: 2, day: 29)), isTrue); // artık yıl
    });

    test('geçersiz günleri reddeder', () {
      expect(isValidDate(const BirthDate(year: 2001, month: 2, day: 29)), isFalse);
      expect(isValidDate(const BirthDate(year: 2000, month: 13, day: 1)), isFalse);
      expect(isValidDate(const BirthDate(year: 2000, month: 4, day: 31)), isFalse);
      expect(isValidDate(const BirthDate(year: 2000, month: 1, day: 0)), isFalse);
    });
  });

  group('ageOn', () {
    test('doğum günü bugünse yaş artmış sayılır', () {
      expect(ageOn(const BirthDate(year: 2008, month: 11, day: 2), today), 18);
    });

    test('doğum günü yarınsa henüz artmamıştır', () {
      expect(ageOn(const BirthDate(year: 2008, month: 11, day: 3), today), 17);
    });

    test('aynı ay, önceki gün', () {
      expect(ageOn(const BirthDate(year: 2008, month: 11, day: 1), today), 18);
    });
  });

  group('checkBirthDate (18+)', () {
    test('tam 18 yaşında olanı kabul eder', () {
      expect(
        checkBirthDate(const BirthDate(year: 2008, month: 11, day: 2), today),
        const BirthDateOk(18),
      );
    });

    test('18 e bir gün kalanı reddeder', () {
      expect(
        checkBirthDate(const BirthDate(year: 2008, month: 11, day: 3), today),
        const BirthDateRejected(BirthDateProblem.underAge),
      );
    });

    test('gelecek tarihi reddeder', () {
      expect(
        checkBirthDate(const BirthDate(year: 2027, month: 1, day: 1), today),
        const BirthDateRejected(BirthDateProblem.future),
      );
    });

    test('geçersiz tarihi reddeder', () {
      expect(
        checkBirthDate(const BirthDate(year: 1990, month: 2, day: 30), today),
        const BirthDateRejected(BirthDateProblem.invalid),
      );
    });

    test('100 yaş üstünü reddeder', () {
      expect(
        checkBirthDate(const BirthDate(year: 1920, month: 1, day: 1), today),
        const BirthDateRejected(BirthDateProblem.tooOld),
      );
    });
  });

  group('ageFromBirthYear', () {
    test('yıl farkı', () {
      expect(ageFromBirthYear(1996, 2026), 30);
    });
  });
}
