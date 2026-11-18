import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/session_controller.dart';
import 'package:missionfit/data/auth/secure_local_storage.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/sync_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDb extends Mock implements AppDatabase {}

class MockSync extends Mock implements SyncEngine {}

class MockOutbox extends Mock implements OutboxRepository {}

class MemStore implements KeyValueStore {
  final map = <String, String>{};
  @override
  Future<String?> read(String key) async => map[key];
  @override
  Future<void> write(String key, String value) async => map[key] = value;
  @override
  Future<void> delete(String key) async => map.remove(key);
}

Session _session(String id) => Session(
  accessToken: 't',
  tokenType: 'bearer',
  user: User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
  ),
);

void main() {
  late MockDb db;
  late MockSync sync;
  late MockOutbox outbox;
  late MemStore store;
  late StreamController<Session?> auth;
  late void Function() tick;
  late int hookCalls;
  late ProviderContainer c;

  setUp(() {
    db = MockDb();
    sync = MockSync();
    outbox = MockOutbox();
    store = MemStore();
    auth = StreamController<Session?>();
    hookCalls = 0;
    when(() => db.clearAllUserData()).thenAnswer((_) async {});
    when(() => sync.downloadCatalogs()).thenAnswer((_) async {});
    when(() => sync.syncNow()).thenAnswer((_) async => SyncResult());
    when(() => outbox.pendingCount()).thenAnswer((_) => Stream.value(0));
    c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncEngineProvider.overrideWithValue(sync),
        outboxProvider.overrideWithValue(outbox),
        keyValueStoreProvider.overrideWithValue(store),
        authStateProvider.overrideWith((ref) => auth.stream),
        signedOutHooksProvider.overrideWithValue([() async => hookCalls++]),
        periodicTimerFactoryProvider.overrideWithValue((period, t) {
          tick = t;
          return Timer(const Duration(days: 1), () {});
        }),
      ],
    );
    addTearDown(c.dispose);
    addTearDown(() => unawaited(auth.close()));
    c.listen(sessionControllerProvider, (_, _) {});
  });

  Future<void> emit(Session? s) async {
    auth.add(s);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test('SessionController: farklı kullanıcı girince clearAllUserData çağrılır', () async {
    store.map[SecureLocalStorage.lastUserIdKey] = 'old';
    await emit(_session('new'));
    verifyInOrder([
      () => db.clearAllUserData(),
      () => sync.downloadCatalogs(),
      () => sync.syncNow(),
    ]);
    expect(store.map[SecureLocalStorage.lastUserIdKey], 'new');
  });

  test('SessionController: aynı kullanıcı tekrar girince veri silinmez', () async {
    store.map[SecureLocalStorage.lastUserIdKey] = 'same';
    await emit(_session('same'));
    verifyNever(() => db.clearAllUserData());
    verify(() => sync.syncNow()).called(1);
  });

  test('SessionController: çıkışta yerel veri temizlenir', () async {
    await emit(_session('u'));
    await emit(null);
    verify(() => db.clearAllUserData()).called(1);
    expect(hookCalls, 1);
    expect(store.map.containsKey(SecureLocalStorage.lastUserIdKey), isFalse);
  });

  test('açılışta oturum yoksa veri silinmez', () async {
    await emit(null);
    verifyNever(() => db.clearAllUserData());
  });

  test('çevrimdışı: eşitleme hatası durumda tutulur, fırlatılmaz', () async {
    when(() => sync.downloadCatalogs()).thenThrow(Exception('ağ yok'));
    await emit(_session('u'));
    final s = c.read(sessionControllerProvider);
    expect(s.userId, 'u');
    expect(s.syncing, isFalse);
    expect(s.lastError, isNotNull);
  });

  test('zamanlayıcı yalnızca bekleyen işlem varsa eşitler', () async {
    await emit(_session('u'));
    clearInteractions(sync);
    tick();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    verifyNever(() => sync.syncNow());
    when(() => outbox.pendingCount()).thenAnswer((_) => Stream.value(2));
    tick();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    verify(() => sync.syncNow()).called(1);
  });

  test('öne gelince bekleyen işlem olmasa da eşitler', () async {
    await emit(_session('u'));
    clearInteractions(sync);
    await c.read(sessionControllerProvider.notifier).onResumed();
    verify(() => sync.syncNow()).called(1);
  });
}
