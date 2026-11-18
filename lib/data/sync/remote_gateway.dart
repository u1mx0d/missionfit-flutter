import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

/// Senkronlanan kullanıcı tabloları, yabancı anahtar sırasıyla (ebeveyn önce).
const syncTables = [
  'profiles',
  'custom_foods',
  'workout_sessions',
  'session_sets',
  'food_entries',
  'favorite_foods',
  'tasks',
  'task_completions',
];

/// Global, salt okunur katalog tabloları.
const catalogTables = [
  'muscle_groups',
  'exercises',
  'exercise_muscles',
  'workout_templates',
  'workout_template_exercises',
  'foods',
  'default_tasks',
];

/// Satırın kimlik sütunu: `profiles` için `user_id`, diğerleri için `id`.
String idColumn(String table) => table == 'profiles' ? 'user_id' : 'id';

/// Sunucu erişimi. Satırlar sunucu biçimindedir (snake_case; jsonb -> Map/List, boolean -> bool).
abstract interface class RemoteGateway {
  /// Satırı yazar (istemci uuid'si ile; tekrar göndermek güvenli).
  Future<void> upsert(String table, Map<String, Object?> row);

  Future<void> delete(String table, String id);

  /// `(updated_at, id) > (since, afterId)` olan satırlar, `(updated_at, id)` artan sırada,
  /// en çok [limit] tane. [afterId] null ise yalnızca `updated_at > since`; [since] null ise baştan.
  Future<List<Map<String, Object?>>> fetchChanged(
    String table, {
    required String? since,
    String? afterId,
    required int limit,
  });

  /// `deletions` kayıtları: `id > since` (identity), `id` artan sırada.
  Future<List<Map<String, Object?>>> fetchDeletions({required String? since, required int limit});

  /// Katalog tablosunun tamamı.
  Future<List<Map<String, Object?>>> fetchCatalog(String table);
}

class SupabaseRemoteGateway implements RemoteGateway {
  SupabaseRemoteGateway(this._client);

  final SupabaseClient _client;

  /// Sunucunun damgaladığı / istemcinin değiştiremeyeceği profil sütunları (kolon bazlı GRANT).
  static const _profileReadOnly = {'user_id', 'created_at', 'updated_at'};

  /// UPDATE yetkisi olmayan (değişmez) tablolar: çakışmada hiçbir şey yapılmaz.
  static const _insertOnly = {'favorite_foods', 'task_completions'};

  @override
  Future<void> upsert(String table, Map<String, Object?> row) async {
    // updated_at sunucuda damgalanır (insert: default now(), update: tetikleyici); istemci
    // saatini göndermek başka cihazların imlecini atlatabilirdi.
    final values = {...row}..remove('updated_at');
    if (table == 'profiles') {
      // Profil satırı kayıtta tetikleyiciyle oluşur; INSERT yetkisi yok, yalnızca UPDATE.
      final id = values['user_id'];
      values.removeWhere((k, _) => _profileReadOnly.contains(k));
      await _client.from(table).update(values).eq('user_id', id!);
      return;
    }
    await _client
        .from(table)
        .upsert(
          values,
          onConflict: 'id',
          ignoreDuplicates: _insertOnly.contains(table),
          defaultToNull: false,
        );
  }

  @override
  Future<void> delete(String table, String id) =>
      _client.from(table).delete().eq(idColumn(table), id);

  @override
  Future<List<Map<String, Object?>>> fetchChanged(
    String table, {
    required String? since,
    String? afterId,
    required int limit,
  }) async {
    final idCol = idColumn(table);
    var query = _client.from(table).select();
    if (since != null) {
      query = afterId == null
          ? query.gt('updated_at', since)
          : query.or('updated_at.gt."$since",and(updated_at.eq."$since",$idCol.gt."$afterId")');
    }
    final rows = await query
        .order('updated_at', ascending: true)
        .order(idCol, ascending: true)
        .limit(limit);
    return rows;
  }

  @override
  Future<List<Map<String, Object?>>> fetchDeletions({
    required String? since,
    required int limit,
  }) async {
    var query = _client.from('deletions').select('id, table_name, row_id, deleted_at');
    if (since != null) query = query.gt('id', int.parse(since));
    return await query.order('id', ascending: true).limit(limit);
  }

  @override
  Future<List<Map<String, Object?>>> fetchCatalog(String table) async {
    const page = 1000;
    final order = table == 'exercise_muscles' ? ['exercise_id', 'muscle_group_id'] : ['id'];
    final all = <Map<String, Object?>>[];
    for (var from = 0; ; from += page) {
      var query = _client.from(table).select().order(order.first, ascending: true);
      for (final col in order.skip(1)) {
        query = query.order(col, ascending: true);
      }
      final rows = await query.range(from, from + page - 1);
      all.addAll(rows);
      if (rows.length < page) return all;
    }
  }
}
