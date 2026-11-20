import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/workout_providers.dart';
import '../../domain/body_map.dart';
import '../../domain/format.dart';
import '../../domain/turkish_text.dart';
import '../../domain/units.dart';
import '../../domain/workout_summary.dart';
import '../components/body_map/body_map.dart';
import '../components/dot_grid.dart';
import '../components/mf_card.dart';
import '../theme/mf_theme.dart';
import 'body_map_legend.dart';
import 'focus_widgets.dart' show FocusCta;

/// "Bitir" sonrası: kaydedildiyse özete, set yoksa mesajla antrenman sekmesine.
void routeAfterFinish(
  GoRouter router,
  ScaffoldMessengerState messenger,
  String sessionId,
  WorkoutFinish r,
) {
  messenger.hideCurrentSnackBar();
  switch (r) {
    case Saved():
      router.go('/antrenman/ozet/$sessionId');
    case DiscardedEmpty():
      router.go('/antrenman');
      messenger.showSnackBar(const SnackBar(content: Text('Hiç set yok, antrenman kaydedilmedi.')));
  }
}

/// Antrenman özeti: süre, set, hacim (kullanıcının biriminde), kalori ve yalnızca bu
/// antrenmanda çalışılan kaslar maket üzerinde (haftalıkla aynı kademeler).
class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(workoutSummaryProvider(sessionId));
    void done() => context.go('/antrenman');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) done();
      },
      child: Scaffold(
        body: MfBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: switch (async) {
                  AsyncData(:final value?) => _Body(view: value, onDone: done),
                  AsyncData() => _Message(text: 'Antrenman bulunamadı.', onDone: done),
                  AsyncError() => _Message(
                    text: 'Özet yüklenemedi. Antrenmanın kaydedildi.',
                    onDone: done,
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isMono(MfTheme t) => t.family == ThemeFamily.mono;

/// Mono'da etiketler büyük harf ve aralıklı (odak modu dili).
String _label(MfTheme t, String s) => _isMono(t) ? turkishUpper(s) : s;

class _Body extends ConsumerWidget {
  const _Body({required this.view, required this.onDone});
  final WorkoutSummaryView view;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final mono = _isMono(t);
    final unit = ref.watch(profileProvider.select((p) => p.value?.units)) ?? WeightUnit.kg;
    final groups = ref.watch(muscleGroupsProvider).value ?? const <MuscleGroupOption>[];
    final d = view.data;
    final s = summarizeWorkout(
      startedAt: d.startedAt,
      endedAt: d.endedAt ?? d.startedAt,
      // Kalori oturumda kayıtlı değerdir (bitirirken hesaplandı); burada yeniden hesaplanmaz.
      weightKg: null,
      sets: d.sets,
    );
    final kcal = d.estimatedKcal;
    final volume = formatInt(fromKg(s.volumeKg, unit));
    final unitName = unit == WeightUnit.kg ? 'kilogram' : 'pound';

    final nameOf = {for (final g in groups) g.slug: g.nameTr};
    final worked = [
      for (final m in bodyMapMuscles)
        if ((view.map.muscleSets[m] ?? 0) > 0) (slug: m, sets: view.map.muscleSets[m]!),
    ]..sort((a, b) => b.sets.compareTo(a.sets));

    final stats = <Widget>[
      _Stat(
        value: formatClock(s.durationSeconds),
        label: _label(t, 'süre'),
        semantics: 'Süre ${formatDuration(s.durationSeconds)}',
      ),
      _Stat(value: '${s.setCount}', label: _label(t, 'set'), semantics: '${s.setCount} set'),
      _Stat(
        value: volume,
        label: _label(t, '${unit.name} hacim'),
        semantics: 'Hacim $volume $unitName',
      ),
      if (kcal != null)
        _Stat(
          value: formatInt(kcal),
          label: _label(t, 'kcal'),
          semantics: 'Tahmini ${formatInt(kcal)} kilokalori',
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Text(
          _label(t, 'Antrenman bitti'),
          style: TextStyle(
            color: t.textMuted,
            fontSize: mono ? 11 : 13,
            letterSpacing: mono ? 1.6 : 0.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          header: true,
          child: Text(
            mono ? turkishUpper(d.name) : d.name,
            style: TextStyle(
              color: t.text,
              fontFamily: t.displayFont,
              fontSize: 28,
              height: 1.15,
              fontWeight: mono ? FontWeight.w700 : FontWeight.w900,
              letterSpacing: mono ? 0.6 : -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${s.exerciseCount} hareket', style: TextStyle(color: t.textMuted, fontSize: 14)),
        const SizedBox(height: 20),
        MfCard(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: LayoutBuilder(
            builder: (context, c) {
              // İki sütun, satırlar alt alta kayar; rakam yalnızca sütuna sığmazsa küçülür.
              final w = (c.maxWidth / 2).floorToDouble();
              return Wrap(
                runSpacing: 20,
                children: [for (final x in stats) SizedBox(width: w, child: x)],
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Semantics(
          header: true,
          child: Text(
            _label(t, 'Bu antrenman'),
            style: TextStyle(
              color: t.textMuted,
              fontSize: mono ? 12 : 13,
              fontWeight: FontWeight.w600,
              letterSpacing: mono ? 1.6 : 0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: Center(
            child: BodyMap(
              levels: view.map.levels,
              semanticLabel: 'Bu antrenmanda çalışılan kaslar, 3 boyutlu maket',
            ),
          ),
        ),
        const SizedBox(height: 8),
        const BodyMapLegend(scope: 'bu antrenmanda'),
        const SizedBox(height: 12),
        for (final m in worked)
          _MuscleRow(name: nameOf[m.slug] ?? m.slug, sets: m.sets, level: bodyMapLevel(m.sets)),
        const SizedBox(height: 24),
        FocusCta(label: 'Tamam', onPressed: onDone),
      ],
    );
  }
}

/// Büyük sayı (Mono: Doto, Canlı: kalın Inter) ve altında küçük etiket.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.semantics});
  final String value;
  final String label;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _isMono(t);
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: t.text,
                fontFamily: t.numberFont,
                fontSize: 40,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: mono ? 0 : -1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textMuted,
              fontSize: mono ? 11 : 13,
              letterSpacing: mono ? 1.5 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Çalışılan kas: ad, ağırlıklı set ve kademe işareti (bilgi yalnızca renkle verilmez).
class _MuscleRow extends StatelessWidget {
  const _MuscleRow({required this.name, required this.sets, required this.level});
  final String name;
  final double sets;
  final int level;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final setText = '${formatAmount(sets)} set';
    return Semantics(
      label: '$name, $setText',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            // Kademe: 1–3 dolu çubuk.
            for (var i = 1; i <= 3; i++)
              Container(
                width: 4,
                height: 16,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: i <= level ? t.accent : t.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name, style: TextStyle(color: t.text, fontSize: 15)),
            ),
            Text(setText, style: TextStyle(color: t.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onDone});
  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.text, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FocusCta(label: 'Tamam', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
