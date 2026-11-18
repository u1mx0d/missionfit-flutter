/// Derleme zamanında `--dart-define-from-file=env.json` ile verilen ortam değişkenleri.
///
/// `env.json` git dışındadır; şablon `env.example.json`. İstemcide yalnızca publishable key bulunur.
class Env {
  const Env({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.googleWebClientId,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;

  /// Boşsa "Google ile devam et" düğmesi gizlenir.
  final String googleWebClientId;

  bool get googleSignInEnabled => googleWebClientId.isNotEmpty;

  /// Değerleri doğrular; geçersizse [FormatException] fırlatır.
  static Env fromMap(Map<String, String> m) {
    final url = (m['SUPABASE_URL'] ?? '').trim();
    final key = (m['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();
    final google = (m['GOOGLE_WEB_CLIENT_ID'] ?? '').trim();

    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('SUPABASE_URL https ile başlayan geçerli bir adres olmalı.');
    }
    // RN kuralı: kök adres olmalı (/rest/v1/ gibi bir yol içermemeli).
    if (uri.path.isNotEmpty && uri.path != '/') {
      throw const FormatException('SUPABASE_URL kök adres olmalı (/rest/v1/ olmadan).');
    }
    if (key.isEmpty) {
      throw const FormatException('SUPABASE_PUBLISHABLE_KEY boş olamaz.');
    }
    return Env(supabaseUrl: url, supabasePublishableKey: key, googleWebClientId: google);
  }

  static Env fromEnvironment() => fromMap(const {
    'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_PUBLISHABLE_KEY': String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    'GOOGLE_WEB_CLIENT_ID': String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  });
}
