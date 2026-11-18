/// Görev serisi ve haftalık oran (algoritma 9). RN `src/domain/streak.ts` karşılığı.
///
/// Gün = o günün planlı görevlerinin hepsi tamam. Planlı görevi olmayan gün atlanır.
/// Bugün henüz eksikse seri bozulmaz (dünden sayılır).
library;

import 'dates.dart';
import 'tasks.dart';
import 'week.dart';

({int scheduled, int completed}) dayStatus(List<TaskDef> tasks, Set<String> done, LocalDate date) {
  var scheduled = 0, completed = 0;
  for (final t in tasks) {
    if (!occursOn(t, date)) continue;
    scheduled += 1;
    if (done.contains('${t.id}|$date')) completed += 1;
  }
  return (scheduled: scheduled, completed: completed);
}

({int current, bool todayComplete}) taskStreak(
  List<TaskDef> tasks,
  List<TaskCompletion> completions,
  LocalDate today, [
  int maxLookbackDays = 365,
]) {
  final done = completionSet(completions);
  final t = dayStatus(tasks, done, today);
  final todayComplete = t.scheduled > 0 && t.completed == t.scheduled;

  var current = todayComplete ? 1 : 0;
  for (var i = 1; i <= maxLookbackDays; i++) {
    final s = dayStatus(tasks, done, addDays(today, -i));
    if (s.scheduled == 0) continue;
    if (s.completed == s.scheduled) {
      current += 1;
    } else {
      break;
    }
  }
  return (current: current, todayComplete: todayComplete);
}

({int scheduled, int completed, double? rate}) weeklyCompletionRate(
  List<TaskDef> tasks,
  List<TaskCompletion> completions,
  DateRange window,
  LocalDate today,
) {
  final done = completionSet(completions);
  final last = today.compareTo(window.end) < 0 ? today : window.end;
  var scheduled = 0, completed = 0;
  if (last.compareTo(window.start) >= 0) {
    for (final date in daysBetween(window.start, last)) {
      final s = dayStatus(tasks, done, date);
      scheduled += s.scheduled;
      completed += s.completed;
    }
  }
  return (
    scheduled: scheduled,
    completed: completed,
    rate: scheduled == 0 ? null : completed / scheduled,
  );
}
