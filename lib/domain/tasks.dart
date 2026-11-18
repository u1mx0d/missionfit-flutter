/// Görev planı (algoritma 8). RN `src/domain/tasks.ts` karşılığı.
///
/// Tekrar: once / daily / weekly (1 = Pzt ... 7 = Paz). Bildirim planı önümüzdeki 7 gün, en çok 60
/// bildirim; geçmiş saatler atlanır; yaz saati güvenli ([zonedTimeToUtc]).
library;

import 'dates.dart';

sealed class RepeatRule {
  const RepeatRule();
}

final class Once extends RepeatRule {
  const Once();
  @override
  bool operator ==(Object other) => other is Once;
  @override
  int get hashCode => 1;
}

final class Daily extends RepeatRule {
  const Daily();
  @override
  bool operator ==(Object other) => other is Daily;
  @override
  int get hashCode => 2;
}

final class Weekly extends RepeatRule {
  const Weekly(this.days);
  final List<int> days;
  @override
  bool operator ==(Object other) =>
      other is Weekly &&
      other.days.length == days.length &&
      Iterable<int>.generate(days.length).every((i) => other.days[i] == days[i]);
  @override
  int get hashCode => Object.hashAll(days);
}

class TaskDef {
  const TaskDef({
    required this.id,
    required this.title,
    required this.time,
    required this.repeatRule,
    required this.startDate,
    required this.isActive,
  });
  final String id;
  final String title;

  /// "HH:MM" veya "HH:MM:SS" ya da null (saatsiz görev)
  final String? time;
  final RepeatRule repeatRule;
  final LocalDate startDate;
  final bool isActive;
}

class TaskCompletion {
  const TaskCompletion(this.taskId, this.localDate);
  final String taskId;
  final LocalDate localDate;
}

class TaskOccurrence {
  const TaskOccurrence({
    required this.taskId,
    required this.title,
    required this.localDate,
    required this.minutes,
    required this.completed,
    required this.overdue,
  });
  final String taskId;
  final String title;
  final LocalDate localDate;

  /// Gece yarısından itibaren dakika; saatsiz görevde null
  final int? minutes;
  final bool completed;
  final bool overdue;
}

/// Sunucudaki `repeat_rule` JSON'unu çözümler; bozuksa null.
RepeatRule? parseRepeatRule(Object? value) {
  if (value is! Map) return null;
  final type = value['type'];
  if (type == 'once') return const Once();
  if (type == 'daily') return const Daily();
  final raw = value['days'];
  if (type == 'weekly' && raw is List) {
    final days = {
      for (final d in raw)
        if (d is int && d >= 1 && d <= 7) d,
    }.toList()..sort();
    return days.isEmpty ? null : Weekly(days);
  }
  return null;
}

bool occursOn(TaskDef task, LocalDate date) {
  if (!task.isActive || !isLocalDate(task.startDate) || date.compareTo(task.startDate) < 0) {
    return false;
  }
  return switch (task.repeatRule) {
    Once() => date == task.startDate,
    Daily() => true,
    Weekly(:final days) => days.contains(isoWeekday(date)),
  };
}

Set<String> completionSet(List<TaskCompletion> completions) => {
  for (final c in completions) '${c.taskId}|${c.localDate}',
};

List<TaskOccurrence> tasksForDate(
  List<TaskDef> tasks,
  List<TaskCompletion> completions,
  LocalDate date,
  ({LocalDate today, int minutes}) now,
) {
  final done = completionSet(completions);
  final list = [
    for (final t in tasks)
      if (occursOn(t, date)) _occurrence(t, date, done, now),
  ];
  list.sort((a, b) {
    if (a.minutes == null && b.minutes != null) return 1;
    if (a.minutes != null && b.minutes == null) return -1;
    final byTime = (a.minutes ?? 0) - (b.minutes ?? 0);
    // RN: localeCompare('tr'); burada kod noktası sırası.
    return byTime != 0 ? byTime : a.title.compareTo(b.title);
  });
  return list;
}

TaskOccurrence _occurrence(
  TaskDef t,
  LocalDate date,
  Set<String> done,
  ({LocalDate today, int minutes}) now,
) {
  final minutes = parseLocalTime(t.time);
  final completed = done.contains('${t.id}|$date');
  final overdue =
      !completed &&
      (date.compareTo(now.today) < 0 ||
          (date == now.today && minutes != null && minutes < now.minutes));
  return TaskOccurrence(
    taskId: t.id,
    title: t.title,
    localDate: date,
    minutes: minutes,
    completed: completed,
    overdue: overdue,
  );
}

({LocalDate today, int minutes}) nowInZone(DateTime instant, String timeZone) {
  final minutes = parseLocalTime(localTimeInZone(instant, timeZone))!;
  return (today: localDateInZone(instant, timeZone), minutes: minutes);
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.taskId,
    required this.title,
    required this.localDate,
    required this.fireAt,
  });

  /// Kararlı kimlik: aynı görev+gün için her planlamada aynı (iptal/yeniden planlama için)
  final String id;
  final String taskId;
  final String title;
  final LocalDate localDate;
  final DateTime fireAt;
}

List<PlannedNotification> notificationPlan({
  required List<TaskDef> tasks,
  required List<TaskCompletion> completions,
  required DateTime now,
  required String timeZone,
  required num leadMinutes,
  int days = 7,
  int limit = 60,
}) {
  final lead = leadMinutes.floor() < 0 ? 0 : leadMinutes.floor();
  final today = localDateInZone(now, timeZone);
  final done = completionSet(completions);
  final nowMs = now.millisecondsSinceEpoch;
  final out = <PlannedNotification>[];

  for (final date in daysBetween(today, addDays(today, days - 1))) {
    for (final task in tasks) {
      if (!occursOn(task, date) || done.contains('${task.id}|$date')) continue;
      final minutes = parseLocalTime(task.time);
      if (minutes == null) continue;
      final taskAt = zonedTimeToUtc(date, minutes, timeZone);
      if (taskAt.millisecondsSinceEpoch <= nowMs) continue; // görev saati geçti
      var fireAt = taskAt.subtract(Duration(minutes: lead));
      if (fireAt.millisecondsSinceEpoch <= nowMs) fireAt = taskAt;
      out.add(
        PlannedNotification(
          id: '${task.id}:$date',
          taskId: task.id,
          title: task.title,
          localDate: date,
          fireAt: fireAt,
        ),
      );
    }
  }
  // Kararlı sıralama (JS sort kararlı): eşit zamanda ekleme sırası korunur.
  final indexed = [for (var i = 0; i < out.length; i++) (i: i, n: out[i])]
    ..sort((a, b) {
      final c = a.n.fireAt.compareTo(b.n.fireAt);
      return c != 0 ? c : a.i.compareTo(b.i);
    });
  return [for (final x in indexed.take(limit)) x.n];
}
