import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/calories.dart';

void main() {
  const male = BodyMetrics(sex: Sex.male, ageYears: 30, heightCm: 180, weightKg: 80);
  const female = BodyMetrics(sex: Sex.female, ageYears: 30, heightCm: 165, weightKg: 60);

  group('bmr (Mifflin-St Jeor)', () {
    test('erkek: 10*80 + 6.25*180 - 5*30 + 5 = 1780', () => expect(bmr(male), 1780));
    test('kadın: 10*60 + 6.25*165 - 5*30 - 161 = 1320.25', () {
      expect(bmr(female), closeTo(1320.25, 0.005));
    });
  });

  group('tdee', () {
    test('BMR × aktivite katsayısı', () {
      expect(tdee(male, ActivityLevel.moderate), closeTo(1780 * 1.55, 0.005));
    });
  });

  group('calorieTarget', () {
    test('koru: TDEE 10a yuvarlanır', () {
      final r = calorieTarget(male, ActivityLevel.moderate, Goal.maintain);
      expect(r.tdee, 2759);
      expect(r.target, 2760);
      expect(r.clampedToFloor, isFalse);
    });

    test('kilo ver: yüksek TDEE de açık 500 ile sınırlı', () {
      expect(calorieTarget(male, ActivityLevel.moderate, Goal.lose).target, 2260);
    });

    test('kilo ver: düşük TDEE de açık TDEE nin %20 si ile sınırlı', () {
      final r = calorieTarget(female, ActivityLevel.sedentary, Goal.lose);
      expect(r.target, 1270);
      expect(r.clampedToFloor, isFalse);
    });

    test('kilo al: +300', () {
      expect(calorieTarget(male, ActivityLevel.moderate, Goal.gain).target, 3060);
    });

    test('güvenlik alt sınırı: çok düşük hedef sınıra çekilir ve işaretlenir', () {
      const small = BodyMetrics(sex: Sex.female, ageYears: 70, heightCm: 145, weightKg: 40);
      final r = calorieTarget(small, ActivityLevel.sedentary, Goal.lose);
      expect(r.target, calorieFloor[Sex.female]);
      expect(r.clampedToFloor, isTrue);
    });

    test('erkek alt sınırı 1500', () {
      const small = BodyMetrics(sex: Sex.male, ageYears: 80, heightCm: 150, weightKg: 45);
      final r = calorieTarget(small, ActivityLevel.sedentary, Goal.lose);
      expect(r.target, 1500);
      expect(r.clampedToFloor, isTrue);
    });

    test('hedef her zaman veritabanı aralığında (500..10000)', () {
      const huge = BodyMetrics(sex: Sex.male, ageYears: 18, heightCm: 250, weightKg: 350);
      final r = calorieTarget(huge, ActivityLevel.veryActive, Goal.gain);
      expect(r.target, lessThanOrEqualTo(10000));
      expect(r.target, greaterThanOrEqualTo(500));
    });
  });

  group('validateManualCalorieTarget', () {
    test('alt sınırın altı engellenir', () {
      expect(
        validateManualCalorieTarget(1100, Sex.female),
        const ManualTargetRejected(ManualTargetProblem.belowFloor, 1200),
      );
      expect(
        validateManualCalorieTarget(1400, Sex.male),
        const ManualTargetRejected(ManualTargetProblem.belowFloor, 1500),
      );
    });

    test('sınır dahil kabul', () {
      expect(
        validateManualCalorieTarget(1200, Sex.female),
        const ManualTargetOk(1200, veryHigh: false),
      );
    });

    test('çok yüksek: uyarı; DB üstü: red', () {
      expect(
        validateManualCalorieTarget(6000, Sex.male),
        const ManualTargetOk(6000, veryHigh: true),
      );
      expect(
        validateManualCalorieTarget(12000, Sex.male),
        isA<ManualTargetRejected>().having((r) => r.reason, 'reason', ManualTargetProblem.tooHigh),
      );
    });

    test('geçersiz sayı', () {
      expect(
        validateManualCalorieTarget(double.nan, Sex.male),
        isA<ManualTargetRejected>().having((r) => r.reason, 'reason', ManualTargetProblem.invalid),
      );
    });
  });

  // RN'de units.test.ts içindeydi.
  group('calorieTargetForProfile', () {
    const full = ProfileForTarget(
      sex: Sex.male,
      birthYear: 1996,
      heightCm: 180,
      weightKg: 80,
      activityLevel: ActivityLevel.moderate,
      goal: Goal.maintain,
    );

    test('tam profil: 2026 yılında 30 yaş', () {
      expect(calorieTargetForProfile(full, 2026)?.target, 2760);
    });

    test('eksik alan → null', () {
      expect(calorieTargetForProfile(full.copyWith(weightKg: null), 2026), isNull);
      expect(calorieTargetForProfile(full.copyWith(goal: null), 2026), isNull);
    });
  });
}
