import 'package:missionfit/data/sync/remote_gateway.dart';

/// Bellekteki sahte sunucu. `updated_at` değerlerini sunucu gibi kendisi damgalar; sorgular
/// `SupabaseRemoteGateway` ile aynı anlamdadır: `(updated_at, id) > (since, afterId)` anahtar
/// kümesi, `(updated_at, id)` artan sıra, `limit`.
class FakeRemoteGateway implements RemoteGateway {
  /// tablo -> id -> satır
  final Map<String, Map<String, Map<String, Object?>>> tables = {};
  final List<Map<String, Object?>> deletions = [];
  final Map<String, List<Map<String, Object?>>> catalogs = {};

  /// Gönderilen işlemler: `'<tablo>.upsert:<id>'` / `'<tablo>.delete:<id>'`.
  final List<String> sent = [];

  /// `fetchChanged` çağrıları ve dönen satır sayıları.
  final List<({String table, String? since, String? afterId, int returned})> fetches = [];
  int catalogFetches = 0;

  /// Bir gönderim için hata döndürürse o hata fırlatılır (ör. `{'code': '42501'}`).
  Object? Function(String table, String id)? failSend;

  /// Verilirse `fetchById` bu hatayı fırlatır.
  Object? failFetchById;

  int _tick = 0;
  int _deletionId = 0;

  /// Sunucu saati: her yazımda ilerler (sabit önek + sıfır dolgulu sayaç, sözlük sırası = zaman).
  String stamp() => '2026-11-18T10:00:00.${(++_tick).toString().padLeft(6, '0')}+00:00';

  void put(String table, Map<String, Object?> row, {String? updatedAt}) {
    final id = row[idColumn(table)]! as String;
    tables.putIfAbsent(table, () => {})[id] = {...row, 'updated_at': updatedAt ?? stamp()};
  }

  /// SQL ile silme gibi: satırı kaldırır ve `deletions` kaydı ekler.
  void serverDelete(String table, String id) {
    final row = tables[table]?.remove(id);
    deletions.add({
      'id': ++_deletionId,
      'table_name': table,
      'row_id': id,
      'user_id': row?['user_id'],
      'deleted_at': stamp(),
    });
  }

  @override
  Future<void> upsert(String table, Map<String, Object?> row) async {
    final id = row[idColumn(table)]! as String;
    final error = failSend?.call(table, id);
    if (error != null) throw error;
    sent.add('$table.upsert:$id');
    put(table, row);
  }

  @override
  Future<void> delete(String table, String id) async {
    final error = failSend?.call(table, id);
    if (error != null) throw error;
    sent.add('$table.delete:$id');
    if (tables[table]?.containsKey(id) ?? false) serverDelete(table, id);
  }

  @override
  Future<List<Map<String, Object?>>> fetchChanged(
    String table, {
    required String? since,
    String? afterId,
    required int limit,
  }) async {
    final idCol = idColumn(table);
    final rows = (tables[table]?.values ?? const <Map<String, Object?>>[]).where((r) {
      if (since == null) return true;
      final u = r['updated_at']! as String;
      final c = u.compareTo(since);
      if (afterId == null) return c > 0;
      return c > 0 || (c == 0 && (r[idCol]! as String).compareTo(afterId) > 0);
    }).toList();
    rows.sort((a, b) {
      final c = (a['updated_at']! as String).compareTo(b['updated_at']! as String);
      return c != 0 ? c : (a[idCol]! as String).compareTo(b[idCol]! as String);
    });
    final page = rows.take(limit).map((r) => {...r}).toList();
    fetches.add((table: table, since: since, afterId: afterId, returned: page.length));
    return page;
  }

  @override
  Future<List<Map<String, Object?>>> fetchDeletions({
    required String? since,
    required int limit,
  }) async {
    final after = since == null ? 0 : int.parse(since);
    return deletions.where((d) => (d['id']! as int) > after).take(limit).toList();
  }

  @override
  Future<Map<String, Object?>?> fetchById(String table, String id) async {
    if (failFetchById != null) throw failFetchById!;
    final row = tables[table]?[id];
    return row == null ? null : {...row};
  }

  @override
  Future<List<Map<String, Object?>>> fetchCatalog(String table) async {
    catalogFetches++;
    return [...?catalogs[table]];
  }
}
