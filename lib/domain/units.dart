/// Birim çevirme. Saf fonksiyonlar (RN `src/domain/units.ts` karşılığı).
/// Veritabanında ağırlık HER ZAMAN kg saklanır; lb yalnızca gösterim/giriş birimidir.
/// 1 lb = 0.45359237 kg (uluslararası tanım, tam değer).
library;

import 'js_math.dart';

enum WeightUnit { kg, lb }

const kgPerLb = 0.45359237;

double _round1(double v) => jsRound(v * 10) / 10;

double kgToLb(double kg) => kg / kgPerLb;

double lbToKg(double lb) => lb * kgPerLb;

/// Kullanıcı biriminden kg'ye (DB'ye yazılacak değer, 1 ondalık).
double toKg(double value, WeightUnit unit) =>
    _round1(unit == WeightUnit.kg ? value : lbToKg(value));

/// kg'den kullanıcı birimine (gösterim, 1 ondalık).
double fromKg(double kg, WeightUnit unit) => _round1(unit == WeightUnit.kg ? kg : kgToLb(kg));

/// 72.5 → "72,5 kg" / "159,8 lb" (Türkçe ondalık virgül).
String formatWeight(double kg, WeightUnit unit) {
  final v = fromKg(kg, unit);
  final text = v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(1).replaceAll('.', ',');
  return '$text ${unit.name}';
}
