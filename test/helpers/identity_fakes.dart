import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/data/db/database.dart';

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

// 1x1 şeffaf PNG.
Uint8List testPng() => Uint8List.fromList(const [
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
