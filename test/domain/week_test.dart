import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/week.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

DateTime utc(String iso) => DateTime.parse(iso).toUtc();

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('weekWindowForDate', () {
    test('Pazartesi başlangıç: Pazar günü önceki Pazartesiye aittir', () {
      final w = weekWindowForDate('2026-11-08', WeekStartsOn.monday); // Pazar
      expect(w.start, '2026-11-02');
      expect(w.end, '2026-11-08');
      expect(w.days, hasLength(7));
    });

    test('Pazar başlangıç: Pazar yeni haftayı başlatır', () {
      expect(weekKeyOf('2026-11-08', WeekStartsOn.sunday), '2026-11-08');
      expect(weekKeyOf('2026-11-07', WeekStartsOn.sunday), '2026-11-01');
    });

    test('başlangıç günü kendisi', () {
      expect(weekKeyOf('2026-11-02', WeekStartsOn.monday), '2026-11-02');
    });

    test('yıl geçişi', () {
      final w = weekWindowForDate('2027-01-01', WeekStartsOn.monday); // Cuma
      expect(w.start, '2026-12-28');
      expect(w.end, '2027-01-03');
    });

    test('yaz saati haftası 7 gün', () {
      expect(weekWindowForDate('2026-03-29', WeekStartsOn.monday).days, [
        '2026-03-23',
        '2026-03-24',
        '2026-03-25',
        '2026-03-26',
        '2026-03-27',
        '2026-03-28',
        '2026-03-29',
      ]);
    });
  });

  group('weekWindow (an + saat dilimi)', () {
    test('İstanbul Pazar 23:59 → eski hafta, Pazartesi 00:00 → yeni hafta', () {
      expect(
        weekWindow(utc('2026-11-08T20:59:00Z'), WeekStartsOn.monday, 'Europe/Istanbul').weekKey,
        '2026-11-02',
      );
      expect(
        weekWindow(utc('2026-11-08T21:00:00Z'), WeekStartsOn.monday, 'Europe/Istanbul').weekKey,
        '2026-11-09',
      );
    });

    test('aynı an, farklı saat diliminde farklı hafta', () {
      final instant = utc('2026-11-09T02:00:00Z');
      expect(weekWindow(instant, WeekStartsOn.monday, 'Europe/Istanbul').weekKey, '2026-11-09');
      expect(weekWindow(instant, WeekStartsOn.monday, 'America/New_York').weekKey, '2026-11-02');
    });

    // Review Focus #4
    test('weekWindow sunday: 2026-11-22 Pazar haftanın ilk günü', () {
      // 2026-11-22 Pazar 10:00 İstanbul = 07:00Z
      final w = weekWindow(utc('2026-11-22T07:00:00Z'), WeekStartsOn.sunday, 'Europe/Istanbul');
      expect(w.start, '2026-11-22');
      expect(w.end, '2026-11-28');
    });
  });

  group('yardımcılar', () {
    test('isInWindow sınırlar dahil', () {
      final w = weekWindowForDate('2026-11-04', WeekStartsOn.monday);
      expect(isInWindow('2026-11-02', w), isTrue);
      expect(isInWindow('2026-11-08', w), isTrue);
      expect(isInWindow('2026-11-09', w), isFalse);
      expect(isInWindow('2026-11-01', w), isFalse);
    });

    test('previousWeeks', () {
      final w = weekWindowForDate('2026-11-04', WeekStartsOn.monday);
      expect(previousWeeks(w, 2, WeekStartsOn.monday).map((x) => x.weekKey).toList(), [
        '2026-10-26',
        '2026-10-19',
      ]);
    });
  });
}
