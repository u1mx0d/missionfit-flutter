import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/workout_summary.dart';

void main() {
  final t0 = DateTime.parse('2026-11-03T10:00:00Z');
  final t1 = DateTime.parse('2026-11-03T11:00:00Z');

  group('volumeKg', () {
    test('yalnızca ağırlık ve tekrarı olan setler', () {
      expect(
        volumeKg([
          (reps: 10, weightKg: 60.0),
          (reps: 8, weightKg: 62.5),
          (reps: 15, weightKg: null),
          (reps: null, weightKg: 20.0),
        ]),
        1100,
      );
    });
  });

  group('summarizeWorkout', () {
    test('kcal, hacim, set ve egzersiz sayısı', () {
      final s = summarizeWorkout(
        startedAt: t0,
        endedAt: t1,
        weightKg: 80,
        sets: const [
          SummarySet(exerciseId: 'a', met: 5, reps: 10, weightKg: 100),
          SummarySet(exerciseId: 'a', met: 5, reps: 10, weightKg: 100),
          SummarySet(exerciseId: 'b', met: 3, durationSeconds: 60),
        ],
      );
      expect(
        s,
        const WorkoutSummary(
          durationSeconds: 3600,
          durationCapped: false,
          kcal: 347,
          volumeKg: 2000,
          setCount: 3,
          exerciseCount: 2,
        ),
      );
    });

    test('kilo yoksa kcal null, süre yine hesaplanır', () {
      final s = summarizeWorkout(startedAt: t0, endedAt: t1, weightKg: null, sets: const []);
      expect(s.kcal, isNull);
      expect(s.durationSeconds, 3600);
    });

    test('4 saati aşan süre sınırlanır', () {
      final s = summarizeWorkout(
        startedAt: t0,
        endedAt: DateTime.parse('2026-11-03T16:00:00Z'),
        weightKg: null,
        sets: const [],
      );
      expect(s.durationSeconds, 4 * 3600);
      expect(s.durationCapped, isTrue);
    });
  });
}
