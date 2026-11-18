/// Giriş/kayıt formu doğrulamaları ve Supabase Auth hatalarının Türkçe karşılıkları.
/// RN `features/auth/schemas.ts` ve `features/auth/authErrors.ts` karşılığı.
///
/// Şifre kuralı: en az 8 karakter (en çok 72), en az bir harf ve bir rakam.
/// Tek kullanımlık kod 6-10 rakam; boşluk ve tire temizlenir.
library;

/// Alan adı → ilk hata mesajı. Boşsa form geçerlidir.
class FormResult {
  const FormResult(this.errors, {this.email});
  final Map<String, String> errors;

  /// Kırpılmış e-posta (varsa)
  final String? email;
  bool get ok => errors.isEmpty;
}

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final _letterRe = RegExp(r'\p{L}', unicode: true);
final _digitRe = RegExp(r'\d');

String? emailError(String email) {
  final e = email.trim();
  if (e.isEmpty) return 'E-posta gerekli.';
  if (!_emailRe.hasMatch(e)) return 'Geçerli bir e-posta adresi gir.';
  return null;
}

String? passwordError(String password) {
  if (password.length < 8) return 'Şifre en az 8 karakter olmalı.';
  if (password.length > 72) return 'Şifre en fazla 72 karakter olabilir.';
  if (!_letterRe.hasMatch(password)) return 'Şifre en az bir harf içermeli.';
  if (!_digitRe.hasMatch(password)) return 'Şifre en az bir rakam içermeli.';
  return null;
}

/// Boşluk/tireyi temizler; 6-10 rakam değilse null.
String? normalizeOtp(String code) {
  final c = code.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^\d{6,10}$').hasMatch(c) ? c : null;
}

const _otpError = 'E-postadaki kodu eksiksiz gir (yalnızca rakam).';
const _mismatch = 'Şifreler eşleşmiyor.';

FormResult validateSignIn({required String email, required String password}) {
  final errors = <String, String>{};
  final e = emailError(email);
  if (e != null) errors['email'] = e;
  if (password.isEmpty) errors['password'] = 'Şifre gerekli.';
  return FormResult(errors, email: email.trim());
}

FormResult validateSignUp({
  required String email,
  required String password,
  required String passwordConfirm,
}) {
  final errors = <String, String>{};
  final e = emailError(email);
  if (e != null) errors['email'] = e;
  final p = passwordError(password);
  if (p != null) errors['password'] = p;
  if (password != passwordConfirm) errors['passwordConfirm'] = _mismatch;
  return FormResult(errors, email: email.trim());
}

FormResult validateForgotPassword({required String email}) {
  final e = emailError(email);
  return FormResult(e == null ? const {} : {'email': e}, email: email.trim());
}

FormResult validateVerifyCode(String code) =>
    FormResult(normalizeOtp(code) == null ? const {'code': _otpError} : const {});

FormResult validateResetPassword({
  required String code,
  required String password,
  required String passwordConfirm,
}) {
  final errors = <String, String>{};
  if (normalizeOtp(code) == null) errors['code'] = _otpError;
  final p = passwordError(password);
  if (p != null) errors['password'] = p;
  if (password != passwordConfirm) errors['passwordConfirm'] = _mismatch;
  return FormResult(errors);
}

enum AuthAction { signIn, signUp, resetRequest, updatePassword, callback, resend, verifyCode }

/// Hata nesnesinden okunan alanlar (veri katmanı supabase hatasını buna çevirir).
class AuthErrorInfo {
  const AuthErrorInfo({this.name, this.code, this.status, this.message});
  final String? name;
  final String? code;
  final int? status;
  final String? message;
}

const networkMessage =
    'İnternet bağlantısı yok gibi görünüyor. Bağlantını kontrol edip tekrar dene.';

bool _isNetwork(AuthErrorInfo e) {
  if (e.name == 'AuthRetryableFetchError' && (e.status == null || e.status == 0)) return true;
  final m = e.message;
  return m != null &&
      RegExp(
        r'network request failed|failed to fetch|SocketException|Failed host lookup|ClientException|Connection (refused|reset|closed)',
        caseSensitive: false,
      ).hasMatch(m);
}

/// 5xx sunucu hatası ağ sorunu DEĞİL. En sık örnek: doğrulama e-postası SMTP'den gönderilemedi.
String? _serverMessage(AuthErrorInfo e) {
  final status = e.status ?? 0;
  if (e.name != 'AuthRetryableFetchError' || status < 500) return null;
  final m = e.message;
  if (m != null && RegExp(r'error sending .*email', caseSensitive: false).hasMatch(m)) {
    return 'Doğrulama e-postası şu an gönderilemedi. Biraz sonra tekrar dene.';
  }
  return 'Sunucu şu an yanıt vermiyor. Biraz sonra tekrar dene.';
}

const _linkExpired =
    'Bağlantının süresi dolmuş veya daha önce kullanılmış. Yeni bir bağlantı iste.';

String authErrorMessage(AuthErrorInfo e, AuthAction action) {
  if (e.name == null && e.code == null && e.status == null && e.message == null) {
    return 'Beklenmeyen bir hata oluştu. Lütfen tekrar dene.';
  }
  if (_isNetwork(e)) return networkMessage;
  final server = _serverMessage(e);
  if (server != null) return server;

  if (e.name == 'AuthPKCECodeVerifierMissingError') {
    return action == AuthAction.callback
        ? 'Bu bağlantı bu cihazda başlatılan bir işleme ait değil. E-postan doğrulandıysa doğrudan giriş yapabilirsin.'
        : 'Bağlantı bu cihazda açılamadı. Lütfen işlemi bu cihazdan yeniden başlat.';
  }

  switch (e.code) {
    case 'invalid_credentials':
      return 'E-posta veya şifre hatalı.';
    case 'email_not_confirmed':
      return 'E-posta adresin henüz doğrulanmadı. Sana gönderdiğimiz kodu gir.';
    case 'user_already_exists':
    case 'email_exists':
      return 'Bu e-postayla zaten bir hesap var. Giriş yapmayı veya şifreni sıfırlamayı deneyebilirsin.';
    case 'weak_password':
      return 'Şifre yeterince güçlü değil. Daha uzun ve harf ile rakam içeren bir şifre dene.';
    case 'same_password':
      return 'Yeni şifre eskisiyle aynı olamaz.';
    case 'email_address_invalid':
      return 'Bu e-posta adresi geçerli görünmüyor.';
    case 'signup_disabled':
      return 'Yeni kayıtlar şu an kapalı.';
    case 'over_email_send_rate_limit':
      return 'Kısa sürede çok fazla e-posta istendi. Birkaç dakika sonra tekrar dene.';
    case 'over_request_rate_limit':
      return 'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.';
    case 'otp_expired':
      return action == AuthAction.verifyCode
          ? 'Kod hatalı veya süresi dolmuş. Kodu kontrol et ya da yeni kod iste.'
          : _linkExpired;
    case 'access_denied':
      return _linkExpired;
    case 'flow_state_not_found':
    case 'flow_state_expired':
    case 'bad_code_verifier':
      return 'Bağlantı artık geçerli değil. Lütfen işlemi yeniden başlat.';
    case 'session_not_found':
    case 'session_expired':
    case 'refresh_token_not_found':
    case 'refresh_token_already_used':
      return 'Oturumun sona erdi. Lütfen tekrar giriş yap.';
    case 'user_banned':
      return 'Bu hesap şu an kullanılamıyor.';
  }
  if (e.status == 429) return 'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.';
  return 'Bir şeyler ters gitti. Lütfen tekrar dene.';
}
