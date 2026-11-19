/// Türkçe arama için büyük/küçük harf ve aksan duyarsız anahtar. Saf Dart.
library;

const _fold = {
  'İ': 'i',
  'I': 'i',
  'ı': 'i',
  'Ş': 's',
  'ş': 's',
  'Ç': 'c',
  'ç': 'c',
  'Ğ': 'g',
  'ğ': 'g',
  'Ö': 'o',
  'ö': 'o',
  'Ü': 'u',
  'ü': 'u',
};

/// "ŞINAV", "şınav" ve "sinav" aynı anahtarı verir.
String turkishKey(String s) {
  final b = StringBuffer();
  for (final r in s.trim().runes) {
    final ch = String.fromCharCode(r);
    b.write(_fold[ch] ?? ch.toLowerCase());
  }
  return b.toString();
}

/// Türkçe büyük harf: "i" → "İ", "ı" → "I" (Dart'ın `toUpperCase`'i "i"yi "I" yapar).
String turkishUpper(String s) => s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
