import 'package:drift/drift.dart';

// Yerel tablolar sunucu şemasının aynasıdır. Sütun adları sunucuyla aynı snake_case
// (drift camelCase alanları otomatik snake_case yapar), böylece senkron satırları ada göre
// eşler. Saklama biçimleri: uuid TEXT, timestamptz TEXT (ISO-8601 UTC), date TEXT
// ("YYYY-MM-DD"), time TEXT ("HH:mm"), jsonb TEXT (JSON), numeric REAL.
//
// Atlanan sunucu sütunları: foods.name_search ve custom_foods.name_search. Bunlar sunucuda
// normalize_search() ile üretilen sütunlardır; istemci arama normalizasyonunu kendi yapar.

// --- Kullanıcı tabloları -----------------------------------------------------------------

class Profiles extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get birthYear => integer().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get activityLevel => text().nullable()();
  TextColumn get goal => text().nullable()();
  IntColumn get calorieTarget => integer().nullable()();
  BoolColumn get calorieTargetIsManual => boolean().withDefault(const Constant(false))();
  TextColumn get units => text().withDefault(const Constant('kg'))();
  TextColumn get weekStartsOn => text().withDefault(const Constant('monday'))();
  TextColumn get timezone => text().withDefault(const Constant('Europe/Istanbul'))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  TextColumn get accent => text().withDefault(const Constant('indigo'))();
  TextColumn get themeFamily => text().withDefault(const Constant('canli'))();
  TextColumn get accentColor => text().withDefault(const Constant('yesil'))();
  TextColumn get notificationSettings =>
      text().withDefault(const Constant('{"enabled": true, "task_lead_minutes": 10}'))();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get consentedAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {userId};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get templateId => text().nullable()();
  TextColumn get name => text().withDefault(const Constant('Antrenman'))();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text().nullable()();
  TextColumn get localDate => text()();
  TextColumn get weekKey => text()();
  IntColumn get estimatedKcal => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get exerciseOrder => integer()();
  IntColumn get setIndex => integer()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get completedAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId, exerciseOrder, setIndex},
  ];
}

class CustomFoods extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get nameTr => text()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real().withDefault(const Constant(0))();
  RealColumn get carbPer100g => real().withDefault(const Constant(0))();
  RealColumn get fatPer100g => real().withDefault(const Constant(0))();
  RealColumn get defaultServingGrams => real().withDefault(const Constant(100))();
  TextColumn get servingLabel => text().withDefault(const Constant('100 g'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class FoodEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get localDate => text()();
  TextColumn get meal => text()();
  TextColumn get foodId => text().nullable()();
  TextColumn get customFoodId => text().nullable()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get unit => text()();
  RealColumn get grams => real()();
  RealColumn get kcal => real()();
  RealColumn get protein => real().withDefault(const Constant(0))();
  RealColumn get carb => real().withDefault(const Constant(0))();
  RealColumn get fat => real().withDefault(const Constant(0))();
  BoolColumn get isManualOverride => boolean().withDefault(const Constant(false))();
  TextColumn get loggedAt => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoriteFoods extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get foodId => text().nullable()();
  TextColumn get customFoodId => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get time => text().nullable()();
  TextColumn get repeatRule => text().withDefault(const Constant('{"type":"once"}'))();
  TextColumn get startDate => text()();
  TextColumn get defaultTaskId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text()();
  TextColumn get localDate => text()();
  TextColumn get completedAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, localDate},
  ];
}

// --- Katalog tabloları (global, salt okunur) ---------------------------------------------

class MuscleGroups extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text().unique()();
  TextColumn get nameTr => text()();
  TextColumn get bodyRegion => text()();
  TextColumn get view => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text().unique()();
  TextColumn get nameTr => text()();
  TextColumn get nameEn => text()();
  TextColumn get equipment => text()();
  TextColumn get type => text()();
  TextColumn get tracking => text()();
  RealColumn get metValue => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseMuscles extends Table {
  TextColumn get exerciseId => text()();
  TextColumn get muscleGroupId => text()();
  TextColumn get role => text()();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
}

class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text().unique()();
  TextColumn get nameTr => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get level => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutTemplateExercises extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get orderIndex => integer()();
  IntColumn get sets => integer()();
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {templateId, orderIndex},
  ];
}

class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text().unique()();
  TextColumn get nameTr => text()();
  TextColumn get category => text()();
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get carbPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get defaultServingGrams => real()();
  TextColumn get servingLabel => text()();
  TextColumn get source => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class DefaultTasks extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text().unique()();
  TextColumn get titleTr => text()();
  TextColumn get category => text()();
  TextColumn get suggestedTime => text().nullable()();
  TextColumn get repeatRule => text().withDefault(const Constant('{"type":"daily"}'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- Senkron tabloları -------------------------------------------------------------------

/// Gönderilmeyi bekleyen yerel değişiklikler. `key` aynı kaydın tekrar kuyruğa alınmasını
/// tekilleştirir; `seq` sıralama içindir (atama ve yeniden kuyruğa almada korunması Task 7).
@DataClassName('OutboxRow')
class OutboxOps extends Table {
  TextColumn get opId => text()();
  TextColumn get key => text().unique()();
  TextColumn get type => text()();
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get seq => integer()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Tablo başına son çekilen `updated_at` imleci (sunucudan gelen ISO metin).
class SyncCursors extends Table {
  TextColumn get targetTable => text().named('table_name')();
  TextColumn get cursor => text()();
  IntColumn get lastPulledAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {targetTable};
}
