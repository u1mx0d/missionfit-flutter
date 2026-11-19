import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_logo.dart';
import 'auth_scaffold.dart';
import 'google_button.dart';

/// Açılış animasyonu uygulama açılışı başına bir kez oynar.
final welcomeIntroPlayedProvider = NotifierProvider<WelcomeIntroPlayed, bool>(
  WelcomeIntroPlayed.new,
);

class WelcomeIntroPlayed extends Notifier<bool> {
  @override
  bool build() => false;

  void markPlayed() => state = true;
}

// Süreler (ms): noktalar, orta nokta, yazı/düğmeler.
const _dotsMs = 900;
const _centerMs = 150;
const _textMs = 250;
const _totalMs = _dotsMs + _centerMs + _textMs;

/// Oturum yokken ilk ekran: nokta-matris logo oluşur, ardından yazı ve düğmeler belirir.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval((_dotsMs + _centerMs) / _totalMs, 1, curve: Curves.easeOut),
  );
  bool _started = false;
  String? _failure;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final skip = ref.read(welcomeIntroPlayedProvider) || MediaQuery.disableAnimationsOf(context);
    if (skip) {
      _c.value = 1;
      // Provider'a build sırasında yazılamaz.
      Future.microtask(() {
        if (mounted) ref.read(welcomeIntroPlayedProvider.notifier).markPlayed();
      });
    } else {
      _c.forward().whenComplete(() {
        if (mounted) ref.read(welcomeIntroPlayedProvider.notifier).markPlayed();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Denetleyici değerini logo ilerlemesine çevirir: noktalar 0..0.84, orta nokta 0.85..1.
  double _logoProgress(double v) {
    final ms = v * _totalMs;
    if (ms <= _dotsMs) return 0.84 * (ms / _dotsMs);
    if (ms >= _dotsMs + _centerMs) return 1;
    return 0.85 + 0.15 * ((ms - _dotsMs) / _centerMs);
  }

  Future<void> _google() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final google = ref.watch(envProvider).googleSignInEnabled;
    return Scaffold(
      body: MfBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (_, _) => MfLogo(size: 160, progress: _logoProgress(_c.value)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'MISSIONFIT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: t.numberFont,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Her gün bir görev. Her set bir adım.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted, fontSize: 15),
                          ),
                          const SizedBox(height: 40),
                          AuthErrorText(_failure),
                          if (google) ...[
                            GoogleButton(onPressed: _busy ? null : _google),
                            const SizedBox(height: 12),
                          ],
                          MfButton(
                            label: 'E-posta ile kayıt ol',
                            onPressed: () => context.go('/kayit'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                            onPressed: () => context.go('/giris'),
                            child: Text(
                              'Hesabın var mı? Giriş yap',
                              style: TextStyle(color: t.text),
                            ),
                          ),
                        ],
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
