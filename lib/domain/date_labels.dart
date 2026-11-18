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
