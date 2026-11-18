import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/auth/secure_local_storage.dart';

class _Mem implements KeyValueStore {
  final m = <String, String>{};
  @override
  Future<String?> read(String key) async => m[key];
  @override
  Future<void> write(String key, String value) async => m[key] = value;
  @override
  Future<void> delete(String key) async => m.remove(key);
}

void main() {
  test('oturum güvenli depoya yazılır, okunur ve silinir', () async {
    final s = SecureLocalStorage(store: _Mem());
    expect(await s.hasAccessToken(), isFalse);
    await s.persistSession('{"a":1}');
    expect(await s.hasAccessToken(), isTrue);
    expect(await s.accessToken(), '{"a":1}');
    await s.removePersistedSession();
    expect(await s.hasAccessToken(), isFalse);
  });
}
