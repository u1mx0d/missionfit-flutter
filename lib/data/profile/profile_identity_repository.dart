import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart';
import '../export/export_service.dart' show isNetworkFailure;

enum IdentityFailure { offline, usernameTaken, usernameInvalid, uploadFailed }

class IdentityError implements Exception {
  const IdentityError(this.failure);
  final IdentityFailure failure;

  String get message => switch (failure) {
    IdentityFailure.offline => 'İnternet bağlantısı gerekiyor.',
    IdentityFailure.usernameTaken => 'Bu kullanıcı adı alınmış.',
    IdentityFailure.usernameInvalid => 'Bu kullanıcı adı kullanılamaz.',
    IdentityFailure.uploadFailed => 'Fotoğraf yüklenemedi, tekrar dene.',
  };

  @override
  String toString() => message;
}

abstract interface class ProfileIdentityRepository {
  Future<bool> isUsernameAvailable(String username);
  Future<String> setUsername(String userId, String username);
  Future<String> uploadAvatar(String userId, Uint8List jpeg);
  Future<String> uploadAvatarFromUrl(String userId, String url);
  Future<void> removeAvatar(String userId);
  String publicUrl(String avatarPath);
}

/// Sunucuya ince erişim; testte sahtesi kullanılır.
abstract interface class IdentityRemote {
  Future<Object?> rpc(String fn, Map<String, Object?> params);
  Future<void> upload(String path, Uint8List bytes);
  Future<void> remove(List<String> paths);
  String publicUrl(String path);
}

class SupabaseIdentityRemote implements IdentityRemote {
  SupabaseIdentityRemote(this._client);
  final SupabaseClient _client;
  static const _bucket = 'avatars';

  @override
  Future<Object?> rpc(String fn, Map<String, Object?> params) => _client.rpc(fn, params: params);

  @override
  Future<void> upload(String path, Uint8List bytes) async {
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
  }

  @override
  Future<void> remove(List<String> paths) async {
    await _client.storage.from(_bucket).remove(paths);
  }

  @override
  String publicUrl(String path) => _client.storage.from(_bucket).getPublicUrl(path);
}

class DefaultProfileIdentityRepository implements ProfileIdentityRepository {
  DefaultProfileIdentityRepository(
    this._remote,
    this._db, {
    DateTime Function()? clock,
    http.Client? httpClient,
  }) : _clock = clock ?? DateTime.now,
       _http = httpClient ?? http.Client();

  final IdentityRemote _remote;
  final AppDatabase _db;
  final DateTime Function() _clock;
  final http.Client _http;

  IdentityError _map(Object e) {
    if (e is IdentityError) return e;
    if (e is PostgrestException) {
      if (e.code == '23505') return const IdentityError(IdentityFailure.usernameTaken);
      if (e.code == '22023') return const IdentityError(IdentityFailure.usernameInvalid);
    }
    if (isNetworkFailure(e)) return const IdentityError(IdentityFailure.offline);
    throw e;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final r = await _remote.rpc('username_available', {'p_username': username});
      return r == true;
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<String> setUsername(String userId, String username) async {
    final String saved;
    try {
      final r = await _remote.rpc('set_username', {'p_username': username});
      saved = r is String ? r : username;
    } catch (e) {
      throw _map(e);
    }
    await (_db.update(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).write(ProfilesCompanion(username: Value(saved)));
    return saved;
  }

  Future<String?> _currentAvatar(String userId) async {
    final row = await (_db.select(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).getSingleOrNull();
    return row?.avatarPath;
  }

  Future<void> _setLocalAvatar(String userId, String? path) => (_db.update(
    _db.profiles,
  )..where((p) => p.userId.equals(userId))).write(ProfilesCompanion(avatarPath: Value(path)));

  Future<void> _bestEffortRemove(String? path) async {
    if (path == null) return;
    try {
      await _remote.remove([path]);
    } catch (_) {}
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List jpeg) async {
    final old = await _currentAvatar(userId);
    final path = '$userId/${_clock().millisecondsSinceEpoch}.jpg';
    try {
      await _remote.upload(path, jpeg);
    } catch (e) {
      if (isNetworkFailure(e)) throw const IdentityError(IdentityFailure.offline);
      throw const IdentityError(IdentityFailure.uploadFailed);
    }
    try {
      await _remote.rpc('set_avatar_path', {'p_path': path});
    } catch (e) {
      await _bestEffortRemove(path);
      if (isNetworkFailure(e)) throw const IdentityError(IdentityFailure.offline);
      throw const IdentityError(IdentityFailure.uploadFailed);
    }
    await _setLocalAvatar(userId, path);
    if (old != null && old != path) await _bestEffortRemove(old);
    return path;
  }

  @override
  Future<String> uploadAvatarFromUrl(String userId, String url) async {
    final Uint8List bytes;
    try {
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode < 200 || res.statusCode > 299) {
        throw const IdentityError(IdentityFailure.uploadFailed);
      }
      bytes = res.bodyBytes;
    } catch (e) {
      if (e is IdentityError) rethrow;
      if (isNetworkFailure(e)) throw const IdentityError(IdentityFailure.offline);
      throw const IdentityError(IdentityFailure.uploadFailed);
    }
    return uploadAvatar(userId, bytes);
  }

  @override
  Future<void> removeAvatar(String userId) async {
    final old = await _currentAvatar(userId);
    try {
      await _remote.rpc('set_avatar_path', {'p_path': null});
    } catch (e) {
      throw _map(e);
    }
    await _setLocalAvatar(userId, null);
    await _bestEffortRemove(old);
  }

  @override
  String publicUrl(String avatarPath) => _remote.publicUrl(avatarPath);
}
