import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/today_provider.dart';
import '../../domain/date_labels.dart';
import '../../domain/greeting.dart';
import '../components/dot_grid.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final t = mf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(
              greetingFor(today.minutes),
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontFamily: t.displayFont, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(formatTurkishDate(today.date), style: TextStyle(color: t.textMuted, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
