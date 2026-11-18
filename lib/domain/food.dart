/// Yemek kaydı hesabı (algoritma 6). RN `src/domain/food.ts` karşılığı.
///
/// - Besin değerleri 100 g başına saklanır. Değer = (100 g değeri) × gram / 100.
/// - Birim: g, serving (porsiyon = defaultServingGrams), piece (adet; pieceGrams yoksa porsiyon).
/// - Elle kcal girilirse kcal o değer olur, isManualOverride = true; makrolar gramdan hesaplanır.
/// - Sonuç SNAPSHOT olarak kayda yazılır. Yuvarlama 1 ondalık.
library;

import 'js_math.dart';

enum AmountUnit { g, serving, piece }

class FoodNutrients {
  const FoodNutrients({
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
  });
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbPer100g;
  final double fatPer100g;
  final double defaultServingGrams;
}

typedef FoodEntryValues = ({
  double grams,
  double kcal,
  double protein,
  double carb,
  double fat,
  bool isManualOverride,
});

enum FoodCalcError { invalidAmount, tooLarge, invalidManualKcal }

sealed class FoodCalcResult {
  const FoodCalcResult();
}

final class FoodCalcOk extends FoodCalcResult {
  const FoodCalcOk(this.values);
  final FoodEntryValues values;
  @override
  bool operator ==(Object o) => o is FoodCalcOk && o.values == values;
  @override
  int get hashCode => values.hashCode;
}

final class FoodCalcFailed extends FoodCalcResult {
  const FoodCalcFailed(this.error);
  final FoodCalcError error;
  @override
  bool operator ==(Object o) => o is FoodCalcFailed && o.error == error;
  @override
  int get hashCode => error.hashCode;
}

const maxEntryGrams = 10000; // DB: grams <= 10000
const maxManualKcal = 20000;

double _round1(double v) => jsRound(v * 10) / 10;

double gramsFor(FoodNutrients food, double amount, AmountUnit unit, {double? pieceGrams}) {
  switch (unit) {
    case AmountUnit.g:
      return amount;
    case AmountUnit.piece:
      return amount *
          (pieceGrams != null && pieceGrams > 0 ? pieceGrams : food.defaultServingGrams);
    case AmountUnit.serving:
      return amount * food.defaultServingGrams;
  }
}

FoodCalcResult foodEntryCalc(
  FoodNutrients food,
  double amount,
  AmountUnit unit, {
  double? pieceGrams,
  double? manualKcal,
}) {
  if (!amount.isFinite || amount <= 0) return const FoodCalcFailed(FoodCalcError.invalidAmount);

  final grams = _round1(gramsFor(food, amount, unit, pieceGrams: pieceGrams));
  if (grams <= 0) return const FoodCalcFailed(FoodCalcError.invalidAmount);
  if (grams > maxEntryGrams) return const FoodCalcFailed(FoodCalcError.tooLarge);

  final factor = grams / 100;
  final computedKcal = _round1(food.kcalPer100g * factor);

  var kcal = computedKcal;
  var isManualOverride = false;
  if (manualKcal != null) {
    if (!manualKcal.isFinite || manualKcal < 0 || manualKcal > maxManualKcal) {
      return const FoodCalcFailed(FoodCalcError.invalidManualKcal);
    }
    kcal = _round1(manualKcal);
    // Hesaplananla aynı değeri yazmak "elle değiştirme" sayılmaz
    isManualOverride = kcal != computedKcal;
  }

  return FoodCalcOk((
    grams: grams,
    kcal: kcal,
    protein: _round1(food.proteinPer100g * factor),
    carb: _round1(food.carbPer100g * factor),
    fat: _round1(food.fatPer100g * factor),
    isManualOverride: isManualOverride,
  ));
}
