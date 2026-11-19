import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/known_accounts.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/identity_fakes.dart';

import 'package:drift/native.dart';
import 'package:missionfit/data/db/database.dart' hide Profile;

KnownAccount _acc(String id, {String? email, DateTime? at}) => KnownAccount(
  userId: id,
  email: email ?? '$id@b.com',
  lastSignedInAt: at ?? DateTime.utc(2026, 1, 1),
);

Profile _profile({String? name = 'Ali', String createdAt = '2026-11-02T10:00:00Z'}) => Profile(
  userId: 'u1',
  displayName: name,
  username: 'ali',
  avatarPath: 'u1/1.jpg',
  createdAt: createdAt,
  updatedAt: createdAt,
);

class _Str extends Notifier<String?> {
  _Str(this.initial);
  final String? initial;
  @override
  String? build() => initial;
  void set(String? v) => state = v;
}

final _emailP = NotifierProvider<_Str, String?>(() => _Str('a@b.com'));
final _uidP = NotifierProvider<_Str, String?>(() => _Str('u1'));

void main() {
  late SharedPreferences sp;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SharedPreferences.getInstance();
  });

  ProviderContainer make({Map<String, Object>? prefs}) {
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(sp)]);
    addTearDown(c.dispose);
    return c;
  }

  test('upsert aynı kullanıcıyı günceller ve en üste taşır', () async {
    final c = make();
    final n = c.read(knownAccountsProvider.notifier);
    await n.upsert(_acc('a'));
    await n.upsert(_acc('b'));
    await n.upsert(_acc('a', email: 'yeni@b.com'));
    final l = c.read(knownAccountsProvider);
    expect(l.map((e) => e.userId), ['a', 'b']);
    expect(l.first.email, 'yeni@b.com');
  });

  test('6. kayıtta en eskisi düşer (en çok 5)', () async {
    final c = make();
    final n = c.read(knownAccountsProvider.notifier);
    for (final id in ['a', 'b', 'c', 'd', 'e', 'f']) {
      await n.upsert(_acc(id));
    }
    final l = c.read(knownAccountsProvider);
    expect(l.length, 5);
    expect(l.map((e) => e.userId), ['f', 'e', 'd', 'c', 'b']);
  });

  test('match kırpar ve küçük harfe çevirir; yoksa null', () async {
    final c = make();
    await c.read(knownAccountsProvider.notifier).upsert(_acc('a', email: 'a@b.com'));
    expect(c.read(knownAccountsProvider.notifier).match('  A@B.com ')?.userId, 'a');
    expect(c.read(knownAccountsProvider.notifier).match('x@y.com'), isNull);
  });

  test('bozuk JSON boş liste verir', () async {
    await sp.setString(knownAccountsKey, '{bozuk');
    expect(make().read(knownAccountsProvider), isEmpty);
    await sp.setString(knownAccountsKey, '[1, {"x": 2}]');
    expect(make().read(knownAccountsProvider), isEmpty);
  });

  test('remove siler ve kalıcıdır; yalnızca remove siler', () async {
    final c = make();
    final n = c.read(knownAccountsProvider.notifier);
    await n.upsert(_acc('a'));
    await n.upsert(_acc('b'));
    await n.remove('a');
    final c2 = make();
    expect(c2.read(knownAccountsProvider).map((e) => e.userId), ['b']);
  });

  test('toJson / fromJson gidiş dönüş', () {
    final a = KnownAccount(
      userId: 'u',
      email: 'e@x.com',
      displayName: 'Ali',
      username: 'ali',
      avatarUrl: 'https://x/y.jpg',
      memberSince: DateTime.utc(2026, 11, 2, 10),
      lastSignedInAt: DateTime.utc(2026, 11, 3),
    );
    final b = KnownAccount.fromJson(a.toJson());
    expect(b.toJson(), a.toJson());
    expect(b.memberSince, DateTime.utc(2026, 11, 2, 10));
  });

  group('eşitleme', () {
    late AppDatabase db;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
    });

    ProviderContainer sync({required StreamController<Profile?> profiles, bool onboarded = true}) {
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          profileProvider.overrideWith((ref) => profiles.stream),
          onboardedProvider.overrideWithValue(onboarded),
          currentUserEmailProvider.overrideWith((ref) => ref.watch(_emailP)),
          signedInUserIdProvider.overrideWith((ref) => ref.watch(_uidP)),
          currentUserIdProvider.overrideWith((ref) => ref.watch(_uidP)),
          profileIdentityRepositoryProvider.overrideWithValue(FakeIdentityRepo(db)),
        ],
      );
      addTearDown(c.dispose);
      c.listen(knownAccountSyncProvider, (_, _) {});
      return c;
    }

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('onboarded profil kayda yazılır; ad değişince güncellenir', () async {
      final profiles = StreamController<Profile?>();
      addTearDown(profiles.close);
      final c = sync(profiles: profiles);
      profiles.add(_profile());
      await settle();
      await settle();
      var l = c.read(knownAccountsProvider);
      expect(l.length, 1);
      expect(l.first.email, 'a@b.com');
      expect(l.first.displayName, 'Ali');
      expect(l.first.username, 'ali');
      expect(l.first.avatarUrl, 'https://cdn.test/u1/1.jpg');
      expect(l.first.memberSince, DateTime.utc(2026, 11, 2, 10));
      final first = l.first.lastSignedInAt;

      profiles.add(_profile(name: 'Veli'));
      await settle();
      await settle();
      l = c.read(knownAccountsProvider);
      expect(l.length, 1);
      expect(l.first.displayName, 'Veli');
      expect(l.first.lastSignedInAt, first); // profil düzenlemesi tarihi değiştirmez
    });

    test('onboarded değilse yazılmaz', () async {
      final profiles = StreamController<Profile?>();
      addTearDown(profiles.close);
      final c = sync(profiles: profiles, onboarded: false);
      profiles.add(_profile());
      await settle();
      await settle();
      expect(c.read(knownAccountsProvider), isEmpty);
      expect(sp.getString(knownAccountsKey), isNull);
    });

    test('çözülemeyen createdAt memberSince null olur', () async {
      final profiles = StreamController<Profile?>();
      addTearDown(profiles.close);
      final c = sync(profiles: profiles);
      profiles.add(_profile(createdAt: 'x'));
      await settle();
      await settle();
      expect(c.read(knownAccountsProvider).single.memberSince, isNull);
    });

    test('kullanıcı değişiminde eski profil yeni e-postayla eşleşmez', () async {
      final profiles = StreamController<Profile?>();
      addTearDown(profiles.close);
      final c = sync(profiles: profiles);
      profiles.add(_profile());
      await settle();
      await settle();
      expect(c.read(knownAccountsProvider).single.email, 'a@b.com');

      // B'nin e-postası ve kimliği gelir; profil hâlâ A'nın.
      c.read(_emailP.notifier).set('b@b.com');
      c.read(_uidP.notifier).set('u2');
      await settle();
      await settle();
      final l = c.read(knownAccountsProvider);
      expect(l.single.userId, 'u1');
      expect(l.single.email, 'a@b.com');
      expect(l.where((e) => e.userId == 'u1' && e.email == 'b@b.com'), isEmpty);
    });

    test('eksik memberSince sonradan tamamlanır, lastSignedInAt değişmez', () async {
      final profiles = StreamController<Profile?>();
      addTearDown(profiles.close);
      final c = sync(profiles: profiles);
      profiles.add(_profile(createdAt: 'x'));
      await settle();
      await settle();
      final first = c.read(knownAccountsProvider).single;
      expect(first.memberSince, isNull);

      profiles.add(_profile());
      await settle();
      await settle();
      final l = c.read(knownAccountsProvider);
      expect(l.length, 1);
      expect(l.single.memberSince, DateTime.utc(2026, 11, 2, 10));
      expect(l.single.lastSignedInAt, first.lastSignedInAt);
    });
  });
}
