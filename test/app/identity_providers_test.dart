import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/data/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gerçek GoTrue gibi: kimlikler o anki kullanıcıdan okunur.
class _FakeAuth extends Fake implements AuthRepository {
  List<String> providers = const [];
  @override
  bool get hasPasswordIdentity => providers.contains('email');
  @override
  bool get hasGoogleIdentity => providers.contains('google');
}

Session _session(String id) => Session(
  accessToken: 't-$id',
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
  test('oturum değişince şifre/Google kimliği yeniden okunur', () async {
    final auth = _FakeAuth()..providers = const ['email'];
    final sessions = StreamController<Session?>();
    addTearDown(sessions.close);
    final c = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        authStateProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    addTearDown(c.dispose);
    c.listen(hasPasswordIdentityProvider, (_, _) {});
    c.listen(hasGoogleIdentityProvider, (_, _) {});

    sessions.add(_session('u1'));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(hasPasswordIdentityProvider), isTrue);
    expect(c.read(hasGoogleIdentityProvider), isFalse);

    // Hesap silindi, aynı uygulama oturumunda Google ile yeni hesap açıldı.
    sessions.add(null);
    await Future<void>.delayed(Duration.zero);
    auth.providers = const ['google'];
    sessions.add(_session('u2'));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(hasPasswordIdentityProvider), isFalse);
    expect(c.read(hasGoogleIdentityProvider), isTrue);
  });
}
