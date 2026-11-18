import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/onboarding_controller.dart';
import '../../app/providers.dart';
import '../../app/theme_controller.dart';
import '../../app/today_provider.dart';
import '../../domain/notification_settings.dart';
import '../../domain/onboarding_rules.dart';
import '../../domain/units.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import 'birth_date_step.dart';
import 'body_step.dart';
import 'calorie_preview_step.dart';
import 'consent_step.dart';
import 'goal_step.dart';
import 'notification_step.dart';
import 'onboarding_draft.dart';
import 'theme_step.dart';

const _stepCount = 7;
const _consentStep = 0, _birthStep = 1, _bodyStep = 2, _goalStep = 3;
const _notificationStep = 5, _themeStep = 6;
const _saveFailedMessage = 'Bilgilerin kaydedilemedi. Lütfen tekrar dene.';

/// 7 adımlı onboarding: rıza, doğum tarihi, vücut, aktivite ve hedef, kalori önizlemesi,
/// bildirim izni, tema. Bitişte tek profil güncellemesi yapılır.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _draft = OnboardingDraft();
  int _step = 0;
  Map<String, String> _errors = {};
  bool _busy = false;
  String? _saveError;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _touch([VoidCallback? change]) => setState(() {
    change?.call();
    _errors = {};
    _saveError = null;
  });

  bool _validate() {
    final e = <String, String>{};
    switch (_step) {
      case _consentStep:
        if (!_draft.consentKvkk || !_draft.consentHealth) {
          e['consent'] = 'Devam etmek için iki onayı da işaretle.';
        }
      case _birthStep:
        final r = validateBirthDate(
          day: _draft.day.text,
          month: _draft.month.text,
          year: _draft.year.text,
          today: localToday(ref.read(clockProvider)()),
        );
        if (r is BirthDateInputError) e['birth'] = r.message;
      case _bodyStep:
        if (_draft.sex == null) e['sex'] = 'Bir seçenek seç.';
        final h = validateHeight(_draft.height.text);
        if (h != null) e['height'] = h;
        final w = parseWeightInUnit(_draft.weight.text, _draft.units).message;
        if (w != null) e['weight'] = w;
      case _goalStep:
        if (_draft.activity == null) e['activity'] = 'Sana en yakın seçeneği seç.';
        if (_draft.goal == null) e['goal'] = 'Bir hedef seç.';
    }
    setState(() => _errors = e);
    return e.isEmpty;
  }

  void _goTo(int step) {
    setState(() {
      _step = step.clamp(0, _stepCount - 1);
      _errors = {};
      _saveError = null;
    });
    if (_step == _themeStep) {
      // Canlı önceden seçili gelir; seçim anında tüm uygulamada önizlenir.
      ref.read(themeControllerProvider.notifier).preview(family: _draft.family, mode: _draft.mode);
    }
  }

  void _next() {
    if (_validate()) _goTo(_step + 1);
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  int get _currentYear => localToday(ref.read(clockProvider)()).year;

  Future<void> _askPermission() async {
    setState(() => _busy = true);
    try {
      _draft.permission = await ref.read(notificationServiceProvider).requestPermission();
    } catch (_) {
      // İzin istenemezse onboarding engellenmez; Profil'den tekrar denenebilir.
    }
    if (!mounted) return;
    setState(() => _busy = false);
    _goTo(_themeStep);
  }

  void _setUnits(WeightUnit next) {
    if (next == _draft.units) return;
    final current = parseDecimal(_draft.weight.text);
    _touch(() {
      if (current != null) {
        final kg = toKg(current, _draft.units);
        final v = fromKg(kg, next);
        _draft.weight.text = (v == v.truncateToDouble() ? v.toInt().toString() : '$v').replaceAll(
          '.',
          ',',
        );
      }
      _draft.units = next;
    });
  }

  Future<void> _finish() async {
    final d = _draft;
    final result = d.preview(_currentYear);
    final kg = d.weightKg;
    final height = d.heightCm;
    final birthYear = d.birthYear;
    if (result == null ||
        kg == null ||
        height == null ||
        birthYear == null ||
        d.sex == null ||
        d.activity == null ||
        d.goal == null) {
      return;
    }
    setState(() {
      _busy = true;
      _saveError = null;
    });
    final theme = ref.read(themeControllerProvider);
    try {
      await ref.read(onboardingSaverProvider)(
        OnboardingData(
          birthYear: birthYear,
          sex: d.sex!,
          heightCm: height,
          weightKg: kg,
          units: d.units,
          activityLevel: d.activity!,
          goal: d.goal!,
          calorieTarget: result.target,
          themeFamily: theme.family,
          themeMode: theme.mode,
          accent: theme.accent,
          notificationSettings: d.permission == PermissionState.denied
              ? const NotificationSettings(enabled: false, taskLeadMinutes: 10)
              : defaultNotificationSettings,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _saveError = e is ProfileNotReadyException
            ? ProfileNotReadyException.message
            : _saveFailedMessage;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/bugun');
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yapılsın mı?'),
        content: const Text('Onboarding\'i daha sonra kaldığın yerden yeniden başlatabilirsin.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Çıkış yap')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _saveError = e.message);
    }
  }

  Widget _body() => switch (_step) {
    _consentStep => ConsentStep(
      kvkk: _draft.consentKvkk,
      health: _draft.consentHealth,
      onKvkk: (v) => _touch(() => _draft.consentKvkk = v),
      onHealth: (v) => _touch(() => _draft.consentHealth = v),
      error: _errors['consent'],
    ),
    _birthStep => BirthDateStep(
      day: _draft.day,
      month: _draft.month,
      year: _draft.year,
      error: _errors['birth'],
      onChanged: _touch,
    ),
    _bodyStep => BodyStep(
      sex: _draft.sex,
      onSex: (v) => _touch(() => _draft.sex = v),
      height: _draft.height,
      weight: _draft.weight,
      units: _draft.units,
      onUnits: _setUnits,
      errors: _errors,
      onChanged: _touch,
    ),
    _goalStep => GoalStep(
      activity: _draft.activity,
      goal: _draft.goal,
      onActivity: (v) => _touch(() => _draft.activity = v),
      onGoal: (v) => _touch(() => _draft.goal = v),
      errors: _errors,
    ),
    4 => CaloriePreviewStep(result: _draft.preview(_currentYear)),
    _notificationStep => const NotificationStep(),
    _ => ThemeStep(
      family: _draft.family,
      mode: _draft.mode,
      onFamily: (v) {
        _touch(() => _draft.family = v);
        ref.read(themeControllerProvider.notifier).preview(family: v);
      },
      onMode: (v) {
        _touch(() => _draft.mode = v);
        ref.read(themeControllerProvider.notifier).preview(mode: v);
      },
    ),
  };

  List<Widget> _actions() {
    switch (_step) {
      case _notificationStep:
        return [
          MfButton(label: 'Bildirimlere izin ver', loading: _busy, onPressed: _askPermission),
          const SizedBox(height: 8),
          MfButton(
            label: 'Şimdi değil',
            secondary: true,
            onPressed: _busy ? null : () => _goTo(_themeStep),
          ),
        ];
      case _themeStep:
        return [
          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(_saveError!, style: TextStyle(color: mf(context).danger)),
              ),
            ),
          MfButton(
            label: _saveError == null ? 'Bitir' : 'Tekrar dene',
            loading: _busy,
            onPressed: _finish,
          ),
        ];
      case _consentStep:
        return [
          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_saveError!, style: TextStyle(color: mf(context).danger)),
            ),
          MfButton(label: 'Devam', onPressed: _next),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _busy ? null : _confirmSignOut,
            child: Text('Çıkış yap', style: TextStyle(color: mf(context).textMuted)),
          ),
        ];
      default:
        return [MfButton(label: 'Devam', onPressed: _next)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MfBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: _step > 0
                                ? IconButton(
                                    key: const Key('back'),
                                    tooltip: 'Önceki adım',
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _busy ? null : _back,
                                  )
                                : null,
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (_step + 1) / _stepCount,
                                minHeight: 6,
                                backgroundColor: t.surfaceMuted,
                                color: t.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Semantics(
                            label: 'Adım ${_step + 1} / $_stepCount',
                            excludeSemantics: true,
                            child: Text(
                              '${_step + 1} / $_stepCount',
                              style: TextStyle(color: t.textMuted, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: _body(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _actions(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
