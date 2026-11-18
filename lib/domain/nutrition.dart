/// Günlük beslenme özeti (algoritma 7). RN `src/domain/nutrition.ts` karşılığı.
///
/// - Toplamlar kayıtlardaki SNAPSHOT değerlerden toplanır.
/// - Makro yüzdeleri ENERJİ payıdır (4/4/9) ve toplamı 100 olacak şekilde yuvarlanır.
/// - Kalan = hedef − alınan; tahmini yakılan EKLENMEZ. Aşımda remaining 0, aşım `over`'da.
library;

import 'js_math.dart';

enum Meal { breakfast, lunch, dinner, snack }

const meals = Meal.values;

const mealLabels = <Meal, String>{
  Meal.breakfast: 'Kahvaltı',
  Meal.lunch: 'Öğle',
  Meal.dinner: 'Akşam',
  Meal.snack: 'Atıştırmalık',
};

class NutritionEntry {
  const NutritionEntry({
    required this.meal,
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });
  final Meal meal;
  final double kcal;
  final double protein;
  final double carb;
  final double fat;
}

typedef Totals = ({double kcal, double protein, double carb, double fat});
typedef MealTotals = ({double kcal, double protein, double carb, double fat, int count});
typedef MacroPercent = ({int protein, int carb, int fat});

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.totals,
    required this.byMeal,
    required this.macroPercent,
    required this.target,
    required this.remaining,
    required this.over,
    required this.progress,
  });
  final Totals totals;
  final Map<Meal, MealTotals> byMeal;

  /// Enerji payı yüzdeleri (toplam 100, hiç makro yoksa hepsi 0)
  final MacroPercent macroPercent;
  final int? target;
  final int? remaining;
  final int over;

  /// 0..1 (halka için), hedef yoksa null
  final double? progress;
}

double _round1(double v) => jsRound(v * 10) / 10;

/// Toplamı tam 100 olacak şekilde yüzdeleri yuvarlar (largest remainder).
List<int> roundPercentages(List<double> values) {
  final total = values.fold<double>(0, (a, b) => a + b);
  if (total <= 0) return [for (final _ in values) 0];
  final raw = [for (final v in values) v / total * 100];
  final floors = [for (final v in raw) v.floor()];
  var rest = 100 - floors.fold<int>(0, (a, b) => a + b);
  final order = [for (var i = 0; i < raw.length; i++) (i: i, frac: raw[i] - raw[i].floor())]
    ..sort((a, b) {
      // JS sort kararlı: eşit kesirde önceki indeks önce gelir.
      final byFrac = b.frac.compareTo(a.frac);
      return byFrac != 0 ? byFrac : a.i.compareTo(b.i);
    });
  for (final o in order) {
    if (rest <= 0) break;
    floors[o.i] += 1;
    rest -= 1;
  }
  return floors;
}

double _clean(double v) => v.isFinite && v > 0 ? v : 0;

DailyNutritionSummary dailyNutritionSummary(List<NutritionEntry> entries, int? target) {
  var k = 0.0, p = 0.0, c = 0.0, f = 0.0;
  final acc = {
    for (final m in meals) m: [0.0, 0.0, 0.0, 0.0, 0.0],
  };
  for (final e in entries) {
    final v = [_clean(e.kcal), _clean(e.protein), _clean(e.carb), _clean(e.fat)];
    k += v[0];
    p += v[1];
    c += v[2];
    f += v[3];
    final a = acc[e.meal]!;
    for (var i = 0; i < 4; i++) {
      a[i] += v[i];
    }
    a[4] += 1;
  }
  final Totals totals = (kcal: _round1(k), protein: _round1(p), carb: _round1(c), fat: _round1(f));
  final byMeal = {
    for (final m in meals)
      m: (
        kcal: _round1(acc[m]![0]),
        protein: _round1(acc[m]![1]),
        carb: _round1(acc[m]![2]),
        fat: _round1(acc[m]![3]),
        count: acc[m]![4].toInt(),
      ),
  };

  final pct = roundPercentages([totals.protein * 4, totals.carb * 4, totals.fat * 9]);
  final validTarget = target != null && target > 0 ? target : null;
  final consumed = jsRound(totals.kcal);
  return DailyNutritionSummary(
    totals: totals,
    byMeal: byMeal,
    macroPercent: (protein: pct[0], carb: pct[1], fat: pct[2]),
    target: validTarget,
    remaining: validTarget == null ? null : (validTarget - consumed).clamp(0, 1 << 31),
    over: validTarget == null ? 0 : (consumed - validTarget).clamp(0, 1 << 31),
    progress: validTarget == null ? null : (consumed / validTarget).clamp(0, 1).toDouble(),
  );
}
