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

double _round1(double v) => (v * 10).round() / 10;

/// Kullanıcı biriminde, ızgaraya (ekipman adımı) en çok 0,15 uzaklıktaki değeri ızgaraya oturtur.
/// kg ↔ lb dönüşümünün yuvarlama hatasını giderir (61,2 kg → 134,9 lb → 135 lb); gerçekten
/// ızgara dışında olan değer (61,2 kg, 137,3 lb) korunur.
double snapToStep(double value, String equipment, WeightUnit unit) {
  final step = weightStep(equipment, unit);
  final near = (value / step).round() * step;
  return _round1((value - near).abs() <= 0.15 ? near : value);
}

/// Kullanıcı biriminde bir adım atar ve sonucu kullanıcı biriminde döndürür (alt sınır 0).
/// Taslak değer bu birimde tutulur; kg'ye yalnızca set yazılırken çevrilir (kayma olmaz).
double stepInUnit(double value, int direction, String equipment, WeightUnit unit) {
  final next = snapToStep(value + direction * weightStep(equipment, unit), equipment, unit);
  return next < 0 ? 0 : next;
}

/// Kayıtlı kg'yi kullanıcı biriminde gösterim değerine çevirir (bir kez, ızgaraya oturtarak).
double shownWeight(double kg, String equipment, WeightUnit unit) =>
    snapToStep(fromKg(kg, unit), equipment, unit);
