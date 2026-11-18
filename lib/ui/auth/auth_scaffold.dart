import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_card.dart';
import '../components/mf_text_field.dart';

/// Tekrar gönderme bekleme süresi; testlerde değiştirilebilir.
final resendCooldownProvider = Provider<Duration>((_) => const Duration(seconds: 60));

/// Tüm kimlik doğrulama ekranlarının ortak çerçevesi: tema zemini, başlık, kart.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.showBack = false,
    super.key,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MfBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MissionFit',
                      style: TextStyle(
                        fontFamily: t.displayFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: t.displayFont,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!, style: TextStyle(color: t.textMuted)),
                    ],
                    const SizedBox(height: 20),
                    MfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
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

/// Satır içi hata kutusu (yalnızca snackbar değil).
class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message!,
          key: const Key('auth-error'),
          style: TextStyle(color: mf(context).danger, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Göster/gizle düğmeli şifre alanı.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.controller,
    this.errorText,
    this.enabled = true,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => MfTextField(
    label: widget.label,
    controller: widget.controller,
    obscureText: _hidden,
    errorText: widget.errorText,
    enabled: widget.enabled,
    suffix: IconButton(
      tooltip: _hidden ? 'Şifreyi göster' : 'Şifreyi gizle',
      icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
      onPressed: () => setState(() => _hidden = !_hidden),
    ),
  );
}

/// Tekrar gönder düğmesi + geri sayım. Geri sayım zamanlayıcı tikleriyle ilerler.
class ResendButton extends ConsumerStatefulWidget {
  const ResendButton({required this.onResend, this.startImmediately = true, super.key});
  final Future<void> Function() onResend;
  final bool startImmediately;

  @override
  ConsumerState<ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends ConsumerState<ResendButton> {
  Timer? _timer;
  int _left = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _left = ref.read(resendCooldownProvider).inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left = _left - 1);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_busy || _left > 0) return;
    setState(() => _busy = true);
    try {
      await widget.onResend();
      _start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _left > 0;
    return MfButton(
      label: waiting ? 'Kodu tekrar gönder ($_left)' : 'Kodu tekrar gönder',
      secondary: true,
      loading: _busy,
      onPressed: waiting ? null : _resend,
    );
  }
}
