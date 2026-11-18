import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/username.dart';

void main() {
  group('normalizeUsername', () {
    test('Türkçe harfleri çevirir, küçültür, kırpar', () {
      expect(normalizeUsername('Şükrü.K '), 'sukru.k');
      expect(normalizeUsername('İLKER'), 'ilker');
      expect(normalizeUsername('ÇAĞLA_Öz'), 'cagla_oz');
    });

    test('geçersiz karakterleri silmez', () {
      expect(normalizeUsername('a b!'), 'a b!');
    });
  });

  group('validateUsername', () {
    test('kısa', () => expect(validateUsername('ab'), 'En az 3 karakter.'));
    test('uzun', () => expect(validateUsername('a' * 21), 'En fazla 20 karakter.'));
    test('geçersiz karakter', () {
      expect(validateUsername('a b'), 'Yalnızca harf, rakam, _ ve . kullanılabilir.');
      expect(validateUsername('Alp'), 'Yalnızca harf, rakam, _ ve . kullanılabilir.');
    });
    test('ayrılmış', () {
      for (final r in reservedUsernames) {
        expect(validateUsername(r), 'Bu kullanıcı adı kullanılamaz.');
      }
      expect(reservedUsernames, {
        'admin',
        'missionfit',
        'support',
        'destek',
        'root',
        'null',
        'system',
      });
    });
    test('geçerli', () {
      expect(validateUsername('alp_34.x'), isNull);
      expect(validateUsername('a' * 20), isNull);
    });
  });

  group('usernameBase', () {
    test('addan', () => expect(usernameBase(fullName: 'Alperen Dağtekin'), 'alperendagtekin'));
    test('Latin dışı ad → sporcu', () => expect(usernameBase(fullName: '李 🙂'), 'sporcu'));
    test('e-postadan', () => expect(usernameBase(email: 'ali.k@x.com'), 'ali.k'));
    test('ad kısa ise e-posta', () {
      expect(usernameBase(fullName: '李', email: 'zeynep@x.com'), 'zeynep');
    });
    test('20 karaktere keser', () {
      expect(usernameBase(fullName: 'Muhammed Abdurrahman Yılmaz'), 'muhammedabdurrahmany');
    });
    test('hiçbiri yok → sporcu', () => expect(usernameBase(), 'sporcu'));
    test('ayrılmış ad önerilmez', () => expect(usernameBase(fullName: 'Admin'), 'sporcu'));
    test('sonuç her zaman geçerli', () {
      for (final n in ['Alperen Dağtekin', '李 🙂', '..', 'admin']) {
        final b = usernameBase(fullName: n);
        expect(validateUsername(b), isNull, reason: n);
      }
    });
  });

  group('usernameWithSuffix', () {
    test('20 karakteri geçmez', () {
      expect(usernameWithSuffix('a' * 20, 7), '${'a' * 18}07');
    });
    test('kısa tabana ekler', () => expect(usernameWithSuffix('alp', 42), 'alp42'));
  });

  group('validateDisplayName', () {
    test('boş', () => expect(validateDisplayName('  '), 'Adını yaz.'));
    test('uzun', () => expect(validateDisplayName('a' * 41), 'En fazla 40 karakter.'));
    test('kırpılmış 40 geçerli', () => expect(validateDisplayName(' ${'a' * 40} '), isNull));
  });

  group('initialsFor', () {
    test('iki kelime', () => expect(initialsFor(displayName: 'alperen dağtekin'), 'AD'));
    test('üç kelime → ilk iki', () => expect(initialsFor(displayName: 'a b c'), 'AB'));
    test('tek kelime', () => expect(initialsFor(displayName: 'ilker'), 'İ'));
    test('kullanıcı adından', () => expect(initialsFor(username: 'zed'), 'Z'));
    test('boş ad → kullanıcı adı', () {
      expect(initialsFor(displayName: '  ', username: 'zed'), 'Z');
    });
    test('hiçbiri', () => expect(initialsFor(), '?'));
  });

  group('googlePhotoAt512', () {
    test('boyutu değiştirir', () {
      expect(googlePhotoAt512('https://x/a=s96-c'), 'https://x/a=s512-c');
    });
    test('kalıp yoksa aynen', () => expect(googlePhotoAt512('https://x/a.jpg'), 'https://x/a.jpg'));
  });
}
