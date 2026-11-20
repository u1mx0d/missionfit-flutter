import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'outbox.dart';
import 'outbox_queue.dart';
import 'remote_gateway.dart';

/// Bir gönderme/çekme turunun özeti.
class SyncResult {
  SyncResult({this.pushed = 0, this.dropped = 0, this.pulled = 0, List<String>? droppedReasons})
    : droppedReasons = droppedReasons ?? [];

  int pushed;
  int dropped;

  /// Yerele uygulanan sunucu satırı sayısı (silme kayıtları hariç).
  int pulled;
  final List<String> droppedReasons;
}

/// Yerel öncelikli senkron: drift doğruluğun kaynağıdır, Supabase arka plan yedeğidir.
///
/// Outbox yükü sözleşmesi: upsert yükü yerel satırın SQL sütun adlarıyla (snake_case) tam
/// hâlidir (jsonb metin, boolean bool ya da 0/1 olabilir); delete yükü `{'id': ...}`
/// (`profiles` için id = user_id).
///
/// Çekme imleci `table_name` başına `sync_cursors` satırıdır: `"<updated_at>|<id>"`. updated_at
/// sunucunun ISO metnidir (aynen geri gönderilir). Sorgu `(updated_at, id) > imleç` anahtar
/// kümesidir; böylece sayfa sınırında aynı damgayı paylaşan satırlar atlanmaz ve tekrar gelmez.
/// `deletions` imleci identity `id`'dir.
class SyncEngine {
  SyncEngine(
    this._db,
    this._outbox,
    this._remote, {
    DateTime Function()? clock,
    this.pageSize = 1000,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final RemoteGateway _remote;
  final DateTime Function() _clock;
  final int pageSize;

  static const staleCursorAge = Duration(days: 90);
  static const catalogMaxAge = Duration(days: 7);
  static const _deletionsCursor = 'deletions';
  static const _catalogMarker = 'catalogs';

  /// sqlite'ta metin olarak saklanan jsonb sütunları.
  static const _jsonColumns = {'notification_settings', 'repeat_rule'};

  Future<SyncResult>? _running;

  /// Önce gönderir, sonra çeker. Çalışırken gelen çağrı aynı çalışmanın bitmesini bekler.
  /// Gönderme ve çekme sonuçlarının birleşimini döndürür (bırakılan işlemler
  /// `droppedReasons`'ta; kullanıcıya bildirilmeli). Eşzamanlı çağıranlar aynı sonucu alır.
  Future<SyncResult> syncNow() => _running ??= _syncOnce().whenComplete(() => _running = null);

  Future<SyncResult> _syncOnce() async {
    final result = await push();
    result.pulled += (await pull()).pulled;
    return result;
  }

  // --- Gönderme --------------------------------------------------------------------------

  Future<SyncResult> push() async {
    final result = SyncResult();
    for (final op in await _outbox.pending()) {
      if (op.attempts >= maxAttempts) {
        await _drop(op, result, '$maxAttempts denemede gönderilemedi');
        continue;
      }
      try {
        await _sendRecovering(op);
      } catch (e) {
        if (e is! _RecoveryFailed && (e is _UnsupportedOp || isPermanentError(e))) {
          await _drop(op, result, _describe(e));
          continue;
        }
        // Geçici hata (ağ, 5xx, JWT): sıra korunur, sonraki işlemler bekler.
        if (op.attempts + 1 >= maxAttempts) {
          await _drop(op, result, '$maxAttempts denemede gönderilemedi: ${_describe(e)}');
        } else {
          await _outbox.bump(op.opId);
        }
        break;
      }
      await _outbox.remove(op.opId);
      result.pushed++;
    }
    return result;
  }

  Future<void> _drop(OutboxOp op, SyncResult result, String reason) async {
    await _outbox.remove(op.opId);
    result.dropped++;
    final note = await _resyncRow(op);
    result.droppedReasons.add('${op.type} ${op.key}: $reason${note == null ? '' : ' ($note)'}');
  }

  /// Bırakılan işlemin satırını sunucudaki sürüme döndürür: bekleyen işlem yüzünden pull
  /// sunucu sürümünü atlamış ve imleci ilerletmiş olabilir. Sunucuda yoksa yerelden silinir.
  /// Yeniden çekme başarısızsa yerel satır kalır; dönen not nedenine eklenir.
  Future<String?> _resyncRow(OutboxOp op) async {
    final colon = op.key.indexOf(':');
    if (colon < 0) return null;
    final table = op.key.substring(0, colon);
    final id = op.key.substring(colon + 1);
    if (!syncTables.contains(table)) return null;
    final Map<String, Object?>? row;
    try {
      row = await _remote.fetchById(table, id);
    } catch (e) {
      return 'yerel satır sunucuyla eşitlenemedi: ${_describe(e)}';
    }
    final info = _table(table);
    await _db.transaction(() async {
      // Bu arada aynı key'e yeni bir yerel değişiklik geldiyse ona dokunma.
      if ((await _pendingKeys()).contains(op.key)) return;
      if (row != null) {
        await _apply(info, row);
      } else {
        await _db.customUpdate(
          'DELETE FROM "$table" WHERE "${idColumn(table)}" = ?',
          variables: [Variable<String>(id)],
          updates: {info},
          updateKind: UpdateKind.delete,
        );
      }
    });
    return null;
  }

  String _describe(Object e) {
    if (e is Map) return '${e['code']} ${e['message'] ?? ''}'.trim();
    return e.toString();
  }

  /// [_send]; aktif oturum yazımı "kullanıcı başına tek aktif" benzersizliğine (23505)
  /// takılırsa sunucudaki diğer aktif oturumlar (ör. başka telefonda açık kalmış, henüz
  /// çekilmemiş) `abandoned` yapılır ve işlem bir kez yeniden denenir. Yeniden deneme de
  /// başarısızsa hata olağan yoldan (kalıcı/geçici) işlenir. Yerel kopya sonraki çekmede eşitlenir.
  /// Kurtarmanın kendisi (diğer oturumları kapatma) başarısız olursa (ör. saat kayması, 23514)
  /// işlem kalıcı hata sayılmaz: bırakılırsa yerel antrenman silinirdi. Geçici sayılır, kalır.
  Future<void> _sendRecovering(OutboxOp op) async {
    try {
      await _send(op);
    } catch (e) {
      final p = op.payload;
      final userId = p['user_id'], id = p['id'];
      if (op.type != 'workout_sessions.upsert' ||
          p['status'] != 'active' ||
          errorCode(e) != '23505' ||
          userId is! String ||
          id is! String) {
        rethrow;
      }
      try {
        await _remote.abandonOtherActiveSessions(
          userId: userId,
          keepId: id,
          endedAt: _clock().toUtc().toIso8601String(),
        );
      } catch (abandonError) {
        throw _RecoveryFailed(abandonError);
      }
      await _send(op);
    }
  }

  Future<void> _send(OutboxOp op) async {
    final dot = op.type.lastIndexOf('.');
    final table = dot < 0 ? '' : op.type.substring(0, dot);
    final action = dot < 0 ? '' : op.type.substring(dot + 1);
    if (!syncTables.contains(table)) throw _UnsupportedOp(op.type);
    switch (action) {
      case 'upsert':
        await _remote.upsert(table, _toRemote(table, op.payload));
      case 'delete':
        final id = op.payload['id'] ?? op.payload[idColumn(table)];
        if (id is! String) throw _UnsupportedOp('${op.type} id yok');
        await _remote.delete(table, id);
      default:
        throw _UnsupportedOp(op.type);
    }
  }

  /// Yerel yük -> sunucu satırı: bilinmeyen sütunlar atılır, jsonb metni çözülür, 0/1 -> bool.
  Map<String, Object?> _toRemote(String table, Map<String, Object?> payload) {
    final columns = {for (final c in _table(table).$columns) c.name: c};
    final out = <String, Object?>{};
    payload.forEach((key, value) {
      final column = columns[key];
      if (column == null) return;
      if (value is String && _jsonColumns.contains(key)) {
        out[key] = jsonDecode(value);
      } else if (value is int && column.type == DriftSqlType.bool) {
        out[key] = value != 0;
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  // --- Çekme -----------------------------------------------------------------------------

  Future<SyncResult> pull() async {
    final result = SyncResult();
    for (final table in syncTables) {
      result.pulled += await _pullTable(table);
    }
    await _pullDeletions();
    return result;
  }

  Future<int> _pullTable(String table) async {
    final info = _table(table);
    final idCol = idColumn(table);
    var cursor = await _readCursor(table);
    if (cursor != null && _isStale(cursor)) {
      // Silme kayıtları budanmış olabilir: tabloyu (bekleyen yerel değişiklikler hariç)
      // temizleyip baştan indir.
      await _db.transaction(() async {
        final keep = await _pendingIds(table);
        await _db.customUpdate(
          'DELETE FROM "$table" WHERE "$idCol" NOT IN (SELECT value FROM json_each(?))',
          variables: [Variable<String>(jsonEncode(keep.toList()))],
          updates: {info},
          updateKind: UpdateKind.delete,
        );
        await _deleteCursor(table);
      });
      cursor = null;
    }

    var (since, afterId) = _splitCursor(cursor?.cursor ?? '');
    var applied = 0;
    while (true) {
      final rows = await _remote.fetchChanged(
        table,
        since: since,
        afterId: afterId,
        limit: pageSize,
      );
      if (rows.isNotEmpty) {
        since = rows.last['updated_at']! as String;
        afterId = rows.last[idCol]! as String;
      }
      await _db.transaction(() async {
        final pending = await _pendingIds(table);
        for (final row in rows) {
          if (pending.contains(row[idCol])) continue; // yerel değişiklik önce gönderilecek
          await _apply(info, row);
          applied++;
        }
        await _writeCursor(table, since == null ? '' : '$since|$afterId');
      });
      if (rows.length < pageSize) break;
    }
    return applied;
  }

  Future<void> _pullDeletions() async {
    var cursor = await _readCursor(_deletionsCursor);
    if (cursor != null && _isStale(cursor)) cursor = null;
    String? since = (cursor?.cursor.isEmpty ?? true) ? null : cursor!.cursor;
    while (true) {
      final rows = await _remote.fetchDeletions(since: since, limit: pageSize);
      if (rows.isNotEmpty) since = '${rows.last['id']}';
      await _db.transaction(() async {
        final pendingKeys = await _pendingKeys();
        for (final row in rows) {
          final table = row['table_name'];
          final id = row['row_id'];
          if (table is! String || id is! String || !syncTables.contains(table)) continue;
          // Bekleyen yerel işlem varsa (ör. upsert) satır silinmez; yerel değişiklik kazanır.
          if (pendingKeys.contains('$table:$id')) continue;
          final info = _table(table);
          await _db.customUpdate(
            'DELETE FROM "$table" WHERE "${idColumn(table)}" = ?',
            variables: [Variable<String>(id)],
            updates: {info},
            updateKind: UpdateKind.delete,
          );
        }
        await _writeCursor(_deletionsCursor, since ?? '');
      });
      if (rows.length < pageSize) break;
    }
  }

  /// Sunucu satırını yerel tabloya yazar. Yerelde olmayan sütunlar (ör. `name_search`) atılır.
  Future<void> _apply(TableInfo<Table, Object?> info, Map<String, Object?> row) async {
    final names = <String>[];
    final variables = <Variable<Object>>[];
    for (final column in info.$columns) {
      if (!row.containsKey(column.name)) continue;
      names.add('"${column.name}"');
      variables.add(Variable<Object>(_toLocal(row[column.name])));
    }
    await _db.customInsert(
      'INSERT OR REPLACE INTO "${info.actualTableName}" (${names.join(', ')}) '
      'VALUES (${List.filled(names.length, '?').join(', ')})',
      variables: variables,
      updates: {info},
    );
  }

  Object? _toLocal(Object? value) => switch (value) {
    Map() || List() => jsonEncode(value),
    bool b => b ? 1 : 0,
    _ => value,
  };

  // --- Kataloglar ------------------------------------------------------------------------

  /// Kataloglar yalnızca yerelde boşsa ya da son indirme 7 günden eskiyse indirilir.
  Future<void> downloadCatalogs() async {
    final marker = await _readCursor(_catalogMarker);
    final fresh =
        marker != null &&
        _clock().difference(DateTime.fromMillisecondsSinceEpoch(marker.lastPulledAt)) <
            catalogMaxAge;
    if (fresh && !await _catalogsEmpty()) return;

    // Önce hepsini indir, sonra tek işlemde değiştir (yarım katalog kalmasın).
    final data = <String, List<Map<String, Object?>>>{};
    for (final table in catalogTables) {
      data[table] = await _remote.fetchCatalog(table);
    }
    await _db.transaction(() async {
      for (final table in catalogTables) {
        final rows = data[table]!;
        if (rows.isEmpty) continue; // boş yanıt yerel kataloğu silmesin
        final info = _table(table);
        await _db.delete(info).go();
        for (final row in rows) {
          await _apply(info, row);
        }
      }
      await _writeCursor(_catalogMarker, '');
    });
  }

  Future<bool> _catalogsEmpty() async {
    for (final table in catalogTables) {
      final row = await _db.customSelect('SELECT 1 FROM "$table" LIMIT 1').getSingleOrNull();
      if (row != null) return false;
    }
    return true;
  }

  // --- Yardımcılar -----------------------------------------------------------------------

  TableInfo<Table, Object?> _table(String name) =>
      _db.allTables.firstWhere((t) => t.actualTableName == name);

  Future<Set<String>> _pendingKeys() async =>
      (await _db.select(_db.outboxOps).get()).map((r) => r.key).toSet();

  Future<Set<String>> _pendingIds(String table) async {
    final prefix = '$table:';
    return {
      for (final key in await _pendingKeys())
        if (key.startsWith(prefix)) key.substring(prefix.length),
    };
  }

  bool _isStale(SyncCursor cursor) =>
      _clock().difference(DateTime.fromMillisecondsSinceEpoch(cursor.lastPulledAt)) >
      staleCursorAge;

  (String?, String?) _splitCursor(String value) {
    if (value.isEmpty) return (null, null);
    final bar = value.lastIndexOf('|');
    if (bar < 0) return (value, null);
    return (value.substring(0, bar), value.substring(bar + 1));
  }

  Future<SyncCursor?> _readCursor(String name) =>
      (_db.select(_db.syncCursors)..where((t) => t.targetTable.equals(name))).getSingleOrNull();

  Future<void> _writeCursor(String name, String value) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(
          targetTable: name,
          cursor: value,
          lastPulledAt: Value(_clock().millisecondsSinceEpoch),
        ),
      );

  Future<void> _deleteCursor(String name) =>
      (_db.delete(_db.syncCursors)..where((t) => t.targetTable.equals(name))).go();
}

/// Tek aktif oturum kurtarması başarısız: hata kodu ne olursa olsun geçici sayılır.
class _RecoveryFailed implements Exception {
  _RecoveryFailed(this.cause);

  final Object cause;

  @override
  String toString() => 'diğer aktif oturumlar kapatılamadı: $cause';
}

class _UnsupportedOp implements Exception {
  _UnsupportedOp(this.what);

  final String what;

  @override
  String toString() => 'desteklenmeyen işlem: $what';
}
