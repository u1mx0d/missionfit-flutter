import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, String> _errors = const {};
  String? _failure;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final r = validateSignUp(
      email: _email.text,
      password: _password.text,
      passwordConfirm: _confirm.text,
    );
    setState(() {
      _errors = r.errors;
      _failure = null;
    });
    if (!r.ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signUp(r.email!, _password.text);
      if (!mounted) return;
      context.go('/dogrula?email=${Uri.encodeQueryComponent(r.email!)}');
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return AuthScaffold(
      title: 'Hesap oluştur',
      subtitle: 'E-postana bir doğrulama kodu göndereceğiz.',
      children: [
        MfTextField(
          label: 'E-posta',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: _errors['email'],
          enabled: !_busy,
        ),
        const SizedBox(height: 12),
        PasswordField(
          label: 'Şifre',
          controller: _password,
          errorText: _errors['password'],
          enabled: !_busy,
        ),
        const SizedBox(height: 12),
        PasswordField(
          label: 'Şifre tekrar',
          controller: _confirm,
          errorText: _errors['passwordConfirm'],
          enabled: !_busy,
        ),
        const SizedBox(height: 16),
        AuthErrorText(_failure),
        MfButton(label: 'Kayıt ol', loading: _busy, onPressed: _submit),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => context.go('/giris'),
          child: Text('Zaten hesabın var mı? Giriş yap', style: TextStyle(color: t.text)),
        ),
      ],
    );
  }
}
