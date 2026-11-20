import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../app/known_accounts.dart';
import '../app/pending_signup.dart';
import '../app/profile_controller.dart';
import '../app/providers.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/verify_code_screen.dart';
import 'auth/welcome_screen.dart';
import 'components/dot_grid.dart';
import 'components/mf_button.dart';
import 'onboarding/onboarding_flow.dart';
import 'placeholders/coming_soon_screen.dart';
import 'profile/profile_routes.dart';
import 'shell/app_shell.dart';
import 'today/today_screen.dart';
import 'training/training_routes.dart';
import 'training/training_screen.dart';

const authRoutes = {'/hosgeldin', '/giris', '/kayit', '/dogrula', '/sifremi-unuttum'};
const _splash = '/yukleniyor';

/// Oturum durumundan hedef yol. null = olduğu yerde kalır.
String? redirectFor({
  required String location,
  required bool authResolved,
  required bool hasSession,
  required bool userReady,
  required bool profileLoading,
  required bool onboarded,
  bool awaitingFirstPull = false,
  bool authHold = false,
  String? pendingSignupEmail,
  bool hasKnownAccount = false,
}) {
  final isAuth = authRoutes.contains(location);
  if (!authResolved) return location == _splash ? null : _splash;
  if (!hasSession) {
    // Auth ekranları arasında gezinirken karışılmaz.
    if (isAuth) return null;
    // Yarım kalan kayıt > bu telefonda tanınan hesap > hoş geldin.
    if (pendingSignupEmail != null) {
      return '/dogrula?email=${Uri.encodeQueryComponent(pendingSignupEmail)}';
    }
    return hasKnownAccount ? '/giris' : '/hosgeldin';
  }
  // Çok adımlı kimlik işlemi (şifre sıfırlama) bitene kadar ekranda kalınır.
  if (authHold && isAuth) return null;
  // Oturum var ama kullanıcı değişimi kontrolü ya da (profil yokken) ilk çekme bitmedi:
  // sekmeler ve onboarding gösterilmez; dönen kullanıcı onboarding'e düşmez.
  if (!userReady || (!onboarded && (profileLoading || awaitingFirstPull))) {
    return location == _splash ? null : _splash;
  }
  if (!onboarded) return location == '/onboarding' ? null : '/onboarding';
  if (isAuth || location == '/onboarding' || location == _splash || location == '/') {
    return '/bugun';
  }
  return null;
}

class _RouterRefresh extends ChangeNotifier {
  void poke() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  // Yönlendirici bir kez kurulur; oturum/tema değişimi gezinme durumunu sıfırlamaz.
  final refresh = _RouterRefresh();
  ref.listen(authStateProvider, (_, _) => refresh.poke());
  ref.listen(signedInUserIdProvider, (_, _) => refresh.poke());
  ref.listen(onboardedProvider, (_, _) => refresh.poke());
  ref.listen(profileProvider.select((p) => p.isLoading), (_, _) => refresh.poke());
  ref.listen(awaitingFirstPullProvider, (_, _) => refresh.poke());
  ref.listen(authHoldProvider, (_, _) => refresh.poke());
  ref.listen(pendingSignupEmailProvider, (_, _) => refresh.poke());
  ref.listen(knownAccountsProvider, (_, _) => refresh.poke());
  final router = GoRouter(
    initialLocation: '/bugun',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return redirectFor(
        location: state.uri.path,
        authResolved: auth.hasValue,
        hasSession: auth.value != null,
        userReady: ref.read(signedInUserIdProvider) != null,
        profileLoading: ref.read(profileProvider).isLoading,
        onboarded: ref.read(onboardedProvider),
        awaitingFirstPull: ref.read(awaitingFirstPullProvider),
        authHold: ref.read(authHoldProvider),
        pendingSignupEmail: ref.read(pendingSignupEmailProvider),
        hasKnownAccount: ref.read(knownAccountsProvider).isNotEmpty,
      );
    },
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const _Splash()),
      GoRoute(path: '/hosgeldin', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/giris', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/kayit', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/dogrula',
        builder: (_, s) => VerifyCodeScreen(email: s.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: '/sifremi-unuttum', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingFlow()),
      // Kabuğun dışında: odak modunda alt bar görünmez.
      ...trainingRoutes,
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/bugun', builder: (_, _) => const TodayScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/antrenman', builder: (_, _) => const TrainingScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kalori',
                builder: (_, _) => const ComingSoonScreen(
                  title: 'Kalori',
                  icon: Icons.restaurant,
                  message: 'Kalori ekranı yakında.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gorevler',
                builder: (_, _) => const ComingSoonScreen(
                  title: 'Görevler',
                  icon: Icons.check_circle,
                  message: 'Görevler ekranı yakında.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profil',
                builder: (_, _) => const ProfileScreen(),
                routes: profileSubRoutes,
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// Açılış ekranı: bekleme göstergesi; ilk çekme ya da kullanıcı kontrolü başarısızsa
/// "Tekrar dene" ve "Çıkış yap" seçenekleri.
class _Splash extends ConsumerStatefulWidget {
  const _Splash();
  @override
  ConsumerState<_Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<_Splash> {
  bool _busy = false;

  Future<void> _do(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      debugPrint('Açılış işlemi başarısız: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final problem = ref.watch(startupProblemProvider);
    if (problem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final t = mf(context);
    final message = switch (problem) {
      StartupProblem.firstPullFailed =>
        'Hesap bilgilerin alınamadı. İnternet bağlantını kontrol edip tekrar dene.',
      StartupProblem.userCheckFailed =>
        'Oturumun hazırlanamadı. Tekrar dene ya da çıkış yapıp yeniden giriş yap.',
    };
    return Scaffold(
      body: MfBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: t.textMuted),
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.text, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MfButton(
                      label: 'Tekrar dene',
                      loading: _busy,
                      onPressed: () => _do(ref.read(sessionRetryProvider)),
                    ),
                    const SizedBox(height: 8),
                    MfButton(
                      label: 'Çıkış yap',
                      secondary: true,
                      onPressed: _busy
                          ? null
                          : () => _do(() => ref.read(authRepositoryProvider).signOut()),
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
