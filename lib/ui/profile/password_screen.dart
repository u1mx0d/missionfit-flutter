import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../auth/auth_scaffold.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import 'profile_widgets.dart';

/// Şifre değiştirme: önce mevcut şifre doğrulanır (yeniden giriş), sonra yeni şifre yazılır.
/// Böylece açık kalmış bir telefonda başkası şifreyi değiştiremez.
class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, String> _errors = {};
  String? _failure;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final errors = <String, String>{};
    if (_current.text.isEmpty) errors['current'] = 'Mevcut şifreni yaz.';
    final p = passwordError(_password.text);
    if (p != null) errors['password'] = p;
    if (_password.text != _confirm.text) errors['confirm'] = 'Şifreler eşleşmiyor.';
    final email = ref.read(currentUserEmailProvider);
    setState(() {
      _errors = errors;
      _failure = null;
    });
    if (errors.isNotEmpty) return;
    if (email == null) {
      setState(() => _failure = 'Oturum bilgisi alınamadı. Lütfen tekrar giriş yap.');
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      try {
        await repo.reauthenticateWithPassword(email, _current.text);
      } on AuthFailure catch (e) {
        if (mounted) setState(() => _errors = {'current': e.message});
        return;
      }
      await repo.updatePassword(_password.text);
      if (!mounted) return;
      showSnack(context, 'Şifren güncellendi.');
      if (context.canPop()) context.pop();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SubPage(
    title: 'Şifre değiştir',
    children: [
      PasswordField(
        label: 'Mevcut şifre',
        controller: _current,
        errorText: _errors['current'],
        enabled: !_busy,
      ),
      const SizedBox(height: 12),
      PasswordField(
        label: 'Yeni şifre',
        controller: _password,
        errorText: _errors['password'],
        enabled: !_busy,
      ),
      const SizedBox(height: 4),
      Text(
        'En az 8 karakter, en az bir harf ve bir rakam.',
        style: TextStyle(color: mf(context).textMuted, fontSize: 13),
      ),
      const SizedBox(height: 12),
      PasswordField(
        label: 'Yeni şifre tekrar',
        controller: _confirm,
        errorText: _errors['confirm'],
        enabled: !_busy,
      ),
      InlineError(_failure),
      const SizedBox(height: 16),
      MfButton(label: 'Şifreyi güncelle', loading: _busy, onPressed: _submit),
    ],
  );
}
