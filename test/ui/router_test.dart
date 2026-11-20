import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/data/auth/auth_repository.dart';
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
import 'package:missionfit/app/session_controller.dart' show signOutFlushProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/identity_fakes.dart';

class _FakeSession extends Fake implements Session {}

class _FakeAuthRepo extends Fake implements AuthRepository {
  int signOuts = 0;
  @override
  Future<void> signOut() async => signOuts++;
}

Future<(ProviderContainer, GoRouter)> _pump(
  WidgetTester tester, {
  required bool signedIn,
  bool onboarded = true,
  bool userReady = true,
  bool awaitingFirstPull = false,
  StartupProblem? startupProblem,
  _FakeAuthRepo? auth,
  Future<void> Function()? retry,
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
      signOutFlushProvider.overrideWithValue(() async => flushLeft),
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
      googleProfileProvider.overrideWithValue(null),
      profileIdentityRepositoryProvider.overrideWithValue(FakeIdentityRepo(db)),
      hasPasswordIdentityProvider.overrideWithValue(true),
      currentUserEmailProvider.overrideWithValue('a@b.com'),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 18, 7, 0, 30)),
      awaitingFirstPullProvider.overrideWithValue(awaitingFirstPull),
      startupProblemProvider.overrideWithValue(startupProblem),
      authRepositoryProvider.overrideWithValue(auth ?? _FakeAuthRepo()),
      sessionRetryProvider.overrideWithValue(retry ?? () async {}),
    ],
  );
  addTearDown(c.dispose);
  final router = c.read(routerProvider);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const _App()));
  // Yükleniyor ekranındaki dönen gösterge pumpAndSettle'ı bitirmez.
  final spinning = !userReady || (awaitingFirstPull && !onboarded && startupProblem == null);
  spinning ? await tester.pump(const Duration(seconds: 1)) : await tester.pumpAndSettle();
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

/// Çıkış öncesi gönderimden sonra kalan işlem sayısı (sahte).
var flushLeft = 0;

void main() {
  setUp(() => flushLeft = 0);
  testWidgets('oturum yokken /bugun → /hosgeldin', (tester) async {
    final (_, router) = await _pump(tester, signedIn: false);
    router.go('/bugun');
    await tester.pumpAndSettle();
    expect(_loc(router), '/hosgeldin');
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

  test('I-1: profil yok ve ilk çekme bitmediyse onboarding yerine yükleniyor', () {
    String? go(String loc, {required bool awaiting}) => redirectFor(
      location: loc,
      authResolved: true,
      hasSession: true,
      userReady: true,
      profileLoading: false,
      onboarded: false,
      awaitingFirstPull: awaiting,
    );
    expect(go('/bugun', awaiting: true), '/yukleniyor');
    expect(go('/onboarding', awaiting: true), '/yukleniyor');
    expect(go('/yukleniyor', awaiting: false), '/onboarding');
  });

  testWidgets('I-1: ilk çekme bitmeden profil yoksa onboarding açılmaz', (t) async {
    final (_, router) = await _pump(t, signedIn: true, onboarded: false, awaitingFirstPull: true);
    expect(_loc(router), '/yukleniyor');
  });

  testWidgets('I-1: ilk çekme başarısız → Tekrar dene / Çıkış yap', (t) async {
    final auth = _FakeAuthRepo();
    var retries = 0;
    final (_, router) = await _pump(
      t,
      signedIn: true,
      onboarded: false,
      awaitingFirstPull: true,
      startupProblem: StartupProblem.firstPullFailed,
      auth: auth,
      retry: () async => retries++,
    );
    expect(_loc(router), '/yukleniyor');
    expect(find.textContaining('Hesap bilgilerin alınamadı'), findsOneWidget);
    await t.tap(find.text('Tekrar dene'));
    await t.pumpAndSettle();
    expect(retries, 1);
    await t.tap(find.text('Çıkış yap'));
    await t.pumpAndSettle();
    expect(auth.signOuts, 1);
  });

  testWidgets('I-1: kullanıcı kontrolü başarısız → sonsuz yükleme yerine seçenekler', (t) async {
    final auth = _FakeAuthRepo();
    final (_, router) = await _pump(
      t,
      signedIn: true,
      userReady: false,
      startupProblem: StartupProblem.userCheckFailed,
      auth: auth,
    );
    expect(_loc(router), '/yukleniyor');
    expect(find.text('Tekrar dene'), findsOneWidget);
    await t.tap(find.text('Çıkış yap'));
    await t.pumpAndSettle();
    expect(auth.signOuts, 1);
  });

  test('M-2: şifre sıfırlama sürerken oturum açılsa da ekranda kalınır', () {
    String? go({required bool hold}) => redirectFor(
      location: '/sifremi-unuttum',
      authResolved: true,
      hasSession: true,
      userReady: true,
      profileLoading: false,
      onboarded: true,
      authHold: hold,
    );
    expect(go(hold: true), isNull);
    expect(go(hold: false), '/bugun');
  });

  group('oturum yokken hoş geldin / giriş / kod seçimi', () {
    String? go(String loc, {String? pending, bool known = false, bool session = false}) =>
        redirectFor(
          location: loc,
          authResolved: true,
          hasSession: session,
          userReady: true,
          profileLoading: false,
          onboarded: true,
          pendingSignupEmail: pending,
          hasKnownAccount: known,
        );

    test('yarım kayıt kayıtlı karttan önce gelir', () {
      expect(go('/bugun', pending: 'a@b.com', known: true), '/dogrula?email=a%40b.com');
    });
    test('yalnızca kayıtlı kart → /giris, hiçbiri → /hosgeldin', () {
      expect(go('/bugun', known: true), '/giris');
      expect(go('/bugun'), '/hosgeldin');
    });
    test('auth rotalarında yarım kayıt olsa da yerinde kalır', () {
      for (final l in ['/giris', '/kayit', '/hosgeldin']) {
        expect(go(l, pending: 'a@b.com'), isNull);
      }
    });
    test('oturum var, /hosgeldin → /bugun', () {
      expect(go('/hosgeldin', session: true), '/bugun');
    });
  });
}
