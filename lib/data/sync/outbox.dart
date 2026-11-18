import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'outbox_queue.dart';

/// Outbox'un drift üzerindeki kalıcı hâli. Dış bir `db.transaction` içinde de çağrılabilir
/// (aynı bağlantıyı kullanır), böylece yerel satır yazımı ile kuyruğa alma atomik olur.
class OutboxRepository {
  OutboxRepository(this._db);

  final AppDatabase _db;

  Future<void> enqueue(OutboxOp op) => _db.transaction(() async {
    final existing = await (_db.select(
      _db.outboxOps,
    )..where((t) => t.key.equals(op.key))).getSingleOrNull();
    if (existing != null) {
      // Aynı key: eski işlemin yerine geç, seq korunur, deneme sıfırlanır.
      await (_db.delete(_db.outboxOps)..where((t) => t.opId.equals(existing.opId))).go();
      await _db.into(_db.outboxOps).insert(_companion(op, existing.seq));
      return;
    }
    final maxSeq = _db.outboxOps.seq.max();
    final row = await (_db.selectOnly(_db.outboxOps)..addColumns([maxSeq])).getSingle();
    await _db.into(_db.outboxOps).insert(_companion(op, (row.read(maxSeq) ?? 0) + 1));
  });

  OutboxOpsCompanion _companion(OutboxOp op, int seq) => OutboxOpsCompanion.insert(
    opId: op.opId,
    key: op.key,
    type: op.type,
    payload: jsonEncode(op.payload),
    attempts: const Value(0),
    createdAt: op.createdAt,
    seq: seq,
  );

  Future<List<OutboxOp>> pending() async {
    final rows = await (_db.select(_db.outboxOps)..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    return rows
        .map(
          (r) => OutboxOp(
            opId: r.opId,
            key: r.key,
            type: r.type,
            payload: (jsonDecode(r.payload) as Map).cast<String, Object?>(),
            attempts: r.attempts,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  Future<void> remove(String opId) =>
      (_db.delete(_db.outboxOps)..where((t) => t.opId.equals(opId))).go();

  Future<void> bump(String opId) => _db.customUpdate(
    'UPDATE outbox_ops SET attempts = attempts + 1 WHERE op_id = ?',
    variables: [Variable<String>(opId)],
    updates: {_db.outboxOps},
  );

  Stream<int> pendingCount() {
    final count = _db.outboxOps.opId.count();
    return (_db.selectOnly(
      _db.outboxOps,
    )..addColumns([count])).watchSingle().map((r) => r.read(count) ?? 0);
  }
}
