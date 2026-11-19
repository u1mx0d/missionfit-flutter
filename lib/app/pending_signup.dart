import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_controller.dart' show sharedPreferencesProvider;

const pendingSignupKey = 'pending_signup_email';

/// Kaydı yapılıp kodu henüz girilmemiş e-posta. Cihazda saklanır: uygulama arka planda
/// sistem tarafından kapatılsa da kullanıcı koda geri dönebilir.
final pendingSignupEmailProvider = NotifierProvider<PendingSignup, String?>(PendingSignup.new);

class PendingSignup extends Notifier<String?> {
  @override
  String? build() => ref.read(sharedPreferencesProvider).getString(pendingSignupKey);

  Future<void> set(String email) async {
    state = email;
    await ref.read(sharedPreferencesProvider).setString(pendingSignupKey, email);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(sharedPreferencesProvider).remove(pendingSignupKey);
  }
}
