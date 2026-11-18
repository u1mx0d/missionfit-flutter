import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/export/export_service.dart';

import '../sync/fake_remote_gateway.dart';

class _FakeSharer implements FileSharer {
  String? fileName;
  String? content;
  @override
  Future<void> shareJson({required String fileName, required String content}) async {
    this.fileName = fileName;
    this.content = content;
  }
}

String _id(int i) => '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

void main() {
  late AppDatabase db;
  late FakeRemoteGateway remote;
  late _FakeSharer sharer;
  late ExportService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = FakeRemoteGateway();
    sharer = _FakeSharer();
    service = ExportService(
      remote: remote,
      db: db,
      sharer: sharer,
      email: () => 'a@b.com',
      clock: () => DateTime.utc(2026, 11, 18, 9, 30),
    );
  });
  tearDown(() => db.close());

  test('export 8 tabloyu içerir ve 2500 satırı sayfalar', () async {
    remote.put('profiles', {'user_id': 'u1', 'display_name': 'Ada'});
    // Sıra karışık eklenir; sayfalar id'ye göre sıralı gelmeli.
    for (final i in [for (var i = 2499; i >= 0; i--) i]) {
      remote.put('food_entries', {'id': _id(i), 'user_id': 'u1', 'name': 'x$i'});
    }
    final result = await service.exportJson();

    expect(result.fromLocal, isFalse);
    expect(result.fileName, 'missionfit-export-2026-11-18.json');
    expect(sharer.fileName, 'missionfit-export-2026-11-18.json');
    final json = jsonDecode(sharer.content!) as Map<String, dynamic>;
    expect(json['format'], 'missionfit-export');
    expect(json['account'], {'email': 'a@b.com'});
    final tables = json['tables'] as Map<String, dynamic>;
    expect(tables.keys, [
      'profiles',
      'workout_sessions',
      'session_sets',
      'food_entries',
      'custom_foods',
      'favorite_foods',
      'tasks',
      'task_completions',
    ]);
    final entries = tables['food_entries'] as List;
    expect(entries, hasLength(2500));
    expect((entries.first as Map)['id'], _id(0));
    expect((entries.last as Map)['id'], _id(2499));
    expect(remote.pageFetches.where((f) => f.startsWith('food_entries@')), [
      'food_entries@0',
      'food_entries@1000',
      'food_entries@2000',
    ]);
    expect(tables['profiles'], hasLength(1));
    expect(result.counts['food_entries'], 2500);
  });

  test('tam sayfa sonrası boş sayfa da denenir (1000 satır → 2 istek)', () async {
    for (var i = 0; i < 1000; i++) {
      remote.put('tasks', {'id': _id(i), 'user_id': 'u1'});
    }
    await service.exportJson();
    expect(remote.pageFetches.where((f) => f.startsWith('tasks@')), ['tasks@0', 'tasks@1000']);
  });

  test('internet yoksa yerel veritabanından aktarılır', () async {
    remote.failFetchPage = const SocketException('yok');
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            createdAt: 'x',
            updatedAt: 'x',
            calorieTargetIsManual: const Value(true),
            username: const Value('alp'),
          ),
        );
    final result = await service.exportJson();
    expect(result.fromLocal, isTrue);
    final json = jsonDecode(sharer.content!) as Map<String, dynamic>;
    final profile = ((json['tables'] as Map)['profiles'] as List).single as Map;
    expect(profile['user_id'], 'u1');
    expect(profile['calorie_target_is_manual'], true);
    expect(profile['username'], 'alp');
    expect(profile['notification_settings'], {'enabled': true, 'task_lead_minutes': 10});
    expect((json['tables'] as Map).keys, hasLength(8));
  });

  test('sunucu hatası (ağ dışı) yutulmaz', () async {
    remote.failFetchPage = StateError('yetki');
    expect(service.exportJson(), throwsStateError);
    expect(sharer.content, isNull);
  });
}
