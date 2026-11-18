import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/food.dart';
import 'package:missionfit/domain/nutrition.dart';

FoodEntryValues ok(FoodCalcResult r) => (r as FoodCalcOk).values;

void main() {
  const soup = FoodNutrients(
    kcalPer100g: 56,
    proteinPer100g: 3.6,
    carbPer100g: 8.2,
    fatPer100g: 1.1,
    defaultServingGrams: 250,
  );

  group('foodEntryCalc', () {
    test('gram', () {
      expect(
        foodEntryCalc(soup, 150, AmountUnit.g),
        const FoodCalcOk((
          grams: 150,
          kcal: 84,
          protein: 5.4,
          carb: 12.3,
          fat: 1.7,
          isManualOverride: false,
        )),
      );
    });

    test('porsiyon ve kesirli porsiyon', () {
      final one = ok(foodEntryCalc(soup, 1, AmountUnit.serving));
      expect(one.grams, 250);
      expect(one.kcal, 140);
      expect(ok(foodEntryCalc(soup, 0.5, AmountUnit.serving)).kcal, 70);
    });

    test('adet: pieceGrams yoksa porsiyon gramı', () {
      const egg = FoodNutrients(
        kcalPer100g: 155,
        proteinPer100g: 13,
        carbPer100g: 1.1,
        fatPer100g: 11,
        defaultServingGrams: 50,
      );
      final r = ok(foodEntryCalc(egg, 2, AmountUnit.piece));
      expect(r.grams, 100);
      expect(r.kcal, 155);
      expect(ok(foodEntryCalc(egg, 2, AmountUnit.piece, pieceGrams: 60)).grams, 120);
    });

    test('elle kalori: kcal değişir, makrolar gramdan', () {
      final r = ok(foodEntryCalc(soup, 1, AmountUnit.serving, manualKcal: 200));
      expect(r.kcal, 200);
      expect(r.protein, 9);
      expect(r.isManualOverride, isTrue);
    });

    test('hesaplananla aynı elle değer override sayılmaz', () {
      expect(
        ok(foodEntryCalc(soup, 1, AmountUnit.serving, manualKcal: 140)).isManualOverride,
        isFalse,
      );
    });

    test('0 kcal elle girilebilir (ör. su)', () {
      expect(ok(foodEntryCalc(soup, 1, AmountUnit.serving, manualKcal: 0)).kcal, 0);
    });

    test('geçersiz girdiler', () {
      expect(
        foodEntryCalc(soup, 0, AmountUnit.g),
        const FoodCalcFailed(FoodCalcError.invalidAmount),
      );
      expect(
        foodEntryCalc(soup, -1, AmountUnit.g),
        const FoodCalcFailed(FoodCalcError.invalidAmount),
      );
      expect(
        foodEntryCalc(soup, double.nan, AmountUnit.g),
        const FoodCalcFailed(FoodCalcError.invalidAmount),
      );
      expect(
        foodEntryCalc(soup, 50, AmountUnit.serving),
        const FoodCalcFailed(FoodCalcError.tooLarge),
      );
      expect(
        foodEntryCalc(soup, 1, AmountUnit.g, manualKcal: -5),
        const FoodCalcFailed(FoodCalcError.invalidManualKcal),
      );
    });

    test('null manualKcal = elle değer yok', () {
      expect(
        ok(foodEntryCalc(soup, 100, AmountUnit.g, manualKcal: null)).isManualOverride,
        isFalse,
      );
    });
  });

  group('roundPercentages', () {
    test('toplam her zaman 100', () {
      expect(roundPercentages([1, 1, 1]), [34, 33, 33]);
      expect(roundPercentages([0, 0, 0]), [0, 0, 0]);
      expect(roundPercentages([10, 0, 0]), [100, 0, 0]);
    });
  });

  group('dailyNutritionSummary', () {
    const entries = [
      NutritionEntry(meal: Meal.breakfast, kcal: 400, protein: 20, carb: 50, fat: 12),
      NutritionEntry(meal: Meal.lunch, kcal: 650.4, protein: 35, carb: 70, fat: 22),
      NutritionEntry(meal: Meal.lunch, kcal: 100, protein: 2, carb: 20, fat: 1),
    ];

    test('toplam, öğün kırılımı, kalan', () {
      final s = dailyNutritionSummary(entries, 2000);
      expect(s.totals, (kcal: 1150.4, protein: 57.0, carb: 140.0, fat: 35.0));
      expect(s.byMeal[Meal.lunch], (kcal: 750.4, protein: 37.0, carb: 90.0, fat: 23.0, count: 2));
      expect(s.byMeal[Meal.dinner]!.count, 0);
      expect(s.remaining, 850);
      expect(s.over, 0);
      expect(s.progress, closeTo(1150 / 2000, 1e-9));
    });

    test('makro enerji yüzdeleri toplam 100', () {
      expect(dailyNutritionSummary(entries, 2000).macroPercent, (protein: 21, carb: 51, fat: 28));
    });

    test('boş gün', () {
      final s = dailyNutritionSummary([], 1800);
      expect(s.totals.kcal, 0);
      expect(s.macroPercent, (protein: 0, carb: 0, fat: 0));
      expect(s.remaining, 1800);
    });

    test('hedef aşımı: kalan 0, aşım ayrı', () {
      final s = dailyNutritionSummary([
        const NutritionEntry(meal: Meal.dinner, kcal: 2300, protein: 0, carb: 0, fat: 0),
      ], 2000);
      expect(s.remaining, 0);
      expect(s.over, 300);
      expect(s.progress, 1);
    });

    test('hedef yok (onboarding eksik)', () {
      final s = dailyNutritionSummary(entries, null);
      expect(s.remaining, isNull);
      expect(s.progress, isNull);
    });

    test('bozuk değerler (NaN/negatif) toplamı bozmaz', () {
      final s = dailyNutritionSummary([
        const NutritionEntry(meal: Meal.snack, kcal: double.nan, protein: -3, carb: 10, fat: 0),
      ], 2000);
      expect(s.totals, (kcal: 0.0, protein: 0.0, carb: 10.0, fat: 0.0));
    });
  });
}
