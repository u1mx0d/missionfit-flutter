import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/env.dart';

void main() {
  const url = 'https://abcdefgh.supabase.co';
  const key = 'sb_publishable_abc123';

  test('fromMap: geçerli değerler okunur', () {
    final env = Env.fromMap({
      'SUPABASE_URL': url,
      'SUPABASE_PUBLISHABLE_KEY': key,
      'GOOGLE_WEB_CLIENT_ID': 'web-id.apps.googleusercontent.com',
    });
    expect(env.supabaseUrl, url);
    expect(env.supabasePublishableKey, key);
    expect(env.googleWebClientId, 'web-id.apps.googleusercontent.com');
  });

  test('fromMap: URL sonunda /rest/v1/ varsa FormatException', () {
    expect(
      () => Env.fromMap({'SUPABASE_URL': '$url/rest/v1/', 'SUPABASE_PUBLISHABLE_KEY': key}),
      throwsFormatException,
    );
  });

  test('fromMap: https olmayan URL FormatException', () {
    expect(
      () => Env.fromMap({'SUPABASE_URL': 'ftp://x.supabase.co', 'SUPABASE_PUBLISHABLE_KEY': key}),
      throwsFormatException,
    );
  });

  test('fromMap: boş anahtar FormatException', () {
    expect(
      () => Env.fromMap({'SUPABASE_URL': url, 'SUPABASE_PUBLISHABLE_KEY': ''}),
      throwsFormatException,
    );
  });

  test('fromMap: GOOGLE_WEB_CLIENT_ID boş olabilir (Google girişi kapalı sayılır)', () {
    final env = Env.fromMap({'SUPABASE_URL': url, 'SUPABASE_PUBLISHABLE_KEY': key});
    expect(env.googleWebClientId, '');
    expect(env.googleSignInEnabled, isFalse);
  });
}
