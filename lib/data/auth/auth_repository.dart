import 'dart:async';
import 'dart:convert';
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
const googleWrongAccountMessage = 'Farklı bir Google hesabı seçildi. Hesap silinmedi.';
const reauthNoSessionMessage = 'Oturum bilgisi alınamadı. Lütfen tekrar giriş yap.';

class AuthRepository {
  AuthRepository(this._auth, {required this.google, required this.googleEnabled});

  final GoTrueClient _auth;
  final GoogleCredentialSource google;
  final bool googleEnabled;

  /// Supabase, e-posta zaten kayıtlıysa güvenlik gereği hata vermez ve e-posta göndermez;
  /// yanıttaki kullanıcının kimlik listesi boş gelir. Bu durumda kullanıcıya açıkça söyleriz.
  Future<void> signUp(String email, String password) => _run(AuthAction.signUp, () async {
    final res = await _auth.signUp(email: email, password: password);
    final identities = res.user?.identities;
    if (res.user != null && identities != null && identities.isEmpty) {
      throw AuthFailure(
        authErrorMessage(const AuthErrorInfo(code: 'user_already_exists'), AuthAction.signUp),
      );
    }
    return res;
  });

  Future<void> verifySignUpCode(String email, String code) => _run(
    AuthAction.verifyCode,
    () => _auth.verifyOTP(email: email, token: code, type: OtpType.signup),
  );

  Future<void> resendSignUpCode(String email) =>
      _run(AuthAction.resend, () => _auth.resend(type: OtpType.signup, email: email));

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

  Future<void> signInWithGoogle() async {
    await _googleFlow();
  }

  /// Yeniden doğrulama; seçilen Google hesabı oturumdaki kullanıcı değilse yeni oturum
  /// kapatılır ve [googleWrongAccountMessage] fırlar (hesap silme ASLA sürmemeli).
  Future<void> reauthenticateWithGoogle() async {
    final before = _auth.currentUser?.id;
    if (before == null) throw const AuthFailure(reauthNoSessionMessage);
    final googleSubs = {
      for (final i in _auth.currentUser?.identities ?? const <UserIdentity>[])
        if (i.provider == 'google') ...[
          i.id,
          if (i.identityData?['sub'] is String) i.identityData!['sub'] as String,
        ],
    };
    // Önce belirteçteki Google hesabı karşılaştırılır: farklıysa başka kullanıcıya oturum hiç
    // açılmaz (o oturum açılsaydı yerel veri kullanıcı değişimiyle silinirdi).
    final after =
        await _googleFlow(
          accept: (c) {
            final sub = googleSubject(c.idToken);
            return googleSubs.isEmpty || sub == null || googleSubs.contains(sub);
          },
        ) ??
        _auth.currentUser?.id;
    if (after != before) {
      try {
        await _auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // Çıkış başarısız olsa da silme durdurulur.
      }
      throw const AuthFailure(googleWrongAccountMessage);
    }
  }

  /// Google ile oturum açar; açılan oturumun kullanıcı kimliğini döndürür.
  Future<String?> _googleFlow({bool Function(GoogleCredentials c)? accept}) async {
    if (!googleEnabled) throw const AuthFailure(googleNotConfiguredMessage);
    String? userId;
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
      if (accept != null && !accept(c)) throw const AuthFailure(googleWrongAccountMessage);
      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: c.idToken,
        accessToken: c.accessToken,
      );
      userId = response.user?.id;
      return response;
    });
    return userId;
  }

  bool get hasPasswordIdentity =>
      _auth.currentUser?.identities?.any((i) => i.provider == 'email') ?? false;

  bool get hasGoogleIdentity =>
      _auth.currentUser?.identities?.any((i) => i.provider == 'google') ?? false;

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

/// Google kimlik belirtecinin (JWT) `sub` alanı; çözülemezse null. İmza burada doğrulanmaz;
/// yalnızca yanlış hesabı erken yakalamak içindir (asıl doğrulamayı Supabase yapar).
String? googleSubject(String idToken) {
  try {
    final parts = idToken.split('.');
    if (parts.length < 2) return null;
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final sub = payload is Map ? payload['sub'] : null;
    return sub is String ? sub : null;
  } catch (_) {
    return null;
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
