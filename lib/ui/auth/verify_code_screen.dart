import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'auth_scaffold.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({required this.email, super.key});
  final String email;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _code = TextEditingController();
  String? _error;
  String? _failure;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final r = validateVerifyCode(_code.text);
    setState(() {
      _error = r.errors['code'];
      _failure = null;
    });
    if (!r.ok) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifySignUpCode(widget.email, normalizeOtp(_code.text)!);
      // Yönlendirme oturum korumalarına bırakılır.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendSignUpCode(widget.email);
      if (mounted) setState(() => _failure = null);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    if (widget.email.isEmpty) {
      return AuthScaffold(
        title: 'E-postanı doğrula',
        children: [
          const Text('Doğrulanacak e-posta bulunamadı. Kayıt adımına dön.'),
          const SizedBox(height: 16),
          MfButton(label: 'Kayıt ol', onPressed: () => context.go('/kayit')),
        ],
      );
    }
    return AuthScaffold(
      title: 'E-postanı doğrula',
      subtitle: '${widget.email} adresine gönderdiğimiz kodu gir.',
      children: [
        MfTextField(
          label: 'Doğrulama kodu',
          controller: _code,
          keyboardType: TextInputType.number,
          errorText: _error,
          enabled: !_busy,
        ),
        const SizedBox(height: 16),
        AuthErrorText(_failure),
        MfButton(label: 'Doğrula', loading: _busy, onPressed: _submit),
        const SizedBox(height: 8),
        ResendButton(onResend: () => _resend().catchError((_) {})),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => context.go('/giris'),
          child: Text('Girişe dön', style: TextStyle(color: t.text)),
        ),
      ],
    );
  }
}
