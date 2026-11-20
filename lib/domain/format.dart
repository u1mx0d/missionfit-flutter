/// Türkçe metin biçimlendirme yardımcıları (RN `src/domain/format.ts` karşılığı).
/// Saf; Intl'e bağımlı değil (cihazdan bağımsız, test edilebilir).
library;

import 'js_math.dart';

/// 1850 → "1.850" (Türkçe binlik ayırıcı nokta). Tam sayıya yuvarlar.
String formatInt(num value) {
  final n = jsRound(value);
  final sign = n < 0 ? '-' : '';
  final digits = n.abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '$sign$digits';
}

/// ["sırt"] → "sırt"; ["sırt","bacak"] → "sırt ve bacak"; 3+ → "a, b ve c".
String joinTurkish(List<String> items) {
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  return '${items.sublist(0, items.length - 1).join(', ')} ve ${items.last}';
}

/// Saniyeyi "1 sa 05 dk" / "12 dk" / "45 sn" biçimine çevirir.
String formatDuration(num totalSeconds) {
  final s = totalSeconds.floor() < 0 ? 0 : totalSeconds.floor();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  if (h > 0) return '$h sa ${m.toString().padLeft(2, '0')} dk';
  if (m > 0) return '$m dk';
  return '$s sn';
}

/// Sayaç görünümü: 3725 → "1:02:05", 65 → "01:05".
String formatClock(num totalSeconds) {
  final s = totalSeconds.floor() < 0 ? 0 : totalSeconds.floor();
  final h = s ~/ 3600;
  final mm = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
  final ss = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// 62.5 → "62,5", 60.0 → "60" (Türkçe ondalık virgül).
String formatAmount(double v) {
  final r = (v * 10).round() / 10;
  return r == r.truncateToDouble()
      ? r.toInt().toString()
      : r.toStringAsFixed(1).replaceAll('.', ',');
}

/// 45 → "0:45", 125 → "2:05", 3725 → "1:02:05".
String formatSeconds(int s) {
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final ss = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}
