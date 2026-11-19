import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/body_map.dart';

void main() {
  test('bölge kimlikleri sıra + 1, bilinmeyen 0', () {
    expect(bodyMapMuscles.length, 14);
    expect(bodyMapRegionId('chest'), 1);
    expect(bodyMapRegionId('calves'), 14);
    expect(bodyMapRegionId('foo'), 0);
  });

  test('bodyMapLevel kademeleri', () {
    expect(bodyMapLevel(0), 0);
    expect(bodyMapLevel(0.5), 1);
    expect(bodyMapLevel(3.5), 1);
    expect(bodyMapLevel(4), 2);
    expect(bodyMapLevel(9.5), 2);
    expect(bodyMapLevel(10), 3);
    expect(bodyMapLevel(double.nan), 0);
  });

  test('frameForAngle en yakın kareye yuvarlar ve sarar', () {
    expect(frameForAngle(0), 0);
    expect(frameForAngle(5), 1);
    expect(frameForAngle(357.6), 0);
    expect(frameForAngle(-5), 71);
    expect(frameForAngle(362.5), 1);
  });
}
