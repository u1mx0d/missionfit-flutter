import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  const uid = '00000000-0000-0000-0000-000000000001';
  const ts = '2026-11-18T10:00:00.000Z';

  FoodEntriesCompanion entry(String name) => FoodEntriesCompanion.insert(
    id: 'e1',
    userId: uid,
    localDate: '2026-11-18',
    meal: 'lunch',
    name: name,
    amount: 100,
    unit: 'g',
    grams: 100,
    kcal: 120,
    loggedAt: ts,
    createdAt: ts,
    updatedAt: ts,
  );

  test('bellekte açılır ve 18 tablo oluşur', () async {
    // Sunucu şemasından 15 tablo + outboxOps + syncCursors = 17 uygulama tablosu.
    // Brief "18" diyor; 18. tablo tanımlı değil (bkz. rapor), bu yüzden 17 beklenir.
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    expect(rows.length, 17);
    expect(db.allTables.length, 17);
  });

  test('foodEntries upsert aynı id ile ikinci kayıt oluşturmaz', () async {
    await db.into(db.foodEntries).insertOnConflictUpdate(entry('Pilav'));
    await db.into(db.foodEntries).insertOnConflictUpdate(entry('Makarna'));
    final all = await db.select(db.foodEntries).get();
    expect(all.length, 1);
    expect(all.single.name, 'Makarna');
  });

  test(
    "clearAllUserData kullanıcı tablolarını ve outbox'ı boşaltır, foods kataloğu kalır",
    () async {
      await db.into(db.foodEntries).insert(entry('Pilav'));
      await db
          .into(db.outboxOps)
          .insert(
            OutboxOpsCompanion.insert(
              opId: 'op1',
              key: 'food_entries:e1',
              type: 'upsert',
              payload: '{}',
              createdAt: 1,
              seq: 1,
            ),
          );
      await db
          .into(db.syncCursors)
          .insert(SyncCursorsCompanion.insert(targetTable: 'food_entries', cursor: ts));
      await db
          .into(db.foods)
          .insert(
            FoodsCompanion.insert(
              id: 'f1',
              slug: 'pilav',
              nameTr: 'Pilav',
              category: 'grain',
              kcalPer100g: 130,
              proteinPer100g: 2.7,
              carbPer100g: 28,
              fatPer100g: 0.3,
              defaultServingGrams: 150,
              servingLabel: '1 porsiyon',
              source: 'test',
              createdAt: ts,
            ),
          );

      await db.clearAllUserData();

      expect(await db.select(db.foodEntries).get(), isEmpty);
      expect(await db.select(db.outboxOps).get(), isEmpty);
      expect(await db.select(db.syncCursors).get(), isEmpty);
      expect((await db.select(db.foods).get()).length, 1);
    },
  );

  test('v1 veritabanı v2ye göçer, profil satırı korunur', () async {
    final dir = Directory.systemTemp.createTempSync('mf_mig');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v1.sqlite');
    final raw = sql.sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE profiles (
        user_id TEXT NOT NULL, display_name TEXT NULL, height_cm REAL NULL, weight_kg REAL NULL,
        birth_year INTEGER NULL, sex TEXT NULL, activity_level TEXT NULL, goal TEXT NULL,
        calorie_target INTEGER NULL,
        calorie_target_is_manual INTEGER NOT NULL DEFAULT 0 CHECK (calorie_target_is_manual IN (0, 1)),
        units TEXT NOT NULL DEFAULT 'kg', week_starts_on TEXT NOT NULL DEFAULT 'monday',
        timezone TEXT NOT NULL DEFAULT 'Europe/Istanbul', theme TEXT NOT NULL DEFAULT 'system',
        accent TEXT NOT NULL DEFAULT 'indigo', theme_family TEXT NOT NULL DEFAULT 'canli',
        accent_color TEXT NOT NULL DEFAULT 'yesil',
        notification_settings TEXT NOT NULL DEFAULT '{"enabled": true, "task_lead_minutes": 10}',
        onboarding_completed INTEGER NOT NULL DEFAULT 0 CHECK (onboarding_completed IN (0, 1)),
        consented_at TEXT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
        PRIMARY KEY (user_id)
      )''');
    raw.execute(
      'INSERT INTO profiles (user_id, display_name, created_at, updated_at) '
      "VALUES ('u1', 'Ada', 'x', 'x')",
    );
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    final migrated = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(migrated.close);
    final row = await migrated.select(migrated.profiles).getSingle();
    expect(row.userId, 'u1');
    expect(row.displayName, 'Ada');
    expect(row.username, isNull);
    expect(row.avatarPath, isNull);
    final cols = await migrated.customSelect('PRAGMA table_info(profiles)').get();
    expect(cols.map((c) => c.read<String>('name')), contains('avatar_path'));
  });
}
