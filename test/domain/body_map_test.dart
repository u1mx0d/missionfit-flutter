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

  test('bestFrameFor: seçili kimliklerin toplamı en büyük kare', () {
    final counts = [
      [0, 50, 0, 10],
      [0, 10, 0, 90],
      [0, 30, 0, 40],
    ];
    expect(bestFrameFor(counts, [1]), 0);
    expect(bestFrameFor(counts, [3]), 1);
    expect(bestFrameFor(counts, [1, 3]), 1);
    expect(bestFrameFor(counts, const <int>[]), 0);
  });

  test('regionsVisibleIn: en iyi karenin %10\'u altı görünmez sayılır', () {
    final counts = [
      [0, 100],
      [0, 9],
      [0, 10],
      [0, 0],
    ];
    expect(regionsVisibleIn(counts, 0, [1]), isTrue);
    expect(regionsVisibleIn(counts, 1, [1]), isFalse);
    expect(regionsVisibleIn(counts, 2, [1]), isTrue);
    expect(regionsVisibleIn(counts, 3, [1]), isFalse);
    // Hiç pikseli olmayan kimlik: döndürme yok.
    expect(regionsVisibleIn(counts, 3, [5]), isTrue);
  });

  test('angleTowardFrame en kısa yoldan döner', () {
    expect(angleTowardFrame(0, 36), anyOf(180, -180));
    expect(angleTowardFrame(10, 70), -10); // 350° = −10°
    expect(angleTowardFrame(350, 2), 370);
    expect(angleTowardFrame(720, 18), 810);
  });
}
