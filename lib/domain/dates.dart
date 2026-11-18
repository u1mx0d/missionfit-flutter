/// Tarih / saat dilimi temeli. Saf fonksiyonlar (RN `src/domain/dates.ts` karşılığı).
///
/// Kural: her kayıtta UTC zaman damgası + kullanıcının YEREL tarihi (local_date, "YYYY-MM-DD")
/// tutulur; gün/hafta hesapları local_date üzerinden yapılır.
///
/// - [LocalDate]: saat dilimi taşımayan takvim günü. Aritmetik UTC epoch-gün üzerinden yapılır,
///   böylece yaz saati geçişleri gün sayısını bozmaz.
/// - Bir anın yerel tarihine/saatine çevrilmesi `package:timezone` (IANA) ile yapılır. Saat dilimi
///   veritabanı uygulama açılışında `initializeTimeZones()` ile yüklenmiş olmalı.
library;

import 'package:timezone/timezone.dart' as tz;

typedef LocalDate = String; // "YYYY-MM-DD"
typedef LocalTime = String; // "HH:MM" (Postgres time "HH:MM:SS" de kabul edilir)

const _dayMs = 86400000;
final _localDateRe = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

bool isLocalDate(String value) {
  final m = _localDateRe.firstMatch(value);
  if (m == null) return false;
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final date = DateTime.utc(y, mo, d);
  return date.year == y && date.month == mo && date.day == d;
}

({int y, int m, int d}) _parse(LocalDate value) {
  final match = _localDateRe.firstMatch(value);
  if (match == null || !isLocalDate(value)) {
    throw RangeError('Geçersiz LocalDate: $value');
  }
  return (y: int.parse(match[1]!), m: int.parse(match[2]!), d: int.parse(match[3]!));
}

String _pad(int n, [int len = 2]) => n.toString().padLeft(len, '0');

LocalDate formatLocalDate(int y, int m, int d) => '${_pad(y, 4)}-${_pad(m)}-${_pad(d)}';

int toEpochDay(LocalDate date) {
  final p = _parse(date);
  return DateTime.utc(p.y, p.m, p.d).millisecondsSinceEpoch ~/ _dayMs;
}

LocalDate fromEpochDay(int day) {
  final dt = DateTime.fromMillisecondsSinceEpoch(day * _dayMs, isUtc: true);
  return formatLocalDate(dt.year, dt.month, dt.day);
}

LocalDate addDays(LocalDate date, int days) => fromEpochDay(toEpochDay(date) + days);

/// b − a (gün).
int diffDays(LocalDate a, LocalDate b) => toEpochDay(b) - toEpochDay(a);

/// ISO hafta günü: 1 = Pazartesi ... 7 = Pazar.
int isoWeekday(LocalDate date) {
  final p = _parse(date);
  return DateTime.utc(p.y, p.m, p.d).weekday; // Dart: 1 = Pazartesi ... 7 = Pazar
}

/// a ile b arası (ikisi dahil) tüm günler. a > b ise boş.
List<LocalDate> daysBetween(LocalDate a, LocalDate b) {
  final start = toEpochDay(a), end = toEpochDay(b);
  return [for (var i = start; i <= end; i++) fromEpochDay(i)];
}

bool isValidTimeZone(String timeZone) {
  try {
    tz.getLocation(timeZone);
    return true;
  } catch (_) {
    return false;
  }
}

/// Geçersiz saat dilimi → UTC (profilde bozuk değer olsa bile uygulama çökmesin).
tz.Location _location(String timeZone) {
  try {
    return tz.getLocation(timeZone);
  } catch (_) {
    return tz.UTC;
  }
}

tz.TZDateTime _zoned(DateTime instant, String timeZone) =>
    tz.TZDateTime.from(instant, _location(timeZone));

/// Anın kullanıcının saat dilimindeki yerel tarihi (local_date).
LocalDate localDateInZone(DateTime instant, String timeZone) {
  final z = _zoned(instant, timeZone);
  return formatLocalDate(z.year, z.month, z.day);
}

/// Anın yerel saati "HH:MM".
LocalTime localTimeInZone(DateTime instant, String timeZone) {
  final z = _zoned(instant, timeZone);
  return '${_pad(z.hour)}:${_pad(z.minute)}';
}

/// Saat diliminin o andaki UTC farkı (dakika; İstanbul = +180).
int timeZoneOffsetMinutes(DateTime instant, String timeZone) =>
    _location(timeZone).timeZone(instant.millisecondsSinceEpoch).offset.inMinutes;

/// "09:05" veya "09:05:00" → gece yarısından itibaren dakika. Geçersiz → null.
int? parseLocalTime(String? value) {
  if (value == null || value.isEmpty) return null;
  final m = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$').firstMatch(value);
  if (m == null) return null;
  final h = int.parse(m[1]!), min = int.parse(m[2]!);
  if (h > 23 || min > 59) return null;
  return h * 60 + min;
}

LocalTime formatMinutesAsTime(int minutes) => '${_pad(minutes ~/ 60)}:${_pad(minutes % 60)}';

/// Yerel tarih + yerel saat (kullanıcının saat diliminde) → UTC an.
/// Yaz saati kenar durumları:
/// - Boşluk (ileri alma, ör. 02:30 yok): saat ileri kaydırılmış an döner (03:30).
/// - Çakışma (geri alma, 02:30 iki kez): ikinci (kış saati) an döner.
DateTime zonedTimeToUtc(LocalDate date, int minutesOfDay, String timeZone) {
  final p = _parse(date);
  final guess = DateTime.utc(
    p.y,
    p.m,
    p.d,
    minutesOfDay ~/ 60,
    minutesOfDay % 60,
  ).millisecondsSinceEpoch;
  final off1 = timeZoneOffsetMinutes(
    DateTime.fromMillisecondsSinceEpoch(guess, isUtc: true),
    timeZone,
  );
  final first = guess - off1 * 60000;
  final off2 = timeZoneOffsetMinutes(
    DateTime.fromMillisecondsSinceEpoch(first, isUtc: true),
    timeZone,
  );
  final ms = off1 == off2 ? first : guess - off2 * 60000;
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

const _regionPrefixes = [
  'Africa/',
  'America/',
  'Antarctica/',
  'Arctic/',
  'Asia/',
  'Atlantic/',
  'Australia/',
  'Europe/',
  'Indian/',
  'Pacific/',
];

/// Seçilebilir IANA saat dilimleri (alfabetik): saat dilimi veritabanındaki geçerli bölge
/// adları ve `UTC`. Eski takma adlar (`US/Pacific`, `Etc/GMT+3` vb.) listelenmez.
List<String> selectableTimeZones() {
  final names = [
    for (final name in tz.timeZoneDatabase.locations.keys)
      if ((name == 'UTC' || _regionPrefixes.any(name.startsWith)) && isValidTimeZone(name)) name,
  ]..sort();
  return names;
}
