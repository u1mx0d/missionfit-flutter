import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../app/profile_controller.dart';
import '../app/providers.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/verify_code_screen.dart';
import 'components/dot_grid.dart';
import 'onboarding/onboarding_flow.dart';
import 'placeholders/coming_soon_screen.dart';
import 'shell/app_shell.dart';
import 'today/today_screen.dart';

const authRoutes = {'/giris', '/kayit', '/dogrula', '/sifremi-unuttum'};
const _splash = '/yukleniyor';

/// Oturum durumundan hedef yol. null = olduğu yerde kalır.
String? redirectFor({
  required String location,
  required bool authResolved,
  required bool hasSession,
  required bool userReady,
  required bool profileLoading,
  required bool onboarded,
}) {
  final isAuth = authRoutes.contains(location);
  if (!authResolved) return location == _splash ? null : _splash;
  if (!hasSession) return isAuth ? null : '/giris';
  // Oturum var ama kullanıcı değişimi kontrolü bitmedi: sekmeleri gösterme.
  if (!userReady || (!onboarded && profileLoading)) return location == _splash ? null : _splash;
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
      );
    },
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const _Splash()),
      GoRoute(path: '/giris', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/kayit', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/dogrula',
        builder: (_, s) => VerifyCodeScreen(email: s.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: '/sifremi-unuttum', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingFlow()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/bugun', builder: (_, _) => const TodayScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/antrenman',
                builder: (_, _) => const ComingSoonScreen(
                  title: 'Antrenman',
                  icon: Icons.fitness_center,
                  message: 'Antrenman ekranı bir sonraki aşamada geliyor.',
                ),
              ),
            ],
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
                builder: (_, _) => const _Placeholder('Profil'),
                routes: [
                  // Task 16 profil alt rotalarıyla değiştirilir.
                  GoRoute(
                    path: 'ayarlar',
                    builder: (_, _) =>
                        const _Placeholder('Ayarlar', key: ValueKey('profil-ayarlar')),
                  ),
                ],
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

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Geçici ekran; Görev 13/15/16'da gerçekleriyle değiştirilir.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Text(title, style: TextStyle(color: mf(context).text)),
    ),
  );
}
