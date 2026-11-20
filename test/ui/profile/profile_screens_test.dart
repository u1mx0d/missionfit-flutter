import 'dart:convert';
import 'dart:ui' show Tristate;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/known_accounts.dart';
import 'package:missionfit/app/profile_controller.dart' hide Profile;
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/data/auth/auth_repository.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/ui/profile/profile_routes.dart';
import 'package:missionfit/ui/profile/training_style_screen.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

class _FakeAuth extends Fake implements AuthRepository {
  _FakeAuth({this.password = true});
  final bool password;
  final calls = <String>[];
  AuthFailure? reauthFailure;

  @override
  bool get hasPasswordIdentity => password;

  @override
  Future<void> reauthenticateWithPassword(String email, String pw) async {
    calls.add('reauth-password:$email');
    if (reauthFailure != null) throw reauthFailure!;
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    calls.add('reauth-google');
    if (reauthFailure != null) throw reauthFailure!;
  }

  @override
  Future<void> updatePassword(String p) async => calls.add('updatePassword');

  @override
  Future<void> signOut() async => calls.add('signOut');
}

class _FakeAccount implements AccountService {
  int deletes = 0;
  Object? error;
  @override
  Future<void> deleteAccount() async {
    if (error != null) throw error!;
    deletes++;
  }
}

class _FakeNotifications implements NotificationService {
  int tests = 0;
  @override
  Future<void> init() async {}
  @override
  Future<PermissionState> permission() async => PermissionState.granted;
  @override
  Future<PermissionState> requestPermission() async => PermissionState.granted;
  @override
  Future<void> showTest() async => tests++;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> showRest({
    required DateTime endsAt,
    required String nextLabel,
    String? payload,
  }) async {}
  @override
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel}) async {}
  @override
  Future<void> cancelRest() async {}
}

class _FakeExport extends Fake implements ExportService {
  _FakeExport(this.result);
  final ExportResult result;
  @override
  Future<ExportResult> exportJson() async => result;
}

class _Ctx {
  _Ctx(this.container, this.router, this.auth, this.account, this.notifications, this.db);
  final AppDatabase db;
  Future<Profile> get profile => db.select(db.profiles).getSingle();
  final ProviderContainer container;
  final GoRouter router;
  final _FakeAuth auth;
  final _FakeAccount account;
  final _FakeNotifications notifications;
}

class _App extends ConsumerWidget {
  const _App(this.router);
  final GoRouter router;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      routerConfig: router,
      theme: buildThemeData(MfTheme.build(sel.family, Brightness.light, sel.accent)),
    );
  }
}

Future<_Ctx> _pump(
  WidgetTester tester, {
  String initial = '/profil',
  bool password = true,
  bool? google,
  ProfilesCompanion? profile,
  ExportResult? export,
  List<KnownAccount> otherKnown = const [],
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await db
      .into(db.profiles)
      .insert(
        profile ??
            ProfilesCompanion.insert(
              userId: 'u1',
              createdAt: 'x',
              updatedAt: 'x',
              sex: const Value('female'),
              birthYear: const Value(1990),
              heightCm: const Value(170),
              weightKg: const Value(70),
              activityLevel: const Value('moderate'),
              goal: const Value('maintain'),
              calorieTarget: const Value(2000),
            ),
      );
  SharedPreferences.setMockInitialValues({
    knownAccountsKey: jsonEncode([
      KnownAccount(
        userId: 'u1',
        email: 'a@b.com',
        lastSignedInAt: DateTime.utc(2026, 1, 1),
      ).toJson(),
      for (final a in otherKnown) a.toJson(),
    ]),
  });
  final sp = await SharedPreferences.getInstance();
  final auth = _FakeAuth(password: password);
  final account = _FakeAccount();
  final notifications = _FakeNotifications();
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sp),
      signedInUserIdProvider.overrideWithValue('u1'),
      authRepositoryProvider.overrideWithValue(auth),
      hasPasswordIdentityProvider.overrideWithValue(password),
      hasGoogleIdentityProvider.overrideWithValue(google ?? !password),
      currentUserEmailProvider.overrideWithValue('a@b.com'),
      accountServiceProvider.overrideWithValue(account),
      notificationServiceProvider.overrideWithValue(notifications),
      deviceTimezoneProvider.overrideWith((ref) async => 'Europe/Berlin'),
      if (export != null) exportServiceProvider.overrideWithValue(_FakeExport(export)),
    ],
  );
  addTearDown(c.dispose);
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/giris',
        builder: (_, _) => const Scaffold(body: Text('GİRİŞ')),
      ),
      GoRoute(
        path: '/hosgeldin',
        builder: (_, _) => const Scaffold(body: Text('HOŞ GELDİN')),
      ),
      GoRoute(path: '/profil', builder: (_, _) => const ProfileScreen(), routes: profileSubRoutes),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _App(router)));
  await tester.pumpAndSettle();
  return _Ctx(c, router, auth, account, notifications, db);
}

Finder _field(String label) => find.widgetWithText(TextField, label);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('Vücut ve hedef', () {
    testWidgets('elle hedef alt sınırın altındaysa kaydet pasif', (t) async {
      await _pump(t, initial: '/profil/vucut');
      Finder save() => find.widgetWithText(FilledButton, 'Kaydet');
      expect(t.widget<FilledButton>(save()).onPressed, isNotNull);

      await t.tap(find.byKey(const Key('manual-switch')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('manual-target')), '1000');
      await t.pumpAndSettle();
      expect(t.widget<FilledButton>(save()).onPressed, isNull);
      expect(find.textContaining('en az 1.200 kcal'), findsOneWidget);

      await t.enterText(find.byKey(const Key('manual-target')), '1300');
      await t.pumpAndSettle();
      expect(t.widget<FilledButton>(save()).onPressed, isNotNull);

      await t.enterText(find.byKey(const Key('manual-target')), '6000');
      await t.pumpAndSettle();
      expect(find.text('Bu oldukça yüksek bir hedef. Emin misin?'), findsOneWidget);
      expect(t.widget<FilledButton>(save()).onPressed, isNotNull);
    });

    testWidgets('kaydet profili günceller', (t) async {
      final ctx = await _pump(t, initial: '/profil/vucut');
      await t.tap(find.byKey(const Key('manual-switch')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('manual-target')), '1800');
      await t.tap(find.widgetWithText(FilledButton, 'Kaydet'));
      await t.pumpAndSettle();
      final p = await ctx.profile;
      expect(p.calorieTarget, 1800);
      expect(p.calorieTargetIsManual, isTrue);
    });
  });

  group('Antrenman tarzım', () {
    ProfilesCompanion styled() => ProfilesCompanion.insert(
      userId: 'u1',
      createdAt: 'x',
      updatedAt: 'x',
      trainingStyle: const Value('calisthenics'),
      trainingLevel: const Value('intermediate'),
    );

    testWidgets('satır alt yazısı ana tarz ve seviyeyi gösterir; boşsa Seçilmedi', (t) async {
      await _pump(t, profile: styled());
      expect(find.text('Antrenman tarzım'), findsOneWidget);
      expect(find.text('Calisthenics · Orta'), findsOneWidget);
    });

    testWidgets('tarz yoksa alt yazı Seçilmedi', (t) async {
      await _pump(t);
      expect(find.text('Seçilmedi'), findsOneWidget);
    });

    testWidgets('ekran mevcut seçimlerle dolu açılır', (t) async {
      final handle = t.ensureSemantics();
      await _pump(t, initial: '/profil/tarz', profile: styled());
      expect(
        t.getSemantics(find.byKey(const Key('style-calisthenics'))).label,
        contains('Ana tarz'),
      );
      expect(
        t.getSemantics(find.byKey(const Key('level-intermediate'))).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      handle.dispose();
    });

    testWidgets('değiştir ve kaydet: satır güncellenir, outbox a yazılır', (t) async {
      final ctx = await _pump(t, profile: styled());
      await t.tap(find.text('Antrenman tarzım'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('level-advanced')));
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const Key('goal-first_pullup')));
      await t.tap(find.byKey(const Key('goal-first_pullup')));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Kaydet'));
      await t.pumpAndSettle();
      final p = await ctx.profile;
      expect(p.trainingLevel, 'advanced');
      expect(jsonDecode(p.goalMoves!) as List, contains('first_pullup'));
      expect(find.text('Calisthenics · İleri'), findsOneWidget);
      final ops = await ctx.db.select(ctx.db.outboxOps).get();
      expect(ops, isNotEmpty);
      expect(ops.last.payload, contains('advanced'));
    });

    testWidgets('tarz seçilmeden kaydet: Ana tarzını seç.', (t) async {
      final ctx = await _pump(t, initial: '/profil/tarz');
      await t.tap(find.widgetWithText(FilledButton, 'Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Ana tarzını seç.'), findsOneWidget);
      // Hata kaydet düğmesinin değil, stil ızgarasının altında durur.
      final msg = t.getTopLeft(find.text('Ana tarzını seç.')).dy;
      expect(msg, lessThan(t.getTopLeft(find.text('SEVIYEN')).dy));
      expect((await ctx.profile).trainingStyle, isNull);
    });

    testWidgets('seviye seçilmeden kaydet: Seviyeni seç. seviyenin altında', (t) async {
      await _pump(t, initial: '/profil/tarz');
      await t.tap(find.byKey(const Key('style-calisthenics')));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Seviyeni seç.'), findsOneWidget);
      expect(
        t.getTopLeft(find.text('Seviyeni seç.')).dy,
        lessThan(t.getTopLeft(find.widgetWithText(FilledButton, 'Kaydet')).dy),
      );
      expect(
        t.getTopLeft(find.text('Seviyeni seç.')).dy,
        greaterThan(t.getTopLeft(find.text('SEVIYEN')).dy),
      );
    });

    testWidgets('profil yüklenemezse hata ve Tekrar dene görünür', (t) async {
      var fail = true;
      final c = ProviderContainer(
        overrides: [
          profileProvider.overrideWith((ref) => fail ? Stream.error('x') : Stream.value(null)),
        ],
      );
      addTearDown(c.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: buildThemeData(
              MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.yesil),
            ),
            home: const TrainingStyleScreen(),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Profil yüklenemedi'), findsOneWidget);
      expect(find.text('Profil yükleniyor'), findsNothing);
      fail = false;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(find.text('Profil yüklenemedi'), findsNothing);
    });
  });

  group('Tema galerisi', () {
    testWidgets("galeride Mono'ya dokununca tema anında değişir", (t) async {
      final ctx = await _pump(t, initial: '/profil/tema');
      expect(ctx.container.read(themeControllerProvider).family, ThemeFamily.canli);
      expect(find.text('Profesyonel'), findsOneWidget);
      expect(find.text('Eğlenceli'), findsOneWidget);
      await t.tap(find.byKey(const Key('theme-mono-light')));
      await t.pumpAndSettle();
      expect(ctx.container.read(themeControllerProvider).family, ThemeFamily.mono);
    });

    testWidgets('vurgu ve görünüm modu seçimi uygulanır', (t) async {
      final ctx = await _pump(t, initial: '/profil/tema');
      await t.tap(find.byKey(const Key('accent-mavi')));
      await t.pumpAndSettle();
      expect(ctx.container.read(themeControllerProvider).accent.name, 'mavi');
      await t.tap(find.text('Koyu'));
      await t.pumpAndSettle();
      expect(ctx.container.read(themeControllerProvider).mode, ThemeModeChoice.dark);
    });
  });

  group('Profil', () {
    testWidgets('bilgi bölümünde 3B model atfı', (t) async {
      await _pump(t);
      final f = find.text('3B model: MakeHuman / MPFB (CC0)');
      await t.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);
      expect(f, findsOneWidget);
    });

    testWidgets('şifre değiştir yalnızca e-posta kimliğinde görünür', (t) async {
      await _pump(t, password: false);
      expect(find.text('Şifre değiştir'), findsNothing);
      expect(find.text('Çıkış yap'), findsOneWidget);
    });

    testWidgets('e-posta kimliği varsa şifre değiştir satırı görünür', (t) async {
      await _pump(t, password: true);
      expect(find.text('Şifre değiştir'), findsOneWidget);
    });

    testWidgets('çıkış onay penceresi sonrası signOut', (t) async {
      final ctx = await _pump(t);
      await t.tap(find.text('Çıkış yap'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, isEmpty);
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, isEmpty);
      await t.tap(find.text('Çıkış yap'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Çıkış yap'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['signOut']);
      expect(ctx.container.read(knownAccountsProvider).map((a) => a.userId), ['u1']); // kart kalır
    });

    testWidgets('birim ve hafta başlangıcı profile yazılır', (t) async {
      final ctx = await _pump(t);
      await t.tap(find.text('Pound (lb)'));
      await t.pumpAndSettle();
      await t.tap(find.text('Pazar'));
      await t.pumpAndSettle();
      final p = await ctx.profile;
      expect(p.units, 'lb');
      expect(p.weekStartsOn, 'sunday');
    });

    testWidgets('deneme bildirimi beklenmeden tetiklenir', (t) async {
      final ctx = await _pump(t);
      await t.ensureVisible(find.text('Deneme bildirimi'));
      await t.tap(find.text('Deneme bildirimi'));
      await t.pumpAndSettle();
      expect(ctx.notifications.tests, 1);
    });

    testWidgets('çevrimdışı dışa aktarma kullanıcıya bildirilir', (t) async {
      await _pump(
        t,
        export: const ExportResult(fileName: 'f.json', fromLocal: true, counts: {}),
      );
      await t.ensureVisible(find.text('Verilerimi dışa aktar'));
      await t.tap(find.text('Verilerimi dışa aktar'));
      await t.pumpAndSettle();
      expect(find.textContaining('cihazdaki verilerin'), findsOneWidget);
    });
  });

  group('Saat dilimi', () {
    testWidgets('cihaz saat dilimi ilk sırada, arama süzer ve seçim yazılır', (t) async {
      final ctx = await _pump(t, initial: '/profil/saat-dilimi');
      expect(find.text('Cihazın saat dilimi'), findsOneWidget);
      expect(find.text('Europe/Berlin'), findsWidgets);
      await t.enterText(find.byKey(const Key('tz-search')), 'tokyo');
      await t.pumpAndSettle();
      expect(find.text('Asia/Tokyo'), findsOneWidget);
      expect(find.text('Europe/Paris'), findsNothing);
      await t.tap(find.text('Asia/Tokyo'));
      await t.pumpAndSettle();
      final p = await ctx.profile;
      expect(p.timezone, 'Asia/Tokyo');
    });
  });

  group('Şifre değiştir', () {
    testWidgets('önce mevcut şifre doğrulanır sonra güncellenir', (t) async {
      final ctx = await _pump(t, initial: '/profil/sifre');
      await t.enterText(_field('Mevcut şifre'), 'Eski1234');
      await t.enterText(_field('Yeni şifre'), 'Yeni12345');
      await t.enterText(_field('Yeni şifre tekrar'), 'Yeni12345');
      await t.tap(find.text('Şifreyi güncelle'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-password:a@b.com', 'updatePassword']);
    });

    testWidgets('yeniden doğrulama başarısızsa şifre güncellenmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/sifre');
      ctx.auth.reauthFailure = const AuthFailure('E-posta veya şifre hatalı.');
      await t.enterText(_field('Mevcut şifre'), 'Yanlis123');
      await t.enterText(_field('Yeni şifre'), 'Yeni12345');
      await t.enterText(_field('Yeni şifre tekrar'), 'Yeni12345');
      await t.tap(find.text('Şifreyi güncelle'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-password:a@b.com']);
      expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
    });
  });

  group('Hesabı sil', () {
    Future<void> fill(WidgetTester t, {String confirm = 'SİL', String pw = 'Sifre123'}) async {
      await t.enterText(find.byKey(const Key('delete-confirm')), confirm);
      if (pw.isNotEmpty) await t.enterText(_field('Onay için şifren'), pw);
      await t.pumpAndSettle();
    }

    testWidgets('onay metni yazılmadan düğme pasif', (t) async {
      await _pump(t, initial: '/profil/hesap-sil');
      Finder btn() => find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil');
      expect(t.widget<FilledButton>(btn()).onPressed, isNull);
      await fill(t, confirm: 'sil');
      expect(t.widget<FilledButton>(btn()).onPressed, isNotNull);
    });

    testWidgets('hesap silmede yeniden doğrulama başarısızsa fonksiyon çağrılmaz', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil');
      ctx.auth.reauthFailure = const AuthFailure('E-posta veya şifre hatalı.');
      await fill(t);
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-password:a@b.com']);
      expect(ctx.account.deletes, 0);
      expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
      expect(find.text('GİRİŞ'), findsNothing);
    });

    testWidgets('başarılı akış: yeniden doğrula, sil, çıkış; kart kalmadıysa /hosgeldin', (
      t,
    ) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil');
      await fill(t);
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-password:a@b.com', 'signOut']);
      expect(ctx.account.deletes, 1);
      expect(find.text('HOŞ GELDİN'), findsOneWidget);
      expect(ctx.container.read(knownAccountsProvider), isEmpty);
    });

    testWidgets('silmeden sonra başka kart kaldıysa /giris', (t) async {
      final ctx = await _pump(
        t,
        initial: '/profil/hesap-sil',
        otherKnown: [
          KnownAccount(userId: 'u2', email: 'c@d.com', lastSignedInAt: DateTime.utc(2025, 1, 1)),
        ],
      );
      await fill(t);
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(find.text('GİRİŞ'), findsOneWidget);
      expect(ctx.container.read(knownAccountsProvider).map((a) => a.userId), ['u2']);
    });

    testWidgets('yalnızca Google kimliğinde Google ile yeniden doğrulanır', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil', password: false);
      expect(_field('Onay için şifren'), findsNothing);
      await fill(t, pw: '');
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-google', 'signOut']);
      expect(ctx.account.deletes, 1);
    });
    testWidgets('şifre ve Google birlikteyse varsayılan şifredir', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil', password: true, google: true);
      expect(_field('Onay için şifren'), findsOneWidget);
      expect(find.text('Şifre yerine Google ile doğrula'), findsOneWidget);
      await fill(t);
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-password:a@b.com', 'signOut']);
      expect(ctx.account.deletes, 1);
    });

    testWidgets('şifre ve Google birlikteyse istenirse Google ile doğrulanır', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil', password: true, google: true);
      await t.tap(find.text('Şifre yerine Google ile doğrula'));
      await t.pumpAndSettle();
      expect(_field('Onay için şifren'), findsNothing);
      expect(find.text('Şifreyle doğrula'), findsOneWidget);
      await fill(t, pw: '');
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.auth.calls, ['reauth-google', 'signOut']);
      expect(ctx.account.deletes, 1);
    });

    testWidgets('yalnızca şifre kimliğinde Google seçeneği görünmez', (t) async {
      await _pump(t, initial: '/profil/hesap-sil', password: true, google: false);
      expect(_field('Onay için şifren'), findsOneWidget);
      expect(find.text('Şifre yerine Google ile doğrula'), findsNothing);
    });

    testWidgets('I-2: farklı Google hesabı seçilirse silinmez ve mesaj gösterilir', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil', password: false);
      ctx.auth.reauthFailure = const AuthFailure(googleWrongAccountMessage);
      await fill(t, pw: '');
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(ctx.account.deletes, 0);
      expect(find.text(googleWrongAccountMessage), findsWidgets);
    });

    testWidgets('M-3: beklenmeyen hata genel mesajla gösterilir', (t) async {
      final ctx = await _pump(t, initial: '/profil/hesap-sil');
      ctx.account.error = StateError('beklenmedik');
      await fill(t);
      await t.tap(find.widgetWithText(FilledButton, 'Hesabımı kalıcı olarak sil'));
      await t.pumpAndSettle();
      expect(find.text('Bir şeyler ters gitti. Lütfen tekrar dene.'), findsOneWidget);
      expect(find.text('GİRİŞ'), findsNothing);
      expect(t.takeException(), isNull);
    });
  });
}
