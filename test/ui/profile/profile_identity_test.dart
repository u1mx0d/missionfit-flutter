import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/app/profile_controller.dart' hide Profile;
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/ui/profile/edit_profile_screen.dart';
import 'package:missionfit/ui/profile/profile_header.dart';
import 'package:missionfit/ui/profile/username_field.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/identity_fakes.dart';

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

class _Ctx {
  _Ctx(this.db, this.repo, this.picker, this.router);
  final AppDatabase db;
  final FakeIdentityRepo repo;
  final FakePicker picker;
  final GoRouter router;

  Future<ProfileRow> row() =>
      (db.select(db.profiles)..where((t) => t.userId.equals('u1'))).getSingle();
}

typedef ProfileRow = Profile;

Future<_Ctx> _pump(
  WidgetTester tester, {
  String initial = '/profil',
  String? displayName,
  String? username,
  String? avatarPath,
  GoogleProfile? google,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          userId: 'u1',
          createdAt: 'x',
          updatedAt: 'x',
          displayName: Value(displayName),
          username: Value(username),
          avatarPath: Value(avatarPath),
        ),
      );
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final repo = FakeIdentityRepo(db);
  final picker = FakePicker();
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sp),
      signedInUserIdProvider.overrideWithValue('u1'),
      currentUserEmailProvider.overrideWithValue('ali.k@x.com'),
      profileIdentityRepositoryProvider.overrideWithValue(repo),
      avatarPickerProvider.overrideWithValue(picker),
      googleProfileProvider.overrideWithValue(google),
    ],
  );
  addTearDown(c.dispose);
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/profil',
        builder: (_, _) => const Scaffold(body: ProfileHeader()),
        routes: [GoRoute(path: 'duzenle', builder: (_, _) => const EditProfileScreen())],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _App(router)));
  await tester.pumpAndSettle();
  return _Ctx(db, repo, picker, router);
}

Finder _text(String s) => find.text(s);

Finder _save() => find.widgetWithText(FilledButton, 'Kaydet');

Future<void> _typeUsername(WidgetTester t, String v, {bool settle = true}) async {
  await t.enterText(
    find.descendant(of: find.byKey(const Key('username')), matching: find.byType(TextField)),
    v,
  );
  await t.pump(usernameCheckDelay);
  if (settle) await t.pumpAndSettle();
}

void main() {
  group('Profil başlığı', () {
    testWidgets('ad ve kullanıcı adı varsa ikisi görünür, tamamla düğmesi yok', (t) async {
      await _pump(t, displayName: 'Alperen', username: 'alp');
      expect(_text('Alperen'), findsOneWidget);
      expect(_text('@alp'), findsOneWidget);
      expect(find.byKey(const Key('complete-profile')), findsNothing);
    });

    testWidgets('eksikse Profilini tamamla düzenlemeyi açar', (t) async {
      final ctx = await _pump(t, displayName: 'Alperen');
      await t.tap(find.text('Profilini tamamla'));
      await t.pumpAndSettle();
      expect(ctx.router.state.uri.path, '/profil/duzenle');
    });

    testWidgets('ad yoksa başlık @kullaniciadi; ikisi de yoksa Profil', (t) async {
      await _pump(t, username: 'alp');
      expect(t.widget<Text>(find.byKey(const Key('profile-title'))).data, '@alp');
    });

    testWidgets('hiçbiri yoksa başlık Profil ve baş harf ?', (t) async {
      await _pump(t);
      expect(t.widget<Text>(find.byKey(const Key('profile-title'))).data, 'Profil');
      expect(_text('?'), findsOneWidget);
    });

    testWidgets('fotoğraf yolu varsa URL ile gösterilir', (t) async {
      await _pump(t, displayName: 'A', username: 'alp', avatarPath: 'u1/1.jpg');
      expect(find.byKey(const Key('avatar-url')), findsOneWidget);
    });
  });

  group('UsernameField', () {
    testWidgets('Türkçe büyük harf anında normalleşir', (t) async {
      await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      await _typeUsername(t, 'Şükrü');
      final field = t.widget<TextField>(
        find.descendant(of: find.byKey(const Key('username')), matching: find.byType(TextField)),
      );
      expect(field.controller!.text, 'sukru');
    });

    testWidgets('geçersiz biçimde sunucuya sorulmaz', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      await _typeUsername(t, 'ab');
      expect(ctx.repo.calls.where((c) => c.startsWith('check:')), isEmpty);
      expect(_text('En az 3 karakter.'), findsOneWidget);
    });

    testWidgets('eski cevap yenisinin üstüne yazılmaz', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'zzz');
      ctx.repo.deferChecks = true;
      await _typeUsername(t, 'alp', settle: false);
      await _typeUsername(t, 'alpe', settle: false);
      ctx.repo.pendingChecks['alpe']!.complete(true);
      await t.pump();
      ctx.repo.pendingChecks['alp']!.complete(false);
      await t.pump();
      expect(_text('Bu kullanıcı adı alınmış.'), findsNothing);
      expect(find.byKey(const Key('username-available')), findsOneWidget);
    });
  });

  group('Düzenleme', () {
    testWidgets('beklenmeyen kullanıcı adı hatası: mesaj, hiçbir şey kaydedilmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.usernameThrows = StateError('jwt expired');
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await _typeUsername(t, 'alpx');
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text(identityUnexpectedMessage), findsOneWidget);
      expect((await ctx.row()).displayName, 'A');
      expect(ctx.router.state.uri.path, '/profil/duzenle');
    });

    testWidgets('beklenmeyen fotoğraf hatası: mesaj gösterilir', (t) async {
      final ctx = await _pump(
        t,
        initial: '/profil/duzenle',
        displayName: 'A',
        username: 'alp',
        avatarPath: 'u1/1.jpg',
      );
      ctx.repo.avatarThrows = StateError('beklenmedik');
      await t.tap(find.text('Fotoğrafı değiştir'));
      await t.pumpAndSettle();
      await t.tap(find.text('Fotoğrafı kaldır'));
      await t.pumpAndSettle();
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text(identityUnexpectedMessage), findsOneWidget);
      expect(ctx.router.state.uri.path, '/profil/duzenle');
    });

    testWidgets('profili tam Google kullanıcısında fotoğraf önceden seçilmez', (t) async {
      final ctx = await _pump(
        t,
        initial: '/profil/duzenle',
        displayName: 'A',
        username: 'alp',
        google: const GoogleProfile(name: 'Alperen', photoUrl: 'https://g/p=s96-c'),
      );
      expect(find.byKey(const Key('avatar-url')), findsNothing);
      ctx.repo.avatarFailure = IdentityFailure.offline;
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(ctx.repo.calls, isNot(contains(startsWith('upload'))));
      expect((await ctx.row()).displayName, 'Yeni Ad');
    });

    testWidgets('yalnızca ad değişti: depo çağrılmaz, ad kaydedilir', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.usernameFailure = IdentityFailure.offline;
      ctx.repo.avatarFailure = IdentityFailure.offline;
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(ctx.repo.calls.where((c) => !c.startsWith('check:')), isEmpty);
      expect((await ctx.row()).displayName, 'Yeni Ad');
      expect(ctx.router.state.uri.path, '/profil');
    });

    testWidgets('kullanıcı adı çevrimdışı: hiçbir şey kaydedilmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.usernameFailure = IdentityFailure.offline;
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await _typeUsername(t, 'alpx');
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text('İnternet bağlantısı gerekiyor.'), findsWidgets);
      final row = await ctx.row();
      expect(row.displayName, 'A');
      expect(row.username, 'alp');
    });

    testWidgets('fotoğraf çevrimdışı, kullanıcı adı aynı: ad da kaydedilmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.avatarFailure = IdentityFailure.offline;
      ctx.picker.result = testPng();
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await t.tap(find.byKey(const Key('edit-avatar')));
      await t.pumpAndSettle();
      await t.tap(_text('Galeriden seç'));
      await t.pumpAndSettle();
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text('İnternet bağlantısı gerekiyor.'), findsOneWidget);
      expect((await ctx.row()).displayName, 'A');
    });

    testWidgets('kullanıcı adı başarılı, fotoğraf başarısız: ad ve kullanıcı adı kalır', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.avatarFailure = IdentityFailure.uploadFailed;
      ctx.picker.result = testPng();
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await _typeUsername(t, 'alpx');
      await t.tap(find.byKey(const Key('edit-avatar')));
      await t.pumpAndSettle();
      await t.tap(_text('Fotoğraf çek'));
      await t.pumpAndSettle();
      expect(ctx.picker.sources, [AvatarSource.camera]);
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text(photoFailedMessage), findsOneWidget);
      final row = await ctx.row();
      expect(row.username, 'alpx');
      expect(row.displayName, 'Yeni Ad');
      expect(ctx.router.state.uri.path, '/profil/duzenle');
    });

    testWidgets('kullanıcı adı alınmış: alan hatası, hiçbir şey kaydedilmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      ctx.repo.usernameFailure = IdentityFailure.usernameTaken;
      await t.enterText(find.byKey(const Key('display-name')), 'Yeni Ad');
      await _typeUsername(t, 'alpx');
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(_text('Bu kullanıcı adı alınmış.'), findsOneWidget);
      expect((await ctx.row()).displayName, 'A');
    });

    testWidgets('seçici iptal edilirse hiçbir şey değişmez', (t) async {
      final ctx = await _pump(t, initial: '/profil/duzenle', displayName: 'A', username: 'alp');
      await t.tap(find.byKey(const Key('edit-avatar')));
      await t.pumpAndSettle();
      await t.tap(_text('Galeriden seç'));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('avatar-bytes')), findsNothing);
      expect(find.byKey(const Key('inline-error')), findsNothing);
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(ctx.repo.calls.where((c) => !c.startsWith('check:')), isEmpty);
    });

    testWidgets('Google hesabı + eksik profil: ad, öneri ve fotoğraf dolu', (t) async {
      final ctx = await _pump(
        t,
        initial: '/profil/duzenle',
        google: const GoogleProfile(name: 'Alperen Dağtekin', photoUrl: 'https://g/p=s96-c'),
      );
      expect(_text('Alperen Dağtekin'), findsOneWidget);
      expect(_text('alperendagtekin'), findsOneWidget);
      expect(find.byKey(const Key('avatar-url')), findsOneWidget);
      await t.pump(usernameCheckDelay);
      await t.pumpAndSettle();
      await t.tap(_save());
      await t.pumpAndSettle();
      expect(ctx.repo.calls, contains('uploadUrl:https://g/p=s512-c'));
      expect((await ctx.row()).username, 'alperendagtekin');
    });
  });
}
