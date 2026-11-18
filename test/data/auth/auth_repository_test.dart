import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:missionfit/data/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuth extends Mock implements GoTrueClient {}

class MockGoogle extends Mock implements GoogleCredentialSource {}

User _user(List<String> providers, {String id = 'u1'}) => User(
  id: id,
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
  identities: [
    for (final p in providers)
      UserIdentity(
        id: p,
        userId: 'u1',
        identityData: const {},
        identityId: p,
        provider: p,
        createdAt: '2026-01-01T00:00:00Z',
        lastSignInAt: '2026-01-01T00:00:00Z',
      ),
  ],
);

void main() {
  late MockAuth auth;
  late MockGoogle google;
  AuthRepository repo({bool enabled = true}) =>
      AuthRepository(auth, google: google, googleEnabled: enabled);

  setUpAll(() {
    registerFallbackValue(OtpType.signup);
    registerFallbackValue(OAuthProvider.google);
    registerFallbackValue(SignOutScope.local);
  });
  setUp(() {
    auth = MockAuth();
    google = MockGoogle();
  });

  test("signIn hatası Türkçe AuthFailure'a çevrilir", () async {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const AuthException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      ),
    );
    await expectLater(
      repo().signIn('a@b.co', 'x'),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'message', isNot(contains('Invalid')))),
    );
  });

  test('ağ hatası internet mesajına çevrilir', () async {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthRetryableFetchException(message: 'Failed to fetch'));
    await expectLater(
      repo().signIn('a@b.co', 'x'),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'm', contains('İnternet'))),
    );
  });

  test('signUp: e-posta zaten kayıtlıysa (identities boş) Türkçe AuthFailure', () async {
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResponse(user: _user([])));
    await expectLater(
      repo().signUp('a@b.co', 'abc12345'),
      throwsA(isA<AuthFailure>().having((f) => f.message, 'message', contains('zaten bir hesap'))),
    );
  });

  test('signUp: yeni hesapta (identities dolu) hata yok', () async {
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResponse(user: _user(['email'])));
    await repo().signUp('a@b.co', 'abc12345');
  });

  test('verifySignUpCode OtpType.signup kullanır', () async {
    when(
      () => auth.verifyOTP(
        email: any(named: 'email'),
        token: any(named: 'token'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => AuthResponse());
    await repo().verifySignUpCode('a@b.co', '12345678');
    verify(() => auth.verifyOTP(email: 'a@b.co', token: '12345678', type: OtpType.signup))
        .called(1);
  });

  test('Google yapılandırılmamışsa Türkçe AuthFailure fırlatır', () async {
    await expectLater(
      repo(enabled: false).signInWithGoogle(),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'm', googleNotConfiguredMessage)),
    );
    verifyNever(() => google.authenticate());
  });

  test('Google girişi idToken ile Supabase e gider', () async {
    when(() => google.authenticate())
        .thenAnswer((_) async => const GoogleCredentials(idToken: 'id', accessToken: 'ac'));
    when(
      () => auth.signInWithIdToken(
        provider: any(named: 'provider'),
        idToken: any(named: 'idToken'),
        accessToken: any(named: 'accessToken'),
      ),
    ).thenAnswer((_) async => AuthResponse());
    await repo().signInWithGoogle();
    verify(
      () =>
          auth.signInWithIdToken(provider: OAuthProvider.google, idToken: 'id', accessToken: 'ac'),
    ).called(1);
  });

  test('Google iptali AuthFailure olur', () async {
    when(() => google.authenticate())
        .thenThrow(const GoogleSignInException(code: GoogleSignInExceptionCode.canceled));
    await expectLater(
      repo().signInWithGoogle(),
      throwsA(isA<AuthFailure>().having((e) => e.message, 'm', googleCancelledMessage)),
    );
  });

  test('hasPasswordIdentity: yalnızca google kimliği varsa false', () {
    when(() => auth.currentUser).thenReturn(_user(['google']));
    expect(repo().hasPasswordIdentity, isFalse);
    when(() => auth.currentUser).thenReturn(_user(['google', 'email']));
    expect(repo().hasPasswordIdentity, isTrue);
  });

  test('signOut yerel kapsamla çağrılır', () async {
    when(() => auth.signOut(scope: any(named: 'scope'))).thenAnswer((_) async {});
    await repo().signOut();
    verify(() => auth.signOut(scope: SignOutScope.local)).called(1);
  });

  group('I-2: Google ile yeniden doğrulama aynı hesabı doğrular', () {
    void stubGoogle(String resultId) {
      when(() => google.authenticate())
          .thenAnswer((_) async => const GoogleCredentials(idToken: 'id'));
      when(
        () => auth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: _user(['google'], id: resultId)));
      when(() => auth.signOut(scope: any(named: 'scope'))).thenAnswer((_) async {});
    }

    test('farklı hesap seçilirse çıkış yapılır ve AuthFailure fırlar', () async {
      when(() => auth.currentUser).thenReturn(_user(['google']));
      stubGoogle('baska');
      await expectLater(
        repo().reauthenticateWithGoogle(),
        throwsA(isA<AuthFailure>().having((e) => e.message, 'm', googleWrongAccountMessage)),
      );
      verify(() => auth.signOut(scope: SignOutScope.local)).called(1);
    });

    test('kimlik belirtecindeki Google hesabı farklıysa Supabase oturumu hiç açılmaz', () async {
      String b64(String j) => base64Url.encode(utf8.encode(j)).replaceAll('=', '');
      final token = '${b64('{"alg":"RS256"}')}.${b64('{"sub":"g-baska"}')}.imza';
      when(() => auth.currentUser).thenReturn(
        User(
          id: 'u1',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: '2026-01-01T00:00:00Z',
          identities: [
            UserIdentity(
              id: 'g-1',
              userId: 'u1',
              identityData: const {'sub': 'g-1'},
              identityId: 'x',
              provider: 'google',
              createdAt: '2026-01-01T00:00:00Z',
              lastSignInAt: '2026-01-01T00:00:00Z',
            ),
          ],
        ),
      );
      stubGoogle('u1');
      when(() => google.authenticate()).thenAnswer((_) async => GoogleCredentials(idToken: token));
      await expectLater(
        repo().reauthenticateWithGoogle(),
        throwsA(isA<AuthFailure>().having((e) => e.message, 'm', googleWrongAccountMessage)),
      );
      verifyNever(
        () => auth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        ),
      );
    });

    test('aynı hesapta sorunsuz biter, çıkış yapılmaz', () async {
      when(() => auth.currentUser).thenReturn(_user(['google']));
      stubGoogle('u1');
      await repo().reauthenticateWithGoogle();
      verifyNever(() => auth.signOut(scope: any(named: 'scope')));
    });
  });
}
