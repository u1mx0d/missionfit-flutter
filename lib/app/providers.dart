import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/account/account_service.dart';
import '../data/auth/auth_repository.dart';
import '../data/auth/secure_local_storage.dart';
import '../data/db/database.dart';
import '../data/export/export_service.dart';
import '../data/notifications/notification_service.dart';
import '../data/profile/avatar_picker.dart';
import '../data/profile/profile_identity_repository.dart';
import '../data/sync/outbox.dart';
import '../data/sync/remote_gateway.dart';
import '../data/sync/sync_engine.dart';
import '../env.dart';

// UI katmanı veri katmanını doğrudan içe aktaramaz; hata türü buradan açılır.
export '../data/account/account_service.dart' show AccountService, DeleteAccountError;
export '../data/auth/auth_repository.dart' show AuthFailure, googleWrongAccountMessage;
export '../data/export/export_service.dart' show ExportResult, ExportService;
export '../data/notifications/notification_service.dart' show NotificationService, PermissionState;
export '../data/profile/avatar_picker.dart' show AvatarPicker, AvatarSource;
export '../data/profile/profile_identity_repository.dart'
    show IdentityError, IdentityFailure, ProfileIdentityRepository;
export '../data/profile/profile_repository.dart' show ProfileNotReadyException;

final envProvider = Provider<Env>((ref) => Env.fromEnvironment());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final keyValueStoreProvider = Provider<KeyValueStore>((ref) => const SecureKeyValueStore());

final outboxProvider = Provider<OutboxRepository>(
  (ref) => OutboxRepository(ref.watch(databaseProvider)),
);

final remoteGatewayProvider = Provider<RemoteGateway>(
  (ref) => SupabaseRemoteGateway(ref.watch(supabaseProvider)),
);

final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    ref.watch(databaseProvider),
    ref.watch(outboxProvider),
    ref.watch(remoteGatewayProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final env = ref.watch(envProvider);
  return AuthRepository(
    ref.watch(supabaseProvider).auth,
    google: GoogleSignInCredentialSource(env.googleWebClientId),
    googleEnabled: env.googleSignInEnabled,
  );
});

final authStateProvider = StreamProvider<Session?>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange.map((s) => s.session),
);

final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.user.id,
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(PluginNotificationsPlatform()),
);

/// Oturumdaki kullanıcının e-postası (yeniden doğrulama ve dışa aktarma için).
final currentUserEmailProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.user.email,
);

/// Şifre kimliği (e-posta) var mı; yoksa (yalnızca Google) şifre değiştirme gösterilmez.
/// Oturum her değiştiğinde yeniden okunur; yoksa önceki hesabın kimlikleri kalır.
final hasPasswordIdentityProvider = Provider<bool>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).hasPasswordIdentity;
});

/// Hesaba Google bağlı mı (hesap silmede şifre yerine seçilebilir). Oturumla yenilenir.
final hasGoogleIdentityProvider = Provider<bool>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).hasGoogleIdentity;
});

final profileIdentityRepositoryProvider = Provider<ProfileIdentityRepository>(
  (ref) => DefaultProfileIdentityRepository(
    SupabaseIdentityRemote(ref.watch(supabaseProvider)),
    ref.watch(databaseProvider),
  ),
);

final avatarPickerProvider = Provider<AvatarPicker>((ref) => DeviceAvatarPicker());

class GoogleProfile {
  const GoogleProfile({this.name, this.photoUrl});
  final String? name;
  final String? photoUrl;
}

/// Google kimliği varsa kullanıcının Google adı/fotoğrafı; yoksa null.
final googleProfileProvider = Provider<GoogleProfile?>((ref) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) return null;
  if (!(user.identities?.any((i) => i.provider == 'google') ?? false)) return null;
  final m = user.userMetadata ?? const {};
  String? str(String k) {
    final v = m[k];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  var name = str('full_name') ?? str('name');
  if (name != null && name.length > 40) name = name.substring(0, 40);
  return GoogleProfile(name: name, photoUrl: str('avatar_url') ?? str('picture'));
});

final accountServiceProvider = Provider<AccountService>(
  (ref) => SupabaseAccountService(ref.watch(supabaseProvider), ref.watch(databaseProvider)),
);

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(
    remote: ref.watch(remoteGatewayProvider),
    db: ref.watch(databaseProvider),
    sharer: const SharePlusFileSharer(),
    email: () => ref.read(currentUserEmailProvider),
  ),
);

/// Cihazın IANA saat dilimi (alınamazsa null).
final deviceTimezoneProvider = FutureProvider<String?>((ref) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {
    return null;
  }
});

/// Şifre sıfırlama gibi birden çok adımlı bir kimlik işlemi sürerken true: oturum açılsa da
/// yönlendirici kullanıcıyı bulunduğu kimlik ekranından çıkarmaz (sonuç ekranda gösterilir).
class AuthHold extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final authHoldProvider = NotifierProvider<AuthHold, bool>(AuthHold.new);
