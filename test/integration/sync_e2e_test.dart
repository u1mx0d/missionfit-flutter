// Yerel Supabase (Docker) üzerinde uçtan uca senkron testi. Varsayılan olarak atlanır.
//
// Çalıştırma (değerler `supabase status` çıktısından; yalnızca YEREL proje):
//   flutter test test/integration/sync_e2e_test.dart --dart-define=E2E=1 \
//     --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
//     --dart-define=SUPABASE_ANON_KEY=<ANON_KEY> \
//     --dart-define=SUPABASE_SERVICE_ROLE_KEY=<SERVICE_ROLE_KEY>
// Değerler ortam değişkenlerinden de okunur (aynı adlar). Anahtarlar depoya yazılmaz.
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';
import 'package:missionfit/data/sync/remote_gateway.dart';
import 'package:missionfit/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _e2e = String.fromEnvironment('E2E');

String _config(String name, String fromDefine) {
  final value = fromDefine.isNotEmpty ? fromDefine : (Platform.environment[name] ?? '');
  if (value.isEmpty) throw StateError('$name verilmedi (--dart-define ya da ortam değişkeni)');
  return value;
}

final _rand = Random.secure();

String _uuid() {
  final b = List<int>.generate(16, (_) => _rand.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

class _Device {
  _Device(this.client, this.userId) : db = AppDatabase.forTesting(NativeDatabase.memory()) {
    outbox = OutboxRepository(db);
  }

  final SupabaseClient client;
  final String userId;
  final AppDatabase db;
  late final OutboxRepository outbox;

  SyncEngine engine({int pageSize = 1000}) =>
      SyncEngine(db, outbox, SupabaseRemoteGateway(client), pageSize: pageSize);

  Future<void> upsert(String table, Map<String, Object?> row) => outbox.enqueue(
    OutboxOp(
      opId: _uuid(),
      key: '$table:${row[idColumn(table)]}',
      type: '$table.upsert',
      payload: row,
      attempts: 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ),
  );

  Map<String, Object?> task(String title) => {
    'id': _uuid(),
    'user_id': userId,
    'title': title,
    'note': null,
    'time': null,
    'repeat_rule': '{"type":"daily"}',
    'start_date': '2026-11-18',
    'default_task_id': null,
    'is_active': 1,
    'created_at': DateTime.now().toUtc().toIso8601String(),
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };

  Future<List<Task>> tasks() => db.select(db.tasks).get();
}

void main() {
  late String url;
  late String anonKey;
  late SupabaseClient admin;
  final createdUsers = <String>[];
  final devices = <_Device>[];

  Future<_Device> newUser(String label) async {
    final email = 'sync-e2e-$label-${_uuid()}@example.test';
    const password = 'e2e-Password-123!';
    final created = await admin.auth.admin.createUser(
      AdminUserAttributes(email: email, password: password, emailConfirm: true),
    );
    createdUsers.add(created.user!.id);
    final client = SupabaseClient(
      url,
      anonKey,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await client.auth.signInWithPassword(email: email, password: password);
    final device = _Device(client, created.user!.id);
    devices.add(device);
    return device;
  }

  setUpAll(() {
    if (_e2e != '1') return;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true; // her cihaz ayrı bellek içi db
    url = _config('SUPABASE_URL', const String.fromEnvironment('SUPABASE_URL'));
    final host = Uri.parse(url).host;
    if (host != '127.0.0.1' && host != 'localhost') {
      throw StateError('E2E yalnızca yerel Supabase ile çalışır: $url');
    }
    anonKey = _config('SUPABASE_ANON_KEY', const String.fromEnvironment('SUPABASE_ANON_KEY'));
    admin = SupabaseClient(
      url,
      _config(
        'SUPABASE_SERVICE_ROLE_KEY',
        const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY'),
      ),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
  });

  tearDownAll(() async {
    if (_e2e != '1') return;
    for (final d in devices) {
      await d.db.close();
    }
    for (final client in devices.map((d) => d.client).toSet()) {
      await client.dispose();
    }
    for (final id in createdUsers) {
      await admin.auth.admin.deleteUser(id);
      // auth.users'a FK'sız silme kayıtlarını da temizle.
      await admin.from('deletions').delete().eq('user_id', id);
    }
    await admin.dispose();
  });

  test(
    'iki kullanıcı: yalıtım, silme kaydı, aynı damga sayfalama, profil ve değişmez tablolar',
    () async {
      final a = await newUser('a');
      final b = await newUser('b');

      // A yazar ve gönderir.
      final t1 = a.task('A görev 1');
      final t2 = a.task('A görev 2');
      final t3 = a.task('A görev 3');
      for (final t in [t1, t2, t3]) {
        await a.upsert('tasks', t);
      }
      final foodId = (await admin.from('foods').select('id').limit(1).single())['id'] as String;
      final fav = {
        'id': _uuid(),
        'user_id': a.userId,
        'food_id': foodId,
        'custom_food_id': null,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await a.upsert('favorite_foods', fav);
      await a.upsert('profiles', {
        'user_id': a.userId,
        'display_name': 'Ayşe',
        'calorie_target_is_manual': 0,
        'notification_settings': '{"enabled": false, "task_lead_minutes": 5}',
        'theme_family': 'mono',
        'created_at': 'yerel',
        'updated_at': 'yerel',
      });
      final pushed = await a.engine().push();
      expect(pushed.droppedReasons, isEmpty);
      expect(pushed.pushed, 5);

      // Değişmez tabloya aynı işlem tekrar gönderilebilir (ignoreDuplicates).
      await a.upsert('favorite_foods', fav);
      expect((await a.engine().push()).dropped, 0);

      final serverProfile = await admin.from('profiles').select().eq('user_id', a.userId).single();
      expect(serverProfile['display_name'], 'Ayşe');
      expect(serverProfile['notification_settings'], {'enabled': false, 'task_lead_minutes': 5});

      // A çeker: kendi satırları gelir (sunucu updated_at'iyle).
      await a.engine().syncNow();
      expect((await a.tasks()).map((t) => t.title).toSet(), {
        'A görev 1',
        'A görev 2',
        'A görev 3',
      });
      expect((await a.db.select(a.db.profiles).getSingle()).displayName, 'Ayşe');
      expect(await a.db.select(a.db.favoriteFoods).get(), hasLength(1));

      // B, A'nın verisini görmez.
      await b.engine().syncNow();
      expect(await b.tasks(), isEmpty);
      expect(await b.db.select(b.db.favoriteFoods).get(), isEmpty);
      final bProfiles = await b.db.select(b.db.profiles).get();
      expect(bProfiles.map((p) => p.userId), [b.userId]);

      // Aynı updated_at: tek UPDATE ifadesi tüm satırlara aynı now() damgasını verir.
      await admin.from('tasks').update({'note': 'aynı damga'}).eq('user_id', a.userId);
      final stamps = await admin.from('tasks').select('updated_at').eq('user_id', a.userId);
      expect(stamps.map((r) => r['updated_at']).toSet(), hasLength(1));
      final fresh = _Device(a.client, a.userId);
      devices.add(fresh);
      final pulled = await fresh.engine(pageSize: 2).pull();
      expect(pulled.pulled, 3 + 1 + 1); // 3 görev + profil + favori
      expect((await fresh.tasks()).map((t) => t.note).toSet(), {'aynı damga'});
      expect((await fresh.engine(pageSize: 2).pull()).pulled, 0);

      // Sunucuda silinen satır (deletions tetikleyicisi) A'nın yerelinden kalkar.
      await admin.from('tasks').delete().eq('id', t1['id']!);
      final deletions = await a.client.from('deletions').select().eq('row_id', t1['id']!);
      expect(deletions, hasLength(1));
      await a.engine().syncNow();
      expect((await a.tasks()).map((t) => t.id).toSet(), {t2['id'], t3['id']});

      // Kataloglar indirilir (name_search atılır).
      await a.engine().downloadCatalogs();
      expect(await a.db.select(a.db.foods).get(), isNotEmpty);
      expect(await a.db.select(a.db.exercises).get(), isNotEmpty);

      // CHECK ihlali (23514) kalıcıdır: işlem bırakılır, syncNow nedeni döndürür ve yerel
      // satır sunucudaki sürüme döner (t2 için eski başlık).
      await a.upsert('tasks', {...t2, 'title': 'x' * 200});
      final dropped = await a.engine().syncNow();
      expect(dropped.dropped, 1);
      expect(dropped.droppedReasons.single, contains('23514'));
      final t2Local = await (a.db.select(
        a.db.tasks,
      )..where((t) => t.id.equals(t2['id']! as String))).getSingle();
      expect(t2Local.title, 'A görev 2');
    },
    skip: _e2e == '1' ? false : 'E2E=1 verilmedi (yerel Supabase gerekir)',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
