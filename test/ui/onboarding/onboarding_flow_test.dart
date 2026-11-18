import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/ui/onboarding/onboarding_flow.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotifications extends Fake implements NotificationService {
  int requests = 0;
  @override
  Future<PermissionState> requestPermission() async {
    requests++;
    return PermissionState.granted;
  }
}

class _Harness {
  _Harness(this.db, this.container, this.router, this.notifications);
  final AppDatabase db;
  final ProviderContainer container;
  final GoRouter router;
  final _FakeNotifications notifications;
}

Future<_Harness> _pump(WidgetTester tester, {bool seedProfile = true}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  if (seedProfile) {
    await db
        .into(db.profiles)
        .insert(ProfilesCompanion.insert(userId: 'u1', createdAt: 'x', updatedAt: 'x'));
  }
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final notifications = _FakeNotifications();
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sp),
      signedInUserIdProvider.overrideWithValue('u1'),
      notificationServiceProvider.overrideWithValue(notifications),
    ],
  );
  addTearDown(c.dispose);
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingFlow()),
      GoRoute(
        path: '/bugun',
        builder: (_, _) => const Scaffold(body: Text('BUGUN-EKRANI')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: Consumer(
        builder: (context, ref, _) {
          final sel = ref.watch(themeControllerProvider);
          return MaterialApp.router(
            routerConfig: router,
            theme: buildThemeData(MfTheme.build(sel.family, Brightness.light, sel.accent)),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(db, c, router, notifications);
}

Future<void> _tapText(WidgetTester t, String text) async {
  await t.ensureVisible(find.text(text));
  await t.tap(find.text(text));
  await t.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester t, String key) async {
  await t.ensureVisible(find.byKey(Key(key)));
  await t.tap(find.byKey(Key(key)));
  await t.pumpAndSettle();
}

Future<void> _enter(WidgetTester t, String key, String text) async {
  await t.ensureVisible(find.byKey(Key(key)));
  await t.enterText(find.byKey(Key(key)), text);
  await t.pump();
}

Future<void> _consent(WidgetTester t) async {
  await _tapKey(t, 'consent-kvkk');
  await _tapKey(t, 'consent-health');
  await _tapText(t, 'Devam');
}

Future<void> _birth(WidgetTester t, {String year = '1995'}) async {
  await _enter(t, 'birth-day', '15');
  await _enter(t, 'birth-month', '6');
  await _enter(t, 'birth-year', year);
  await _tapText(t, 'Devam');
}

Future<void> _body(WidgetTester t) async {
  await _tapKey(t, 'sex-male');
  await _enter(t, 'height', '180');
  await _enter(t, 'weight', '80,5');
  await _tapText(t, 'Devam');
}

Future<void> _goal(WidgetTester t) async {
  await _tapKey(t, 'activity-moderate');
  await _tapKey(t, 'goal-lose');
  await _tapText(t, 'Devam');
}

void main() {
  testWidgets('KVKK onaylanmadan ileri gidilemez', (tester) async {
    await _pump(tester);
    expect(find.text('Hoş geldin!'), findsOneWidget);
    await _tapText(tester, 'Devam');
    expect(find.text('Hoş geldin!'), findsOneWidget);
    expect(find.text('Devam etmek için iki onayı da işaretle.'), findsOneWidget);
    await _tapKey(tester, 'consent-kvkk');
    await _tapText(tester, 'Devam');
    expect(find.text('Hoş geldin!'), findsOneWidget);
    await _tapKey(tester, 'consent-health');
    await _tapText(tester, 'Devam');
    expect(find.text('Doğum tarihin'), findsOneWidget);
  });

  testWidgets('17 yaş reddedilir', (tester) async {
    await _pump(tester);
    await _consent(tester);
    await _birth(tester, year: '${DateTime.now().year - 17}');
    expect(find.text('Doğum tarihin'), findsOneWidget);
    expect(find.text('MissionFit 18 yaş ve üzeri kullanıcılar içindir.'), findsOneWidget);
  });

  testWidgets('tema adımında Canlı seçili gelir', (tester) async {
    final h = await _pump(tester);
    // Önbellekte Mono kalmış olsa bile Canlı ile başlanır.
    await h.container.read(themeControllerProvider.notifier).setFamily(ThemeFamily.mono);
    await _consent(tester);
    await _birth(tester);
    await _body(tester);
    await _goal(tester);
    await _tapText(tester, 'Devam');
    await _tapText(tester, 'Bildirimlere izin ver');
    expect(find.text('Görünüm'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('theme-canli')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(h.container.read(themeControllerProvider).family, ThemeFamily.canli);
    // Mono'ya geçince anında önizlenir; profile henüz yazılmaz.
    await _tapKey(tester, 'theme-mono');
    expect(h.container.read(themeControllerProvider).family, ThemeFamily.mono);
    await _tapText(tester, 'Koyu');
    expect(h.container.read(themeControllerProvider).mode, ThemeModeChoice.dark);
    // Yalnızca testin kendi setFamily çağrısı kuyruğa yazdı; önizleme yazmaz.
    expect(await OutboxRepository(h.db).pending(), hasLength(1));
  });

  testWidgets('bitirince profil güncellenir ve /bugun açılır', (tester) async {
    final h = await _pump(tester);
    await _consent(tester);
    await _birth(tester);
    await _body(tester);
    await _goal(tester);
    expect(find.text('Günlük kalori hedefi önizlemesi'), findsOneWidget);
    await _tapText(tester, 'Devam');
    await _tapText(tester, 'Bildirimlere izin ver');
    expect(h.notifications.requests, 1);
    await _tapKey(tester, 'theme-mono');
    await _tapText(tester, 'Bitir');

    final p = await h.db.select(h.db.profiles).getSingle();
    expect(p.birthYear, 1995);
    expect(p.sex, 'male');
    expect(p.heightCm, 180);
    expect(p.weightKg, 80.5);
    expect(p.units, 'kg');
    expect(p.activityLevel, 'moderate');
    expect(p.goal, 'lose');
    expect(p.calorieTarget, isNotNull);
    expect(p.calorieTargetIsManual, isFalse);
    expect(p.consentedAt, isNotNull);
    expect(DateTime.parse(p.consentedAt!).isUtc, isTrue);
    expect(p.onboardingCompleted, isTrue);
    expect(p.themeFamily, 'mono');
    expect(p.theme, 'system');
    expect(p.accentColor, 'kirmizi');
    expect(p.notificationSettings, contains('"enabled":true'));
    expect(await OutboxRepository(h.db).pending(), hasLength(1));
    expect(h.container.read(sharedPreferencesProvider).getBool('onboarded.u1'), isTrue);
    expect(h.router.routerDelegate.currentConfiguration.uri.path, '/bugun');
    expect(find.text('BUGUN-EKRANI'), findsOneWidget);
  });

  testWidgets('profil yüklenmediyse mesaj ve tekrar dene; değerler korunur', (tester) async {
    final h = await _pump(tester, seedProfile: false);
    await _consent(tester);
    await _birth(tester);
    await _body(tester);
    await _goal(tester);
    await _tapText(tester, 'Devam');
    await _tapText(tester, 'Şimdi değil');
    await _tapText(tester, 'Bitir');
    expect(
      find.text('Profil henüz yüklenmedi. İnternet bağlantını kontrol edip tekrar dene.'),
      findsOneWidget,
    );
    expect(h.router.routerDelegate.currentConfiguration.uri.path, '/onboarding');
    await h.db
        .into(h.db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            createdAt: 'x',
            updatedAt: 'x',
            theme: const Value('system'),
          ),
        );
    await _tapText(tester, 'Tekrar dene');
    final p = await h.db.select(h.db.profiles).getSingle();
    expect(p.birthYear, 1995);
    expect(p.onboardingCompleted, isTrue);
    expect(h.router.routerDelegate.currentConfiguration.uri.path, '/bugun');
  });

  testWidgets('geri tuşu bir önceki adıma döner, girilen değerler korunur', (tester) async {
    await _pump(tester);
    await _consent(tester);
    await _birth(tester);
    await _tapKey(tester, 'sex-female');
    await _enter(tester, 'height', '170');
    await _tapKey(tester, 'back');
    expect(find.text('Doğum tarihin'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('birth-year'))).controller!.text, '1995');
    await _tapKey(tester, 'back');
    expect(find.text('Hoş geldin!'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byKey(const Key('consent-kvkk'))).value, isTrue);
    await _tapText(tester, 'Devam');
    await _tapText(tester, 'Devam');
    expect(tester.widget<TextField>(find.byKey(const Key('height'))).controller!.text, '170');
  });
}
