import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/today_provider.dart';
import '../../domain/calories.dart';
import '../../domain/format.dart';
import '../../domain/onboarding_rules.dart';
import '../../domain/units.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_card.dart';
import '../components/mf_empty_state.dart';
import '../onboarding/goal_step.dart';
import '../onboarding/onboarding_widgets.dart';
import 'profile_widgets.dart';

String _decimalText(num? v) => v == null ? '' : v.toString().replaceAll('.', ',');

/// Vücut bilgileri ve günlük kalori hedefi (otomatik ya da elle).
class BodyGoalScreen extends ConsumerWidget {
  const BodyGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) {
      return const SubPage(
        title: 'Vücut ve hedef',
        children: [MfEmptyState(icon: Icons.hourglass_empty, title: 'Profil yükleniyor')],
      );
    }
    return _BodyForm(profile: profile);
  }
}

class _BodyForm extends ConsumerStatefulWidget {
  const _BodyForm({required this.profile});
  final Profile profile;

  @override
  ConsumerState<_BodyForm> createState() => _BodyFormState();
}

class _BodyFormState extends ConsumerState<_BodyForm> {
  late final WeightUnit _unit = widget.profile.units;
  late final _height = TextEditingController(text: _decimalText(widget.profile.heightCm));
  late final _weight = TextEditingController(
    text: widget.profile.weightKg == null
        ? ''
        : _decimalText(fromKg(widget.profile.weightKg!, _unit)),
  );
  late final _birthYear = TextEditingController(text: widget.profile.birthYear?.toString() ?? '');
  late final _manualTarget = TextEditingController(
    text: widget.profile.calorieTarget?.toString() ?? '',
  );
  late Sex? _sex = widget.profile.sex;
  late ActivityLevel? _activity = widget.profile.activityLevel;
  late Goal? _goal = widget.profile.goal;
  late bool _manual = widget.profile.calorieTargetIsManual;
  Map<String, String> _errors = {};
  bool _busy = false;

  int get _year => ref.read(clockProvider)().year;

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _birthYear.dispose();
    _manualTarget.dispose();
    super.dispose();
  }

  void _changed() => setState(() => _errors = {});

  CalorieTargetResult? get _computed {
    final w = parseWeightInUnit(_weight.text, _unit);
    final y = validateBirthYear(_birthYear.text, _year);
    return calorieTargetForProfile(
      ProfileForTarget(
        sex: _sex,
        birthYear: y.year,
        heightCm: validateHeight(_height.text) == null ? parseDecimal(_height.text) : null,
        weightKg: w.kg,
        activityLevel: _activity,
        goal: _goal,
      ),
      _year,
    );
  }

  ManualTargetCheck? get _manualCheck {
    if (!_manual) return null;
    final n = parseIntStrict(_manualTarget.text);
    if (n == null) {
      return ManualTargetRejected(ManualTargetProblem.invalid, calorieFloor[_sex ?? Sex.female]!);
    }
    return validateManualCalorieTarget(n.toDouble(), _sex ?? Sex.female);
  }

  String? _manualError(ManualTargetCheck? check) {
    if (check is! ManualTargetRejected) return null;
    // Alan boşken henüz hata göstermeyiz; yine de kaydet pasif kalır.
    if (_manualTarget.text.trim().isEmpty) return null;
    return switch (check.reason) {
      ManualTargetProblem.belowFloor =>
        'Güvenlik için hedef en az ${formatInt(check.floor)} kcal olabilir. '
            'Daha düşük bir hedef için bir sağlık profesyoneline danış.',
      ManualTargetProblem.tooHigh => 'Hedef en fazla ${formatInt(manualTargetMax)} kcal olabilir.',
      ManualTargetProblem.invalid => 'Geçerli bir sayı yaz (ör. 2100).',
    };
  }

  Future<void> _save() async {
    final next = <String, String>{};
    final h = validateHeight(_height.text);
    if (h != null) next['height'] = h;
    final w = parseWeightInUnit(_weight.text, _unit);
    if (w.message != null) next['weight'] = w.message!;
    final y = validateBirthYear(_birthYear.text, _year);
    if (y.message != null) next['birthYear'] = y.message!;
    if (_sex == null || _activity == null || _goal == null) next['form'] = 'Tüm seçimleri yap.';

    var target = _computed?.target;
    final check = _manualCheck;
    if (check is ManualTargetOk) target = check.value;
    if (_manual && check is! ManualTargetOk) next['manualTarget'] = _manualError(check) ?? '';
    if (next.isEmpty && target == null) next['form'] = 'Hesaplama için tüm alanları doldur.';
    setState(() => _errors = next);
    if (next.isNotEmpty) return;

    setState(() => _busy = true);
    final ok = await saveProfile(
      context,
      ref,
      (p) => p.copyWith(
        heightCm: parseDecimal(_height.text),
        weightKg: w.kg,
        birthYear: y.year,
        sex: _sex,
        activityLevel: _activity,
        goal: _goal,
        calorieTarget: target,
        calorieTargetIsManual: _manual,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showSnack(context, 'Bilgilerin kaydedildi.');
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final computed = _computed;
    final check = _manualCheck;
    final canSave = !_busy && (!_manual || check is ManualTargetOk);
    return SubPage(
      title: 'Vücut ve hedef',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('height'),
                controller: _height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                maxLength: 5,
                onChanged: (_) => _changed(),
                decoration: InputDecoration(
                  labelText: 'Boy (cm)',
                  counterText: '',
                  errorText: _errors['height'],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('weight'),
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                maxLength: 5,
                onChanged: (_) => _changed(),
                decoration: InputDecoration(
                  labelText: 'Kilo (${_unit.name})',
                  counterText: '',
                  errorText: _errors['weight'],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('birth-year'),
          controller: _birthYear,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 4,
          onChanged: (_) => _changed(),
          decoration: InputDecoration(
            labelText: 'Doğum yılı',
            counterText: '',
            errorText: _errors['birthYear'],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Biyolojik cinsiyet',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OptionCard(
                key: const Key('sex-female'),
                title: 'Kadın',
                selected: _sex == Sex.female,
                onTap: () => setState(() {
                  _sex = Sex.female;
                  _errors = {};
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionCard(
                key: const Key('sex-male'),
                title: 'Erkek',
                selected: _sex == Sex.male,
                onTap: () => setState(() {
                  _sex = Sex.male;
                  _errors = {};
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Aktivite seviyesi',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final (value, title, description) in activityOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionCard(
              key: Key(
                'activity-${value == ActivityLevel.veryActive ? 'very-active' : value.name}',
              ),
              title: title,
              description: description,
              selected: _activity == value,
              onTap: () => setState(() {
                _activity = value;
                _errors = {};
              }),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Hedef',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final (value, title, description, icon) in goalOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionCard(
              key: Key('goal-${value.name}'),
              title: title,
              description: description,
              icon: icon,
              selected: _goal == value,
              onTap: () => setState(() {
                _goal = value;
                _errors = {};
              }),
            ),
          ),
        const SizedBox(height: 12),
        MfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Günlük kalori hedefi',
                style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                computed == null
                    ? 'Hesaplama için tüm alanları doldur.'
                    : 'Hesaplanan: ${formatInt(computed.target)} kcal (tahmini; '
                          'BMR ${formatInt(computed.bmr)}, günlük harcama ${formatInt(computed.tdee)})',
                style: TextStyle(color: t.textMuted, fontSize: 13),
              ),
              if (computed != null && computed.clampedToFloor && !_manual)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Hesaplanan değer güvenli alt sınırın altında kaldığı için '
                    '${formatInt(computed.floor)} kcal olarak ayarlandı.',
                    style: TextStyle(color: t.warning, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(child: Text('Hedefi elle belirle')),
                  Switch(
                    key: const Key('manual-switch'),
                    value: _manual,
                    onChanged: (v) => setState(() {
                      _manual = v;
                      _errors = {};
                      if (v && _manualTarget.text.isEmpty && computed != null) {
                        _manualTarget.text = computed.target.toString();
                      }
                    }),
                  ),
                ],
              ),
              if (_manual) ...[
                const SizedBox(height: 8),
                TextField(
                  key: const Key('manual-target'),
                  controller: _manualTarget,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 5,
                  onChanged: (_) => _changed(),
                  decoration: InputDecoration(
                    labelText: 'Hedef (kcal)',
                    counterText: '',
                    errorText: _errors['manualTarget'] ?? _manualError(check),
                    helperText: check is ManualTargetOk && check.veryHigh
                        ? 'Bu oldukça yüksek bir hedef. Emin misin?'
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        StepError(_errors['form']),
        const SizedBox(height: 16),
        MfButton(label: 'Kaydet', loading: _busy, onPressed: canSave ? _save : null),
      ],
    );
  }
}
