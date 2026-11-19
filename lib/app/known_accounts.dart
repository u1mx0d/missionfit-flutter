import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_controller.dart';
import 'providers.dart';

const knownAccountsKey = 'known_accounts';
const _maxKnownAccounts = 5;

/// Bu telefonda daha önce giriş yapılmış bir hesabın sporcu kartı için yerel özeti.
class KnownAccount {
  const KnownAccount({
    required this.userId,
    required this.email,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.memberSince,
    required this.lastSignedInAt,
  });

  final String userId;
  final String email;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final DateTime? memberSince;
  final DateTime lastSignedInAt;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'email': email,
    'displayName': displayName,
    'username': username,
    'avatarUrl': avatarUrl,
    'memberSince': memberSince?.toUtc().toIso8601String(),
    'lastSignedInAt': lastSignedInAt.toUtc().toIso8601String(),
  };

  factory KnownAccount.fromJson(Map<dynamic, dynamic> j) => KnownAccount(
    userId: j['userId'] as String,
    email: j['email'] as String,
    displayName: j['displayName'] as String?,
    username: j['username'] as String?,
    avatarUrl: j['avatarUrl'] as String?,
    memberSince: DateTime.tryParse((j['memberSince'] as String?) ?? ''),
    lastSignedInAt: DateTime.parse(j['lastSignedInAt'] as String),
  );

  /// Tarih dışındaki alanlar aynı mı (gereksiz yazmayı önlemek için).
  bool sameContent(KnownAccount o) =>
      userId == o.userId &&
      email == o.email &&
      displayName == o.displayName &&
      username == o.username &&
      avatarUrl == o.avatarUrl &&
      memberSince == o.memberSince;
}

/// Telefonda kayıtlı kartlar: en çok 5, en son giriş en üstte. Yalnızca `remove` siler
/// (çıkış yapmak kartı silmez).
final knownAccountsProvider = NotifierProvider<KnownAccounts, List<KnownAccount>>(
  KnownAccounts.new,
);

class KnownAccounts extends Notifier<List<KnownAccount>> {
  @override
  List<KnownAccount> build() {
    final raw = ref.read(sharedPreferencesProvider).getString(knownAccountsKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return [for (final e in list) KnownAccount.fromJson(e as Map)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(List<KnownAccount> list) async {
    state = list;
    await ref
        .read(sharedPreferencesProvider)
        .setString(knownAccountsKey, jsonEncode([for (final a in list) a.toJson()]));
  }

  Future<void> upsert(KnownAccount a) =>
      _save([a, ...state.where((e) => e.userId != a.userId)].take(_maxKnownAccounts).toList());

  Future<void> remove(String userId) => _save([...state.where((e) => e.userId != userId)]);

  KnownAccount? match(String email) {
    final key = email.trim().toLowerCase();
    for (final a in state) {
      if (a.email == key) return a;
    }
    return null;
  }
}

/// Oturumdaki, tanışma bitmiş kullanıcıyı kayda geçirir; yalnızca dinler.
final knownAccountSyncProvider = Provider<void>((ref) {
  void sync() {
    if (!ref.read(onboardedProvider)) return;
    final profile = ref.read(profileProvider).value;
    final email = ref.read(currentUserEmailProvider);
    if (profile == null || email == null) return;
    final notifier = ref.read(knownAccountsProvider.notifier);
    final list = ref.read(knownAccountsProvider);
    final top = list.isEmpty ? null : list.first;
    final avatarPath = profile.avatarPath;
    final next = KnownAccount(
      userId: profile.userId,
      email: email.trim().toLowerCase(),
      displayName: profile.displayName,
      username: profile.username,
      avatarUrl: avatarPath == null
          ? null
          : ref.read(profileIdentityRepositoryProvider).publicUrl(avatarPath),
      memberSince: DateTime.tryParse(profile.createdAt)?.toUtc(),
      // Tarih yalnızca ilk yazımda ya da kullanıcı değişince yenilenir.
      lastSignedInAt: top != null && top.userId == profile.userId
          ? top.lastSignedInAt
          : DateTime.now(),
    );
    if (top != null && top.userId == next.userId && top.sameContent(next)) return;
    notifier.upsert(next);
  }

  ref.listen(profileProvider, (_, _) => sync());
  ref.listen(onboardedProvider, (_, _) => sync());
  ref.listen(currentUserEmailProvider, (_, _) => sync());
  sync();
});
