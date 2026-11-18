import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth/auth_repository.dart';
import '../data/auth/secure_local_storage.dart';
import '../data/db/database.dart';
import '../data/sync/outbox.dart';
import '../data/sync/remote_gateway.dart';
import '../data/sync/sync_engine.dart';
import '../env.dart';

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
