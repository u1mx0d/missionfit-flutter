import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../domain/training_style.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_empty_state.dart';
import '../onboarding/onboarding_widgets.dart';
import '../training/training_style_picker.dart';
import 'profile_widgets.dart';

/// Antrenman tarzı, seviye ve hedefler (Profil'den düzenleme).
class TrainingStyleScreen extends ConsumerWidget {
  const TrainingStyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) {
      return const SubPage(
        title: 'Antrenman tarzım',
        children: [MfEmptyState(icon: Icons.hourglass_empty, title: 'Profil yükleniyor')],
      );
    }
    return _StyleForm(profile: profile);
  }
}

class _StyleForm extends ConsumerStatefulWidget {
  const _StyleForm({required this.profile});
  final Profile profile;

  @override
  ConsumerState<_StyleForm> createState() => _StyleFormState();
}

class _StyleFormState extends ConsumerState<_StyleForm> {
  late StyleSelection _style = StyleSelection(
    main: widget.profile.trainingStyle,
    sides: widget.profile.sideStyles,
  );
  late TrainingLevel? _level = widget.profile.trainingLevel;
  late Set<String> _goals = {...widget.profile.goalMoves};
  late Set<FocusArea> _areas = {...widget.profile.focusAreas};
  String? _error;
  bool _busy = false;

  Future<void> _save() async {
    final problem = validateStyle(_style, _level);
    setState(() => _error = problem);
    if (problem != null) return;
    setState(() => _busy = true);
    final options = goalOptionsFor(_style, keep: _goals);
    final ok = await saveProfile(
      context,
      ref,
      (p) => p.copyWith(
        trainingStyle: _style.main,
        sideStyles: _style.sides,
        trainingLevel: _level,
        // Seçim sırası ekrandaki seçenek sırasını izler.
        goalMoves: [
          for (final k in options)
            if (_goals.contains(k)) k,
        ],
        focusAreas: [
          for (final a in FocusArea.values)
            if (_areas.contains(a)) a,
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showSnack(context, 'Antrenman tarzın kaydedildi.');
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return SubPage(
      title: 'Antrenman tarzım',
      children: [
        StyleGrid(
          value: _style,
          onChanged: (s) => setState(() {
            _style = s;
            _error = null;
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'İlk seçtiğin ana tarzın olur, sonrakiler yan tarz. '
            'Bir yan tarzı ana yapmak için kartına uzun bas.',
            style: TextStyle(color: t.textMuted, fontSize: 13),
          ),
        ),
        const PickerLabel('Seviyen'),
        LevelSelector(
          value: _level,
          onChanged: (l) => setState(() {
            _level = l;
            _error = null;
          }),
        ),
        const SizedBox(height: 8),
        GoalChips(
          options: goalOptionsFor(_style, keep: _goals),
          goals: _goals,
          areas: _areas,
          onGoals: (g) => setState(() => _goals = g),
          onAreas: (a) => setState(() => _areas = a),
        ),
        StepError(_error),
        const SizedBox(height: 16),
        MfButton(label: 'Kaydet', loading: _busy, onPressed: _busy ? null : _save),
      ],
    );
  }
}
