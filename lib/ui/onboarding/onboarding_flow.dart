import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/onboarding_controller.dart';
import '../../app/profile_controller.dart' show signedInUserIdProvider;
import '../../app/providers.dart';
import '../../app/theme_controller.dart';
import '../../app/today_provider.dart';
import '../components/unsynced_sign_out.dart';
import '../../domain/notification_settings.dart';
import '../../domain/onboarding_rules.dart';
import '../../domain/training_style.dart';
import '../../domain/units.dart';
import '../../domain/username.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../profile/avatar_source_sheet.dart';
import '../profile/edit_profile_screen.dart'
    show AvatarBytes, AvatarFromUrl, applyAvatarChange, identityUnexpectedMessage;
import '../profile/profile_widgets.dart' show showSnack;
import 'birth_date_step.dart';
import 'body_step.dart';
import 'calorie_preview_step.dart';
import 'consent_step.dart';
import 'goal_step.dart';
import 'goals_step.dart';
import 'identity_step.dart';
import 'notification_step.dart';
import 'onboarding_draft.dart';
import 'style_step.dart';
import 'theme_step.dart';

const _stepCount = 10;
const _consentStep = 0, _identityStep = 1, _styleStep = 2, _goalsStep = 3, _birthStep = 4;
const _bodyStep = 5, _goalStep = 6, _previewStep = 7, _notificationStep = 8, _themeStep = 9;
const _suggestionAttempts = 5;
const photoLaterMessage = 'Fotoğrafını profilden ekleyebilirsin.';
const _saveFailedMessage = 'Bilgilerin kaydedilemedi. Lütfen tekrar dene.';

/// 10 adımlı onboarding: rıza, profil (ad, kullanıcı adı, fotoğraf), antrenman tarzı ve seviye,
/// hedef hareketler/alanlar (atlanabilir), doğum tarihi, vücut, aktivite ve hedef, kalori
/// önizlemesi, bildirim izni, tema. Kullanıcı adı profil adımında
/// sunucuda alınır; geri kalan her şey bitişte tek profil güncellemesiyle yazılır.
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
  void initState() {
    super.initState();
    final current = ref.read(themeControllerProvider);
    _draft
      ..family = current.family
      ..mode = current.mode;
    final google = ref.read(googleProfileProvider);
    if (google?.name != null) _draft.displayName.text = google!.name!;
    if (google?.photoUrl != null) {
      _draft.avatar = AvatarFromUrl(googlePhotoAt512(google!.photoUrl!));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _suggestUsername(google?.name));
  }

  /// Addan/e-postadan kullanıcı adı önerir; alınmışsa sonuna sayı ekleyip birkaç kez dener.
  /// Çevrimdışıysa taban öneri olduğu gibi kalır (adımda sunucu yine kontrol eder).
  Future<void> _suggestUsername(String? name) async {
    if (_draft.username.text.isNotEmpty) return;
    final base = usernameBase(fullName: name, email: ref.read(currentUserEmailProvider));
    final repo = ref.read(profileIdentityRepositoryProvider);
    final random = Random();
    var candidate = base;
    try {
      for (var i = 0; i < _suggestionAttempts; i++) {
        if (await repo.isUsernameAvailable(candidate)) break;
        candidate = usernameWithSuffix(base, 10 + random.nextInt(90));
      }
    } catch (_) {
      candidate = base;
    }
    if (!mounted || _draft.username.text.isNotEmpty) return;
    _draft.username.text = candidate;
  }

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
      case _identityStep:
        final n = validateDisplayName(_draft.displayName.text);
        if (n != null) e['displayName'] = n;
        final u = validateUsername(normalizeUsername(_draft.username.text));
        if (u != null) e['username'] = u;
      case _styleStep:
        final s = validateStyle(_draft.style, _draft.level);
        if (s != null) e[_draft.style.main == null ? 'style' : 'level'] = s;
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
      // Cihazdaki mevcut tema önceden seçili gelir (yoksa Canlı); seçim anında önizlenir.
      ref.read(themeControllerProvider.notifier).preview(family: _draft.family, mode: _draft.mode);
    }
  }

  void _next() {
    if (!_validate()) return;
    if (_step == _identityStep) {
      _claimUsername();
      return;
    }
    _goTo(_step + 1);
  }

  /// Kullanıcı adını sunucuda alır; alınamazsa adımda kalınır.
  Future<void> _claimUsername() async {
    final username = normalizeUsername(_draft.username.text);
    if (username == _draft.claimedUsername) return _goTo(_identityStep + 1);
    final userId = ref.read(signedInUserIdProvider);
    if (userId == null) {
      setState(() => _errors = {'identity': identityUnexpectedMessage});
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(profileIdentityRepositoryProvider).setUsername(userId, username);
      _draft.claimedUsername = username;
      if (!mounted) return;
      setState(() => _busy = false);
      _goTo(_identityStep + 1);
    } on IdentityError catch (e) {
      if (!mounted) return;
      final field =
          e.failure == IdentityFailure.usernameTaken ||
          e.failure == IdentityFailure.usernameInvalid;
      setState(() {
        _busy = false;
        _errors = {field ? 'username' : 'identity': e.message};
      });
    } catch (e) {
      // Eşlenmemiş sunucu/auth hatası: adım kilitli kalmasın.
      debugPrint('Kullanıcı adı alınamadı: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errors = {'identity': identityUnexpectedMessage};
      });
    }
  }

  Future<void> _pickAvatar() async {
    final action = await showAvatarSourceSheet(context, canRemove: _draft.avatar != null);
    if (action == null || !mounted) return;
    if (action == AvatarAction.remove) return _touch(() => _draft.avatar = null);
    final source = action == AvatarAction.camera ? AvatarSource.camera : AvatarSource.gallery;
    try {
      final bytes = await ref.read(avatarPickerProvider).pick(source);
      if (bytes != null && mounted) _touch(() => _draft.avatar = AvatarBytes(bytes));
    } catch (_) {
      if (mounted) setState(() => _errors = {'identity': 'Fotoğraf açılamadı.'});
    }
  }

  /// "Hedeflerin" atlanır: hedef ve alan listeleri boş kaydedilir.
  void _skipGoals() {
    _draft
      ..goalMoves = {}
      ..focusAreas = {};
    _goTo(_goalsStep + 1);
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
        d.goal == null ||
        d.style.main == null ||
        d.level == null) {
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
          trainingStyle: d.style.main!,
          sideStyles: d.style.sides,
          trainingLevel: d.level!,
          goalMoves: d.orderedGoalMoves,
          focusAreas: [
            for (final a in FocusArea.values)
              if (d.focusAreas.contains(a)) a,
          ],
          displayName: d.displayName.text.trim(),
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
    // Fotoğraf isteğe bağlı: yüklenemezse onboarding yine tamamlanır.
    var photoFailed = false;
    final avatar = d.avatar;
    final userId = ref.read(signedInUserIdProvider);
    if (avatar != null && userId != null) {
      try {
        await applyAvatarChange(ref.read(profileIdentityRepositoryProvider), userId, avatar);
      } catch (_) {
        photoFailed = true;
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/bugun');
    if (photoFailed) showSnack(context, photoLaterMessage);
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
    if (!await flushOrConfirmSignOut(context, ref) || !mounted) return;
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
    _identityStep => IdentityStep(
      displayName: _draft.displayName,
      username: _draft.username,
      avatar: _draft.avatar,
      ownUsername: _draft.claimedUsername,
      email: ref.watch(currentUserEmailProvider),
      onPickAvatar: _pickAvatar,
      onChanged: _touch,
      errors: _errors,
      enabled: !_busy,
    ),
    _styleStep => StyleStep(
      style: _draft.style,
      level: _draft.level,
      onStyle: (v) => _touch(() => _draft.style = v),
      onLevel: (v) => _touch(() => _draft.level = v),
      errors: _errors,
    ),
    _goalsStep => GoalsStep(
      options: _draft.goalOptions,
      goals: _draft.goalMoves,
      areas: _draft.focusAreas,
      onGoals: (v) => _touch(() => _draft.goalMoves = v),
      onAreas: (v) => _touch(() => _draft.focusAreas = v),
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
    _previewStep => CaloriePreviewStep(result: _draft.preview(_currentYear)),
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
      case _goalsStep:
        return [
          MfButton(label: 'Devam', onPressed: _next),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _skipGoals,
            child: Text('Şimdilik atla', style: TextStyle(color: mf(context).textMuted)),
          ),
        ];
      case _identityStep:
        return [MfButton(label: 'Devam', loading: _busy, onPressed: _busy ? null : _next)];
      default:
        return [MfButton(label: 'Devam', onPressed: _next)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return PopScope(
      canPop: _step == 0 && !_busy,
      onPopInvokedWithResult: (didPop, _) {
        // Kayıt sürerken geri gidilmez (yoksa sonuç gelince adım atlanırdı).
        if (!didPop && !_busy) _back();
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
