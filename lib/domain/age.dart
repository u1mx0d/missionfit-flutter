/// Yaş ve 18+ kontrolü. Saf fonksiyonlar (RN `src/domain/age.ts` karşılığı).
///
/// Tam doğum tarihi sorulur ama yalnızca yıl saklanır: yalnızca yıl ile 18+ kontrolü belirsiz kalır;
/// tam tarihle kesin kontrol yapıp veritabanına sadece `birth_year` yazarak veri minimizasyonu
/// sağlanır (KVKK). Kalori hesabındaki yaş için yıl yeterlidir.
library;

const minAge = 18;
const maxAge = 100;

class BirthDate {
  const BirthDate({required this.year, required this.month, required this.day});
  final int year;
  final int month;
  final int day;
}

/// Geçerli bir takvim günü mü (ör. 31 Şubat değil)?
bool isValidDate(BirthDate b) {
  if (b.month < 1 || b.month > 12 || b.day < 1) return false;
  final d = DateTime.utc(b.year, b.month, b.day);
  return d.year == b.year && d.month == b.month && d.day == b.day;
}

/// [today] yerel takvim günüdür (saat dilimi çözümlemesi çağıranın işi).
int ageOn(BirthDate birth, BirthDate today) {
  var age = today.year - birth.year;
  if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
    age -= 1;
  }
  return age;
}

/// Kalori formülü için yalnızca doğum yılından yaş (doğum günü bilinmez → yıl farkı).
int ageFromBirthYear(int birthYear, int currentYear) => currentYear - birthYear;

enum BirthDateProblem { invalid, future, underAge, tooOld }

sealed class BirthDateCheck {
  const BirthDateCheck();
}

final class BirthDateOk extends BirthDateCheck {
  const BirthDateOk(this.age);
  final int age;
  @override
  bool operator ==(Object other) => other is BirthDateOk && other.age == age;
  @override
  int get hashCode => age.hashCode;
}

final class BirthDateRejected extends BirthDateCheck {
  const BirthDateRejected(this.reason);
  final BirthDateProblem reason;
  @override
  bool operator ==(Object other) => other is BirthDateRejected && other.reason == reason;
  @override
  int get hashCode => reason.hashCode;
}

BirthDateCheck checkBirthDate(BirthDate birth, BirthDate today) {
  if (!isValidDate(birth)) return const BirthDateRejected(BirthDateProblem.invalid);
  final age = ageOn(birth, today);
  if (age < 0) return const BirthDateRejected(BirthDateProblem.future);
  if (age < minAge) return const BirthDateRejected(BirthDateProblem.underAge);
  if (age > maxAge) return const BirthDateRejected(BirthDateProblem.tooOld);
  return BirthDateOk(age);
}
