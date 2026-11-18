import 'dart:async';
import 'dart:typed_data';

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

/// Bellek içi DB'ye yazan sahte kimlik deposu; hata ve gecikme enjekte edilebilir.
class FakeIdentityRepo implements ProfileIdentityRepository {
  FakeIdentityRepo(this.db);
  final AppDatabase db;
  final calls = <String>[];
  IdentityFailure? usernameFailure;
  IdentityFailure? avatarFailure;
  final taken = <String>{};
  final pendingChecks = <String, Completer<bool>>{};
  bool deferChecks = false;

  Future<void> _write(String userId, ProfilesCompanion c) =>
      (db.update(db.profiles)..where((t) => t.userId.equals(userId))).write(c);

  @override
  Future<bool> isUsernameAvailable(String username) {
    calls.add('check:$username');
    if (deferChecks) return (pendingChecks[username] = Completer<bool>()).future;
    return Future.value(!taken.contains(username));
  }

  @override
  Future<String> setUsername(String userId, String username) async {
    calls.add('setUsername:$username');
    if (usernameFailure != null) throw IdentityError(usernameFailure!);
    await _write(userId, ProfilesCompanion(username: Value(username)));
    return username;
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List jpeg) async {
    calls.add('upload:${jpeg.length}');
    if (avatarFailure != null) throw IdentityError(avatarFailure!);
    await _write(userId, const ProfilesCompanion(avatarPath: Value('u1/2.jpg')));
    return 'u1/2.jpg';
  }

  @override
  Future<String> uploadAvatarFromUrl(String userId, String url) async {
    calls.add('uploadUrl:$url');
    if (avatarFailure != null) throw IdentityError(avatarFailure!);
    await _write(userId, const ProfilesCompanion(avatarPath: Value('u1/3.jpg')));
    return 'u1/3.jpg';
  }

  @override
  Future<void> removeAvatar(String userId) async {
    calls.add('remove');
    if (avatarFailure != null) throw IdentityError(avatarFailure!);
    await _write(userId, const ProfilesCompanion(avatarPath: Value(null)));
  }

  @override
  String publicUrl(String avatarPath) => 'https://cdn.test/$avatarPath';
}

class FakePicker implements AvatarPicker {
  Uint8List? result;
  final sources = <AvatarSource>[];
  @override
  Future<Uint8List?> pick(AvatarSource source) async {
    sources.add(source);
    return result;
  }
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

// 1x1 şeffaf PNG.
Uint8List _png() => Uint8List.fromList(const [
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  13,
  73,
  68,
  65,
  84,
  120,
  156,
  99,
  0,
  1,
  0,
  0,
  5,
  0,
  1,
  13,
  10,
  45,
  180,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
]);
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
      ctx.picker.result = _png();
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
      ctx.picker.result = _png();
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
