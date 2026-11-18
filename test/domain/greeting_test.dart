import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/greeting.dart';
import 'package:missionfit/domain/nutrition.dart';

int at(int h, [int m = 0]) => h * 60 + m;

void main() {
  group('greetingFor', () {
    test('saat aralıkları ve sınırlar', () {
      expect(greetingFor(at(4, 59)), 'İyi geceler');
      expect(greetingFor(at(5)), 'Günaydın');
      expect(greetingFor(at(11, 59)), 'Günaydın');
      expect(greetingFor(at(12)), 'İyi günler');
      expect(greetingFor(at(18)), 'İyi akşamlar');
      expect(greetingFor(at(22)), 'İyi geceler');
      expect(greetingFor(at(0)), 'İyi geceler');
    });
  });

  group('suggestedMealFor', () {
    test('saate göre öğün', () {
      expect(suggestedMealFor(at(7)), Meal.breakfast);
      expect(suggestedMealFor(at(11)), Meal.lunch);
      expect(suggestedMealFor(at(16)), Meal.dinner);
      expect(suggestedMealFor(at(21)), Meal.snack);
      expect(suggestedMealFor(at(2)), Meal.snack);
    });
  });
}
