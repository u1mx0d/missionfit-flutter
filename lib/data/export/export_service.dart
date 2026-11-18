import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthRetryableFetchException;

import '../db/database.dart';
import '../sync/remote_gateway.dart';

/// Dışa aktarılan 8 kullanıcı tablosu (RN `exportData.ts` ile aynı sıra).
const exportTables = [
  'profiles',
  'workout_sessions',
  'session_sets',
  'food_entries',
  'custom_foods',
  'favorite_foods',
  'tasks',
  'task_completions',
];

/// PostgREST tek yanıtta en çok ~1000 satır döndürür.
const exportPageSize = 1000;

/// Üretilen JSON dosyasını paylaşma menüsüyle açar; testlerde taklit edilir.
abstract interface class FileSharer {
  Future<void> shareJson({required String fileName, required String content});
}

class SharePlusFileSharer implements FileSharer {
  const SharePlusFileSharer();

  @override
  Future<void> shareJson({required String fileName, required String content}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json', name: fileName)],
        title: 'Verilerini dışa aktar',
        fileNameOverrides: [fileName],
      ),
    );
  }
}

class ExportResult {
  const ExportResult({required this.fileName, required this.fromLocal, required this.counts});
  final String fileName;

  /// İnternet yoktu; veri cihazdaki yerel veritabanından alındı.
  final bool fromLocal;
  final Map<String, int> counts;
}

bool isNetworkFailure(Object e) =>
    e is SocketException ||
    e is TimeoutException ||
    e is AuthRetryableFetchException ||
    e.runtimeType.toString() == 'ClientException';

const _boolColumns = {
  'calorie_target_is_manual',
  'onboarding_completed',
  'is_manual_override',
  'is_active',
};
const _jsonColumns = {'notification_settings'};

/// Kullanıcının tüm verisini JSON olarak dışa aktarır (KVKK veri taşınabilirliği).
/// Önce sunucudan (id'ye göre sıralı 1000'lik sayfalar); ağ yoksa yerel veritabanından.
class ExportService {
  ExportService({
    required this._remote,
    required this._db,
    required this._sharer,
    required this._email,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RemoteGateway _remote;
  final AppDatabase _db;
  final FileSharer _sharer;
  final String? Function() _email;
  final DateTime Function() _clock;

  Future<ExportResult> exportJson() async {
    var fromLocal = false;
    Map<String, List<Map<String, Object?>>> tables;
    try {
      tables = {for (final t in exportTables) t: await _fetchAll(t)};
    } catch (e) {
      if (!isNetworkFailure(e)) rethrow;
      fromLocal = true;
      tables = {for (final t in exportTables) t: await _readLocal(t)};
    }
    final now = _clock().toUtc();
    final payload = {
      'format': 'missionfit-export',
      'version': 1,
      'exported_at': now.toIso8601String(),
      'account': {'email': _email()},
      'note':
          'Ağırlıklar kg, besin değerleri kayıt anındaki değerlerdir (snapshot). '
          'Zaman damgaları UTC.',
      'tables': tables,
    };
    final fileName = 'missionfit-export-${now.toIso8601String().substring(0, 10)}.json';
    await _sharer.shareJson(
      fileName: fileName,
      content: const JsonEncoder.withIndent('  ').convert(payload),
    );
    return ExportResult(
      fileName: fileName,
      fromLocal: fromLocal,
      counts: {for (final e in tables.entries) e.key: e.value.length},
    );
  }

  Future<List<Map<String, Object?>>> _fetchAll(String table) async {
    final rows = <Map<String, Object?>>[];
    for (var offset = 0; ; offset += exportPageSize) {
      final page = await _remote.fetchPage(table, offset: offset, limit: exportPageSize);
      rows.addAll(page);
      if (page.length < exportPageSize) return rows;
    }
  }

  Future<List<Map<String, Object?>>> _readLocal(String table) async {
    final result = await _db.customSelect('SELECT * FROM $table ORDER BY ${idColumn(table)}').get();
    return [
      for (final r in result) {for (final e in r.data.entries) e.key: _normalize(e.key, e.value)},
    ];
  }

  /// Yerel biçimi (boolean 0/1, jsonb metin) sunucudaki JSON biçimine çevirir.
  Object? _normalize(String column, Object? value) {
    if (value == null) return null;
    if (_boolColumns.contains(column)) return value == 1 || value == true;
    if (_jsonColumns.contains(column) && value is String) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }
    return value;
  }
}
