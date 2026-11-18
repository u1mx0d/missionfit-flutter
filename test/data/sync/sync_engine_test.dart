import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';
import 'package:missionfit/data/sync/sync_engine.dart';

import 'fake_remote_gateway.dart';

const user = '00000000-0000-0000-0000-0000000000aa';

String uid(int n) => '00000000-0000-0000-0000-${n.toString().padLeft(12, '0')}';

/// Sunucu biçiminde görev satırı (jsonb -> Map, boolean -> bool).
Map<String, Object?> serverTask(String id, {String title = 'Su iç'}) => {
  'id': id,
  'user_id': user,
  'title': title,
  'note': null,
  'time': null,
  'repeat_rule': {'type': 'daily'},
  'start_date': '2026-11-18',
  'default_task_id': null,
  'is_active': true,
  'created_at': '2026-11-18T09:00:00+00:00',
};

/// Yerel outbox biçiminde görev (SQL sütun adları, jsonb metin olarak).
Map<String, Object?> localTask(String id, {String title = 'Yerel'}) => {
  'id': id,
  'user_id': user,
  'title': title,
  'note': null,
  'time': null,
  'repeat_rule': '{"type":"once"}',
  'start_date': '2026-11-18',
  'default_task_id': null,
  'is_active': true,
  'created_at': '2026-11-18T09:00:00.000Z',
  'updated_at': '2026-11-18T09:00:00.000Z',
};

OutboxOp upsertOp(String opId, String table, Map<String, Object?> row) => OutboxOp(
  opId: opId,
  key: '$table:${row['id']}',
  type: '$table.upsert',
  payload: row,
  attempts: 0,
  createdAt: 1,
);

void main() {
  late AppDatabase db;
  late OutboxRepository outbox;
  late FakeRemoteGateway remote;
  late DateTime now;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    outbox = OutboxRepository(db);
    remote = FakeRemoteGateway();
    now = DateTime.utc(2026, 11, 18, 12);
    engine = SyncEngine(db, outbox, remote, clock: () => now);
  });
  tearDown(() => db.close());

  Future<List<String>> localTaskTitles() async => (await (db.select(
    db.tasks,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get()).map((t) => t.title).toList();

  group('push', () {
    test('push: başarıyla gönderilen işlem kuyruktan çıkar', () async {
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      final r = await engine.push();
      expect(r.pushed, 1);
      expect(r.dropped, 0);
      expect(await outbox.pending(), isEmpty);
      expect(remote.sent, ['tasks.upsert:${uid(1)}']);
      // Sunucuya giden satır: jsonb çözülmüş, updated_at sunucu tarafından damgalanır.
      final sentRow = remote.tables['tasks']![uid(1)]!;
      expect(sentRow['repeat_rule'], {'type': 'once'});
      expect(sentRow['is_active'], true);
    });

    test('push: 42501 hatası işlemi bırakır, dropped=1', () async {
      remote.failSend = (t, id) => id == uid(1) ? {'code': '42501', 'message': 'rls'} : null;
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      await outbox.enqueue(upsertOp('o2', 'tasks', localTask(uid(2))));
      final r = await engine.push();
      expect(r.dropped, 1);
      expect(r.droppedReasons.single, contains('42501'));
      expect(r.pushed, 1);
      expect(await outbox.pending(), isEmpty);
    });

    test('push: ağ hatası attempts\'i artırır ve sonraki işlemleri göndermez', () async {
      remote.failSend = (t, id) => id == uid(1) ? Exception('SocketException') : null;
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      await outbox.enqueue(upsertOp('o2', 'tasks', localTask(uid(2))));
      final r = await engine.push();
      expect(r.pushed, 0);
      expect(r.dropped, 0);
      expect(remote.sent, isEmpty);
      final pending = await outbox.pending();
      expect(pending.map((o) => [o.opId, o.attempts]).toList(), [
        ['o1', 1],
        ['o2', 0],
      ]);
    });

    test('push: attempts >= 15 olan işlem bırakılır', () async {
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      for (var i = 0; i < maxAttempts; i++) {
        await outbox.bump('o1');
      }
      final r = await engine.push();
      expect(r.dropped, 1);
      expect(remote.sent, isEmpty);
      expect(await outbox.pending(), isEmpty);
    });

    test('push: delete işlemi ve profiles anahtarı user_id', () async {
      await outbox.enqueue(
        const OutboxOp(
          opId: 'd1',
          key: 'tasks:x',
          type: 'tasks.delete',
          payload: {'id': 'x'},
          attempts: 0,
          createdAt: 1,
        ),
      );
      await outbox.enqueue(
        const OutboxOp(
          opId: 'p1',
          key: 'profiles:$user',
          type: 'profiles.upsert',
          payload: {
            'user_id': user,
            'display_name': 'Ayşe',
            'calorie_target_is_manual': 0,
            'notification_settings': '{"enabled":true}',
            'created_at': 'x',
            'updated_at': 'x',
          },
          attempts: 0,
          createdAt: 1,
        ),
      );
      final r = await engine.push();
      expect(r.pushed, 2);
      expect(remote.sent, ['tasks.delete:x', 'profiles.upsert:$user']);
      final p = remote.tables['profiles']![user]!;
      expect(p['calorie_target_is_manual'], false);
      expect(p['notification_settings'], {'enabled': true});
    });
  });

  group('pull', () {
    test('pull: updated_at imleci ilerler ve ikinci pull aynı satırları tekrar istemez', () async {
      remote.put('tasks', serverTask(uid(1)));
      remote.put('tasks', serverTask(uid(2)));
      final r1 = await engine.pull();
      expect(r1.pulled, 2);
      expect(await localTaskTitles(), ['Su iç', 'Su iç']);
      final local = await (db.select(db.tasks)..where((t) => t.id.equals(uid(1)))).getSingle();
      expect(local.repeatRule, '{"type":"daily"}');
      expect(local.isActive, true);

      final r2 = await engine.pull();
      expect(r2.pulled, 0);
      final taskFetches = remote.fetches.where((f) => f.table == 'tasks').toList();
      expect(taskFetches.last.since, isNotNull);
      expect(taskFetches.last.returned, 0);

      remote.put('tasks', serverTask(uid(1), title: 'Yeni'));
      final r3 = await engine.pull();
      expect(r3.pulled, 1);
      expect(await localTaskTitles(), ['Yeni', 'Su iç']);
    });

    test('pull: 1000\'den fazla satır sayfalanır', () async {
      for (var i = 0; i < 2500; i++) {
        remote.put('tasks', serverTask(uid(i)));
      }
      final r = await engine.pull();
      expect(r.pulled, 2500);
      expect(await db.select(db.tasks).get(), hasLength(2500));
      final pages = remote.fetches.where((f) => f.table == 'tasks').map((f) => f.returned);
      expect(pages.toList(), [1000, 1000, 500]);
    });

    test('pull: sayfa sınırında aynı updated_at taşıyan satırlar atlanmaz', () async {
      engine = SyncEngine(db, outbox, remote, clock: () => now, pageSize: 2);
      const same = '2026-11-18T10:00:00.5+00:00';
      for (var i = 1; i <= 5; i++) {
        remote.put('tasks', serverTask(uid(i)), updatedAt: same);
      }
      final r = await engine.pull();
      expect(r.pulled, 5);
      expect(await db.select(db.tasks).get(), hasLength(5));
      remote.put('tasks', serverTask(uid(6)), updatedAt: same); // aynı damga, daha büyük id
      expect((await engine.pull()).pulled, 1);
      expect((await engine.pull()).pulled, 0);
    });

    test('pull: outbox\'ta bekleyen satır sunucu sürümüyle ezilmez', () async {
      await db.batch((b) {
        b.insert(
          db.tasks,
          TasksCompanion.insert(
            id: uid(1),
            userId: user,
            title: 'Yerel',
            startDate: '2026-11-18',
            createdAt: 'x',
            updatedAt: 'x',
          ),
        );
      });
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      remote.put('tasks', serverTask(uid(1), title: 'Sunucu'));
      remote.put('tasks', serverTask(uid(2), title: 'Başka'));
      final r = await engine.pull();
      expect(r.pulled, 1);
      expect(await localTaskTitles(), ['Yerel', 'Başka']);
    });

    test('pull: deletions kaydı yerel satırı siler', () async {
      remote.put('tasks', serverTask(uid(1)));
      remote.put('tasks', serverTask(uid(2)));
      remote.put('tasks', serverTask(uid(3)));
      await engine.pull();
      remote.serverDelete('tasks', uid(1));
      remote.serverDelete('tasks', uid(2));
      // uid(2) için bekleyen yerel upsert var: silinmemeli.
      await outbox.enqueue(upsertOp('o2', 'tasks', localTask(uid(2))));
      await engine.pull();
      final ids = (await db.select(db.tasks).get()).map((t) => t.id).toList()..sort();
      expect(ids, [uid(2), uid(3)]);
      // İmleç ilerledi: aynı silme kayıtları tekrar uygulanmaz (uid(2) yeniden eklenip kalır).
      await outbox.remove('o2');
      await engine.pull();
      expect(await db.select(db.tasks).get(), hasLength(2));
    });

    test('pull: profiles satırı user_id anahtarıyla uygulanır, bilinmeyen sütun atılır', () async {
      remote.put('profiles', {
        'user_id': user,
        'display_name': 'Ayşe',
        'calorie_target_is_manual': true,
        'notification_settings': {'enabled': false},
        'units': 'kg',
        'unknown_future_column': 1,
        'created_at': '2026-11-18T09:00:00+00:00',
      });
      expect((await engine.pull()).pulled, 1);
      final p = await db.select(db.profiles).getSingle();
      expect(p.displayName, 'Ayşe');
      expect(p.calorieTargetIsManual, true);
      expect(p.notificationSettings, '{"enabled":false}');
    });

    test('pull: 90 günden eski imleç tam yeniden indirme yapar', () async {
      remote.put('tasks', serverTask(uid(1)));
      await engine.pull();
      // Sunucuda silinmiş ama silme kaydı budanmış satır yerelde kaldı.
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: uid(9),
              userId: user,
              title: 'Hayalet',
              startDate: '2026-11-18',
              createdAt: 'x',
              updatedAt: 'x',
            ),
          );
      now = now.add(const Duration(days: 91));
      final r = await engine.pull();
      expect(r.pulled, 1);
      expect(remote.fetches.where((f) => f.table == 'tasks').last.since, isNull);
      expect((await db.select(db.tasks).get()).map((t) => t.id), [uid(1)]);
    });

    test('pull: 90 günden yeni imleç tam indirme yapmaz', () async {
      remote.put('tasks', serverTask(uid(1)));
      await engine.pull();
      now = now.add(const Duration(days: 89));
      await engine.pull();
      expect(remote.fetches.where((f) => f.table == 'tasks').last.since, isNotNull);
    });
  });

  group('syncNow ve kataloglar', () {
    test('syncNow önce gönderir sonra çeker; eşzamanlı çağrı aynı çalışmayı kullanır', () async {
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      await Future.wait([engine.syncNow(), engine.syncNow()]);
      expect(remote.sent, ['tasks.upsert:${uid(1)}']);
      expect(await localTaskTitles(), ['Yerel']);
      expect(remote.fetches.where((f) => f.table == 'tasks'), hasLength(1));
      await engine.syncNow();
      expect(remote.fetches.where((f) => f.table == 'tasks'), hasLength(2));
    });

    test('downloadCatalogs: boşsa indirir, 7 gün içinde tekrar indirmez', () async {
      remote.catalogs['foods'] = [
        {
          'id': uid(1),
          'slug': 'elma',
          'name_tr': 'Elma',
          'name_search': 'elma',
          'category': 'fruit',
          'kcal_per_100g': 52,
          'protein_per_100g': 0.3,
          'carb_per_100g': 14,
          'fat_per_100g': 0.2,
          'default_serving_grams': 150,
          'serving_label': '1 orta boy',
          'source': 'seed',
          'created_at': '2026-11-01T00:00:00+00:00',
        },
      ];
      await engine.downloadCatalogs();
      expect((await db.select(db.foods).getSingle()).nameTr, 'Elma');
      final first = remote.catalogFetches;
      expect(first, greaterThan(0));

      now = now.add(const Duration(days: 6));
      await engine.downloadCatalogs();
      expect(remote.catalogFetches, first);

      now = now.add(const Duration(days: 2));
      remote.catalogs['foods']!.first['name_tr'] = 'Yeşil elma';
      await engine.downloadCatalogs();
      expect(remote.catalogFetches, greaterThan(first));
      expect((await db.select(db.foods).getSingle()).nameTr, 'Yeşil elma');
    });
  });
}
