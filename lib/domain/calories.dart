/// Günlük kalori hedefi (algoritma 1). RN `src/domain/calories.ts` karşılığı.
///
/// BMR — Mifflin-St Jeor (1990):
///   erkek: 10 × kilo + 6.25 × boy − 5 × yaş + 5
///   kadın: 10 × kilo + 6.25 × boy − 5 × yaş − 161
/// TDEE = BMR × aktivite katsayısı. Hedef = TDEE + hedef ayarı, ardından güvenlik alt sınırına
/// kırpılır. Bu bir tahmindir; tıbbi/diyetisyen tavsiyesi değildir.
library;

import 'js_math.dart';

enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { lose, maintain, gain }

const activityFactors = <ActivityLevel, double>{
  ActivityLevel.sedentary: 1.2, // masa başı, egzersiz yok/çok az
  ActivityLevel.light: 1.375, // haftada 1-3 gün hafif egzersiz
  ActivityLevel.moderate: 1.55, // haftada 3-5 gün orta egzersiz
  ActivityLevel.active: 1.725, // haftada 6-7 gün yoğun egzersiz
  ActivityLevel.veryActive: 1.9, // çok yoğun egzersiz + fiziksel iş
};

/// Kilo vermede açık en çok 500 kcal ve TDEE'nin %20'si; kilo almada +300 kcal.
const loseMaxDeficit = 500;
const loseMaxDeficitRatio = 0.2;
const gainSurplus = 300;

/// Güvenlik alt sınırı (kadın 1200, erkek 1500 kcal). Hedef bunun altına inemez.
const calorieFloor = <Sex, int>{Sex.female: 1200, Sex.male: 1500};

class BodyMetrics {
  const BodyMetrics({
    required this.sex,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
  });
  final Sex sex;
  final int ageYears;
  final double heightCm;
  final double weightKg;
}

double bmr(BodyMetrics m) {
  final base = 10 * m.weightKg + 6.25 * m.heightCm - 5 * m.ageYears;
  return base + (m.sex == Sex.male ? 5 : -161);
}

double tdee(BodyMetrics metrics, ActivityLevel activity) =>
    bmr(metrics) * activityFactors[activity]!;

class CalorieTargetResult {
  const CalorieTargetResult({
    required this.bmr,
    required this.tdee,
    required this.target,
    required this.clampedToFloor,
    required this.floor,
  });
  final int bmr;
  final int tdee;

  /// 10'a yuvarlanmış günlük hedef
  final int target;

  /// Hesaplanan değer güvenlik alt sınırının altındaydı ve sınıra çekildi
  final bool clampedToFloor;
  final int floor;
}

int _roundTo10(double v) => jsRound(v / 10) * 10;

CalorieTargetResult calorieTarget(BodyMetrics metrics, ActivityLevel activity, Goal goal) {
  final b = bmr(metrics);
  final t = b * activityFactors[activity]!;

  var raw = t;
  if (goal == Goal.lose) {
    final deficit = t * loseMaxDeficitRatio;
    raw = t - (deficit < loseMaxDeficit ? deficit : loseMaxDeficit);
  } else if (goal == Goal.gain) {
    raw = t + gainSurplus;
  }

  final floor = calorieFloor[metrics.sex]!;
  final rounded = _roundTo10(raw);
  final clamped = rounded < floor;
  return CalorieTargetResult(
    bmr: jsRound(b),
    tdee: jsRound(t),
    // Üst sınır DB kısıtı (calorie_target <= 10000); gerçekçi girdilerde ulaşılmaz.
    target: clamped ? floor : (rounded > 10000 ? 10000 : rounded),
    clampedToFloor: clamped,
    floor: floor,
  );
}

/// Elle girilen kalori hedefi: alt sınırın altı ENGELLENİR; > 5000 uyarı; > 10000 reddedilir.
const manualTargetWarnAbove = 5000;
const manualTargetMax = 10000;

enum ManualTargetProblem { invalid, belowFloor, tooHigh }

sealed class ManualTargetCheck {
  const ManualTargetCheck();
}

final class ManualTargetOk extends ManualTargetCheck {
  const ManualTargetOk(this.value, {required this.veryHigh});
  final int value;
  final bool veryHigh;
  @override
  bool operator ==(Object other) =>
      other is ManualTargetOk && other.value == value && other.veryHigh == veryHigh;
  @override
  int get hashCode => Object.hash(value, veryHigh);
}

final class ManualTargetRejected extends ManualTargetCheck {
  const ManualTargetRejected(this.reason, this.floor);
  final ManualTargetProblem reason;
  final int floor;
  @override
  bool operator ==(Object other) =>
      other is ManualTargetRejected && other.reason == reason && other.floor == floor;
  @override
  int get hashCode => Object.hash(reason, floor);
}

ManualTargetCheck validateManualCalorieTarget(double value, Sex sex) {
  final floor = calorieFloor[sex]!;
  if (!value.isFinite) return ManualTargetRejected(ManualTargetProblem.invalid, floor);
  final v = jsRound(value);
  if (v < floor) return ManualTargetRejected(ManualTargetProblem.belowFloor, floor);
  if (v > manualTargetMax) return ManualTargetRejected(ManualTargetProblem.tooHigh, floor);
  return ManualTargetOk(v, veryHigh: v > manualTargetWarnAbove);
}

const _keep = Object();

class ProfileForTarget {
  const ProfileForTarget({
    this.sex,
    this.birthYear,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
  });
  final Sex? sex;
  final int? birthYear;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final Goal? goal;

  ProfileForTarget copyWith({
    Object? sex = _keep,
    Object? birthYear = _keep,
    Object? heightCm = _keep,
    Object? weightKg = _keep,
    Object? activityLevel = _keep,
    Object? goal = _keep,
  }) => ProfileForTarget(
    sex: identical(sex, _keep) ? this.sex : sex as Sex?,
    birthYear: identical(birthYear, _keep) ? this.birthYear : birthYear as int?,
    heightCm: identical(heightCm, _keep) ? this.heightCm : heightCm as double?,
    weightKg: identical(weightKg, _keep) ? this.weightKg : weightKg as double?,
    activityLevel: identical(activityLevel, _keep)
        ? this.activityLevel
        : activityLevel as ActivityLevel?,
    goal: identical(goal, _keep) ? this.goal : goal as Goal?,
  );
}

/// Profilden otomatik hedef. Eksik alan varsa null. Yaş doğum yılından hesaplanır.
CalorieTargetResult? calorieTargetForProfile(ProfileForTarget p, int currentYear) {
  final sex = p.sex, by = p.birthYear, h = p.heightCm, w = p.weightKg;
  final a = p.activityLevel, g = p.goal;
  if (sex == null || by == null || by == 0 || h == null || h == 0 || w == null || w == 0) {
    return null;
  }
  if (a == null || g == null) return null;
  return calorieTarget(
    BodyMetrics(sex: sex, ageYears: currentYear - by, heightCm: h, weightKg: w),
    a,
    g,
  );
}
