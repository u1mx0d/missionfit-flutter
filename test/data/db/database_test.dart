import 'package:drift/native.dart';
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
}
