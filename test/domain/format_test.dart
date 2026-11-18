import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/format.dart';

void main() {
  group('format', () {
    test('formatInt', () {
      expect(formatInt(1850), '1.850');
      expect(formatInt(1234567), '1.234.567');
      expect(formatInt(999.6), '1.000');
      expect(formatInt(-1200), '-1.200');
      expect(formatInt(0), '0');
    });

    test('joinTurkish', () {
      expect(joinTurkish([]), '');
      expect(joinTurkish(['a']), 'a');
      expect(joinTurkish(['a', 'b']), 'a ve b');
      expect(joinTurkish(['a', 'b', 'c']), 'a, b ve c');
    });

    test('süre', () {
      expect(formatDuration(3900), '1 sa 05 dk');
      expect(formatDuration(720), '12 dk');
      expect(formatDuration(45), '45 sn');
      expect(formatClock(3725), '1:02:05');
      expect(formatClock(65), '01:05');
    });
  });
}
