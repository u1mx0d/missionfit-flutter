import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/known_accounts.dart';
import '../../app/pending_signup.dart';
import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/athlete_card.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_card.dart';
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
  void initState() {
    super.initState();
    // E-posta bir kez en son giriş yapılan hesapla doldurulur; sonra kart alanı izler.
    final known = ref.read(knownAccountsProvider);
    if (known.isNotEmpty) _email.text = known.first.email;
    _email.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _email.removeListener(_onEmailChanged);
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
      // Giriş başarılı: bekleyen kayıt artık geçersiz. Yönlendirme oturum korumalarına bırakılır.
      await ref.read(pendingSignupEmailProvider.notifier).clear();
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
    final email = r.email!;
    await _run(() async {
      try {
        await ref.read(authRepositoryProvider).signIn(email, _password.text);
      } on AuthFailure catch (e) {
        if (e.code != 'email_not_confirmed') rethrow;
        // Kod hiç girilmemiş: yeni kod gönderip doğrulama ekranına götür.
        await ref.read(authRepositoryProvider).resendSignUpCode(email);
        await ref.read(pendingSignupEmailProvider.notifier).set(email);
        if (mounted) _goVerify(email);
      }
    });
  }

  /// Kartı bu telefondan kaldırır; bildirimdeki "Geri al" aynı kaydı geri yazar.
  Future<void> _removeCard(KnownAccount account) async {
    final notifier = ref.read(knownAccountsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    await notifier.remove(account.userId);
    if (!mounted) return;
    // Alandaki e-posta kaldırılan karta aitse temizlenir.
    final matched = _email.text.trim().toLowerCase() == account.email;
    if (matched) _email.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Kart bu telefondan kaldırıldı.'),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () async {
              await notifier.upsert(account);
              if (mounted && matched && _email.text.isEmpty) _email.text = account.email;
            },
          ),
        ),
      );
  }

  void _goVerify(String email) => context.go('/dogrula?email=${Uri.encodeQueryComponent(email)}');

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final google = ref.watch(envProvider).googleSignInEnabled;
    final pending = ref.watch(pendingSignupEmailProvider);
    ref.watch(knownAccountsProvider);
    final known = ref.read(knownAccountsProvider.notifier).match(_email.text);
    final noAnim = MediaQuery.of(context).disableAnimations;
    return AuthScaffold(
      title: 'Hesabına giriş yap',
      showBack: true,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kayıtlı hesap ile örnek kart arasında kısa çapraz geçiş.
          AnimatedSwitcher(
            duration: noAnim ? Duration.zero : const Duration(milliseconds: 200),
            child: known == null
                ? const AthleteCard(key: ValueKey('sample'), mode: AthleteCardMode.sample)
                : AthleteCard(
                    key: ValueKey(known.userId),
                    mode: AthleteCardMode.saved,
                    data: AthleteCardData(
                      displayName: known.displayName,
                      username: known.username,
                      email: known.email,
                      avatarUrl: known.avatarUrl,
                      memberSince: known.memberSince,
                    ),
                    onRemove: () => _removeCard(known),
                  ),
          ),
          if (pending != null) ...[
            const SizedBox(height: 12),
            _PendingSignupCard(email: pending, onOpen: _goVerify),
          ],
        ],
      ),
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MfTextField(
                label: 'E-posta',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                errorText: _errors['email'],
                enabled: !_busy,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              PasswordField(
                label: 'Şifre',
                controller: _password,
                autofillHints: const [AutofillHints.password],
                errorText: _errors['password'],
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
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

/// Kaydı yarım kalan kullanıcıyı (ör. Gmail'e bakarken uygulama kapandıysa) koda geri götürür.
class _PendingSignupCard extends ConsumerWidget {
  const _PendingSignupCard({required this.email, required this.onOpen});
  final String email;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    return MfCard(
      child: Row(
        children: [
          Icon(Icons.mark_email_unread_outlined, color: t.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaydını tamamla',
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('$email adresine gelen kodu gir.', style: TextStyle(color: t.textMuted)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: () => onOpen(email), child: const Text('Kodu gir')),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('pending-signup-dismiss'),
            tooltip: 'Kapat',
            icon: Icon(Icons.close, color: t.textMuted),
            onPressed: () => ref.read(pendingSignupEmailProvider.notifier).clear(),
          ),
        ],
      ),
    );
  }
}
