/// Onboarding form doğrulamaları. RN `features/onboarding/validation.ts` karşılığı.
/// Aralıklar DB kısıtlarıyla aynı: boy 100-250 cm, kilo 30-350 kg.
library;

import 'age.dart';
import 'units.dart';

const heightMin = 100, heightMax = 250;
const weightMin = 30, weightMax = 350;

/// "72,5" / "72.5" → 72.5; negatif, boş veya bozuk → null.
double? parseDecimal(String input) {
  final n = input.trim().replaceFirst(',', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(n)) return null;
  return double.parse(n);
}

int? parseIntStrict(String input) {
  final t = input.trim();
  return RegExp(r'^\d+$').hasMatch(t) ? int.parse(t) : null;
}

String? validateHeight(String input) {
  final v = parseDecimal(input);
  if (v == null) return 'Boyunu santimetre olarak yaz (ör. 175).';
  if (v < heightMin || v > heightMax) return 'Boy $heightMin-$heightMax cm arasında olmalı.';
  return null;
}

String? validateWeight(String input) {
  final v = parseDecimal(input);
  if (v == null) return 'Kilonu kilogram olarak yaz (ör. 72,5).';
  if (v < weightMin || v > weightMax) return 'Kilo $weightMin-$weightMax kg arasında olmalı.';
  return null;
}

sealed class BirthDateInputResult {
  const BirthDateInputResult();
}

final class BirthDateInputOk extends BirthDateInputResult {
  const BirthDateInputOk(this.birth, this.age);
  final BirthDate birth;
  final int age;
}

final class BirthDateInputError extends BirthDateInputResult {
  const BirthDateInputError(this.message);
  final String message;
}

BirthDateInputResult validateBirthDate({
  required String day,
  required String month,
  required String year,
  required BirthDate today,
}) {
  final d = parseIntStrict(day), m = parseIntStrict(month), y = parseIntStrict(year);
  if (d == null || m == null || y == null || year.trim().length != 4) {
    return const BirthDateInputError('Doğum tarihini GG / AA / YYYY şeklinde yaz.');
  }
  final birth = BirthDate(year: y, month: m, day: d);
  return switch (checkBirthDate(birth, today)) {
    BirthDateOk(:final age) => BirthDateInputOk(birth, age),
    BirthDateRejected(reason: BirthDateProblem.invalid) => const BirthDateInputError(
      'Bu tarih takvimde yok. Gün ve ayı kontrol et.',
    ),
    BirthDateRejected(reason: BirthDateProblem.future) => const BirthDateInputError(
      'Doğum tarihi bugünden sonra olamaz.',
    ),
    BirthDateRejected(reason: BirthDateProblem.underAge) => const BirthDateInputError(
      'MissionFit 18 yaş ve üzeri kullanıcılar içindir.',
    ),
    BirthDateRejected(reason: BirthDateProblem.tooOld) => const BirthDateInputError(
      'Lütfen doğum tarihini kontrol et.',
    ),
  };
}

/// Cihazın yerel takvim günü (onboarding'de saat dilimi henüz seçilmemiş olabilir).
BirthDate localToday([DateTime? now]) {
  final n = (now ?? DateTime.now()).toLocal();
  return BirthDate(year: n.year, month: n.month, day: n.day);
}

/// Kullanıcı birimindeki kiloyu kg'ye çevirip aralığı denetler. Hata varsa kg null.
({double? kg, String? message}) parseWeightInUnit(String input, WeightUnit unit) {
  final v = parseDecimal(input);
  if (v == null) {
    return (
      kg: null,
      message: unit == WeightUnit.kg
          ? 'Kilonu kilogram olarak yaz (ör. 72,5).'
          : 'Kilonu pound olarak yaz (ör. 160).',
    );
  }
  final kg = toKg(v, unit); // tek dönüşüm kaynağı: units.dart
  if (kg < weightMin || kg > weightMax) {
    return (
      kg: null,
      message: unit == WeightUnit.kg
          ? 'Kilo $weightMin-$weightMax kg arasında olmalı.'
          : 'Kilo 67-771 lb arasında olmalı.',
    );
  }
  return (kg: kg, message: null);
}

({int? year, String? message}) validateBirthYear(String input, int currentYear) {
  final y = parseIntStrict(input);
  if (y == null || input.trim().length != 4) {
    return (year: null, message: 'Doğum yılını 4 haneli yaz (ör. 1995).');
  }
  if (currentYear - y < 18) {
    return (year: null, message: 'MissionFit 18 yaş ve üzeri kullanıcılar içindir.');
  }
  if (currentYear - y > 100) return (year: null, message: 'Lütfen doğum yılını kontrol et.');
  return (year: y, message: null);
}
