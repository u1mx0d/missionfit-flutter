import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';
import 'package:missionfit/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

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

  group('bırakılan işlemler', () {
    Future<void> insertLocal(String id, String title) => db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: id,
            userId: user,
            title: title,
            startDate: '2026-11-18',
            createdAt: 'x',
            updatedAt: 'x',
          ),
        );

    test('syncNow: kalıcı hata droppedReasons ile döner', () async {
      remote.failSend = (t, id) => id == uid(1) ? {'code': '23514', 'message': 'check'} : null;
      remote.put('tasks', serverTask(uid(5)));
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      await outbox.enqueue(upsertOp('o2', 'tasks', localTask(uid(2))));
      final results = await Future.wait([engine.syncNow(), engine.syncNow()]);
      final r = results.first;
      expect(identical(results.first, results.last), isTrue);
      expect(r.pushed, 1);
      expect(r.dropped, 1);
      expect(r.droppedReasons.single, contains('23514'));
      expect(r.pulled, 2); // uid(2) sunucu sürümü + uid(5)
    });

    test('drop sonrası satır sunucudaki sürüme döner', () async {
      remote.put('tasks', serverTask(uid(1), title: 'Sunucu'));
      await insertLocal(uid(1), 'Yerel');
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      await engine.pull(); // bekleyen işlem yüzünden atlanır, imleç ilerler
      expect(await localTaskTitles(), ['Yerel']);
      remote.failSend = (t, id) => {'code': '23514', 'message': 'check'};
      final r = await engine.push();
      expect(r.dropped, 1);
      expect(await localTaskTitles(), ['Sunucu']);
      final local = await db.select(db.tasks).getSingle();
      expect(local.repeatRule, '{"type":"daily"}');
    });

    test('drop sonrası sunucuda yoksa yerelden silinir', () async {
      await insertLocal(uid(1), 'Yerel');
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      remote.failSend = (t, id) => {'code': '42501', 'message': 'rls'};
      final r = await engine.push();
      expect(r.dropped, 1);
      expect(await db.select(db.tasks).get(), isEmpty);
    });

    test('drop sonrası yeniden çekme başarısızsa yerel satır kalır ve push hata atmaz', () async {
      await insertLocal(uid(1), 'Yerel');
      await outbox.enqueue(upsertOp('o1', 'tasks', localTask(uid(1))));
      remote.failSend = (t, id) => {'code': '42501', 'message': 'rls'};
      remote.failFetchById = Exception('SocketException');
      final r = await engine.push();
      expect(r.dropped, 1);
      expect(r.droppedReasons.single, contains('eşitlenemedi'));
      expect(await localTaskTitles(), ['Yerel']);
    });
  });

  group('başka telefonda açık kalan aktif oturum', () {
    const ts = '2026-11-18T11:00:00.000Z';
    final sessionId = uid(10), setId = uid(11), otherId = uid(9);

    Map<String, Object?> sessionPayload() => {
      'id': sessionId,
      'user_id': user,
      'template_id': null,
      'name': 'Antrenman',
      'started_at': ts,
      'ended_at': null,
      'local_date': '2026-11-18',
      'week_key': '2026-11-16',
      'estimated_kcal': null,
      'status': 'active',
    };

    Map<String, Object?> setPayload() => {
      'id': setId,
      'session_id': sessionId,
      'user_id': user,
      'exercise_id': uid(20),
      'exercise_order': 0,
      'set_index': 1,
      'reps': 10,
      'duration_seconds': null,
      'weight_kg': 40.0,
      'completed_at': ts,
    };

    Future<void> seedLocal() async {
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: sessionId,
              userId: user,
              startedAt: ts,
              localDate: '2026-11-18',
              weekKey: '2026-11-16',
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await outbox.enqueue(upsertOp('o1', 'workout_sessions', sessionPayload()));
      await outbox.enqueue(upsertOp('o2', 'session_sets', setPayload()));
      // Sunucuda başka telefondan açık kalmış, yerele henüz çekilmemiş aktif oturum.
      remote.put('workout_sessions', {
        'id': otherId,
        'user_id': user,
        'status': 'active',
        'started_at': '2026-11-18T08:00:00+00:00',
        'ended_at': null,
      });
    }

    PostgrestException uniqueViolation() => const PostgrestException(
      message:
          'duplicate key value violates unique constraint '
          '"workout_sessions_one_active_per_user_idx"',
      code: '23505',
    );

    test('23505: diğer aktif oturum abandoned yapılır, işlem yeniden denenir', () async {
      await seedLocal();
      var failures = 0;
      remote.failSend = (t, id) =>
          t == 'workout_sessions' && id == sessionId && failures++ == 0 ? uniqueViolation() : null;

      final r = await engine.push();

      expect(r.pushed, 2);
      expect(r.dropped, 0);
      expect(remote.abandonCalls.single.userId, user);
      expect(remote.abandonCalls.single.keepId, sessionId);
      expect(remote.abandonCalls.single.endedAt, '2026-11-18T12:00:00.000Z');
      expect(remote.tables['workout_sessions']![otherId]!['status'], 'abandoned');
      expect(remote.sent, ['workout_sessions.upsert:$sessionId', 'session_sets.upsert:$setId']);
      expect(await outbox.pending(), isEmpty);
      final local = await db.select(db.workoutSessions).getSingle();
      expect(local.id, sessionId);
      expect(local.status, 'active');
    });

    test('yeniden deneme de 23505 verirse olağan kalıcı hata yolu işler', () async {
      await seedLocal();
      remote.failSend = (t, id) =>
          t == 'workout_sessions' && id == sessionId ? uniqueViolation() : null;

      final r = await engine.push();

      expect(remote.abandonCalls, hasLength(1));
      expect(r.dropped, 1);
      expect(r.droppedReasons.single, contains('workout_sessions.upsert'));
      // Sunucuda yok -> yerelden silinir (bugünkü kalıcı hata davranışı).
      expect(
        await (db.select(db.workoutSessions)..where((t) => t.id.equals(sessionId))).get(),
        isEmpty,
      );
      expect(remote.sent, ['session_sets.upsert:$setId']);
    });

    test('active olmayan oturumda 23505 kurtarma denenmez', () async {
      await outbox.enqueue(
        upsertOp('o1', 'workout_sessions', {
          ...sessionPayload(),
          'status': 'completed',
          'ended_at': ts,
        }),
      );
      remote.failSend = (t, id) => uniqueViolation();
      final r = await engine.push();
      expect(remote.abandonCalls, isEmpty);
      expect(r.dropped, 1);
    });
  });
}
