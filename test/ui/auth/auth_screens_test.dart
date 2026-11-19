import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/known_accounts.dart';
import 'package:missionfit/app/pending_signup.dart';
import 'package:missionfit/app/profile_controller.dart' show sharedPreferencesProvider;
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/data/auth/auth_repository.dart';
import 'package:missionfit/env.dart';
import 'package:missionfit/ui/auth/forgot_password_screen.dart';
import 'package:missionfit/ui/auth/login_screen.dart';
import 'package:missionfit/ui/auth/register_screen.dart';
import 'package:missionfit/ui/auth/verify_code_screen.dart';
import 'package:missionfit/ui/auth/welcome_screen.dart';
import 'package:missionfit/ui/components/athlete_card.dart';
import 'package:missionfit/ui/components/mf_logo.dart';
import 'package:missionfit/ui/router.dart' show redirectFor;
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends Fake implements AuthRepository {
  final calls = <String>[];
  AuthFailure? failure;

  Future<void> _do(String call) async {
    final f = failure; // çağrı anındaki hata (test sonradan değiştirebilir)
    calls.add(call);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (f != null) throw f;
  }

  @override
  Future<void> signIn(String email, String password) => _do('signIn:$email');
  @override
  Future<void> signUp(String email, String password) => _do('signUp:$email');
  @override
  Future<void> verifySignUpCode(String email, String code) => _do('verify:$email:$code');
  @override
  Future<void> resendSignUpCode(String email) => _do('resend:$email');
  @override
  Future<void> sendResetCode(String email) => _do('sendReset:$email');
  @override
  Future<void> verifyResetCode(String email, String code) => _do('verifyReset:$email:$code');
  @override
  Future<void> updatePassword(String p) => _do('updatePassword');
  @override
  Future<void> signInWithGoogle() => _do('google');
}

Env _env(String google) => Env(
  supabaseUrl: 'https://x.supabase.co',
  supabasePublishableKey: 'k',
  googleWebClientId: google,
);

late SharedPreferences _prefs;

Future<GoRouter> _pump(
  WidgetTester tester,
  _FakeRepo repo, {
  String? pendingEmail,
  String initial = '/giris',
  String google = '',
  ThemeFamily family = ThemeFamily.mono,
  Brightness brightness = Brightness.light,
  bool noAnim = false,
  List<Map<String, Object?>>? knownAccounts,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    pendingSignupKey: ?pendingEmail,
    if (knownAccounts != null) knownAccountsKey: jsonEncode(knownAccounts),
  });
  _prefs = await SharedPreferences.getInstance();
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/hosgeldin', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/giris', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/kayit', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/dogrula',
        builder: (_, s) => VerifyCodeScreen(email: s.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: '/sifremi-unuttum', builder: (_, _) => const ForgotPasswordScreen()),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        envProvider.overrideWithValue(_env(google)),
        sharedPreferencesProvider.overrideWithValue(_prefs),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: noAnim
            ? (c, w) =>
                  MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: w!)
            : null,
        theme: buildThemeData(MfTheme.build(family, brightness, AccentColor.yesil)),
      ),
    ),
  );
  if (noAnim) {
    await tester.pump();
  } else {
    await tester.pumpAndSettle();
  }
  return router;
}

String _loc(GoRouter r) => r.routerDelegate.currentConfiguration.uri.toString();

Finder _field(String label) => find.widgetWithText(TextField, label);

const _alperen = {
  'userId': 'u1',
  'email': 'a@b.com',
  'displayName': 'Alperen',
  'username': 'alperen',
  'avatarUrl': null,
  'memberSince': '2026-11-01T00:00:00.000Z',
  'lastSignedInAt': '2026-11-18T00:00:00.000Z',
};

AthleteCard _card(WidgetTester t) => t.widget<AthleteCard>(find.byType(AthleteCard));

void main() {
  group('hoş geldin', () {
    // Geçiş sırasında giriş ekranının kartındaki logo da ağaçta olabilir.
    double progress(WidgetTester t) => t
        .widget<MfLogo>(
          find.descendant(of: find.byType(WelcomeScreen), matching: find.byType(MfLogo)),
        )
        .progress;

    testWidgets('sabit metinler ve düğmeler görünür', (t) async {
      await _pump(t, _FakeRepo(), initial: '/hosgeldin');
      expect(find.text('MISSIONFIT'), findsOneWidget);
      expect(find.text('Her gün bir görev. Her set bir adım.'), findsOneWidget);
      expect(find.text('E-posta ile kayıt ol'), findsOneWidget);
      expect(find.text('Hesabın var mı? Giriş yap'), findsOneWidget);
      expect(find.text('Google ile devam et'), findsNothing);
    });

    testWidgets('E-posta ile kayıt ol /kayit açar', (t) async {
      final r = await _pump(t, _FakeRepo(), initial: '/hosgeldin');
      await t.tap(find.text('E-posta ile kayıt ol'));
      await t.pumpAndSettle();
      expect(_loc(r), '/kayit');
    });

    testWidgets('Hesabın var mı? /giris açar', (t) async {
      final r = await _pump(t, _FakeRepo(), initial: '/hosgeldin');
      await t.tap(find.text('Hesabın var mı? Giriş yap'));
      await t.pumpAndSettle();
      expect(_loc(r), '/giris');
    });

    testWidgets('Google açıkken signInWithGoogle çağrılır', (t) async {
      final repo = _FakeRepo();
      await _pump(t, repo, initial: '/hosgeldin', google: 'cid');
      await t.tap(find.text('Google ile devam et'));
      await t.pumpAndSettle();
      expect(repo.calls, ['google']);
    });

    testWidgets('Google hatası gösterilir', (t) async {
      final repo = _FakeRepo()
        ..failure = const AuthFailure('Google ile giriş yapılamadı.', code: 'google_failed');
      await _pump(t, repo, initial: '/hosgeldin', google: 'cid');
      await t.tap(find.text('Google ile devam et'));
      await t.pumpAndSettle();
      expect(find.text('Google ile giriş yapılamadı.'), findsOneWidget);
    });

    testWidgets('animasyon kapalıyken ilk karede her şey hazır', (t) async {
      await _pump(t, _FakeRepo(), initial: '/hosgeldin', noAnim: true);
      expect(progress(t), 1);
      expect(find.text('E-posta ile kayıt ol'), findsOneWidget);
      expect(t.widget<FadeTransition>(find.byType(FadeTransition).last).opacity.value, 1);
    });

    testWidgets('ikinci gelişte animasyon tekrar oynamaz', (t) async {
      final r = await _pump(t, _FakeRepo(), initial: '/hosgeldin');
      expect(progress(t), 1);
      r.go('/giris');
      await t.pumpAndSettle();
      r.go('/hosgeldin');
      await t.pump();
      await t.pump();
      expect(progress(t), 1);
    });

    testWidgets('ilk gelişte animasyon sürerken progress < 1', (t) async {
      t.view.physicalSize = const Size(800, 2000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      SharedPreferences.setMockInitialValues({});
      _prefs = await SharedPreferences.getInstance();
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeRepo()),
            envProvider.overrideWithValue(_env('')),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: MaterialApp(
            theme: buildThemeData(
              MfTheme.build(ThemeFamily.mono, Brightness.light, AccentColor.yesil),
            ),
            home: const WelcomeScreen(),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 300));
      expect(progress(t), lessThan(1));
      await t.pumpAndSettle();
      expect(progress(t), 1);
    });
  });

  group('giriş: sporcu kartı', () {
    testWidgets('kayıtlı kartla e-posta dolu, kart kayıtlı ve "Tekrar hoş geldin"', (t) async {
      await _pump(t, _FakeRepo(), knownAccounts: [_alperen]);
      expect(t.widget<TextField>(_field('E-posta')).controller!.text, 'a@b.com');
      expect(_card(t).mode, AthleteCardMode.saved);
      expect(find.text('Alperen'), findsOneWidget);
      expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    });

    testWidgets('e-posta değişince kart örneğe döner, eşleşince geri gelir', (t) async {
      await _pump(t, _FakeRepo(), knownAccounts: [_alperen]);
      await t.enterText(_field('E-posta'), 'x@y.com');
      await t.pumpAndSettle();
      expect(_card(t).mode, AthleteCardMode.sample);
      expect(find.text('MissionFit sporcusu'), findsOneWidget);
      expect(find.text('Alperen'), findsNothing);
      await t.enterText(_field('E-posta'), ' A@B.com ');
      await t.pumpAndSettle();
      expect(_card(t).mode, AthleteCardMode.saved);
      expect(find.text('Alperen'), findsOneWidget);
    });

    testWidgets('kartı kaldırmak kaydı siler, e-posta kalır', (t) async {
      await _pump(t, _FakeRepo(), knownAccounts: [_alperen]);
      await t.tap(find.byKey(const Key('athlete-card-remove')));
      await t.pumpAndSettle();
      expect(_card(t).mode, AthleteCardMode.sample);
      expect(t.widget<TextField>(_field('E-posta')).controller!.text, 'a@b.com');
      expect(jsonDecode(_prefs.getString(knownAccountsKey)!), isEmpty);
    });

    testWidgets('kayıtlı kart yokken örnek kart ve boş e-posta', (t) async {
      await _pump(t, _FakeRepo());
      expect(_card(t).mode, AthleteCardMode.sample);
      expect(find.byKey(const Key('athlete-card-remove')), findsNothing);
      expect(t.widget<TextField>(_field('E-posta')).controller!.text, isEmpty);
    });

    testWidgets('bekleyen kayıt kartı sporcu kartının altında', (t) async {
      await _pump(t, _FakeRepo(), pendingEmail: 'p@q.com', knownAccounts: [_alperen]);
      expect(find.text('Kaydını tamamla'), findsOneWidget);
      expect(
        t.getTopLeft(find.text('Kaydını tamamla')).dy,
        greaterThan(t.getBottomLeft(find.byType(AthleteCard)).dy),
      );
    });

    testWidgets('otomatik doldurma ipuçları ve AutofillGroup', (t) async {
      await _pump(t, _FakeRepo());
      expect(t.widget<TextField>(_field('E-posta')).autofillHints, [AutofillHints.email]);
      expect(t.widget<TextField>(_field('Şifre')).autofillHints, [AutofillHints.password]);
      for (final l in ['E-posta', 'Şifre']) {
        expect(find.ancestor(of: _field(l), matching: find.byType(AutofillGroup)), findsOneWidget);
      }
    });

    testWidgets("geri oku /hosgeldin'e götürür", (t) async {
      final r = await _pump(t, _FakeRepo());
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(_loc(r), '/hosgeldin');
    });
  });

  testWidgets('kayıt: yeni şifre alanlarında newPassword ipucu', (t) async {
    await _pump(t, _FakeRepo(), initial: '/kayit');
    expect(t.widget<TextField>(_field('E-posta')).autofillHints, [AutofillHints.email]);
    for (final l in ['Şifre', 'Şifre tekrar']) {
      expect(t.widget<TextField>(_field(l)).autofillHints, [AutofillHints.newPassword]);
    }
  });

  group('kayıt: dolan sporcu kartı', () {
    testWidgets('açılışta kart boş', (t) async {
      await _pump(t, _FakeRepo(), initial: '/kayit');
      expect(_card(t).mode, AthleteCardMode.empty);
      expect(find.text('Kartımı oluştur'), findsOneWidget);
    });

    testWidgets('geçerli e-posta yazılınca kartta görünür, hata gösterilmez', (t) async {
      await _pump(t, _FakeRepo(), initial: '/kayit');
      await t.enterText(_field('E-posta'), 'a@b');
      await t.pumpAndSettle();
      expect(_card(t).mode, AthleteCardMode.empty);
      expect(find.text('Geçerli bir e-posta adresi gir.'), findsNothing);
      await t.enterText(_field('E-posta'), ' a@b.com ');
      await t.pumpAndSettle();
      expect(_card(t).mode, AthleteCardMode.filling);
      expect(_card(t).data.email, 'a@b.com');
      expect(
        find.descendant(of: find.byType(AthleteCard), matching: find.text('a@b.com')),
        findsOneWidget,
      );
    });

    testWidgets('kurallara uyan şifre ve tekrarı eşleşince "✓ Şifre"', (t) async {
      await _pump(t, _FakeRepo(), initial: '/kayit');
      await t.enterText(_field('E-posta'), 'a@b.com');
      await t.enterText(_field('Şifre'), 'Sifre123');
      await t.pumpAndSettle();
      expect(_card(t).data.passwordOk, isFalse);
      await t.enterText(_field('Şifre tekrar'), 'Sifre123');
      await t.pumpAndSettle();
      expect(_card(t).data.passwordOk, isTrue);
      expect(find.text('✓ Şifre'), findsOneWidget);
      await t.enterText(_field('Şifre'), 'kisa1');
      await t.enterText(_field('Şifre tekrar'), 'kisa1');
      await t.pumpAndSettle();
      expect(_card(t).data.passwordOk, isFalse);
    });
  });

  group('kod: sporcu kartı ve AKTİF', () {
    ProviderContainer container(WidgetTester t) =>
        ProviderScope.containerOf(t.element(find.byType(VerifyCodeScreen)));

    testWidgets('kart "KOD BEKLENİYOR" ve e-posta gösterir; geri oku var', (t) async {
      await _pump(t, _FakeRepo(), initial: '/dogrula?email=a%40b.com');
      expect(_card(t).mode, AthleteCardMode.awaitingCode);
      expect(find.text('KOD BEKLENİYOR'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AthleteCard), matching: find.text('a@b.com')),
        findsOneWidget,
      );
      expect(find.byTooltip('Geri'), findsOneWidget);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('başarıda AKTİF, bekleme boyunca authHold açık, sonra kapanır', (t) async {
      final repo = _FakeRepo();
      await _pump(t, repo, initial: '/dogrula?email=a%40b.com', pendingEmail: 'a@b.com');
      expect(container(t).read(authHoldProvider), isFalse);
      await t.enterText(_field('Doğrulama kodu'), '123456');
      await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
      await t.pump();
      expect(container(t).read(authHoldProvider), isTrue);
      await t.pump(const Duration(milliseconds: 150));
      expect(_card(t).mode, AthleteCardMode.active);
      expect(find.text('AKTİF'), findsOneWidget);
      expect(container(t).read(authHoldProvider), isTrue);
      expect(_prefs.getString(pendingSignupKey), isNull);
      await t.pump(const Duration(milliseconds: 400));
      expect(container(t).read(authHoldProvider), isTrue);
      await t.pump(const Duration(milliseconds: 400));
      expect(container(t).read(authHoldProvider), isFalse);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('bekleme süresi sağlayıcıdan okunur', (t) async {
      expect(activeStampHold, const Duration(milliseconds: 700));
      await _pump(
        t,
        _FakeRepo(),
        initial: '/dogrula?email=a%40b.com',
        overrides: [activeStampHoldProvider.overrideWithValue(const Duration(milliseconds: 50))],
      );
      await t.enterText(_field('Doğrulama kodu'), '123456');
      await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
      await t.pump(const Duration(milliseconds: 120));
      await t.pump(const Duration(milliseconds: 100));
      expect(container(t).read(authHoldProvider), isFalse);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('bekleme sürerken ekran kapanırsa authHold yine kapanır', (t) async {
      final router = await _pump(
        t,
        _FakeRepo(),
        initial: '/dogrula?email=a%40b.com',
        overrides: [activeStampHoldProvider.overrideWithValue(const Duration(seconds: 5))],
      );
      final c = container(t);
      await t.enterText(_field('Doğrulama kodu'), '123456');
      await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
      await t.pump(const Duration(milliseconds: 150));
      expect(c.read(authHoldProvider), isTrue);
      router.go('/giris');
      // Bekleme süresi (5 sn) dolmadan ekran kapanır.
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(VerifyCodeScreen), findsNothing);
      expect(c.read(authHoldProvider), isFalse);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('başarısızlıkta hata gösterilir, authHold kapanır, kart kod bekler', (t) async {
      final repo = _FakeRepo()..failure = const AuthFailure('Kod hatalı.');
      await _pump(t, repo, initial: '/dogrula?email=a%40b.com', pendingEmail: 'a@b.com');
      await t.enterText(_field('Doğrulama kodu'), '123456');
      await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
      await t.pump();
      expect(container(t).read(authHoldProvider), isTrue);
      await t.pumpAndSettle();
      expect(find.text('Kod hatalı.'), findsOneWidget);
      expect(container(t).read(authHoldProvider), isFalse);
      expect(_card(t).mode, AthleteCardMode.awaitingCode);
      expect(_prefs.getString(pendingSignupKey), 'a@b.com');
      await t.pump(const Duration(seconds: 61));
    });
  });

  testWidgets('şifremi unuttum: kart yok, küçük logo var', (t) async {
    await _pump(t, _FakeRepo(), initial: '/sifremi-unuttum');
    expect(find.byType(AthleteCard), findsNothing);
    expect(t.widget<MfLogo>(find.byType(MfLogo)).size, 40);
  });

  testWidgets('geçersiz e-postada hata metni görünür ve repository çağrılmaz', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo);
    await t.enterText(_field('E-posta'), 'abc');
    await t.enterText(_field('Şifre'), 'Sifre123');
    await t.tap(find.text('Giriş yap'));
    await t.pumpAndSettle();
    expect(find.text('Geçerli bir e-posta adresi gir.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('şifreler eşleşmezse kayıt gönderilmez', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, initial: '/kayit');
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.enterText(_field('Şifre'), 'Sifre123');
    await t.enterText(_field('Şifre tekrar'), 'Sifre124');
    await t.tap(find.text('Kartımı oluştur'));
    await t.pumpAndSettle();
    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets("başarılı kayıt /dogrula'ya e-postayla gider", (t) async {
    final repo = _FakeRepo();
    final router = await _pump(t, repo, initial: '/kayit');
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.enterText(_field('Şifre'), 'Sifre123');
    await t.enterText(_field('Şifre tekrar'), 'Sifre123');
    await t.tap(find.text('Kartımı oluştur'));
    await t.pumpAndSettle();
    expect(repo.calls, ['signUp:a@b.com']);
    expect(_loc(router), '/dogrula?email=a%40b.com');
    expect(find.text('Doğrula'), findsWidgets);
    // Uygulama arka planda kapatılırsa koda geri dönülebilsin diye saklanır.
    expect(_prefs.getString(pendingSignupKey), 'a@b.com');
    await t.pumpAndSettle(const Duration(seconds: 61));
  });

  testWidgets('bekleyen kayıt varsa girişte kod kartı görünür ve koda götürür', (t) async {
    final router = await _pump(t, _FakeRepo(), pendingEmail: 'a@b.com');
    expect(find.text('Kaydını tamamla'), findsOneWidget);
    await t.tap(find.text('Kodu gir'));
    await t.pumpAndSettle();
    expect(_loc(router), '/dogrula?email=a%40b.com');
    await t.pumpAndSettle(const Duration(seconds: 61));
  });

  testWidgets('bekleyen kayıt kartı kapatılabilir', (t) async {
    await _pump(t, _FakeRepo(), pendingEmail: 'a@b.com');
    await t.tap(find.byKey(const Key('pending-signup-dismiss')));
    await t.pumpAndSettle();
    expect(find.text('Kaydını tamamla'), findsNothing);
    expect(_prefs.getString(pendingSignupKey), isNull);
  });

  testWidgets('kod doğrulanınca bekleyen kayıt silinir', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, initial: '/dogrula?email=a%40b.com', pendingEmail: 'a@b.com');
    await t.enterText(find.byType(TextField).first, '123456');
    await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
    await t.pumpAndSettle();
    expect(repo.calls, ['verify:a@b.com:123456']);
    expect(_prefs.getString(pendingSignupKey), isNull);
    await t.pumpAndSettle(const Duration(seconds: 61));
  });

  testWidgets('doğrulanmamış e-postayla girişte kod yeniden gönderilir ve koda gidilir', (t) async {
    final repo = _FakeRepo()
      ..failure = const AuthFailure('doğrulanmadı', code: 'email_not_confirmed');
    final router = await _pump(t, repo);
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.enterText(_field('Şifre'), 'Sifre123');
    await t.tap(find.text('Giriş yap'));
    repo.failure = null;
    await t.pumpAndSettle();
    expect(repo.calls, ['signIn:a@b.com', 'resend:a@b.com']);
    expect(_loc(router), '/dogrula?email=a%40b.com');
    await t.pumpAndSettle(const Duration(seconds: 61));
  });

  testWidgets('kodu tekrar gönder 60 sn pasif kalır', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, initial: '/dogrula?email=a%40b.com');
    Finder resend() =>
        find.widgetWithText(OutlinedButton, 'Kodu tekrar gönder', skipOffstage: false);
    OutlinedButton btn() => t.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(btn().onPressed, isNull);
    await t.pump(const Duration(seconds: 59));
    expect(btn().onPressed, isNull);
    await t.pump(const Duration(seconds: 2));
    expect(btn().onPressed, isNotNull);
    expect(resend(), findsOneWidget);
    await t.tap(find.byType(OutlinedButton));
    await t.pump();
    expect(repo.calls, ['resend:a@b.com']);
    expect(btn().onPressed, isNull);
    await t.pump(const Duration(seconds: 61));
  });

  testWidgets('kod 6-10 hane kabul edilir ve boşluk temizlenir', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, initial: '/dogrula?email=a%40b.com');
    await t.enterText(_field('Doğrulama kodu'), '1234 5678');
    await t.tap(find.widgetWithText(FilledButton, 'Doğrula'));
    await t.pump();
    expect(repo.calls, ['verify:a@b.com:12345678']);
    await t.pump(const Duration(seconds: 61));
  });

  testWidgets('googleWebClientId boşken Google düğmesi yok', (t) async {
    await _pump(t, _FakeRepo());
    expect(find.text('Google ile devam et'), findsNothing);
  });

  testWidgets('googleWebClientId doluyken Google düğmesi var ve çağırır', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, google: 'id.apps.googleusercontent.com');
    await t.tap(find.text('Google ile devam et'));
    await t.pumpAndSettle();
    expect(repo.calls, ['google']);
  });

  testWidgets('AuthFailure mesajı ekranda gösterilir', (t) async {
    final repo = _FakeRepo()..failure = const AuthFailure('E-posta veya şifre hatalı.');
    await _pump(t, repo);
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.enterText(_field('Şifre'), 'yanlis');
    await t.tap(find.text('Giriş yap'));
    await t.pumpAndSettle();
    expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
    // Düğme tekrar kullanılabilir.
    expect(t.widget<FilledButton>(find.byType(FilledButton).first).onPressed, isNotNull);
  });

  testWidgets('istek sürerken ikinci dokunuş tekrar göndermez', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo);
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.enterText(_field('Şifre'), 'yanlis');
    await t.tap(find.text('Giriş yap'));
    await t.tap(find.byType(FilledButton).first, warnIfMissed: false);
    await t.pumpAndSettle();
    expect(repo.calls.length, 1);
  });

  testWidgets('şifremi unuttum: önce kod gönderilir, sonra kod ve yeni şifre', (t) async {
    final repo = _FakeRepo();
    await _pump(t, repo, initial: '/sifremi-unuttum');
    await t.enterText(_field('E-posta'), 'a@b.com');
    await t.tap(find.text('Kod gönder'));
    await t.pumpAndSettle();
    expect(repo.calls, ['sendReset:a@b.com']);
    await t.enterText(_field('Doğrulama kodu'), '12345678');
    await t.enterText(_field('Yeni şifre'), 'Sifre123');
    await t.enterText(_field('Yeni şifre tekrar'), 'Sifre123');
    await t.tap(find.widgetWithText(FilledButton, 'Şifreyi güncelle'));
    await t.pump(const Duration(milliseconds: 300));
    expect(repo.calls, ['sendReset:a@b.com', 'verifyReset:a@b.com:12345678', 'updatePassword']);
    await t.pump(const Duration(seconds: 61));
  });

  for (final family in ThemeFamily.values) {
    for (final b in Brightness.values) {
      testWidgets('giriş ekranı $family/$b çizilir', (t) async {
        await _pump(t, _FakeRepo(), family: family, brightness: b);
        expect(find.text('Giriş yap'), findsWidgets);
        expect(t.takeException(), isNull);
      });
    }
  }

  group('M-2: şifre sıfırlamada sonuç her zaman bildirilir', () {
    Future<(GoRouter, _ResetRepo)> pumpReset(WidgetTester t, {AuthFailure? updateFailure}) async {
      final signedIn = ValueNotifier(false);
      final hold = ValueNotifier(0);
      addTearDown(signedIn.dispose);
      addTearDown(hold.dispose);
      final repo = _ResetRepo(signedIn, updateFailure);
      final c = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          envProvider.overrideWithValue(_env('')),
        ],
      );
      addTearDown(c.dispose);
      c.listen(authHoldProvider, (_, _) => hold.value++);
      final router = GoRouter(
        initialLocation: '/sifremi-unuttum',
        refreshListenable: Listenable.merge([signedIn, hold]),
        redirect: (_, s) => redirectFor(
          location: s.uri.path,
          authResolved: true,
          hasSession: signedIn.value,
          userReady: true,
          profileLoading: false,
          onboarded: true,
          authHold: c.read(authHoldProvider),
        ),
        routes: [
          GoRoute(path: '/giris', builder: (_, _) => const LoginScreen()),
          GoRoute(path: '/sifremi-unuttum', builder: (_, _) => const ForgotPasswordScreen()),
          GoRoute(
            path: '/bugun',
            builder: (_, _) => const Scaffold(body: Text('BUGUN')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
            routerConfig: router,
            theme: buildThemeData(
              MfTheme.build(ThemeFamily.mono, Brightness.light, AccentColor.yesil),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.enterText(_field('E-posta'), 'a@b.com');
      await t.tap(find.text('Kod gönder'));
      await t.pumpAndSettle();
      await t.enterText(_field('Doğrulama kodu'), '12345678');
      await t.enterText(_field('Yeni şifre'), 'Sifre123');
      await t.enterText(_field('Yeni şifre tekrar'), 'Sifre123');
      await t.tap(find.widgetWithText(FilledButton, 'Şifreyi güncelle'));
      await t.pumpAndSettle();
      return (router, repo);
    }

    testWidgets('kod doğrulanıp oturum açılsa da şifre güncelleme hatası ekranda kalır', (t) async {
      final (router, repo) = await pumpReset(
        t,
        updateFailure: const AuthFailure('Şifre güncellenemedi.'),
      );
      expect(_loc(router), '/sifremi-unuttum');
      expect(find.text('Şifre güncellenemedi.'), findsOneWidget);
      // Tekrar denemede kod yeniden doğrulanmaz (kod tek kullanımlık).
      repo.updateFailure = null;
      await t.tap(find.widgetWithText(FilledButton, 'Şifreyi güncelle'));
      await t.pumpAndSettle();
      expect(repo.calls, ['sendReset', 'verifyReset', 'updatePassword', 'updatePassword']);
      expect(_loc(router), '/bugun');
      expect(find.text('Şifren güncellendi.'), findsOneWidget);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('başarıda "Şifren güncellendi." gösterilir ve uygulamaya geçilir', (t) async {
      final (router, _) = await pumpReset(t);
      expect(_loc(router), '/bugun');
      expect(find.text('Şifren güncellendi.'), findsOneWidget);
      await t.pump(const Duration(seconds: 61));
    });
  });
}

class _ResetRepo extends Fake implements AuthRepository {
  _ResetRepo(this.signedIn, this.updateFailure);
  final ValueNotifier<bool> signedIn;
  AuthFailure? updateFailure;
  final calls = <String>[];

  @override
  Future<void> sendResetCode(String email) async => calls.add('sendReset');
  @override
  Future<void> verifyResetCode(String email, String code) async {
    calls.add('verifyReset');
    signedIn.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> updatePassword(String p) async {
    calls.add('updatePassword');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (updateFailure != null) throw updateFailure!;
  }
}
