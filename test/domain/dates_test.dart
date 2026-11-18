import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/dates.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

DateTime utc(String iso) => DateTime.parse(iso).toUtc();

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('LocalDate aritmetiği', () {
    test('ay/yıl geçişi', () {
      expect(addDays('2026-12-31', 1), '2027-01-01');
      expect(addDays('2026-03-01', -1), '2026-02-28');
      expect(addDays('2028-03-01', -1), '2028-02-29');
    });

    test('yaz saati geçişi gün sayısını bozmaz', () {
      expect(diffDays('2026-03-28', '2026-03-30'), 2);
      expect(daysBetween('2026-10-24', '2026-10-26'), ['2026-10-24', '2026-10-25', '2026-10-26']);
    });

    test('ISO hafta günü', () {
      expect(isoWeekday('2026-11-02'), 1); // Pazartesi
      expect(isoWeekday('2026-11-08'), 7); // Pazar
    });

    test('geçerlilik', () {
      expect(isLocalDate('2026-02-29'), isFalse);
      expect(isLocalDate('2026-1-01'), isFalse);
      expect(() => addDays('bozuk', 1), throwsRangeError);
    });
  });

  group('saat dilimine göre yerel tarih', () {
    test('İstanbul gece yarısı: UTC 20:59 → aynı gün, 21:00 → ertesi gün', () {
      expect(localDateInZone(utc('2026-11-02T20:59:59Z'), 'Europe/Istanbul'), '2026-11-02');
      expect(localDateInZone(utc('2026-11-02T21:00:00Z'), 'Europe/Istanbul'), '2026-11-03');
    });

    test('aynı an farklı dilimlerde farklı gün', () {
      final instant = utc('2026-11-03T02:00:00Z');
      expect(localDateInZone(instant, 'Europe/Istanbul'), '2026-11-03');
      expect(localDateInZone(instant, 'America/New_York'), '2026-11-02');
    });

    test('geçersiz saat dilimi UTC ye düşer', () {
      expect(localDateInZone(utc('2026-11-02T23:30:00Z'), 'Mars/Olympus'), '2026-11-02');
    });

    test('yerel saat ve offset', () {
      expect(localTimeInZone(utc('2026-11-02T06:05:00Z'), 'Europe/Istanbul'), '09:05');
      expect(timeZoneOffsetMinutes(utc('2026-07-01T00:00:00Z'), 'Europe/Berlin'), 120);
      expect(timeZoneOffsetMinutes(utc('2026-01-01T00:00:00Z'), 'Europe/Berlin'), 60);
    });

    // Review Focus #4
    test('localDateInZone: 2026-11-18T21:30Z İstanbul\'da 2026-11-19', () {
      expect(localDateInZone(utc('2026-11-18T21:30:00Z'), 'Europe/Istanbul'), '2026-11-19');
    });
  });

  group('zonedTimeToUtc', () {
    test('İstanbul (sabit +3)', () {
      expect(
        zonedTimeToUtc('2026-11-02', 9 * 60, 'Europe/Istanbul').toIso8601String(),
        '2026-11-02T06:00:00.000Z',
      );
    });

    test('gece yarısı 00:00', () {
      expect(
        zonedTimeToUtc('2026-11-03', 0, 'Europe/Istanbul').toIso8601String(),
        '2026-11-02T21:00:00.000Z',
      );
    });

    test('yaz saati boşluğu (Berlin 29 Mart 02:30 yok) → 03:30 CEST', () {
      final t = zonedTimeToUtc('2026-03-29', 2 * 60 + 30, 'Europe/Berlin');
      expect(t.toIso8601String(), '2026-03-29T01:30:00.000Z');
      expect(localTimeInZone(t, 'Europe/Berlin'), '03:30');
    });

    test('geri alma çakışması (Berlin 25 Ekim 02:30 iki kez) → ikinci (CET)', () {
      final t = zonedTimeToUtc('2026-10-25', 2 * 60 + 30, 'Europe/Berlin');
      expect(t.toIso8601String(), '2026-10-25T01:30:00.000Z');
      expect(localTimeInZone(t, 'Europe/Berlin'), '02:30');
    });

    test('normal yaz günü Berlin', () {
      expect(
        zonedTimeToUtc('2026-07-01', 8 * 60, 'Europe/Berlin').toIso8601String(),
        '2026-07-01T06:00:00.000Z',
      );
    });
  });

  group('parseLocalTime', () {
    test('HH:MM ve HH:MM:SS', () {
      expect(parseLocalTime('09:05'), 545);
      expect(parseLocalTime('23:59:00'), 1439);
    });

    test('geçersiz', () {
      expect(parseLocalTime('24:00'), isNull);
      expect(parseLocalTime('9:05'), isNull);
      expect(parseLocalTime(null), isNull);
    });
  });

  group('selectableTimeZones', () {
    test('bölge adlarını ve UTC yi alfabetik verir, eski takma adları vermez', () {
      final zones = selectableTimeZones();
      expect(zones, containsAll(['Europe/Istanbul', 'Asia/Tokyo', 'UTC']));
      expect(zones, isNot(contains('US/Pacific')));
      expect(zones.any((z) => z.startsWith('Etc/')), isFalse);
      expect(zones, [...zones]..sort());
      expect(zones.every(isValidTimeZone), isTrue);
    });
  });
}
