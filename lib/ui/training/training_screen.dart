import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/active_workout_controller.dart';
import '../../app/profile_controller.dart';
import '../../app/today_provider.dart';
import '../../app/workout_providers.dart';
import '../../domain/active_workout.dart';
import '../../domain/body_map.dart';
import '../../domain/date_labels.dart';
import '../../domain/dates.dart';
import '../../domain/feedback.dart' show regionLabels;
import '../../domain/format.dart';
import '../../domain/muscle_coverage.dart';
import '../../domain/turkish_text.dart';
import '../../domain/week.dart';
import '../components/body_map/body_map.dart';
import '../components/dot_grid.dart';
import '../components/mf_card.dart';
import '../theme/mf_theme.dart';
import 'focus_widgets.dart' show FocusCta;
import 'start_workout_screen.dart' show startOrResume;

/// Bölgenin ekranda görünen adı: "göğüs" → "Göğüs".
String regionTitle(BodyRegion r) {
  final s = regionLabels[r]!;
  return turkishUpper(s.substring(0, 1)) + s.substring(1);
}

/// Antrenman sekmesi: üstte haftanın maketi ve bölge listesi, "Antrenmana başla",
/// süren antrenman için "Devam et", son 3 antrenman ("Tekrarla") ve hazır programlar.
class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  /// Açık bölge (liste satırı ya da maket dokunuşuyla).
  BodyRegion? _open;
  bool _busy = false;

  Future<void> _start(
    Future<List<PlannedExercise>> Function() plan, {
    String? templateId,
    String? name,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await startOrResume(context, ref, plan, templateId: templateId, name: name);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggle(BodyRegion r) => setState(() => _open = _open == r ? null : r);

  void _onMuscleTap(String slug, List<MuscleGroupOption> groups) {
    final g = groups.where((x) => x.slug == slug).firstOrNull;
    if (g != null) setState(() => _open = g.region);
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final active = ref.watch(activeWorkoutControllerProvider).value;
    final week = ref.watch(weeklyBodyMapProvider).value ?? WeeklyBodyMap.empty;
    final groups = ref.watch(muscleGroupsProvider).value ?? const <MuscleGroupOption>[];
    final today = ref.watch(todayProvider.select((x) => x.date));
    final weekStartsOn =
        ref.watch(profileProvider.select((p) => p.value?.weekStartsOn)) ?? WeekStartsOn.monday;
    final window = weekWindowForDate(today, weekStartsOn);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (active != null) ...[
                  _ResumeCard(workout: active, onResume: () => context.go('/antrenman/odak')),
                  const SizedBox(height: 20),
                ],
                _WeekHeader(week: week, range: formatDayRange(window.start, window.end)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 360,
                  child: Center(
                    child: BodyMap(
                      levels: week.levels,
                      onRegionTap: (slug) => _onMuscleTap(slug, groups),
                      semanticLabel: 'Bu hafta çalışılan kaslar, 3 boyutlu maket',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const _Legend(),
                const SizedBox(height: 4),
                Text(
                  'Çevirmek için sürükle · kasa dokun',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _RegionList(
                  week: week,
                  groups: groups,
                  open: _open,
                  today: today,
                  onToggle: _toggle,
                ),
                const SizedBox(height: 16),
                FocusCta(
                  label: 'Antrenmana başla',
                  onPressed: () => context.push('/antrenman/basla'),
                ),
                const SizedBox(height: 28),
                _Recents(
                  today: today,
                  onRepeat: (r) =>
                      _start(() => ref.read(planForExercisesProvider)(r.exerciseIds), name: r.name),
                ),
                const SizedBox(height: 28),
                _Templates(
                  onStart: (tpl) => _start(
                    () => ref.read(workoutQueriesProvider).templatePlan(tpl.id),
                    templateId: tpl.id,
                    name: tpl.nameTr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _isMono(MfTheme t) => t.family == ThemeFamily.mono;

/// Bölüm başlığı (Mono: büyük harf, aralıklı).
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    final style = TextStyle(
      color: t.textMuted,
      fontSize: mono ? 12 : 13,
      fontWeight: FontWeight.w600,
      letterSpacing: mono ? 1.6 : 0.2,
    );
    return Semantics(
      header: true,
      child: Wrap(
        spacing: 8,
        children: [
          Text(mono ? turkishUpper(text) : text, style: style),
          if (trailing != null)
            Text(
              mono ? '· ${turkishUpper(trailing!)}' : '· $trailing',
              style: style.copyWith(fontWeight: FontWeight.w400),
            ),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.workout, required this.onResume});
  final ActiveWorkout workout;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    final n = workout.sets.length;
    final m = workout.plan.length;
    return MfCard(
      key: const Key('resume-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            mono ? turkishUpper('Süren antrenman') : 'Süren antrenman',
            style: TextStyle(
              color: t.text,
              fontFamily: t.displayFont,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: mono ? 0.6 : 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$m hareket · $n set tamamlandı',
            style: TextStyle(color: t.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 12),
          FocusCta(label: 'Devam et', onPressed: onResume),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week, required this.range});
  final WeeklyBodyMap week;
  final String range;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    // 14 bölgeden kaçı bu hafta çalışıldı (maketteki bölgeler).
    final worked = week.muscleSets.values.where((v) => v > 0).length;
    final total = bodyMapMuscles.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Bu hafta', trailing: range),
        const SizedBox(height: 6),
        Semantics(
          label: '$total bölgeden $worked bölge çalışıldı, ${week.totalSets} set',
          excludeSemantics: true,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(
                '$worked/$total',
                style: TextStyle(
                  color: t.text,
                  fontFamily: mono ? t.numberFont : t.displayFont,
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'bölge · ${week.totalSets} set',
                  style: TextStyle(color: t.textMuted, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Yoğunluk ölçeği: işaret + sayı aralığı (bilgi yalnızca renkle verilmez).
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = t.bodyMapStyle == BodyMapStyle.dots;
    const labels = ['0', '0,5–3,5', '4–9,5', '10+'];
    Widget mark(int level) {
      if (mono) {
        final size = const [4.0, 5.0, 7.0, 9.0][level];
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: level == 0 ? t.textMuted : t.accent,
          ),
        );
      }
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: level == 0
              ? t.surfaceMuted
              : t.accent.withValues(alpha: const [0.0, 0.45, 0.75, 1.0][level]),
          border: level == 0 ? Border.all(color: t.textMuted) : null,
        ),
      );
    }

    final style = TextStyle(color: t.textMuted, fontSize: 12);
    return Semantics(
      label: 'Ölçek, haftalık ağırlıklı set: ${labels.join(', ')}',
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: [
          Text('Set', style: style),
          for (var i = 0; i < 4; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10, height: 10, child: Center(child: mark(i))),
                const SizedBox(width: 4),
                Text(labels[i], style: style),
              ],
            ),
        ],
      ),
    );
  }
}

/// 6 üst bölge, set sayılarıyla. Satıra dokununca altında kasları ve son çalışma açılır.
class _RegionList extends StatelessWidget {
  const _RegionList({
    required this.week,
    required this.groups,
    required this.open,
    required this.today,
    required this.onToggle,
  });
  final WeeklyBodyMap week;
  final List<MuscleGroupOption> groups;
  final BodyRegion? open;
  final LocalDate today;
  final ValueChanged<BodyRegion> onToggle;

  double _sets(BodyRegion r) => [
    for (final g in groups)
      if (g.region == r) week.muscleSets[g.slug] ?? 0,
  ].fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final r in BodyRegion.values)
        _RegionRow(
          key: Key('region-${r.name}'),
          title: regionTitle(r),
          sets: _sets(r),
          open: open == r,
          onTap: () => onToggle(r),
        ),
    ];
    final detail = open == null
        ? null
        : _RegionDetail(
            key: Key('region-detail-${open!.name}'),
            muscles: [
              for (final g in groups)
                if (g.region == open) g,
            ],
            week: week,
            today: today,
          );
    return LayoutBuilder(
      builder: (context, c) {
        // Büyük yazıda ya da dar ekranda tek sütun.
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final twoCols = c.maxWidth >= 300 && scale <= 1.3;
        final children = <Widget>[];
        if (twoCols) {
          for (var i = 0; i < rows.length; i += 2) {
            children.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: rows[i]),
                  const SizedBox(width: 14),
                  Expanded(child: rows[i + 1]),
                ],
              ),
            );
          }
        } else {
          children.addAll(rows);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...children,
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              alignment: Alignment.topCenter,
              child: detail ?? const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

class _RegionRow extends StatelessWidget {
  const _RegionRow({
    required this.title,
    required this.sets,
    required this.open,
    required this.onTap,
    super.key,
  });
  final String title;
  final double sets;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    final zero = sets <= 0;
    final color = zero ? t.textMuted : t.text;
    return Semantics(
      button: true,
      expanded: open,
      label: '$title, ${formatAmount(sets)} set',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: open ? t.accent : t.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: open ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                formatAmount(sets),
                style: TextStyle(
                  color: color,
                  fontFamily: mono ? t.numberFont : null,
                  fontSize: mono ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(open ? Icons.expand_less : Icons.expand_more, size: 20, color: t.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionDetail extends StatelessWidget {
  const _RegionDetail({required this.muscles, required this.week, required this.today, super.key});
  final List<MuscleGroupOption> muscles;
  final WeeklyBodyMap week;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    LocalDate? last;
    for (final m in muscles) {
      final d = week.lastWorked[m.slug];
      if (d != null && (last == null || d.compareTo(last) > 0)) last = d;
    }
    final lastText = last == null
        ? 'Bu hafta çalışılmadı'
        : 'Son çalışma: ${daysAgoLabel(last, today)}';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MfCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(lastText, style: TextStyle(color: t.text, fontSize: 14)),
            ),
            const SizedBox(height: 6),
            for (final m in muscles)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.nameTr,
                        style: TextStyle(
                          color: (week.muscleSets[m.slug] ?? 0) > 0 ? t.text : t.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      formatAmount(week.muscleSets[m.slug] ?? 0),
                      style: TextStyle(
                        color: (week.muscleSets[m.slug] ?? 0) > 0 ? t.text : t.textMuted,
                        fontFamily: mono ? t.numberFont : null,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Recents extends ConsumerWidget {
  const _Recents({required this.today, required this.onRepeat});
  final LocalDate today;
  final ValueChanged<RecentWorkout> onRepeat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final recents = ref.watch(recentWorkoutsProvider);
    final zone = ref.watch(profileProvider.select((p) => p.value?.timezone)) ?? defaultTimeZone;
    final list = recents.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Son antrenmanlar'),
        const SizedBox(height: 8),
        if (list == null && recents.isLoading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (list == null || list.isEmpty)
          Text(
            recents.hasError ? 'Son antrenmanlar yüklenemedi.' : 'Henüz tamamlanan antrenman yok.',
            style: TextStyle(color: t.textMuted, fontSize: 14),
          )
        else
          for (final r in list)
            _RecentRow(
              workout: r,
              when: _capitalize(daysAgoLabel(localDateInZone(r.startedAt, zone), today)),
              onRepeat: () => onRepeat(r),
            ),
      ],
    );
  }
}

String _capitalize(String s) => s.isEmpty ? s : turkishUpper(s.substring(0, 1)) + s.substring(1);

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.workout, required this.when, required this.onRepeat});
  final RecentWorkout workout;
  final String when;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final meta = '$when · ${workout.exerciseIds.length} hareket · ${workout.setCount} set';
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: TextStyle(color: t.text, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(meta, style: TextStyle(color: t.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: '${workout.name} antrenmanını tekrarla',
            excludeSemantics: true,
            child: OutlinedButton(
              onPressed: workout.exerciseIds.isEmpty ? null : onRepeat,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: t.text,
                side: BorderSide(color: t.border),
                shape: const StadiumBorder(),
              ),
              child: const Text('Tekrarla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Templates extends ConsumerWidget {
  const _Templates({required this.onStart});
  final ValueChanged<TemplateOption> onStart;

  static const _levels = {'beginner': 'Başlangıç', 'intermediate': 'Orta', 'advanced': 'İleri'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final templates = ref.watch(workoutTemplatesProvider);
    final list = templates.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Hazır programlar'),
        const SizedBox(height: 8),
        if (list == null && templates.isLoading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (list == null || list.isEmpty)
          Text(
            'Hazır programlar internete bağlanınca gelir.',
            style: TextStyle(color: t.textMuted, fontSize: 14),
          )
        else
          for (final tpl in list)
            Semantics(
              button: true,
              label:
                  '${tpl.nameTr}, ${_levels[tpl.level] ?? tpl.level}, '
                  '${tpl.exerciseCount} hareket. Başlat',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onStart(tpl),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: t.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tpl.nameTr,
                              style: TextStyle(
                                color: t.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_levels[tpl.level] ?? tpl.level} · ${tpl.exerciseCount} hareket'
                              '${tpl.description.isEmpty ? '' : ' · ${tpl.description}'}',
                              style: TextStyle(color: t.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow_rounded, color: t.textMuted),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
