import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/auth_rules.dart';

/// Arayüze gösterilecek Türkçe hata.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Google'dan alınan kimlik bilgileri.
class GoogleCredentials {
  const GoogleCredentials({required this.idToken, this.accessToken});
  final String idToken;
  final String? accessToken;
}

/// google_sign_in v7 tekilini sarar; testlerde taklit edilir.
abstract class GoogleCredentialSource {
  Future<GoogleCredentials> authenticate();
}

class GoogleSignInCredentialSource implements GoogleCredentialSource {
  GoogleSignInCredentialSource(this._serverClientId);

  final String _serverClientId;
  bool _initialized = false;

  @override
  Future<GoogleCredentials> authenticate() async {
    final google = GoogleSignIn.instance;
    if (!_initialized) {
      await google.initialize(serverClientId: _serverClientId);
      _initialized = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const AuthFailure('Google kimlik bilgisi alınamadı.');
    String? accessToken;
    try {
      final authz = await account.authorizationClient.authorizationForScopes(const ['email']);
      accessToken = authz?.accessToken;
    } catch (_) {
      // accessToken isteğe bağlı; idToken yeterli.
    }
    return GoogleCredentials(idToken: idToken, accessToken: accessToken);
  }
}

const googleNotConfiguredMessage = 'Google ile giriş bu sürümde yapılandırılmamış.';
const googleCancelledMessage = 'Google ile giriş iptal edildi.';

class AuthRepository {
  AuthRepository(this._auth, {required this.google, required this.googleEnabled});

  final GoTrueClient _auth;
  final GoogleCredentialSource google;
  final bool googleEnabled;

  Future<void> signUp(String email, String password) =>
      _run(AuthAction.signUp, () => _auth.signUp(email: email, password: password));

  Future<void> verifySignUpCode(String email, String code) => _run(
    AuthAction.verifyCode,
    () => _auth.verifyOTP(email: email, token: code, type: OtpType.signup),
  );

  Future<void> signIn(String email, String password) =>
      _run(AuthAction.signIn, () => _auth.signInWithPassword(email: email, password: password));

  Future<void> sendResetCode(String email) =>
      _run(AuthAction.resetRequest, () => _auth.resetPasswordForEmail(email));

  Future<void> verifyResetCode(String email, String code) => _run(
    AuthAction.verifyCode,
    () => _auth.verifyOTP(email: email, token: code, type: OtpType.recovery),
  );

  Future<void> updatePassword(String newPassword) => _run(
    AuthAction.updatePassword,
    () => _auth.updateUser(UserAttributes(password: newPassword)),
  );

  Future<void> reauthenticateWithPassword(String email, String password) =>
      _run(AuthAction.signIn, () => _auth.signInWithPassword(email: email, password: password));

  Future<void> signInWithGoogle() => _googleFlow();

  Future<void> reauthenticateWithGoogle() => _googleFlow();

  Future<void> _googleFlow() async {
    if (!googleEnabled) throw const AuthFailure(googleNotConfiguredMessage);
    await _run(AuthAction.signIn, () async {
      final GoogleCredentials c;
      try {
        c = await google.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted) {
          throw const AuthFailure(googleCancelledMessage);
        }
        throw const AuthFailure('Google ile giriş başarısız oldu. Lütfen tekrar dene.');
      }
      return _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: c.idToken,
        accessToken: c.accessToken,
      );
    });
  }

  bool get hasPasswordIdentity =>
      _auth.currentUser?.identities?.any((i) => i.provider == 'email') ?? false;

  Future<void> signOut() =>
      _run(AuthAction.callback, () => _auth.signOut(scope: SignOutScope.local));

  Future<void> _run(AuthAction action, Future<Object?> Function() body) async {
    try {
      await body();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(authErrorMessage(toAuthErrorInfo(e), action));
    }
  }
}

/// Supabase ve ağ istisnalarını alan kuralının beklediği biçime çevirir.
AuthErrorInfo toAuthErrorInfo(Object e) {
  if (e is AuthRetryableFetchException) {
    return AuthErrorInfo(
      name: 'AuthRetryableFetchError',
      code: e.code,
      status: int.tryParse(e.statusCode ?? ''),
      message: e.message,
    );
  }
  if (e is AuthException) {
    return AuthErrorInfo(
      name: e.runtimeType.toString(),
      code: e.code,
      status: int.tryParse(e.statusCode ?? ''),
      message: e.message,
    );
  }
  if (e is SocketException ||
      e.runtimeType.toString() == 'ClientException' ||
      e is TimeoutException) {
    return const AuthErrorInfo(name: 'AuthRetryableFetchError', message: 'Failed to fetch');
  }
  return AuthErrorInfo(message: e.toString());
}
