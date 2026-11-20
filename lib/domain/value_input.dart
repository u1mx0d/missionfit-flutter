/// Odak modunda değere dokunarak yazılan girişin çözümlenmesi. Saf Dart.
/// Sınırlar sunucu kurallarıyla aynı: ağırlık 0–1000 kg, tekrar 1–500, süre 1–86400 sn.
library;

import 'units.dart';

/// Çözümleme sonucu: [value] dolu ya da [error] (satır içi gösterilecek Türkçe ileti).
typedef Parsed<T> = ({T? value, String? error});

/// Ağırlık, KULLANICININ BİRİMİNDE. Virgül ya da nokta ondalık ayırıcı olabilir; sonuç
/// 0,1'e yuvarlanır (adım ızgarasına oturtulmaz). 1000 kg karşılığını aşamaz.
Parsed<double> parseWeightInput(String text, WeightUnit unit) {
  final s = text.trim().replaceAll(',', '.');
  final v = RegExp(r'^\d+(\.\d+)?$').hasMatch(s) ? double.tryParse(s) : null;
  final max = unit == WeightUnit.kg ? '1000 kg' : '${_fmt(fromKg(1000, unit))} lb';
  if (v == null) return (value: null, error: 'Bir sayı gir (ör. 62,5).');
  final r = (v * 10).round() / 10;
  if (toKg(r, unit) > 1000) return (value: null, error: 'En fazla $max.');
  return (value: r, error: null);
}

/// Tekrar: 1–500 arası tam sayı.
Parsed<int> parseRepsInput(String text) {
  final s = text.trim();
  final v = RegExp(r'^\d+$').hasMatch(s) ? int.tryParse(s) : null;
  if (v == null) return (value: null, error: 'Tam sayı gir (ör. 8).');
  if (v < 1 || v > 500) return (value: null, error: '1 ile 500 arasında olmalı.');
  return (value: v, error: null);
}

/// Süre, ekrandaki biçimle aynı: "dk:sn" (ör. 1:30), bir saati aşınca "sa:dk:sn".
/// İki noktasız tek sayı saniye sayılır. 1 sn – 24 sa (86400 sn).
Parsed<int> parseDurationInput(String text) {
  const bad = (value: null, error: 'Süreyi dk:sn olarak gir (ör. 1:30).');
  final parts = text.trim().split(':');
  if (parts.length > 3 || parts.any((p) => !RegExp(r'^\d+$').hasMatch(p))) return bad;
  final n = parts.map(int.parse).toList();
  // İlk alan dışındakiler 0–59.
  if (n.skip(1).any((x) => x > 59)) return bad;
  final secs = n.fold(0, (a, x) => a * 60 + x);
  if (secs < 1 || secs > 86400) {
    return (value: null, error: '1 sn ile 24 saat arasında olmalı.');
  }
  return (value: secs, error: null);
}

String _fmt(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1).replaceAll('.', ',');
