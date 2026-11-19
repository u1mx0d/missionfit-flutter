/// Ağırlık adımı kuralları (–/+ düğmeleri). Saf Dart.
library;

import 'units.dart';

/// Ekipmana göre adım, kullanıcının biriminde (kg: 2,5 / 2 / 5 / 5 / 4; lb: 5 / 5 / 10 / 10 / 5).
double weightStep(String equipment, WeightUnit unit) {
  final kg = unit == WeightUnit.kg;
  switch (equipment) {
    case 'dumbbell':
      return kg ? 2 : 5;
    case 'machine':
    case 'cable':
      return kg ? 5 : 10;
    case 'kettlebell':
      return kg ? 4 : 5;
    default: // barbell ve diğerleri
      return kg ? 2.5 : 5;
  }
}

/// Ağırlık alanı var mı: `weight_reps` ve ekipman `bodyweight`/`cardio` değil.
bool tracksWeight(String tracking, String equipment) =>
    tracking == 'weight_reps' && equipment != 'bodyweight' && equipment != 'cardio';

/// Kullanıcının biriminde bir adım atar, kg döndürür (0,1'e yuvarlı, alt sınır 0).
double stepWeight(double kg, int direction, String equipment, WeightUnit unit) {
  final next = fromKg(kg, unit) + direction * weightStep(equipment, unit);
  final result = toKg(next, unit);
  return result < 0 ? 0 : result;
}
