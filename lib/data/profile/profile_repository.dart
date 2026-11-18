import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/calories.dart';
import '../../domain/notification_settings.dart';
import '../../domain/units.dart';
import '../../domain/week.dart';
import '../../ui/theme/accents.dart';
import '../../ui/theme/mf_theme.dart';
import '../db/database.dart' hide Profile;
import '../db/database.dart' as d show Profile;
import '../sync/outbox.dart';
import '../sync/outbox_queue.dart';

T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

Object? _tryDecode(String s) {
  try {
    return jsonDecode(s);
  } catch (_) {
    return null;
  }
}

/// Yerel profil satırı yok ve sunucudan da alınamadı (ör. ilk eşitleme gelmedi, çevrimdışı).
class ProfileNotReadyException implements Exception {
  const ProfileNotReadyException();
  static const message = 'Profil henüz yüklenmedi. İnternet bağlantını kontrol edip tekrar dene.';
  @override
  String toString() => message;
}

String activityLevelToServer(ActivityLevel a) =>
    a == ActivityLevel.veryActive ? 'very_active' : a.name;

ActivityLevel? activityLevelFromServer(String? s) =>
    s == 'very_active' ? ActivityLevel.veryActive : _byName(ActivityLevel.values, s);

/// Sunucudaki `profiles` satırının yerel, türlü hâli. Bilinmeyen değerler asla fırlatmaz:
/// enum alanlarında null/varsayılana düşer.
class Profile {
  const Profile({
    required this.userId,
    this.displayName,
    this.heightCm,
    this.weightKg,
    this.birthYear,
    this.sex,
    this.activityLevel,
    this.goal,
    this.calorieTarget,
    this.calorieTargetIsManual = false,
    this.units = WeightUnit.kg,
    this.weekStartsOn = WeekStartsOn.monday,
    this.timezone = 'Europe/Istanbul',
    this.theme = ThemeModeChoice.system,
    this.accent = 'indigo',
    this.themeFamily = ThemeFamily.canli,
    this.accentColor = AccentColor.yesil,
    this.notificationSettings = defaultNotificationSettings,
    this.onboardingCompleted = false,
    this.consentedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? displayName;
  final double? heightCm;
  final double? weightKg;
  final int? birthYear;
  final Sex? sex;
  final ActivityLevel? activityLevel;
  final Goal? goal;
  final int? calorieTarget;
  final bool calorieTargetIsManual;
  final WeightUnit units;
  final WeekStartsOn weekStartsOn;
  final String timezone;
  final ThemeModeChoice theme;

  /// Eski (RN) `accent` sütunu; olduğu gibi korunur.
  final String accent;
  final ThemeFamily themeFamily;
  final AccentColor accentColor;
  final NotificationSettings notificationSettings;
  final bool onboardingCompleted;
  final String? consentedAt;
  final String createdAt;
  final String updatedAt;

  factory Profile.fromRow(d.Profile r) {
    final ns = _tryDecode(r.notificationSettings);
    return Profile(
      userId: r.userId,
      displayName: r.displayName,
      heightCm: r.heightCm,
      weightKg: r.weightKg,
      birthYear: r.birthYear,
      sex: _byName(Sex.values, r.sex),
      activityLevel: activityLevelFromServer(r.activityLevel),
      goal: _byName(Goal.values, r.goal),
      calorieTarget: r.calorieTarget,
      calorieTargetIsManual: r.calorieTargetIsManual,
      units: r.units == 'lb' ? WeightUnit.lb : WeightUnit.kg,
      weekStartsOn: r.weekStartsOn == 'sunday' ? WeekStartsOn.sunday : WeekStartsOn.monday,
      timezone: r.timezone,
      theme: modeFromString(r.theme),
      accent: r.accent,
      themeFamily: familyFromString(r.themeFamily),
      accentColor: accentFromString(r.accentColor),
      notificationSettings: parseNotificationSettings(ns),
      onboardingCompleted: r.onboardingCompleted,
      consentedAt: r.consentedAt,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  /// SQL snake_case sütun adlarıyla tam satır. `updated_at` sunucuya gönderilmez; yük için
  /// [toPayload] kullanılır.
  Map<String, Object?> toRow() => {
    'user_id': userId,
    'display_name': displayName,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'birth_year': birthYear,
    'sex': sex?.name,
    'activity_level': activityLevel == null ? null : activityLevelToServer(activityLevel!),
    'goal': goal?.name,
    'calorie_target': calorieTarget,
    'calorie_target_is_manual': calorieTargetIsManual,
    'units': units.name,
    'week_starts_on': weekStartsOn.name,
    'timezone': timezone,
    'theme': theme.name,
    'accent': accent,
    'theme_family': themeFamily.name,
    'accent_color': accentColor.name,
    'notification_settings': jsonEncode(notificationSettings.toJson()),
    'onboarding_completed': onboardingCompleted,
    'consented_at': consentedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Sunucu satırı (snake_case, jsonb -> Map, boolean -> bool) -> yerel profil. Tolerant.
  static Profile? fromServer(Map<String, Object?> m) {
    final userId = m['user_id'];
    if (userId is! String) return null;
    String? str(String k) => m[k] is String ? m[k]! as String : null;
    double? dbl(String k) => m[k] is num ? (m[k]! as num).toDouble() : null;
    int? integer(String k) => m[k] is num ? (m[k]! as num).toInt() : null;
    final now = DateTime.now().toUtc().toIso8601String();
    return Profile(
      userId: userId,
      displayName: str('display_name'),
      heightCm: dbl('height_cm'),
      weightKg: dbl('weight_kg'),
      birthYear: integer('birth_year'),
      sex: _byName(Sex.values, str('sex')),
      activityLevel: activityLevelFromServer(str('activity_level')),
      goal: _byName(Goal.values, str('goal')),
      calorieTarget: integer('calorie_target'),
      calorieTargetIsManual: m['calorie_target_is_manual'] == true,
      units: str('units') == 'lb' ? WeightUnit.lb : WeightUnit.kg,
      weekStartsOn: str('week_starts_on') == 'sunday' ? WeekStartsOn.sunday : WeekStartsOn.monday,
      timezone: str('timezone') ?? 'Europe/Istanbul',
      theme: modeFromString(str('theme')),
      accent: str('accent') ?? 'indigo',
      themeFamily: familyFromString(str('theme_family')),
      accentColor: accentFromString(str('accent_color')),
      notificationSettings: parseNotificationSettings(
        m['notification_settings'] is String
            ? _tryDecode(m['notification_settings']! as String)
            : m['notification_settings'],
      ),
      onboardingCompleted: m['onboarding_completed'] == true,
      consentedAt: str('consented_at'),
      createdAt: str('created_at') ?? now,
      updatedAt: str('updated_at') ?? now,
    );
  }

  Map<String, Object?> toPayload() => toRow()..remove('updated_at');

  ProfilesCompanion toCompanion() => ProfilesCompanion(
    userId: Value(userId),
    displayName: Value(displayName),
    heightCm: Value(heightCm),
    weightKg: Value(weightKg),
    birthYear: Value(birthYear),
    sex: Value(sex?.name),
    activityLevel: Value(activityLevel == null ? null : activityLevelToServer(activityLevel!)),
    goal: Value(goal?.name),
    calorieTarget: Value(calorieTarget),
    calorieTargetIsManual: Value(calorieTargetIsManual),
    units: Value(units.name),
    weekStartsOn: Value(weekStartsOn.name),
    timezone: Value(timezone),
    theme: Value(theme.name),
    accent: Value(accent),
    themeFamily: Value(themeFamily.name),
    accentColor: Value(accentColor.name),
    notificationSettings: Value(jsonEncode(notificationSettings.toJson())),
    onboardingCompleted: Value(onboardingCompleted),
    consentedAt: Value(consentedAt),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );

  Profile copyWith({
    Object? displayName = _keep,
    Object? heightCm = _keep,
    Object? weightKg = _keep,
    Object? birthYear = _keep,
    Object? sex = _keep,
    Object? activityLevel = _keep,
    Object? goal = _keep,
    Object? calorieTarget = _keep,
    bool? calorieTargetIsManual,
    WeightUnit? units,
    WeekStartsOn? weekStartsOn,
    String? timezone,
    ThemeModeChoice? theme,
    ThemeFamily? themeFamily,
    AccentColor? accentColor,
    NotificationSettings? notificationSettings,
    bool? onboardingCompleted,
    Object? consentedAt = _keep,
  }) => Profile(
    userId: userId,
    displayName: identical(displayName, _keep) ? this.displayName : displayName as String?,
    heightCm: identical(heightCm, _keep) ? this.heightCm : heightCm as double?,
    weightKg: identical(weightKg, _keep) ? this.weightKg : weightKg as double?,
    birthYear: identical(birthYear, _keep) ? this.birthYear : birthYear as int?,
    sex: identical(sex, _keep) ? this.sex : sex as Sex?,
    activityLevel: identical(activityLevel, _keep)
        ? this.activityLevel
        : activityLevel as ActivityLevel?,
    goal: identical(goal, _keep) ? this.goal : goal as Goal?,
    calorieTarget: identical(calorieTarget, _keep) ? this.calorieTarget : calorieTarget as int?,
    calorieTargetIsManual: calorieTargetIsManual ?? this.calorieTargetIsManual,
    units: units ?? this.units,
    weekStartsOn: weekStartsOn ?? this.weekStartsOn,
    timezone: timezone ?? this.timezone,
    theme: theme ?? this.theme,
    accent: accent,
    themeFamily: themeFamily ?? this.themeFamily,
    accentColor: accentColor ?? this.accentColor,
    notificationSettings: notificationSettings ?? this.notificationSettings,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    consentedAt: identical(consentedAt, _keep) ? this.consentedAt : consentedAt as String?,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

const Object _keep = Object();

class ProfileRepository {
  ProfileRepository(this._db, this._outbox, {DateTime Function()? clock, this.fetchRemote})
    : _clock = clock ?? DateTime.now;

  /// Yerel satır yokken sunucudan tek seferlik profil çeker (null: yok).
  final Future<Map<String, Object?>?> Function(String userId)? fetchRemote;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final DateTime Function() _clock;
  int _counter = 0;

  /// Yerel satırı izler; ağ gerekmez.
  Stream<Profile?> watch(String userId) =>
      (_db.select(_db.profiles)..where((t) => t.userId.equals(userId))).watchSingleOrNull().map(
        (r) => r == null ? null : Profile.fromRow(r),
      );

  /// Yerel satırı değiştirir ve `profiles.upsert` işlemini aynı transaction'da kuyruğa alır;
  /// biri başarısız olursa ikisi de geri alınır. Yerel satır yoksa önce sunucudan bir kez
  /// alınıp uygulanır; alınamazsa [ProfileNotReadyException] fırlar (sessizce yutulmaz).
  Future<void> update(String userId, Profile Function(Profile) change) async {
    if (!await _hasRow(userId)) await _fetchAndStore(userId);
    await _db.transaction(() async {
      final row = await (_db.select(
        _db.profiles,
      )..where((t) => t.userId.equals(userId))).getSingleOrNull();
      if (row == null) throw const ProfileNotReadyException();
      final next = change(Profile.fromRow(row));
      await _db.into(_db.profiles).insertOnConflictUpdate(next.toCompanion());
      final now = _clock();
      await _outbox.enqueue(
        OutboxOp(
          opId: 'profiles-$userId-${now.microsecondsSinceEpoch}-${_counter++}',
          key: 'profiles:$userId',
          type: 'profiles.upsert',
          payload: next.toPayload(),
          attempts: 0,
          createdAt: now.millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<bool> _hasRow(String userId) async =>
      await (_db.select(_db.profiles)..where((t) => t.userId.equals(userId))).getSingleOrNull() !=
      null;

  Future<void> _fetchAndStore(String userId) async {
    final fetch = fetchRemote;
    if (fetch == null) throw const ProfileNotReadyException();
    final Profile? remote;
    try {
      final m = await fetch(userId);
      remote = m == null ? null : Profile.fromServer(m);
    } catch (_) {
      throw const ProfileNotReadyException();
    }
    if (remote == null || remote.userId != userId) throw const ProfileNotReadyException();
    // Bu arada pull satırı getirmiş olabilir; varsa ezme.
    await _db.transaction(() async {
      if (!await _hasRow(userId)) {
        await _db.into(_db.profiles).insert(remote!.toCompanion());
      }
    });
  }
}
