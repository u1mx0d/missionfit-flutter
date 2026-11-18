/// Saate göre selamlama ve öğün önerisi. RN `features/home/greeting.ts` karşılığı.
/// Girdi: gece yarısından itibaren dakika (kullanıcının saat diliminde).
library;

import 'nutrition.dart';

String greetingFor(int minutes) {
  final h = minutes ~/ 60;
  if (h >= 5 && h < 12) return 'Günaydın';
  if (h >= 12 && h < 18) return 'İyi günler';
  if (h >= 18 && h < 22) return 'İyi akşamlar';
  return 'İyi geceler';
}

Meal suggestedMealFor(int minutes) {
  final h = minutes ~/ 60;
  if (h >= 4 && h < 11) return Meal.breakfast;
  if (h >= 11 && h < 16) return Meal.lunch;
  if (h >= 16 && h < 21) return Meal.dinner;
  return Meal.snack;
}
