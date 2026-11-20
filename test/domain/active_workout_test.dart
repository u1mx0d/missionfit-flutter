import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/active_workout.dart';

PlannedExercise ex(String id, {int target = 3}) => PlannedExercise(
  exerciseId: id,
  tracking: 'weight_reps',
  equipment: 'barbell',
  targetSets: target,
  restSeconds: 90,
);

int _n = 0;
LoggedSet set(String exId, int order, int idx, {double? w, int? reps, int? dur}) => LoggedSet(
  id: 's${_n++}',
  exerciseId: exId,
  exerciseOrder: order,
  setIndex: idx,
  reps: reps,
  durationSeconds: dur,
  weightKg: w,
  completedAt: DateTime.utc(2026, 11, 19, 10),
);

ActiveWorkout base(List<PlannedExercise> plan, {String? current}) => ActiveWorkout(
  sessionId: 'sess',
  startedAt: DateTime.utc(2026, 11, 19, 9),
  plan: plan,
  sets: const [],
  currentExerciseId: current ?? (plan.isEmpty ? null : plan.first.exerciseId),
);

void main() {
  group('sıra', () {
    test('bench 2 set, dips 1 set, bench 3. set', () {
      var w = base([ex('bench'), ex('dips')]);
      expect(w.orderFor('bench'), 0);
      w = w.logSet(set('bench', w.orderFor('bench'), w.nextSetIndex('bench'), reps: 8));
      w = w.logSet(set('bench', w.orderFor('bench'), w.nextSetIndex('bench'), reps: 8));
      expect(w.orderFor('dips'), 1);
      w = w.select('dips');
      w = w.logSet(set('dips', w.orderFor('dips'), w.nextSetIndex('dips'), reps: 8));
      expect(w.orderFor('dips'), 1);
      w = w.select('bench');
      expect(w.orderFor('bench'), 0);
      expect(w.nextSetIndex('bench'), 3);
      expect(w.doneSets('bench'), 2);
    });

    test('silince aynı setIndex yeniden kullanılır', () {
      var w = base([ex('bench')]);
      final s3 = set('bench', 0, 3, reps: 5);
      w = w.logSet(set('bench', 0, 1, reps: 5)).logSet(set('bench', 0, 2, reps: 5)).logSet(s3);
      expect(w.nextSetIndex('bench'), 4);
      w = w.removeSet(s3.id);
      expect(w.nextSetIndex('bench'), 3);
    });

    test('50 sette StateError', () {
      var w = base([ex('bench')]);
      for (var i = 1; i <= 50; i++) {
        w = w.logSet(set('bench', 0, i, reps: 1));
      }
      expect(() => w.nextSetIndex('bench'), throwsStateError);
    });

    test('replaceSet aynı kimlikli seti değiştirir', () {
      final s = set('bench', 0, 1, reps: 5);
      var w = base([ex('bench')]).logSet(s);
      w = w.replaceSet(
        LoggedSet(
          id: s.id,
          exerciseId: 'bench',
          exerciseOrder: 0,
          setIndex: 1,
          reps: 9,
          weightKg: 50,
          completedAt: s.completedAt,
        ),
      );
      expect(w.sets.single.reps, 9);
    });
  });

  group('nextUp', () {
    test('current eksik: sıradaki set', () {
      var w = base([ex('bench'), ex('dips')])
          .logSet(set('bench', 0, 1, reps: 5))
          .logSet(set('bench', 0, 2, reps: 5));
      expect(w.nextUp(), (exerciseId: 'bench', setIndex: 3));
    });

    test('current tamam: sıradaki eksik hareket', () {
      var w = base([ex('bench', target: 1), ex('dips')]).logSet(set('bench', 0, 1, reps: 5));
      expect(w.nextUp(), (exerciseId: 'dips', setIndex: 1));
    });

    test('hepsi tamam: null', () {
      var w = base([ex('bench', target: 1), ex('dips', target: 1)])
          .logSet(set('bench', 0, 1, reps: 5))
          .logSet(set('dips', 1, 1, reps: 5));
      expect(w.nextUp(), isNull);
    });

    test('başa dönme', () {
      var w = base([
        ex('bench'),
        ex('dips', target: 1),
      ], current: 'dips').logSet(set('dips', 0, 1, reps: 5));
      expect(w.nextUp(), (exerciseId: 'bench', setIndex: 1));
    });

    test('boş plan: null', () {
      expect(base([]).nextUp(), isNull);
    });
  });

  group('addExercise', () {
    test('aynı hareket iki kez eklenince değişmez', () {
      final w = base([ex('bench')]);
      final a = w.addExercise(ex('dips'));
      expect(a.plan.map((e) => e.exerciseId), ['bench', 'dips']);
      expect(a.currentExerciseId, 'dips');
      expect(a.addExercise(ex('dips')), a);
      expect(a.select('bench').addExercise(ex('dips')).currentExerciseId, 'bench');
    });

    test('değer eşitliği', () {
      expect(base([ex('bench')]), base([ex('bench')]));
      expect(base([ex('bench')]).hashCode, base([ex('bench')]).hashCode);
      expect(base([ex('bench')]) == base([ex('dips')]), isFalse);
    });
  });

  group('prefill', () {
    final last = [
      set('bench', 0, 1, w: 60, reps: 8),
      set('bench', 0, 2, w: 60, reps: 7),
      set('bench', 0, 3, w: 55, reps: 6),
    ];

    test('bu antrenmanda set yokken geçen antrenmanın aynı setIndex seti', () {
      final w = base([ex('bench')]);
      // Sıradaki set 1: geçen antrenmanın 1. seti
      expect(prefill('bench', w, last), const SetValues(weightKg: 60, reps: 8));
    });

    test('aynı setIndex yoksa geçen antrenmanın son seti', () {
      final w = base([ex('bench')]);
      // Geçen antrenmanda 1. set yok (yalnızca 2. ve 3.): son set (3.)
      expect(prefill('bench', w, last.sublist(1)), const SetValues(weightKg: 55, reps: 6));
    });

    test('bu antrenmandaki son set, geçen antrenmandan önceliklidir', () {
      final w = base([ex('bench')]).logSet(set('bench', 0, 1, w: 62.5, reps: 8));
      expect(prefill('bench', w, last), const SetValues(weightKg: 62.5, reps: 8));
    });

    test('hiçbiri yoksa boş', () {
      expect(prefill('bench', base([ex('bench')]), const []), const SetValues());
    });

    test('diğer hareketin geçmişi kullanılmaz', () {
      expect(prefill('dips', base([ex('dips')]), last), const SetValues());
    });
  });

  group('targetSetsFor', () {
    test('öncelik', () {
      expect(targetSetsFor(templateSets: 4), 4);
      expect(targetSetsFor(lastSessionSetCount: 5), 5);
      expect(targetSetsFor(), 3);
      expect(targetSetsFor(templateSets: 4, lastSessionSetCount: 5), 4);
    });
  });

  test('PlannedExercise JSON gidiş-dönüş', () {
    final e = ex('bench', target: 4);
    expect(PlannedExercise.fromJson(e.toJson()), e);
  });

  test('isStaleWorkout: 24 saatten eski', () {
    final start = DateTime.utc(2026, 11, 19, 10);
    expect(isStaleWorkout(start, start.add(const Duration(hours: 23, minutes: 59))), isFalse);
    expect(isStaleWorkout(start, start.add(const Duration(hours: 24))), isFalse);
    expect(isStaleWorkout(start, start.add(const Duration(hours: 24, seconds: 1))), isTrue);
    expect(isStaleWorkout(start, start.toLocal().add(const Duration(days: 3))), isTrue);
  });
}
