import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/streak.dart';
import 'package:missionfit/domain/tasks.dart';
import 'package:missionfit/domain/week.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

const tzName = 'Europe/Istanbul';

TaskDef task(
  String id, {
  String? title,
  String? time,
  RepeatRule repeatRule = const Daily(),
  String startDate = '2026-11-01',
  bool isActive = true,
}) => TaskDef(
  id: id,
  title: title ?? id,
  time: time,
  repeatRule: repeatRule,
  startDate: startDate,
  isActive: isActive,
);

DateTime utc(String iso) => DateTime.parse(iso).toUtc();

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('parseRepeatRule', () {
    test('geçerli biçimler', () {
      expect(parseRepeatRule({'type': 'once'}), const Once());
      expect(
        parseRepeatRule({
          'type': 'weekly',
          'days': [5, 1, 1, 3],
        }),
        const Weekly([1, 3, 5]),
      );
    });

    test('bozuk biçimler null', () {
      expect(parseRepeatRule(null), isNull);
      expect(parseRepeatRule({'type': 'monthly'}), isNull);
      expect(parseRepeatRule({'type': 'weekly', 'days': <Object>[]}), isNull);
      expect(
        parseRepeatRule({
          'type': 'weekly',
          'days': [0, 8, 'x'],
        }),
        isNull,
      );
    });
  });

  group('occursOn', () {
    test('tek seferlik yalnızca başlangıç günü', () {
      final t = task('a', repeatRule: const Once(), startDate: '2026-11-03');
      expect(occursOn(t, '2026-11-03'), isTrue);
      expect(occursOn(t, '2026-11-04'), isFalse);
    });

    test('günlük: başlangıçtan önce yok', () {
      final t = task('a', startDate: '2026-11-03');
      expect(occursOn(t, '2026-11-02'), isFalse);
      expect(occursOn(t, '2026-12-25'), isTrue);
    });

    test('haftalık belirli günler', () {
      final t = task('a', repeatRule: const Weekly([1, 3]));
      expect(occursOn(t, '2026-11-02'), isTrue);
      expect(occursOn(t, '2026-11-03'), isFalse);
      expect(occursOn(t, '2026-11-04'), isTrue);
    });

    test('pasif görev hiç oluşmaz', () {
      expect(occursOn(task('a', isActive: false), '2026-11-03'), isFalse);
    });
  });

  group('tasksForDate', () {
    final tasks = [
      task('vitamin', title: 'Vitamin al', time: '09:00:00'),
      task('su', title: 'Su iç'),
      task('yuruyus', title: 'Yürüyüş', time: '18:30'),
      task('erken', title: 'Esneme', time: '07:15'),
    ];

    test('saat sırası, saatsizler sonda', () {
      final list = tasksForDate(tasks, [], '2026-11-03', (today: '2026-11-03', minutes: 8 * 60));
      expect(list.map((t) => t.taskId).toList(), ['erken', 'vitamin', 'yuruyus', 'su']);
    });

    test('geciken: saati geçmiş ve tamamlanmamış', () {
      final list = tasksForDate(
        tasks,
        [const TaskCompletion('erken', '2026-11-03')],
        '2026-11-03',
        (today: '2026-11-03', minutes: 10 * 60),
      );
      final byId = {for (final t in list) t.taskId: t};
      expect(byId['erken']!.completed, isTrue);
      expect(byId['erken']!.overdue, isFalse);
      expect(byId['vitamin']!.overdue, isTrue);
      expect(byId['yuruyus']!.overdue, isFalse);
      expect(byId['su']!.overdue, isFalse);
    });

    test('geçmiş gün: tamamlanmayanlar gecikmiş', () {
      final list = tasksForDate(tasks, [], '2026-11-02', (today: '2026-11-03', minutes: 0));
      expect(list.every((t) => t.overdue), isTrue);
    });
  });

  group('nowInZone', () {
    test('İstanbul', () {
      expect(nowInZone(utc('2026-11-02T21:30:00Z'), tzName), (today: '2026-11-03', minutes: 30));
    });
  });

  group('notificationPlan', () {
    final now = utc('2026-11-03T05:55:00Z'); // İstanbul 08:55

    test('geçmiş saat atlanır, öncesi dakika uygulanır, sıralı', () {
      final plan = notificationPlan(
        tasks: [
          task('erken', time: '07:00'),
          task('aksam', time: '20:00'),
        ],
        completions: [],
        now: now,
        timeZone: tzName,
        leadMinutes: 10,
        days: 2,
      );
      expect(plan.map((p) => p.id).toList(), [
        'aksam:2026-11-03',
        'erken:2026-11-04',
        'aksam:2026-11-04',
      ]);
      expect(plan[0].fireAt.toIso8601String(), '2026-11-03T16:50:00.000Z');
    });

    test('öncesi süre geçti ama görev saati gelmediyse görev saatinde', () {
      final plan = notificationPlan(
        tasks: [task('vitamin', time: '09:00', repeatRule: const Once(), startDate: '2026-11-03')],
        completions: [],
        now: now,
        timeZone: tzName,
        leadMinutes: 10,
      );
      expect(plan, hasLength(1));
      expect(plan[0].fireAt.toIso8601String(), '2026-11-03T06:00:00.000Z');
    });

    test('tamamlanan, saatsiz ve pasif görevler atlanır', () {
      final plan = notificationPlan(
        tasks: [
          task('a', time: '12:00'),
          task('b'),
          task('c', time: '12:00', isActive: false),
        ],
        completions: [const TaskCompletion('a', '2026-11-03')],
        now: now,
        timeZone: tzName,
        leadMinutes: 0,
        days: 1,
      );
      expect(plan, isEmpty);
    });

    test('limit: en yakın N bildirim', () {
      final tasks = List.generate(20, (i) => task('t$i', time: '12:00'));
      final plan = notificationPlan(
        tasks: tasks,
        completions: [],
        now: now,
        timeZone: tzName,
        leadMinutes: 0,
        days: 7,
        limit: 60,
      );
      expect(plan, hasLength(60));
      expect(plan[59].localDate, '2026-11-05');
    });

    test('kimlikler her planlamada aynı (iptal/yeniden planlama için kararlı)', () {
      List<PlannedNotification> run() => notificationPlan(
        tasks: [task('a', time: '12:00')],
        completions: [],
        now: now,
        timeZone: tzName,
        leadMinutes: 5,
        days: 1,
      );
      expect(run()[0].id, run()[0].id);
    });

    test('yaz saati günü (Berlin, 29 Mart 02:30 yok) → 03:30 a planlanır', () {
      final plan = notificationPlan(
        tasks: [task('a', time: '02:30', startDate: '2026-03-01')],
        completions: [],
        now: utc('2026-03-28T22:00:00Z'),
        timeZone: 'Europe/Berlin',
        leadMinutes: 0,
        days: 2,
      );
      expect(plan[0].fireAt.toIso8601String(), '2026-03-29T01:30:00.000Z');
    });
  });

  group('taskStreak', () {
    final tasks = [task('su', startDate: '2026-10-01')];
    List<TaskCompletion> done(List<String> dates) => [
      for (final d in dates) TaskCompletion('su', d),
    ];

    test('bugün eksik → seri dünden sayılır, bozulmaz', () {
      expect(taskStreak(tasks, done(['2026-11-01', '2026-11-02']), '2026-11-03'), (
        current: 2,
        todayComplete: false,
      ));
    });

    test('bugün tamam → bugün de sayılır', () {
      expect(
        taskStreak(tasks, done(['2026-11-01', '2026-11-02', '2026-11-03']), '2026-11-03').current,
        3,
      );
    });

    test('boşluk seriyi bozar', () {
      expect(taskStreak(tasks, done(['2026-10-30', '2026-11-02']), '2026-11-03').current, 1);
    });

    test('planlı görevi olmayan günler atlanır', () {
      final weekly = [
        task('su', repeatRule: const Weekly([1, 3]), startDate: '2026-10-01'),
      ];
      expect(
        taskStreak(weekly, done(['2026-10-28', '2026-11-02', '2026-11-04']), '2026-11-04').current,
        3,
      );
    });

    test('çok görevli gün: biri eksikse gün tamam değil', () {
      final two = [...tasks, task('vitamin', startDate: '2026-10-01')];
      final completions = [
        ...done(['2026-11-02']),
        const TaskCompletion('vitamin', '2026-11-01'),
        ...done(['2026-11-01']),
      ];
      expect(taskStreak(two, completions, '2026-11-03').current, 0);
      final allDone = [...completions, const TaskCompletion('vitamin', '2026-11-02')];
      expect(taskStreak(two, allDone, '2026-11-03').current, 2);
    });

    test('hiç görev yok', () {
      expect(taskStreak([], [], '2026-11-03'), (current: 0, todayComplete: false));
    });
  });

  group('weeklyCompletionRate', () {
    final tasks = [task('su', startDate: '2026-10-01')];
    final w = weekWindowForDate('2026-11-04', WeekStartsOn.monday);

    test('yalnızca bugüne kadarki günler', () {
      final r = weeklyCompletionRate(
        tasks,
        [const TaskCompletion('su', '2026-11-02')],
        w,
        '2026-11-04',
      );
      expect(r, (scheduled: 3, completed: 1, rate: 1 / 3));
    });

    test('planlı görev yoksa oran null', () {
      expect(weeklyCompletionRate([], [], w, '2026-11-04').rate, isNull);
    });

    test('geçmiş hafta tümüyle sayılır', () {
      expect(weeklyCompletionRate(tasks, [], w, '2026-11-20').scheduled, 7);
    });
  });
}
