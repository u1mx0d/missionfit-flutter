/// Türkçe gün/ay adlarıyla tarih etiketi (Intl'e bağımlı değil).
library;

import 'dates.dart';

const _days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _months = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// "2026-11-18" → "Çarşamba, 18 Kasım".
String formatTurkishDate(LocalDate date) {
  final month = int.parse(date.substring(5, 7));
  final day = int.parse(date.substring(8, 10));
  return '${_days[isoWeekday(date) - 1]}, $day ${_months[month - 1]}';
}

/// Geçen gün sayısı: 0 → "bugün", 1 → "dün", n → "n gün önce".
String daysAgoLabel(LocalDate date, LocalDate today) {
  final d = diffDays(date, today);
  if (d <= 0) return 'bugün';
  if (d == 1) return 'dün';
  return '$d gün önce';
}

/// "2026-11-16".."2026-11-22" → "16–22 Kasım"; ay değişirse "30 Kasım – 6 Aralık".
String formatDayRange(LocalDate start, LocalDate end) {
  final sm = int.parse(start.substring(5, 7)), em = int.parse(end.substring(5, 7));
  final sd = int.parse(start.substring(8, 10)), ed = int.parse(end.substring(8, 10));
  if (sm == em) return '$sd–$ed ${_months[em - 1]}';
  return '$sd ${_months[sm - 1]} – $ed ${_months[em - 1]}';
}
