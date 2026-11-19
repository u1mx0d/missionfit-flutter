import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'auth_scaffold.dart';

const passwordUpdatedMessage = 'Şifren güncellendi.';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, String> _errors = const {};
  String? _failure;
  String? _sentTo;
  bool _busy = false;

  /// Kod doğrulandı (oturum açıldı); tekrar denemede yalnızca şifre güncellenir.
  bool _verified = false;
  bool _holding = false;
  late final AuthHold _hold = ref.read(authHoldProvider.notifier);

  /// Doğrulama + güncelleme bitene kadar yönlendirici bu ekranda tutulur; böylece sonuç
  /// (hata ya da başarı) kullanıcıya her zaman gösterilir.
  void _setHold(bool value) {
    _holding = value;
    _hold.set(value);
  }

  @override
  void dispose() {
    if (_holding) {
      final hold = _hold;
      // Ağaç kapanırken sağlayıcı değiştirilmez; bir sonraki mikro görevde bırakılır.
      Future.microtask(() {
        try {
          hold.set(false);
        } catch (_) {}
      });
    }
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() body) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await body();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    final r = validateForgotPassword(email: _email.text);
    setState(() => _errors = r.errors);
    if (!r.ok) return;
    await _run(() async {
      await ref.read(authRepositoryProvider).sendResetCode(r.email!);
      if (mounted) setState(() => _sentTo = r.email);
    });
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).sendResetCode(_sentTo!);
      if (mounted) setState(() => _failure = null);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    }
  }

  Future<void> _reset() async {
    final r = validateResetPassword(
      code: _code.text,
      password: _password.text,
      passwordConfirm: _confirm.text,
    );
    setState(() => _errors = r.errors);
    if (!r.ok) return;
    final messenger = ScaffoldMessenger.of(context);
    await _run(() async {
      final repo = ref.read(authRepositoryProvider);
      _setHold(true);
      try {
        if (!_verified) {
          await repo.verifyResetCode(_sentTo!, normalizeOtp(_code.text)!);
          _verified = true;
        }
        await repo.updatePassword(_password.text);
      } catch (_) {
        // Kod doğrulanamadıysa oturum yok; tutmaya gerek kalmaz. Doğrulandıysa hata bu
        // ekranda gösterilir ve kullanıcı yeniden deneyebilir.
        if (!_verified) _setHold(false);
        rethrow;
      }
      messenger.showSnackBar(const SnackBar(content: Text(passwordUpdatedMessage)));
      // Oturum açık; tutma bırakılınca yönlendirme korumalara bırakılır.
      _setHold(false);
    });
  }

  /// Girişe dönüş: üste açıldıysa kapatılır, değilse girişe gidilir.
  void _leave() {
    if (_busy) return;
    if (_holding) _setHold(false);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/giris');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final second = _sentTo != null;
    return AuthScaffold(
      title: 'Şifreni sıfırla',
      showBack: true,
      onBack: _leave,
      subtitle: second
          ? '$_sentTo adresine gönderdiğimiz kodu ve yeni şifreni gir.'
          : 'E-postana bir sıfırlama kodu göndereceğiz.',
      children: [
        if (!second) ...[
          MfTextField(
            label: 'E-posta',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _errors['email'],
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: 16),
          AuthErrorText(_failure),
          MfButton(label: 'Kod gönder', loading: _busy, onPressed: _sendCode),
        ] else ...[
          MfTextField(
            label: 'Doğrulama kodu',
            controller: _code,
            keyboardType: TextInputType.number,
            errorText: _errors['code'],
            enabled: !_busy,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          PasswordField(
            label: 'Yeni şifre',
            controller: _password,
            errorText: _errors['password'],
            enabled: !_busy,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          PasswordField(
            label: 'Yeni şifre tekrar',
            controller: _confirm,
            errorText: _errors['passwordConfirm'],
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _reset(),
          ),
          const SizedBox(height: 16),
          AuthErrorText(_failure),
          MfButton(label: 'Şifreyi güncelle', loading: _busy, onPressed: _reset),
          const SizedBox(height: 8),
          ResendButton(onResend: _resend),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy
              ? null
              : () {
                  if (_holding) _setHold(false);
                  context.go('/giris');
                },
          child: Text('Girişe dön', style: TextStyle(color: t.text)),
        ),
      ],
    );
  }
}
