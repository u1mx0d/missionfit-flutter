import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/auth_rules.dart';

void main() {
  group('signUp', () {
    test('geçerli girdi', () {
      final r = validateSignUp(
        email: ' a@b.co ',
        password: 'şifre1234',
        passwordConfirm: 'şifre1234',
      );
      expect(r.ok, isTrue);
      expect(r.email, 'a@b.co');
    });

    test('kısa şifre', () {
      final r = validateSignUp(email: 'a@b.co', password: 'ab1', passwordConfirm: 'ab1');
      expect(r.ok, isFalse);
      expect(r.errors['password'], contains('8 karakter'));
    });

    test('rakamsız şifre', () {
      final r = validateSignUp(email: 'a@b.co', password: 'abcdefgh', passwordConfirm: 'abcdefgh');
      expect(r.errors['password'], contains('rakam'));
    });

    test('eşleşmeyen şifreler', () {
      final r = validateSignUp(email: 'a@b.co', password: 'abcd1234', passwordConfirm: 'abcd12345');
      expect(r.errors['passwordConfirm'], contains('eşleşmiyor'));
    });
  });

  group('signIn', () {
    test('boş ve geçersiz e-posta', () {
      final empty = validateSignIn(email: '', password: '');
      expect(empty.errors['email'], 'E-posta gerekli.');
      expect(empty.errors['password'], 'Şifre gerekli.');
      final bad = validateSignIn(email: 'abc', password: 'x');
      expect(bad.errors['email'], contains('Geçerli'));
    });
  });

  group('verifyCode', () {
    test('6 haneli kod geçerli, boşluk/tire temizlenir', () {
      expect(normalizeOtp('123456'), '123456');
      expect(normalizeOtp(' 123-456 '), '123456');
    });

    test('kısa, harfli veya boş kod reddedilir', () {
      for (final code in ['12345', '12a456', '']) {
        expect(normalizeOtp(code), isNull);
        expect(validateVerifyCode(code).ok, isFalse);
      }
    });
  });

  group('resetPassword', () {
    test('kod + geçerli şifre', () {
      expect(
        validateResetPassword(code: '654321', password: 'abc12345', passwordConfirm: 'abc12345').ok,
        isTrue,
      );
    });

    test('eksik kod ve eşleşmeyen şifre ayrı alanlarda raporlanır', () {
      final r = validateResetPassword(
        code: '12',
        password: 'abc12345',
        passwordConfirm: 'abc12346',
      );
      expect(r.ok, isFalse);
      expect(r.errors['code'], isNotNull);
    });
  });

  group('authErrorMessage', () {
    String msg(AuthErrorInfo e, [AuthAction a = AuthAction.signIn]) => authErrorMessage(e, a);

    test('yanlış şifre', () {
      expect(
        msg(const AuthErrorInfo(name: 'AuthApiError', code: 'invalid_credentials', status: 400)),
        'E-posta veya şifre hatalı.',
      );
    });

    test('e-posta doğrulanmamış', () {
      expect(
        msg(const AuthErrorInfo(code: 'email_not_confirmed', status: 400)),
        contains('doğrulanmadı'),
      );
    });

    test('hesap zaten var', () {
      expect(
        msg(const AuthErrorInfo(code: 'user_already_exists', status: 422), AuthAction.signUp),
        contains('zaten bir hesap'),
      );
    });

    test('ağ yok: supabase retryable hatası', () {
      expect(msg(const AuthErrorInfo(name: 'AuthRetryableFetchError', status: 0)), networkMessage);
    });

    test('ağ yok: soket hatası', () {
      expect(
        msg(const AuthErrorInfo(message: 'SocketException: Failed host lookup')),
        networkMessage,
      );
    });

    test('PKCE verifier yok (başka cihazda açılan link)', () {
      expect(
        msg(const AuthErrorInfo(name: 'AuthPKCECodeVerifierMissingError'), AuthAction.callback),
        contains('giriş yapabilirsin'),
      );
    });

    test('bilinmeyen kod: genel mesaj', () {
      expect(
        msg(const AuthErrorInfo(code: 'something_new', status: 500)),
        'Bir şeyler ters gitti. Lütfen tekrar dene.',
      );
    });

    test('429: hız sınırı', () {
      expect(msg(const AuthErrorInfo(status: 429), AuthAction.resetRequest), contains('Çok fazla'));
    });

    test('bilgi yok: beklenmeyen hata', () {
      expect(msg(const AuthErrorInfo()), contains('Beklenmeyen'));
    });

    test('yanlış veya süresi dolmuş kod', () {
      expect(
        msg(const AuthErrorInfo(code: 'otp_expired', status: 403), AuthAction.verifyCode),
        contains('Kod hatalı'),
      );
    });

    test('linkte otp_expired: bağlantı mesajı', () {
      expect(
        msg(const AuthErrorInfo(code: 'otp_expired'), AuthAction.callback),
        contains('Bağlantının süresi'),
      );
    });

    test('500 e-posta gönderilemedi', () {
      expect(
        msg(
          const AuthErrorInfo(
            name: 'AuthRetryableFetchError',
            status: 500,
            message: 'Error sending confirmation email',
          ),
          AuthAction.signUp,
        ),
        contains('gönderilemedi'),
      );
    });

    test('503: sunucu yanıt vermiyor', () {
      expect(
        msg(const AuthErrorInfo(name: 'AuthRetryableFetchError', status: 503, message: 'HTTP 503')),
        contains('Sunucu şu an yanıt vermiyor'),
      );
    });
  });
}
