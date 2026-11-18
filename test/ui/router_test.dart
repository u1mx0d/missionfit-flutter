import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/app/today_provider.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/env.dart';
import 'package:missionfit/ui/components/pill_nav_bar.dart';
import 'package:missionfit/ui/profile/theme_gallery_screen.dart';
import 'package:missionfit/ui/router.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSession extends Fake implements Session {}

Future<(ProviderContainer, GoRouter)> _pump(
  WidgetTester tester, {
  required bool signedIn,
  bool onboarded = true,
  bool userReady = true,
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await db
      .into(db.profiles)
      .insert(ProfilesCompanion.insert(userId: 'u1', createdAt: 'x', updatedAt: 'x'));
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      envProvider.overrideWithValue(
        const Env(
          supabaseUrl: 'https://x.supabase.co',
          supabasePublishableKey: 'k',
          googleWebClientId: '',
        ),
      ),
      sharedPreferencesProvider.overrideWithValue(sp),
      authStateProvider.overrideWithValue(AsyncData<Session?>(signedIn ? _FakeSession() : null)),
      signedInUserIdProvider.overrideWithValue(signedIn && userReady ? 'u1' : null),
      onboardedProvider.overrideWithValue(signedIn && onboarded),
      hasPasswordIdentityProvider.overrideWithValue(true),
      currentUserEmailProvider.overrideWithValue('a@b.com'),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 18, 7, 0, 30)),
    ],
  );
  addTearDown(c.dispose);
  final router = c.read(routerProvider);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const _App()));
  // Yükleniyor ekranındaki dönen gösterge pumpAndSettle'ı bitirmez.
  userReady ? await tester.pumpAndSettle() : await tester.pump(const Duration(seconds: 1));
  return (c, router);
}

class _App extends ConsumerWidget {
  const _App();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      theme: buildThemeData(MfTheme.build(sel.family, Brightness.light, sel.accent)),
    );
  }
}

String _loc(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('oturum yokken /bugun → /giris', (tester) async {
    final (_, router) = await _pump(tester, signedIn: false);
    router.go('/bugun');
    await tester.pumpAndSettle();
    expect(_loc(router), '/giris');
  });

  testWidgets('oturum var ama kullanıcı doğrulanmadıysa sekmeler yerine yükleniyor', (t) async {
    final (_, router) = await _pump(t, signedIn: true, userReady: false);
    expect(_loc(router), '/yukleniyor');
    expect(find.byType(PillNavBar), findsNothing);
  });

  testWidgets('Bugün: selamlama ve Türkçe tarih', (tester) async {
    await _pump(tester, signedIn: true);
    expect(find.text('Günaydın'), findsOneWidget);
    expect(find.text('Çarşamba, 18 Kasım'), findsOneWidget);
  });

  testWidgets('oturum var, onboarding yok → /onboarding', (tester) async {
    final (_, router) = await _pump(tester, signedIn: true, onboarded: false);
    router.go('/bugun');
    await tester.pumpAndSettle();
    expect(_loc(router), '/onboarding');
  });

  testWidgets('onboarding tamam → /giris açılınca /bugun', (tester) async {
    final (_, router) = await _pump(tester, signedIn: true);
    router.go('/giris');
    await tester.pumpAndSettle();
    expect(_loc(router), '/bugun');
  });

  testWidgets('sekme değiştirip geri gelince alt sayfa korunur', (tester) async {
    final (_, router) = await _pump(tester, signedIn: true);
    router.go('/profil/tema');
    await tester.pumpAndSettle();
    expect(_loc(router), '/profil/tema');
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(_loc(router), '/bugun');
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(_loc(router), '/profil/tema');
  });

  testWidgets('tema değişince açık olan sekme ve alt sayfa korunur', (tester) async {
    final (c, router) = await _pump(tester, signedIn: true);
    router.go('/profil/tema');
    await tester.pumpAndSettle();
    await c.read(themeControllerProvider.notifier).setFamily(ThemeFamily.mono);
    await c.read(themeControllerProvider.notifier).setAccent(AccentColor.mavi);
    await tester.pumpAndSettle();
    expect(c.read(themeControllerProvider).family, ThemeFamily.mono);
    expect(_loc(router), '/profil/tema');
    expect(find.text('Tema galerisi'), findsWidgets);
    expect(find.byType(ThemeGalleryScreen), findsOneWidget);
  });
}
