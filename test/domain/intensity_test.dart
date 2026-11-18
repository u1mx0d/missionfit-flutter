import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/muscle_coverage.dart';

void main() {
  group('intensityLevel', () {
    test('haftalık 5 kademe ve sınırlar', () {
      expect(
        [0, 0.5, 1.5, 2, 3.5, 4, 9.5, 10, 25].map((s) => intensityLevel(s.toDouble())).toList(),
        [0, 1, 1, 2, 2, 3, 3, 4, 4],
      );
    });

    test('tek oturum eşikleri daha düşük', () {
      expect(
        [0, 0.5, 1, 2, 4].map((s) => intensityLevel(s.toDouble(), sessionIntensity)).toList(),
        [0, 1, 2, 3, 4],
      );
    });

    test('geçersiz değer çalışılmadı sayılır', () {
      expect(intensityLevel(double.nan), 0);
      expect(intensityLevel(-1), 0);
    });

    test('kapsamdan harita', () {
      final map = intensityByMuscle(
        const Coverage(
          muscles: {
            'chest': (sets: 6.0, status: CoverageStatus.adequate),
            'lats': (sets: 0.0, status: CoverageStatus.none),
          },
          regions: {},
          totalSets: 6,
        ),
      );
      expect(map, {'chest': 3, 'lats': 0});
    });
  });
}
