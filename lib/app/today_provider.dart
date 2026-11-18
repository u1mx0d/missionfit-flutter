import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dates.dart';
import 'profile_controller.dart';

/// Profildeki saat diliminde bugünün tarihi ve gece yarısından itibaren dakika.
class Today {
  const Today({required this.date, required this.minutes});
  final LocalDate date;
  final int minutes;

  @override
  bool operator ==(Object other) =>
      other is Today && other.date == date && other.minutes == minutes;
  @override
  int get hashCode => Object.hash(date, minutes);
}

const defaultTimeZone = 'Europe/Istanbul';

/// Testlerde sahte saat için değiştirilir.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class TodayNotifier extends Notifier<Today> {
  Timer? _timer;

  @override
  Today build() {
    final zone = ref.watch(profileProvider.select((p) => p.value?.timezone)) ?? defaultTimeZone;
    _zone = zone;
    final listener = AppLifecycleListener(onResume: refresh);
    ref.onDispose(() {
      _timer?.cancel();
      listener.dispose();
    });
    final now = _compute();
    _schedule();
    return now;
  }

  late String _zone;

  Today _compute() {
    final now = ref.read(clockProvider)();
    return Today(
      date: localDateInZone(now, _zone),
      minutes: parseLocalTime(localTimeInZone(now, _zone))!,
    );
  }

  /// Her dakika başında güncellenir; gece yarısı ve selamlama saatleri kendiliğinden döner.
  void _schedule() {
    _timer?.cancel();
    final secs = ref.read(clockProvider)().second;
    _timer = Timer(Duration(seconds: 61 - secs), () {
      refresh();
    });
  }

  void refresh() {
    final next = _compute();
    if (next != state) state = next;
    _schedule();
  }
}

final todayProvider = NotifierProvider<TodayNotifier, Today>(TodayNotifier.new);
