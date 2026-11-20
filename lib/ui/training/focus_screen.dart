import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/active_workout_controller.dart';
import '../../app/profile_controller.dart';
import '../../app/rest_timer.dart';
import '../../app/screen_awake.dart';
import '../../app/today_provider.dart' show clockProvider;
import '../../app/workout_providers.dart';
import '../../domain/active_workout.dart';
import '../../domain/feedback.dart' show regionLabels;
import '../../domain/turkish_text.dart';
import '../../domain/units.dart';
import '../../domain/weight_step.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';
import 'focus_sheets.dart';
import 'focus_rail.dart';
import 'focus_steppers.dart';
import 'focus_widgets.dart';
import 'rest_screen.dart';
import 'workout_summary_screen.dart' show routeAfterFinish;

/// "Geri al" snackbar'ının alt boşluğu: odak modunda alt şerit (48 dp) ve "Seti tamamla"
/// (60 dp), dinlenmede "Atla" (60 dp) üstünde kalır; kenar boşlukları dahil.
const _undoBottomGap = 12.0 + 48 + 12 + 60 + 12;

/// Odak modu: yalnızca o anki hareket ve set. Klavye açılmaz; değerler önceden dolu gelir,
/// –/+ ile değişir, set tek dokunuşla tamamlanır. Ekran açık kalır. Dinlenme sürerken
/// dinlenme ekranı bunun üstünde tam ekran durur.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with WidgetsBindingObserver {
  late final ScreenAwake _awake;
  bool _busy = false;
  bool _askingFinish = false;
  bool _restored = false;

  ActiveWorkoutController get _ctl => ref.read(activeWorkoutControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _awake = ref.read(screenAwakeProvider);
    unawaited(_awake.enable());
    WidgetsBinding.instance.addObserver(this);
    // Uygulama dinlenme sırasında kapatıldıysa sayaç diskteki bitişten sürer.
    ref.listenManual(activeWorkoutControllerProvider, (_, next) {
      final w = next.value;
      if (w == null || _restored) return;
      _restored = true;
      unawaited(ref.read(restTimerProvider.notifier).restoreFrom(w));
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_awake.disable());
    super.dispose();
  }

  /// Öne gelince diskteki bitiş yeniden okunur (bildirimden yapılan değişiklikler).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final w = ref.read(activeWorkoutControllerProvider).value;
    if (w != null) unawaited(ref.read(restTimerProvider.notifier).restoreFrom(w));
  }

  /// "Son seti düzenle": dinlenme durur, en son tamamlanan set düzenleyicide açılır.
  Future<void> _editLast() async {
    await ref.read(restTimerProvider.notifier).skip();
    final w = ref.read(activeWorkoutControllerProvider).value;
    if (w == null || !mounted) return;
    LoggedSet? last;
    for (final s in w.sets) {
      if (last == null || s.completedAt.isAfter(last.completedAt)) last = s;
    }
    if (last == null) return;
    final p = w.plan.where((x) => x.exerciseId == last!.exerciseId).firstOrNull;
    if (p == null) return;
    final done = w.sets.where((s) => s.exerciseId == p.exerciseId).toList()
      ..sort((a, b) => a.setIndex.compareTo(b.setIndex));
    await _edit(w, p, last, done.indexOf(last) + 1);
  }

  WeightUnit get _unit => ref.read(profileProvider).value?.units ?? WeightUnit.kg;

  /// Taslak > ön doldurma (bu antrenmandaki son set, yoksa geçen seferin seti). Ağırlık
  /// kullanıcının biriminde; kayıtlı kg bir kez çevrilip adım ızgarasına oturtulur.
  FocusDraft _valuesFor(ActiveWorkout w, PlannedExercise p) {
    final draft = ref.read(focusDraftsProvider)[p.exerciseId];
    if (draft != null) return draft;
    final v = prefill(
      p.exerciseId,
      w,
      ref.read(lastSessionSetsProvider(p.exerciseId)).value ?? const [],
    );
    return FocusDraft(
      weight: v.weightKg == null ? null : shownWeight(v.weightKg!, p.equipment, _unit),
      reps: v.reps,
      durationSeconds: v.durationSeconds,
    );
  }

  void _change(ActiveWorkout w, PlannedExercise p, FocusDraft Function(FocusDraft) f) {
    // Basılı tutarken her adım son değeri okur.
    final latest = ref.read(activeWorkoutControllerProvider).value ?? w;
    ref.read(focusDraftsProvider.notifier).put(p.exerciseId, f(_valuesFor(latest, p)));
  }

  /// Hata mesajı gösterip yutar (ör. diske yazılamadı).
  Future<void> _guard(Future<void> Function() op) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await op();
    } catch (e) {
      debugPrint('Odak modu işlemi başarısız: $e');
      messenger.showSnackBar(const SnackBar(content: Text('İşlem yapılamadı. Tekrar dene.')));
    }
  }

  Future<void> _complete(PlannedExercise p, FocusDraft v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    // Snackbar eylemi ekran kapandıktan sonra da çalışabilir; ref yerine bildirici tutulur.
    final ctl = _ctl;
    final rest = ref.read(restTimerProvider.notifier);
    // Geri al, ana düğmelerin (dinlenmede "Atla", odakta "Seti tamamla") üstünde yüzer.
    final undoBottom = MediaQuery.paddingOf(context).bottom + _undoBottomGap;
    try {
      final duration = p.tracking == 'duration';
      final s = await ctl.completeSet(
        SetValues(
          weightKg: tracksWeight(p.tracking, p.equipment) && v.weight != null
              ? toKg(v.weight!, _unit)
              : null,
          reps: duration ? null : v.reps,
          durationSeconds: duration ? v.durationSeconds : null,
        ),
      );
      unawaited(HapticFeedback.lightImpact());
      if (!mounted) return;
      ref.read(onSetCompletedProvider)(p.exerciseId);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Set kaydedildi.'),
          duration: const Duration(seconds: 5),
          persist: false,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, undoBottom),
          action: SnackBarAction(
            label: 'Geri al',
            // Set geri alınınca o setin dinlenmesi de biter (bildirim ve alarm kalkar).
            onPressed: () => unawaited(
              Future.wait([rest.skip(), ctl.undo(s)]).then(
                (_) {},
                onError: (Object e) => messenger.showSnackBar(
                  const SnackBar(content: Text('İşlem yapılamadı. Tekrar dene.')),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Set yazılamadı: $e');
      messenger.showSnackBar(const SnackBar(content: Text('Set kaydedilemedi. Tekrar dene.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(ActiveWorkout w, PlannedExercise p, LoggedSet s, int number) async {
    final r = await showSetEditor(
      context,
      set: s,
      number: number,
      plan: p,
      unit: _unit,
      clock: ref.read(clockProvider),
    );
    if (!mounted) return;
    await _guard(() async {
      switch (r) {
        case SetEditSave(:final set):
          await _ctl.editSet(set);
        case SetEditDelete():
          await _ctl.deleteSet(s);
        case null:
          break;
      }
    });
  }

  Future<void> _add(ActiveWorkout w) async {
    final e = await Navigator.of(context).push<ExerciseOption>(
      MaterialPageRoute(
        builder: (_) => ExerciseSearchPage(inPlan: {for (final p in w.plan) p.exerciseId}),
      ),
    );
    if (e == null || !mounted) return;
    await _guard(() async {
      final cur = ref.read(activeWorkoutControllerProvider).value ?? w;
      if (cur.plan.any((p) => p.exerciseId == e.id)) return _ctl.select(e.id);
      final last = await ref.read(lastSessionSetsProvider(e.id).future);
      await _ctl.addExercise(
        PlannedExercise(
          exerciseId: e.id,
          tracking: e.tracking,
          equipment: e.equipment,
          targetSets: targetSetsFor(lastSessionSetCount: last.isEmpty ? null : last.length),
          restSeconds: 90,
        ),
      );
    });
  }

  Future<void> _showList(ActiveWorkout w, List<RailItem> items) async {
    final id = await showExerciseList(
      context,
      items: items,
      currentId: w.currentExerciseId,
      progress: {
        for (final p in w.plan) p.exerciseId: '${w.doneSets(p.exerciseId)}/${p.targetSets}',
      },
    );
    if (id != null && mounted) await _guard(() => _ctl.select(id));
  }

  Future<void> _confirmFinish() async {
    final w = ref.read(activeWorkoutControllerProvider).value;
    if (w == null) {
      context.go('/antrenman');
      return;
    }
    if (_askingFinish) return;
    _askingFinish = true;
    final n = w.sets.length;
    final yes = await showFinishDialog(context, setCount: n);
    _askingFinish = false;
    if (yes != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final WorkoutFinish r;
    try {
      r = await _ctl.finish();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Antrenman bitirilemedi. Tekrar dene.')));
      return;
    }
    routeAfterFinish(router, messenger, w.sessionId, r);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutControllerProvider);
    final w = state.value;
    final resting = w != null && ref.watch(restTimerProvider) != null;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmFinish());
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Dinlenirken odak modu durumunu korur ama görünmez, dokunulmaz, okunmaz.
            Visibility(
              visible: !resting,
              maintainState: true,
              child: MfBackground(
                child: SafeArea(
                  child: w != null
                      // Tablette ve yatayda içerik okunur genişlikte ortalanır.
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: _body(w),
                          ),
                        )
                      : state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : NoActiveWorkout(onBack: () => context.go('/antrenman')),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
              child: resting ? RestScreen(onEditLast: _editLast) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ActiveWorkout w) {
    final t = mf(context);
    ref.watch(focusDraftsProvider);
    final names = {
      for (final p in w.plan) p.exerciseId: ref.watch(exerciseInfoProvider(p.exerciseId)).value,
    };
    final items = [
      for (final p in w.plan)
        RailItem(
          id: p.exerciseId,
          name: names[p.exerciseId]?.nameTr ?? '…',
          complete: w.doneSets(p.exerciseId) >= p.targetSets,
        ),
    ];
    final index = w.plan.indexWhere((p) => p.exerciseId == w.currentExerciseId);
    final p = index < 0 ? null : w.plan[index];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FocusTopBar(
            startedAt: w.startedAt,
            onClose: _confirmFinish,
            onList: w.plan.isEmpty ? null : () => _showList(w, items),
          ),
          const SizedBox(height: 8),
          if (p != null) ...[
            ExerciseProgress(done: [for (final it in items) it.complete], current: index),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(child: _exercise(w, p, index, names[p.exerciseId])),
            ),
          ] else
            Expanded(
              child: Center(
                child: Text(
                  'Başlamak için aşağıdan hareket ekle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.textMuted, fontSize: 16),
                ),
              ),
            ),
          if (p != null) _cta(w, p),
          const SizedBox(height: 12),
          ExerciseRail(
            items: items,
            currentId: w.currentExerciseId,
            onSelect: (id) => _guard(() => _ctl.select(id)),
            onAdd: () => _add(w),
          ),
        ],
      ),
    );
  }

  Widget _exercise(ActiveWorkout w, PlannedExercise p, int index, ExerciseOption? info) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    final id = p.exerciseId;
    final last = ref.watch(lastSessionSetsProvider(id)).value ?? const <LoggedSet>[];
    final unit = ref.watch(profileProvider.select((x) => x.value?.units)) ?? WeightUnit.kg;
    final v = _valuesFor(w, p);
    final done = w.sets.where((s) => s.exerciseId == id).toList()
      ..sort((a, b) => a.setIndex.compareTo(b.setIndex));
    final weight = tracksWeight(p.tracking, p.equipment);
    final duration = p.tracking == 'duration';
    final r = info?.region == null ? null : regionLabels[info!.region]!;
    final region = r == null ? null : turkishUpper(r.substring(0, 1)) + r.substring(1);
    final caption = 'Hareket ${index + 1}/${w.plan.length}${region == null ? '' : ' · $region'}';
    final setNo = done.length >= p.targetSets ? done.length : done.length + 1;
    final setCaption = 'Set $setNo/${p.targetSets}';
    final name = info?.nameTr ?? '…';

    String fmt(LoggedSet s) {
      if (duration) return formatSeconds(s.durationSeconds ?? 0);
      if (weight && s.weightKg != null) {
        return '${formatAmount(shownWeight(s.weightKg!, p.equipment, unit))} × ${s.reps ?? '–'}';
      }
      return '${s.reps ?? '–'}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          mono ? turkishUpper(caption) : caption,
          style: TextStyle(
            color: t.textMuted,
            fontSize: mono ? 11 : 12,
            letterSpacing: mono ? 1.5 : 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mono ? turkishUpper(name) : name,
          key: const Key('exercise-title'),
          style: TextStyle(
            fontFamily: t.displayFont,
            color: t.text,
            fontSize: 28,
            height: 1.1,
            fontWeight: mono ? FontWeight.w700 : FontWeight.w900,
            letterSpacing: mono ? 0.4 : -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SetDots(
                done: done,
                target: p.targetSets,
                onEdit: (s) => _edit(w, p, s, done.indexOf(s) + 1),
                onAddSet: _canAddSet(w, id) ? () => _guard(() => _ctl.addTargetSet(id)) : null,
              ),
            ),
            Text(
              mono ? turkishUpper(setCaption) : setCaption,
              style: TextStyle(color: t.textMuted, fontSize: 12, letterSpacing: mono ? 1.4 : 0),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (weight)
          ValueStepper(
            valueKey: const Key('value-weight'),
            valueText: v.weight == null ? null : formatAmount(v.weight!),
            unit: unit.name,
            noun: 'ağırlığı',
            onStep: (d) => _change(
              w,
              p,
              (x) => FocusDraft(
                weight: nextWeight(x.weight, d, p.equipment, unit),
                reps: x.reps,
                durationSeconds: x.durationSeconds,
              ),
            ),
          ),
        if (duration)
          DurationField(
            key: ValueKey('duration-$id'),
            seconds: v.durationSeconds,
            clock: ref.read(clockProvider),
            onChanged: (s) => ref
                .read(focusDraftsProvider.notifier)
                .put(id, FocusDraft(weight: v.weight, reps: v.reps, durationSeconds: s)),
          )
        else
          ValueStepper(
            valueKey: const Key('value-reps'),
            valueText: v.reps?.toString(),
            unit: 'tekrar',
            noun: 'tekrarı',
            onStep: (d) => _change(
              w,
              p,
              (x) => FocusDraft(
                weight: x.weight,
                reps: nextReps(x.reps, d),
                durationSeconds: x.durationSeconds,
              ),
            ),
          ),
        const SizedBox(height: 8),
        LastTimeNote(
          text: last.isEmpty
              ? 'İlk kez: değerleri –/+ ile gir.'
              : 'Geçen sefer: ${last.map(fmt).join(' · ')}',
          trend: last.isNotEmpty,
        ),
      ],
    );
  }

  bool _canAddSet(ActiveWorkout w, String id) {
    try {
      w.nextSetIndex(id);
      return true;
    } on StateError {
      return false;
    }
  }

  String? _nextExercise(ActiveWorkout w) {
    try {
      return w.nextUp()?.exerciseId;
    } on StateError {
      return null;
    }
  }

  Widget _cta(ActiveWorkout w, PlannedExercise p) {
    final v = _valuesFor(w, p);
    final full = w.doneSets(p.exerciseId) >= p.targetSets;
    final next = full ? _nextExercise(w) : null;
    final valid = p.tracking == 'duration'
        ? (v.durationSeconds ?? 0) >= 1
        : v.reps != null && (!tracksWeight(p.tracking, p.equipment) || v.weight != null);

    final (String label, VoidCallback? onTap) = !full
        ? ('Seti tamamla', valid && !_busy ? () => _complete(p, v) : null)
        : next != null
        ? ('Sıradaki hareket', () => unawaited(_guard(() => _ctl.select(next))))
        : ('Bitir', () => unawaited(_confirmFinish()));
    return FocusCta(label: label, onPressed: onTap);
  }
}
