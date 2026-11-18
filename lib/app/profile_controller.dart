import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/profile/profile_repository.dart';
import 'providers.dart';
import 'session_controller.dart';

// UI katmanı veri katmanını içe aktaramaz; profil modeli buradan açılır.
export '../data/profile/profile_repository.dart' show Profile;

/// Önceden yüklenmiş tercihler; `main` içinde geçersiz kılınır (ağ beklemez).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider geçersiz kılınmalı'),
);

/// Yerel okumalar için oturum açmış kullanıcı (kullanıcı değişimi kontrolünden sonra dolar).
final signedInUserIdProvider = Provider<String?>(
  (ref) => ref.watch(sessionControllerProvider.select((s) => s.userId)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    ref.watch(databaseProvider),
    ref.watch(outboxProvider),
    fetchRemote: (userId) => ref.read(remoteGatewayProvider).fetchById('profiles', userId),
  ),
);

final profileProvider = StreamProvider<Profile?>((ref) {
  final userId = ref.watch(signedInUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watch(userId);
});

String onboardedFlagKey(String userId) => 'onboarded.$userId';

/// Yerel bayrak `onboarded.<userId>` ya da `profile.onboardingCompleted`.
final onboardedProvider = Provider<bool>((ref) {
  final userId = ref.watch(signedInUserIdProvider);
  if (userId == null) return false;
  final flag = ref.watch(sharedPreferencesProvider).getBool(onboardedFlagKey(userId)) ?? false;
  return flag || (ref.watch(profileProvider).value?.onboardingCompleted ?? false);
});

/// Oturumdaki kullanıcının profilini günceller (yerel satır + outbox). Profil yüklenmediyse
/// `ProfileNotReadyException` fırlar.
typedef ProfileUpdater = Future<void> Function(Profile Function(Profile) change);

final profileUpdaterProvider = Provider<ProfileUpdater>((ref) {
  return (change) async {
    final userId = ref.read(signedInUserIdProvider);
    if (userId == null) throw StateError('Oturum yok');
    await ref.read(profileRepositoryProvider).update(userId, change);
  };
});

/// Profil yerelde yok ve bu kullanıcı için ilk çekme henüz başarılamadı: yönlendirici
/// onboarding'e göndermek yerine açılış ekranında bekler (dönen kullanıcı korunur).
final awaitingFirstPullProvider = Provider<bool>((ref) {
  if (ref.watch(signedInUserIdProvider) == null) return false;
  if (ref.watch(sessionControllerProvider.select((s) => s.initialPullDone))) return false;
  return ref.watch(profileProvider.select((p) => p.value == null));
});

/// Açılış ekranında "Tekrar dene / Çıkış yap" gerektiren durum.
enum StartupProblem { userCheckFailed, firstPullFailed }

final startupProblemProvider = Provider<StartupProblem?>((ref) {
  final s = ref.watch(sessionControllerProvider);
  if (s.userCheckFailed) return StartupProblem.userCheckFailed;
  if (s.initialPullFailed && !s.syncing && ref.watch(awaitingFirstPullProvider)) {
    return StartupProblem.firstPullFailed;
  }
  return null;
});

/// Açılış ekranındaki "Tekrar dene"; testlerde değiştirilir.
final sessionRetryProvider = Provider<Future<void> Function()>(
  (ref) => ref.read(sessionControllerProvider.notifier).retry,
);
