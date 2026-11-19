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
}
