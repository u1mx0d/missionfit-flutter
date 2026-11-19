import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/pending_signup.dart';
import '../../app/providers.dart';
import '../../domain/auth_rules.dart';
import '../components/athlete_card.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'auth_scaffold.dart';

/// "AKTİF" damgasından sonra yönlendirmenin bekletildiği süre.
const activeStampHold = Duration(milliseconds: 700);

/// Testlerde kısaltılabilsin diye sağlayıcı üzerinden okunur.
final activeStampHoldProvider = Provider<Duration>((_) => activeStampHold);

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
  bool _active = false;
  bool _holding = false;
  late final AuthHold _hold = ref.read(authHoldProvider.notifier);

  /// Doğrulama ve "AKTİF" beklemesi bitene kadar yönlendirici bu ekranda tutulur.
  void _setHold(bool value) {
    _holding = value;
    _hold.set(value);
  }

  @override
  void dispose() {
    // Bekleme sürerken ekran kapanırsa yönlendirme kilitli kalmasın.
    if (_holding) {
      _holding = false;
      final hold = _hold;
      // Ağaç kapanırken sağlayıcı değiştirilmez; bir sonraki mikro görevde bırakılır.
      Future.microtask(() {
        try {
          hold.set(false);
        } catch (_) {}
      });
    }
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
    final holdFor = ref.read(activeStampHoldProvider);
    // Oturum açılsa da "AKTİF" damgası görünene dek yönlendirme bekletilir.
    _setHold(true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifySignUpCode(widget.email, normalizeOtp(_code.text)!);
      await ref.read(pendingSignupEmailProvider.notifier).clear();
      if (!mounted) return;
      setState(() => _active = true);
      await Future<void>.delayed(holdFor);
      // Yönlendirme oturum korumalarına bırakılır.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (_holding) _setHold(false);
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
        showBack: true,
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
      showBack: true,
      header: AthleteCard(
        mode: _active ? AthleteCardMode.active : AthleteCardMode.awaitingCode,
        data: AthleteCardData(email: widget.email),
      ),
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
