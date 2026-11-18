/// Kullanıcı adı ve görünen ad kuralları (saf Dart). Sunucu aynı kuralları
/// `set_username` RPC'sinde tekrar uygular; benzersizliği yalnızca sunucu garanti eder.
library;

const reservedUsernames = {'admin', 'missionfit', 'support', 'destek', 'root', 'null', 'system'};

const _minLength = 3;
const _maxLength = 20;
const _displayNameMax = 40;
const _fallbackBase = 'sporcu';

final _valid = RegExp(r'^[a-z0-9_.]+$');
final _invalidChars = RegExp(r'[^a-z0-9_.]');

const _turkish = {
  'ç': 'c',
  'Ç': 'c',
  'ğ': 'g',
  'Ğ': 'g',
  'ı': 'i',
  'I': 'i',
  'İ': 'i',
  'ö': 'o',
  'Ö': 'o',
  'ş': 's',
  'Ş': 's',
  'ü': 'u',
  'Ü': 'u',
};

/// Kırpar, Türkçe harfleri çevirir, küçültür. Geçersiz karakterleri silmez; onları
/// [validateUsername] bildirir.
String normalizeUsername(String input) {
  final b = StringBuffer();
  for (final ch in input.trim().split('')) {
    b.write(_turkish[ch] ?? ch.toLowerCase());
  }
  return b.toString();
}

/// Normalleştirilmiş ad geçerliyse null, değilse arayüzde gösterilecek mesaj.
String? validateUsername(String normalized) {
  if (normalized.length < _minLength) return 'En az $_minLength karakter.';
  if (normalized.length > _maxLength) return 'En fazla $_maxLength karakter.';
  if (!_valid.hasMatch(normalized)) return 'Yalnızca harf, rakam, _ ve . kullanılabilir.';
  if (reservedUsernames.contains(normalized)) return 'Bu kullanıcı adı kullanılamaz.';
  return null;
}

String _slug(String s) {
  final cleaned = normalizeUsername(s).replaceAll(_invalidChars, '');
  return cleaned.length > _maxLength ? cleaned.substring(0, _maxLength) : cleaned;
}

/// Öneri tabanı: addan, olmazsa e-postanın `@` öncesinden; ikisi de geçerli bir ad
/// vermezse `sporcu`. Sonuç her zaman [validateUsername]'den geçer.
String usernameBase({String? fullName, String? email}) {
  final candidates = [?fullName, ?email?.split('@').first];
  for (final c in candidates) {
    final s = _slug(c);
    if (validateUsername(s) == null) return s;
  }
  return _fallbackBase;
}

/// Taban alınmışsa denenecek ad: taban 18 karaktere kesilir, iki haneli sayı eklenir.
String usernameWithSuffix(String base, int n) {
  final head = base.length > _maxLength - 2 ? base.substring(0, _maxLength - 2) : base;
  return '$head${(n % 100).toString().padLeft(2, '0')}';
}

String? validateDisplayName(String input) {
  final t = input.trim();
  if (t.isEmpty) return 'Adını yaz.';
  if (t.length > _displayNameMax) return 'En fazla $_displayNameMax karakter.';
  return null;
}

String _upperTr(String ch) => switch (ch) {
  'i' => 'İ',
  'ı' => 'I',
  _ => ch.toUpperCase(),
};

/// Avatar için baş harfler: görünen addan en çok 2, yoksa kullanıcı adının ilk harfi, yoksa `?`.
String initialsFor({String? displayName, String? username}) {
  final words = (displayName ?? '').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isNotEmpty) {
    return words.take(2).map((w) => _upperTr(String.fromCharCode(w.runes.first))).join();
  }
  final u = (username ?? '').trim();
  if (u.isNotEmpty) return _upperTr(String.fromCharCode(u.runes.first));
  return '?';
}

final _googleSize = RegExp(r'=s\d+-c$');

/// Google profil fotoğrafı URL'sini 512 px kare sürüme çevirir (`=s96-c` → `=s512-c`).
String googlePhotoAt512(String url) => url.replaceFirst(_googleSize, '=s512-c');
