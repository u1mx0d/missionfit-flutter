import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/units.dart';
import 'package:missionfit/domain/weight_step.dart';

void main() {
  test('weightStep', () {
    expect(weightStep('barbell', WeightUnit.kg), 2.5);
    expect(weightStep('dumbbell', WeightUnit.kg), 2);
    expect(weightStep('machine', WeightUnit.lb), 10);
    expect(weightStep('band', WeightUnit.kg), 2.5);
  });

  test('tracksWeight', () {
    expect(tracksWeight('weight_reps', 'barbell'), isTrue);
    expect(tracksWeight('weight_reps', 'bodyweight'), isFalse);
    expect(tracksWeight('reps', 'dumbbell'), isFalse);
  });

  test('stepWeight', () {
    expect(stepWeight(60, 1, 'barbell', WeightUnit.kg), 62.5);
    expect(stepWeight(1, -1, 'barbell', WeightUnit.kg), 0);
    expect(
      stepWeight(100, 1, 'barbell', WeightUnit.lb),
      toKg(fromKg(100, WeightUnit.lb) + 5, WeightUnit.lb),
    );
  });

  group('kullanıcı biriminde adım (lb kayması yok)', () {
    test('lb: boştan + ile 5, 10, 15, 20', () {
      var v = 0.0;
      final seen = <double>[];
      for (var i = 0; i < 4; i++) {
        v = stepInUnit(v, 1, 'barbell', WeightUnit.lb);
        seen.add(v);
      }
      expect(seen, [5, 10, 15, 20]);
    });

    test('snapToStep: dönüşüm hatası ızgaraya oturur, gerçek değer korunur', () {
      expect(snapToStep(fromKg(61.2, WeightUnit.lb), 'barbell', WeightUnit.lb), 135);
      expect(snapToStep(61.2, 'barbell', WeightUnit.kg), 61.2);
      expect(snapToStep(137.3, 'barbell', WeightUnit.lb), 137.3);
    });

    test('135 lb kg olarak 61,2 yazılır', () {
      expect(toKg(135, WeightUnit.lb), 61.2);
    });

    test('kg davranışı aynı; alt sınır 0', () {
      expect(stepInUnit(60, 1, 'barbell', WeightUnit.kg), 62.5);
      expect(stepInUnit(61.2, 1, 'barbell', WeightUnit.kg), 63.7);
      expect(stepInUnit(1, -1, 'dumbbell', WeightUnit.kg), 0);
    });
  });
}
