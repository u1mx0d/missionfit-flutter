/// Hafta penceresi (algoritma 3). Saf fonksiyonlar (RN `src/domain/week.ts` karşılığı).
///
/// - Haftalık reset veri SİLMEZ: "bu hafta" yalnızca [start, end] local_date aralığıdır.
/// - weekKey = haftanın ilk günü. DB'deki workout_sessions.week_key ile aynı değer.
/// - Bir kaydın günü, kaydın BAŞLADIĞI andaki yerel tarihtir.
/// - Hafta başlangıcı kullanıcı ayarıdır, saat dilimi profildeki IANA değeridir.
library;

import 'dates.dart';

export 'dates.dart' show LocalDate;

enum WeekStartsOn { monday, sunday }

/// Başı ve sonu dahil bir tarih aralığı.
abstract interface class DateRange {
  LocalDate get start;
  LocalDate get end;
}

class WeekWindow implements DateRange {
  const WeekWindow({
    required this.weekKey,
    required this.start,
    required this.end,
    required this.days,
  });

  final LocalDate weekKey;
  @override
  final LocalDate start;

  /// Dahil
  @override
  final LocalDate end;
  final List<LocalDate> days;
}

int _startIso(WeekStartsOn w) => w == WeekStartsOn.monday ? 1 : 7;

LocalDate weekStartOf(LocalDate date, WeekStartsOn weekStartsOn) {
  final offset = (isoWeekday(date) - _startIso(weekStartsOn) + 7) % 7;
  return addDays(date, -offset);
}

LocalDate weekKeyOf(LocalDate date, WeekStartsOn weekStartsOn) => weekStartOf(date, weekStartsOn);

WeekWindow weekWindowForDate(LocalDate date, WeekStartsOn weekStartsOn) {
  final start = weekStartOf(date, weekStartsOn);
  final end = addDays(start, 6);
  return WeekWindow(weekKey: start, start: start, end: end, days: daysBetween(start, end));
}

/// Bir an için (ör. şimdi) kullanıcının saat dilimi ve hafta başlangıcına göre pencere.
WeekWindow weekWindow(DateTime instant, WeekStartsOn weekStartsOn, String timeZone) =>
    weekWindowForDate(localDateInZone(instant, timeZone), weekStartsOn);

/// ISO biçimi sözlük sırasıyla karşılaştırılabilir.
bool isInWindow(LocalDate date, DateRange window) =>
    date.compareTo(window.start) >= 0 && date.compareTo(window.end) <= 0;

/// "Geçmiş" listesi için: verilen haftadan önceki n haftanın pencereleri (yeniden eskiye).
List<WeekWindow> previousWeeks(WeekWindow window, int count, WeekStartsOn weekStartsOn) => [
  for (var i = 1; i <= count; i++) weekWindowForDate(addDays(window.start, -7 * i), weekStartsOn),
];
