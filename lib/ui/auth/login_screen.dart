import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'auth_scaffold.dart';
import 'google_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  Map<String, String> _errors = const {};
  String? _failure;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      // Yönlendirme oturum korumalarına bırakılır.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final r = validateSignIn(email: _email.text, password: _password.text);
    setState(() => _errors = r.errors);
    if (!r.ok) return;
    await _run(() => ref.read(authRepositoryProvider).signIn(r.email!, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final google = ref.watch(envProvider).googleSignInEnabled;
    return AuthScaffold(
      title: 'Hoş geldin',
      subtitle: 'Hesabına giriş yap.',
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _busy ? null : () => context.push('/sifremi-unuttum'),
            child: const Text('Şifremi unuttum'),
          ),
        ),
        AuthErrorText(_failure),
        MfButton(label: 'Giriş yap', loading: _busy, onPressed: _submit),
        if (google) ...[
          const SizedBox(height: 12),
          GoogleButton(
            onPressed: _busy
                ? null
                : () => _run(() => ref.read(authRepositoryProvider).signInWithGoogle()),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => context.go('/kayit'),
          child: Text('Hesabın yok mu? Kayıt ol', style: TextStyle(color: t.text)),
        ),
      ],
    );
  }
}
