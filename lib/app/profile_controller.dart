import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/profile/profile_repository.dart';
import 'providers.dart';
import 'session_controller.dart';

/// Önceden yüklenmiş tercihler; `main` içinde geçersiz kılınır (ağ beklemez).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider geçersiz kılınmalı'),
);

/// Yerel okumalar için oturum açmış kullanıcı (kullanıcı değişimi kontrolünden sonra dolar).
final signedInUserIdProvider = Provider<String?>(
  (ref) => ref.watch(sessionControllerProvider.select((s) => s.userId)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider), ref.watch(outboxProvider)),
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
