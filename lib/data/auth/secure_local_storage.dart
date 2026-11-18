import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Küçük anahtar-değer deposu (son kullanıcı kimliği için); testlerde bellekte taklit edilir.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

const _storage = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: true));

/// Android Keystore / iOS Keychain üzerinde saklar.
class SecureKeyValueStore implements KeyValueStore {
  const SecureKeyValueStore();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Supabase oturumunu düz SharedPreferences yerine güvenli depoda tutar.
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage({this.store = const SecureKeyValueStore()});

  static const sessionKey = 'supabase_session';
  static const lastUserIdKey = 'last_user_id';

  final KeyValueStore store;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await accessToken()) != null;

  /// Keystore bozulursa (yedekten geri yükleme, anahtar sıfırlama) uygulama çökmesin:
  /// oturum silinir ve oturumsuz başlanır.
  @override
  Future<String?> accessToken() async {
    try {
      return await store.read(sessionKey);
    } catch (_) {
      try {
        await store.delete(sessionKey);
      } catch (_) {
        // En iyi çaba.
      }
      return null;
    }
  }

  @override
  Future<void> removePersistedSession() => store.delete(sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      store.write(sessionKey, persistSessionString);
}
