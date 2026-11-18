import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';

OutboxOp op(String opId, String key, [String type = 'x.upsert', Map<String, Object?>? p]) =>
    OutboxOp(
      opId: opId,
      key: key,
      type: type,
      payload: p ?? {'id': key},
      attempts: 0,
      createdAt: 1,
    );

void main() {
  test('aynı key\'e ikinci işlem sırayı korur', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final box = OutboxRepository(db);
    await box.enqueue(op('1', 'a'));
    await box.enqueue(op('2', 'b'));
    await box.bump('1');
    await box.enqueue(op('3', 'a', 'x.delete'));
    final list = await box.pending();
    expect(list.map((o) => [o.opId, o.type, o.attempts]).toList(), [
      ['3', 'x.delete', 0],
      ['2', 'x.upsert', 0],
    ]);
    await box.enqueue(op('4', 'c'));
    expect((await box.pending()).map((o) => o.opId).toList(), ['3', '2', '4']);
  });

  test('uygulama yeniden açılınca bekleyen işlemler okunur', () async {
    final dir = Directory.systemTemp.createTempSync('outbox');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/t.sqlite');
    final db1 = AppDatabase.forTesting(NativeDatabase(file));
    await OutboxRepository(db1).enqueue(op('1', 'a', 'x.upsert', {'id': 'a', 'n': 2}));
    await db1.close();
    final db2 = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db2.close);
    final list = await OutboxRepository(db2).pending();
    expect(list.single.opId, '1');
    expect(list.single.payload, {'id': 'a', 'n': 2});
  });

  test('remove, bump, pendingCount ve dış transaction içinde enqueue', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final box = OutboxRepository(db);
    final counts = <int>[];
    final sub = box.pendingCount().listen(counts.add);
    await db.transaction(() async {
      await box.enqueue(op('1', 'a'));
      await box.enqueue(op('2', 'b'));
    });
    await box.bump('1');
    expect((await box.pending()).first.attempts, 1);
    await box.remove('1');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(counts.last, 1);
    expect((await box.pending()).single.opId, '2');
  });
}
