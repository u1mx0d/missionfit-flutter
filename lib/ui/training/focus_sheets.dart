import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/workout_providers.dart';
import '../../domain/active_workout.dart';
import '../../domain/units.dart';
import '../../domain/weight_step.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import 'focus_rail.dart';
import 'focus_steppers.dart';

/// Set düzenleme sayfasının sonucu.
sealed class SetEdit {
  const SetEdit();
}

final class SetEditSave extends SetEdit {
  const SetEditSave(this.set);
  final LoggedSet set;
}

final class SetEditDelete extends SetEdit {
  const SetEditDelete();
}

/// Biten bir seti açar: –/+ ile düzenle, "Kaydet" ya da onaylı "Seti sil".
Future<SetEdit?> showSetEditor(
  BuildContext context, {
  required LoggedSet set,
  required int number,
  required PlannedExercise plan,
  required WeightUnit unit,
  required DateTime Function() clock,
}) => showModalBottomSheet<SetEdit>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: mf(context).surface,
  builder: (_) => _SetEditor(set: set, number: number, plan: plan, unit: unit, clock: clock),
);

class _SetEditor extends StatefulWidget {
  const _SetEditor({
    required this.set,
    required this.number,
    required this.plan,
    required this.unit,
    required this.clock,
  });

  final LoggedSet set;
  final int number;
  final PlannedExercise plan;
  final WeightUnit unit;
  final DateTime Function() clock;

  @override
  State<_SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends State<_SetEditor> {
  late double? _kg = widget.set.weightKg;
  late int? _reps = widget.set.reps;
  late int? _seconds = widget.set.durationSeconds;

  bool get _duration => widget.plan.tracking == 'duration';
  bool get _weight => tracksWeight(widget.plan.tracking, widget.plan.equipment);
  bool get _valid => _duration ? (_seconds ?? 0) >= 1 : _reps != null;

  void _save() {
    final s = widget.set;
    Navigator.of(context).pop(
      SetEditSave(
        LoggedSet(
          id: s.id,
          exerciseId: s.exerciseId,
          exerciseOrder: s.exerciseOrder,
          setIndex: s.setIndex,
          reps: _duration ? null : _reps,
          durationSeconds: _duration ? _seconds : null,
          weightKg: _weight ? _kg : null,
          completedAt: s.completedAt,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final t = mf(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set silinsin mi?'),
        content: Text('Set ${widget.number} bu antrenmandan silinir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: t.danger),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) Navigator.of(context).pop(const SetEditDelete());
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set ${widget.number}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.text),
            ),
            const SizedBox(height: 8),
            if (_weight)
              ValueStepper(
                valueKey: const Key('edit-weight'),
                valueText: _kg == null ? null : formatAmount(fromKg(_kg!, widget.unit)),
                unit: widget.unit.name,
                noun: 'ağırlığı',
                onStep: (d) =>
                    setState(() => _kg = nextWeight(_kg, d, widget.plan.equipment, widget.unit)),
              ),
            if (_duration)
              DurationField(
                valueKey: const Key('edit-duration'),
                seconds: _seconds,
                clock: widget.clock,
                onChanged: (v) => setState(() => _seconds = v),
              )
            else
              ValueStepper(
                valueKey: const Key('edit-reps'),
                valueText: _reps?.toString(),
                unit: 'tekrar',
                noun: 'tekrarı',
                onStep: (d) => setState(() => _reps = nextReps(_reps, d)),
              ),
            const SizedBox(height: 16),
            MfButton(label: 'Kaydet', onPressed: _valid ? _save : null),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                foregroundColor: t.danger,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Seti sil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Antrenman ortasında hareket arama sayfası; seçilen hareketi döndürür.
class ExerciseSearchPage extends ConsumerStatefulWidget {
  const ExerciseSearchPage({required this.inPlan, super.key});

  /// Zaten listede olan hareketler ("Listede" diye işaretlenir).
  final Set<String> inPlan;

  @override
  ConsumerState<ExerciseSearchPage> createState() => _ExerciseSearchPageState();
}

class _ExerciseSearchPageState extends ConsumerState<ExerciseSearchPage> {
  late Future<List<ExerciseOption>> _results = _search('');

  Future<List<ExerciseOption>> _search(String q) =>
      ref.read(workoutQueriesProvider).searchExercises(q);

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hareket ekle'),
        backgroundColor: t.background,
        foregroundColor: t.text,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Hareket ara',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) {
                final next = _search(q);
                setState(() {
                  _results = next;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ExerciseOption>>(
              future: _results,
              builder: (context, snap) {
                final list = snap.data;
                if (list == null) return const Center(child: CircularProgressIndicator());
                if (list.isEmpty) {
                  return Center(
                    child: Text('Hareket bulunamadı.', style: TextStyle(color: t.textMuted)),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    final has = widget.inPlan.contains(e.id);
                    return ListTile(
                      minTileHeight: 56,
                      title: Text(e.nameTr, style: TextStyle(color: t.text)),
                      trailing: has
                          ? Text('Listede', style: TextStyle(color: t.textMuted))
                          : Icon(Icons.add, color: t.text),
                      onTap: () => Navigator.of(context).pop(e),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tüm hareket listesi (üstteki liste düğmesi); seçilen hareketin kimliğini döndürür.
Future<String?> showExerciseList(
  BuildContext context, {
  required List<RailItem> items,
  required Map<String, String> progress,
  required String? currentId,
}) {
  final t = mf(context);
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: t.surface,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final it in items)
            ListTile(
              minTileHeight: 56,
              selected: it.id == currentId,
              selectedColor: t.text,
              leading: Icon(
                it.complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: it.complete ? t.text : t.textMuted,
              ),
              title: Text(it.name, style: TextStyle(color: t.text)),
              trailing: Text(progress[it.id] ?? '', style: TextStyle(color: t.textMuted)),
              onTap: () => Navigator.pop(ctx, it.id),
            ),
        ],
      ),
    ),
  );
}

/// "Antrenmanı bitir / devam" sorusu; "Bitir" seçilirse true.
Future<bool> showFinishDialog(BuildContext context, {required int setCount}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Antrenmanı bitir?'),
        content: Text(
          setCount == 0
              ? 'Henüz set yok. Bitirirsen antrenman kaydedilmez.'
              : '$setCount set tamamlandı. Bitirirsen antrenman kaydedilir.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Devam et')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bitir')),
        ],
      ),
    ) ??
    false;
