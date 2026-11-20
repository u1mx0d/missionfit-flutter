import 'package:drift/drift.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    WorkoutSessions,
    SessionSets,
    CustomFoods,
    FoodEntries,
    FavoriteFoods,
    Tasks,
    TaskCompletions,
    MuscleGroups,
    Exercises,
    ExerciseMuscles,
    WorkoutTemplates,
    WorkoutTemplateExercises,
    Foods,
    DefaultTasks,
    OutboxOps,
    SyncCursors,
    ActiveWorkoutPlans,
    RestMemory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  AppDatabase.forTesting(super.e);

  /// Üretim: uygulama belgeler klasöründe `missionfit.sqlite` (arka plan isolate'ında).
  static AppDatabase open() {
    return AppDatabase._(
      LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        return NativeDatabase.createInBackground(
          File(p.join(dir.path, 'missionfit.sqlite')),
          // Her bağlantıda (ana ve arka plan isolate'ı): dinlenme bildirimi eylemleri ikinci
          // bir bağlantı açabilir; WAL okuma/yazmayı ayırır, meşgulse 3 sn beklenir.
          setup: (db) {
            db.execute('PRAGMA busy_timeout = 3000');
            db.execute('PRAGMA journal_mode = WAL');
          },
        );
      }),
    );
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(profiles, profiles.username);
        await m.addColumn(profiles, profiles.avatarPath);
      }
      if (from < 3) {
        await m.addColumn(profiles, profiles.trainingStyle);
        await m.addColumn(profiles, profiles.sideStyles);
        await m.addColumn(profiles, profiles.trainingLevel);
        await m.addColumn(profiles, profiles.goalMoves);
        await m.addColumn(profiles, profiles.focusAreas);
        // Eski şemayla çekilen profil satırları yeni sütunları taşımaz; imleç silinince
        // sonraki çekme profili baştan alır.
        await (delete(syncCursors)..where((c) => c.targetTable.equals('profiles'))).go();
      }
      if (from < 4) {
        await m.createTable(activeWorkoutPlans);
        await m.createTable(restMemory);
      }
    },
  );

  /// Çıkış/hesap silme: kullanıcı verisi, outbox ve senkron imleçleri silinir; kataloglar kalır.
  Future<void> clearAllUserData() => transaction(() async {
    final List<TableInfo<Table, Object?>> all = [
      activeWorkoutPlans,
      restMemory,
      taskCompletions,
      tasks,
      favoriteFoods,
      foodEntries,
      customFoods,
      sessionSets,
      workoutSessions,
      profiles,
      outboxOps,
      syncCursors,
    ];
    for (final table in all) {
      await delete(table).go();
    }
  });
}
