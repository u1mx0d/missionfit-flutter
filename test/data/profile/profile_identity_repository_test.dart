import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/profile/profile_identity_repository.dart';
import 'package:missionfit/data/profile/profile_repository.dart' show ProfileRepository;
import 'package:missionfit/data/sync/outbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeRemote implements IdentityRemote {
  final calls = <String>[];
  final uploads = <String>[];
  final removed = <List<String>>[];
  Object? rpcError;
  Object? uploadError;
  Object? removeError;
  Object? rpcResult;

  @override
  Future<Object?> rpc(String fn, Map<String, Object?> params) async {
    calls.add('$fn:${params.values.first}');
    if (rpcError != null) throw rpcError!;
    return rpcResult;
  }

  @override
  Future<void> upload(String path, Uint8List bytes) async {
    if (uploadError != null) throw uploadError!;
    uploads.add(path);
  }

  @override
  Future<void> remove(List<String> paths) async {
    removed.add(paths);
    if (removeError != null) throw removeError!;
  }

  @override
  String publicUrl(String path) => 'https://x/$path';
}

void main() {
  late AppDatabase db;
  late FakeRemote remote;
  late DefaultProfileIdentityRepository repo;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
            avatarPath: const Value('u1/old.jpg'),
          ),
        );
    remote = FakeRemote();
    repo = DefaultProfileIdentityRepository(
      remote,
      db,
      clock: () => DateTime.fromMillisecondsSinceEpoch(1234),
    );
  });
  tearDown(() => db.close());

  Future<Profile> row() =>
      (db.select(db.profiles)..where((p) => p.userId.equals('u1'))).getSingle();

  test('setUsername yerel satırı günceller, outbox eklenmez', () async {
    remote.rpcResult = 'ali';
    expect(await repo.setUsername('u1', 'ali'), 'ali');
    expect((await row()).username, 'ali');
    expect(await OutboxRepository(db).pending(), isEmpty);
  });

  test('setUsername hata eşlemesi, yerel değişmez', () async {
    remote.rpcError = const PostgrestException(message: 'x', code: '23505');
    await expectLater(
      repo.setUsername('u1', 'ali'),
      throwsA(isA<IdentityError>().having((e) => e.failure, 'f', IdentityFailure.usernameTaken)),
    );
    remote.rpcError = const PostgrestException(message: 'x', code: '22023');
    await expectLater(
      repo.setUsername('u1', 'ali'),
      throwsA(isA<IdentityError>().having((e) => e.failure, 'f', IdentityFailure.usernameInvalid)),
    );
    remote.rpcError = const SocketException('yok');
    await expectLater(
      repo.setUsername('u1', 'ali'),
      throwsA(isA<IdentityError>().having((e) => e.failure, 'f', IdentityFailure.offline)),
    );
    expect((await row()).username, isNull);
  });

  test('uploadAvatar yükler, yolu kaydeder, eskisini siler', () async {
    final path = await repo.uploadAvatar('u1', Uint8List(3));
    expect(path, 'u1/1234.jpg');
    expect(remote.uploads, ['u1/1234.jpg']);
    expect(remote.calls, ['set_avatar_path:u1/1234.jpg']);
    expect((await row()).avatarPath, 'u1/1234.jpg');
    expect(remote.removed, [
      ['u1/old.jpg'],
    ]);
  });

  test('eski dosya silme hatası yutulur', () async {
    remote.removeError = StateError('x');
    expect(await repo.uploadAvatar('u1', Uint8List(3)), 'u1/1234.jpg');
    expect((await row()).avatarPath, 'u1/1234.jpg');
  });

  test('yükleme hatası: uploadFailed / offline, yerel değişmez', () async {
    remote.uploadError = StateError('x');
    await expectLater(
      repo.uploadAvatar('u1', Uint8List(3)),
      throwsA(isA<IdentityError>().having((e) => e.failure, 'f', IdentityFailure.uploadFailed)),
    );
    remote.uploadError = const SocketException('yok');
    await expectLater(
      repo.uploadAvatar('u1', Uint8List(3)),
      throwsA(isA<IdentityError>().having((e) => e.failure, 'f', IdentityFailure.offline)),
    );
    expect(remote.calls, isEmpty);
    expect((await row()).avatarPath, 'u1/old.jpg');
  });

  test('removeAvatar yolu temizler ve dosyayı siler', () async {
    await repo.removeAvatar('u1');
    expect((await row()).avatarPath, isNull);
    expect(remote.calls, ['set_avatar_path:null']);
    expect(remote.removed, [
      ['u1/old.jpg'],
    ]);
  });

  test('ProfileRepository.update sonrası username korunur', () async {
    remote.rpcResult = 'ali';
    await repo.setUsername('u1', 'ali');
    await ProfileRepository(
      db,
      OutboxRepository(db),
    ).update('u1', (p) => p.copyWith(weightKg: 80.0));
    final r = await row();
    expect(r.username, 'ali');
    expect(r.avatarPath, 'u1/old.jpg');
  });
}
