// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta('birthYear');
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calorieTargetMeta = const VerificationMeta('calorieTarget');
  @override
  late final GeneratedColumn<int> calorieTarget = GeneratedColumn<int>(
    'calorie_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calorieTargetIsManualMeta = const VerificationMeta(
    'calorieTargetIsManual',
  );
  @override
  late final GeneratedColumn<bool> calorieTargetIsManual = GeneratedColumn<bool>(
    'calorie_target_is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("calorie_target_is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kg'),
  );
  static const VerificationMeta _weekStartsOnMeta = const VerificationMeta('weekStartsOn');
  @override
  late final GeneratedColumn<String> weekStartsOn = GeneratedColumn<String>(
    'week_starts_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monday'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Europe/Istanbul'),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _accentMeta = const VerificationMeta('accent');
  @override
  late final GeneratedColumn<String> accent = GeneratedColumn<String>(
    'accent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('indigo'),
  );
  static const VerificationMeta _themeFamilyMeta = const VerificationMeta('themeFamily');
  @override
  late final GeneratedColumn<String> themeFamily = GeneratedColumn<String>(
    'theme_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('canli'),
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta('accentColor');
  @override
  late final GeneratedColumn<String> accentColor = GeneratedColumn<String>(
    'accent_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('yesil'),
  );
  static const VerificationMeta _notificationSettingsMeta = const VerificationMeta(
    'notificationSettings',
  );
  @override
  late final GeneratedColumn<String> notificationSettings = GeneratedColumn<String>(
    'notification_settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{"enabled": true, "task_lead_minutes": 10}'),
  );
  static const VerificationMeta _onboardingCompletedMeta = const VerificationMeta(
    'onboardingCompleted',
  );
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _consentedAtMeta = const VerificationMeta('consentedAt');
  @override
  late final GeneratedColumn<String> consentedAt = GeneratedColumn<String>(
    'consented_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingStyleMeta = const VerificationMeta('trainingStyle');
  @override
  late final GeneratedColumn<String> trainingStyle = GeneratedColumn<String>(
    'training_style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sideStylesMeta = const VerificationMeta('sideStyles');
  @override
  late final GeneratedColumn<String> sideStyles = GeneratedColumn<String>(
    'side_styles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingLevelMeta = const VerificationMeta('trainingLevel');
  @override
  late final GeneratedColumn<String> trainingLevel = GeneratedColumn<String>(
    'training_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalMovesMeta = const VerificationMeta('goalMoves');
  @override
  late final GeneratedColumn<String> goalMoves = GeneratedColumn<String>(
    'goal_moves',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusAreasMeta = const VerificationMeta('focusAreas');
  @override
  late final GeneratedColumn<String> focusAreas = GeneratedColumn<String>(
    'focus_areas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    displayName,
    heightCm,
    weightKg,
    birthYear,
    sex,
    activityLevel,
    goal,
    calorieTarget,
    calorieTargetIsManual,
    units,
    weekStartsOn,
    timezone,
    theme,
    accent,
    themeFamily,
    accentColor,
    notificationSettings,
    onboardingCompleted,
    consentedAt,
    createdAt,
    updatedAt,
    username,
    avatarPath,
    trainingStyle,
    sideStyles,
    trainingLevel,
    goalMoves,
    focusAreas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(_sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(data['activity_level']!, _activityLevelMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(_goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('calorie_target')) {
      context.handle(
        _calorieTargetMeta,
        calorieTarget.isAcceptableOrUnknown(data['calorie_target']!, _calorieTargetMeta),
      );
    }
    if (data.containsKey('calorie_target_is_manual')) {
      context.handle(
        _calorieTargetIsManualMeta,
        calorieTargetIsManual.isAcceptableOrUnknown(
          data['calorie_target_is_manual']!,
          _calorieTargetIsManualMeta,
        ),
      );
    }
    if (data.containsKey('units')) {
      context.handle(_unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    }
    if (data.containsKey('week_starts_on')) {
      context.handle(
        _weekStartsOnMeta,
        weekStartsOn.isAcceptableOrUnknown(data['week_starts_on']!, _weekStartsOnMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(_themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('accent')) {
      context.handle(_accentMeta, accent.isAcceptableOrUnknown(data['accent']!, _accentMeta));
    }
    if (data.containsKey('theme_family')) {
      context.handle(
        _themeFamilyMeta,
        themeFamily.isAcceptableOrUnknown(data['theme_family']!, _themeFamilyMeta),
      );
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(data['accent_color']!, _accentColorMeta),
      );
    }
    if (data.containsKey('notification_settings')) {
      context.handle(
        _notificationSettingsMeta,
        notificationSettings.isAcceptableOrUnknown(
          data['notification_settings']!,
          _notificationSettingsMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('consented_at')) {
      context.handle(
        _consentedAtMeta,
        consentedAt.isAcceptableOrUnknown(data['consented_at']!, _consentedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('training_style')) {
      context.handle(
        _trainingStyleMeta,
        trainingStyle.isAcceptableOrUnknown(data['training_style']!, _trainingStyleMeta),
      );
    }
    if (data.containsKey('side_styles')) {
      context.handle(
        _sideStylesMeta,
        sideStyles.isAcceptableOrUnknown(data['side_styles']!, _sideStylesMeta),
      );
    }
    if (data.containsKey('training_level')) {
      context.handle(
        _trainingLevelMeta,
        trainingLevel.isAcceptableOrUnknown(data['training_level']!, _trainingLevelMeta),
      );
    }
    if (data.containsKey('goal_moves')) {
      context.handle(
        _goalMovesMeta,
        goalMoves.isAcceptableOrUnknown(data['goal_moves']!, _goalMovesMeta),
      );
    }
    if (data.containsKey('focus_areas')) {
      context.handle(
        _focusAreasMeta,
        focusAreas.isAcceptableOrUnknown(data['focus_areas']!, _focusAreasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      sex: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sex']),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      goal: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}goal']),
      calorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_target'],
      ),
      calorieTargetIsManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}calorie_target_is_manual'],
      )!,
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}units'],
      )!,
      weekStartsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_starts_on'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      accent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent'],
      )!,
      themeFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_family'],
      )!,
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_color'],
      )!,
      notificationSettings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_settings'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      consentedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consented_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      trainingStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_style'],
      ),
      sideStyles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_styles'],
      ),
      trainingLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_level'],
      ),
      goalMoves: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_moves'],
      ),
      focusAreas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus_areas'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String userId;
  final String? displayName;
  final double? heightCm;
  final double? weightKg;
  final int? birthYear;
  final String? sex;
  final String? activityLevel;
  final String? goal;
  final int? calorieTarget;
  final bool calorieTargetIsManual;
  final String units;
  final String weekStartsOn;
  final String timezone;
  final String theme;
  final String accent;
  final String themeFamily;
  final String accentColor;
  final String notificationSettings;
  final bool onboardingCompleted;
  final String? consentedAt;
  final String createdAt;
  final String updatedAt;

  /// Sunucuda sütun düzeyinde yetkili (RPC ile yazılır); normal güncellemeyle gönderilmez.
  final String? username;
  final String? avatarPath;

  /// Antrenman tarzı alanları. Liste sütunları JSON metin (`["a","b"]`); null = boş liste.
  final String? trainingStyle;
  final String? sideStyles;
  final String? trainingLevel;
  final String? goalMoves;
  final String? focusAreas;
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
    required this.calorieTargetIsManual,
    required this.units,
    required this.weekStartsOn,
    required this.timezone,
    required this.theme,
    required this.accent,
    required this.themeFamily,
    required this.accentColor,
    required this.notificationSettings,
    required this.onboardingCompleted,
    this.consentedAt,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.avatarPath,
    this.trainingStyle,
    this.sideStyles,
    this.trainingLevel,
    this.goalMoves,
    this.focusAreas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || calorieTarget != null) {
      map['calorie_target'] = Variable<int>(calorieTarget);
    }
    map['calorie_target_is_manual'] = Variable<bool>(calorieTargetIsManual);
    map['units'] = Variable<String>(units);
    map['week_starts_on'] = Variable<String>(weekStartsOn);
    map['timezone'] = Variable<String>(timezone);
    map['theme'] = Variable<String>(theme);
    map['accent'] = Variable<String>(accent);
    map['theme_family'] = Variable<String>(themeFamily);
    map['accent_color'] = Variable<String>(accentColor);
    map['notification_settings'] = Variable<String>(notificationSettings);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || consentedAt != null) {
      map['consented_at'] = Variable<String>(consentedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || trainingStyle != null) {
      map['training_style'] = Variable<String>(trainingStyle);
    }
    if (!nullToAbsent || sideStyles != null) {
      map['side_styles'] = Variable<String>(sideStyles);
    }
    if (!nullToAbsent || trainingLevel != null) {
      map['training_level'] = Variable<String>(trainingLevel);
    }
    if (!nullToAbsent || goalMoves != null) {
      map['goal_moves'] = Variable<String>(goalMoves);
    }
    if (!nullToAbsent || focusAreas != null) {
      map['focus_areas'] = Variable<String>(focusAreas);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      displayName: displayName == null && nullToAbsent ? const Value.absent() : Value(displayName),
      heightCm: heightCm == null && nullToAbsent ? const Value.absent() : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent ? const Value.absent() : Value(weightKg),
      birthYear: birthYear == null && nullToAbsent ? const Value.absent() : Value(birthYear),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      calorieTarget: calorieTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(calorieTarget),
      calorieTargetIsManual: Value(calorieTargetIsManual),
      units: Value(units),
      weekStartsOn: Value(weekStartsOn),
      timezone: Value(timezone),
      theme: Value(theme),
      accent: Value(accent),
      themeFamily: Value(themeFamily),
      accentColor: Value(accentColor),
      notificationSettings: Value(notificationSettings),
      onboardingCompleted: Value(onboardingCompleted),
      consentedAt: consentedAt == null && nullToAbsent ? const Value.absent() : Value(consentedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      username: username == null && nullToAbsent ? const Value.absent() : Value(username),
      avatarPath: avatarPath == null && nullToAbsent ? const Value.absent() : Value(avatarPath),
      trainingStyle: trainingStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingStyle),
      sideStyles: sideStyles == null && nullToAbsent ? const Value.absent() : Value(sideStyles),
      trainingLevel: trainingLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingLevel),
      goalMoves: goalMoves == null && nullToAbsent ? const Value.absent() : Value(goalMoves),
      focusAreas: focusAreas == null && nullToAbsent ? const Value.absent() : Value(focusAreas),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      sex: serializer.fromJson<String?>(json['sex']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      goal: serializer.fromJson<String?>(json['goal']),
      calorieTarget: serializer.fromJson<int?>(json['calorieTarget']),
      calorieTargetIsManual: serializer.fromJson<bool>(json['calorieTargetIsManual']),
      units: serializer.fromJson<String>(json['units']),
      weekStartsOn: serializer.fromJson<String>(json['weekStartsOn']),
      timezone: serializer.fromJson<String>(json['timezone']),
      theme: serializer.fromJson<String>(json['theme']),
      accent: serializer.fromJson<String>(json['accent']),
      themeFamily: serializer.fromJson<String>(json['themeFamily']),
      accentColor: serializer.fromJson<String>(json['accentColor']),
      notificationSettings: serializer.fromJson<String>(json['notificationSettings']),
      onboardingCompleted: serializer.fromJson<bool>(json['onboardingCompleted']),
      consentedAt: serializer.fromJson<String?>(json['consentedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      username: serializer.fromJson<String?>(json['username']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      trainingStyle: serializer.fromJson<String?>(json['trainingStyle']),
      sideStyles: serializer.fromJson<String?>(json['sideStyles']),
      trainingLevel: serializer.fromJson<String?>(json['trainingLevel']),
      goalMoves: serializer.fromJson<String?>(json['goalMoves']),
      focusAreas: serializer.fromJson<String?>(json['focusAreas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String?>(displayName),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'birthYear': serializer.toJson<int?>(birthYear),
      'sex': serializer.toJson<String?>(sex),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'goal': serializer.toJson<String?>(goal),
      'calorieTarget': serializer.toJson<int?>(calorieTarget),
      'calorieTargetIsManual': serializer.toJson<bool>(calorieTargetIsManual),
      'units': serializer.toJson<String>(units),
      'weekStartsOn': serializer.toJson<String>(weekStartsOn),
      'timezone': serializer.toJson<String>(timezone),
      'theme': serializer.toJson<String>(theme),
      'accent': serializer.toJson<String>(accent),
      'themeFamily': serializer.toJson<String>(themeFamily),
      'accentColor': serializer.toJson<String>(accentColor),
      'notificationSettings': serializer.toJson<String>(notificationSettings),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'consentedAt': serializer.toJson<String?>(consentedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'username': serializer.toJson<String?>(username),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'trainingStyle': serializer.toJson<String?>(trainingStyle),
      'sideStyles': serializer.toJson<String?>(sideStyles),
      'trainingLevel': serializer.toJson<String?>(trainingLevel),
      'goalMoves': serializer.toJson<String?>(goalMoves),
      'focusAreas': serializer.toJson<String?>(focusAreas),
    };
  }

  Profile copyWith({
    String? userId,
    Value<String?> displayName = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
    Value<String?> goal = const Value.absent(),
    Value<int?> calorieTarget = const Value.absent(),
    bool? calorieTargetIsManual,
    String? units,
    String? weekStartsOn,
    String? timezone,
    String? theme,
    String? accent,
    String? themeFamily,
    String? accentColor,
    String? notificationSettings,
    bool? onboardingCompleted,
    Value<String?> consentedAt = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> username = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> trainingStyle = const Value.absent(),
    Value<String?> sideStyles = const Value.absent(),
    Value<String?> trainingLevel = const Value.absent(),
    Value<String?> goalMoves = const Value.absent(),
    Value<String?> focusAreas = const Value.absent(),
  }) => Profile(
    userId: userId ?? this.userId,
    displayName: displayName.present ? displayName.value : this.displayName,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    sex: sex.present ? sex.value : this.sex,
    activityLevel: activityLevel.present ? activityLevel.value : this.activityLevel,
    goal: goal.present ? goal.value : this.goal,
    calorieTarget: calorieTarget.present ? calorieTarget.value : this.calorieTarget,
    calorieTargetIsManual: calorieTargetIsManual ?? this.calorieTargetIsManual,
    units: units ?? this.units,
    weekStartsOn: weekStartsOn ?? this.weekStartsOn,
    timezone: timezone ?? this.timezone,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    themeFamily: themeFamily ?? this.themeFamily,
    accentColor: accentColor ?? this.accentColor,
    notificationSettings: notificationSettings ?? this.notificationSettings,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    consentedAt: consentedAt.present ? consentedAt.value : this.consentedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    username: username.present ? username.value : this.username,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    trainingStyle: trainingStyle.present ? trainingStyle.value : this.trainingStyle,
    sideStyles: sideStyles.present ? sideStyles.value : this.sideStyles,
    trainingLevel: trainingLevel.present ? trainingLevel.value : this.trainingLevel,
    goalMoves: goalMoves.present ? goalMoves.value : this.goalMoves,
    focusAreas: focusAreas.present ? focusAreas.value : this.focusAreas,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      sex: data.sex.present ? data.sex.value : this.sex,
      activityLevel: data.activityLevel.present ? data.activityLevel.value : this.activityLevel,
      goal: data.goal.present ? data.goal.value : this.goal,
      calorieTarget: data.calorieTarget.present ? data.calorieTarget.value : this.calorieTarget,
      calorieTargetIsManual: data.calorieTargetIsManual.present
          ? data.calorieTargetIsManual.value
          : this.calorieTargetIsManual,
      units: data.units.present ? data.units.value : this.units,
      weekStartsOn: data.weekStartsOn.present ? data.weekStartsOn.value : this.weekStartsOn,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      theme: data.theme.present ? data.theme.value : this.theme,
      accent: data.accent.present ? data.accent.value : this.accent,
      themeFamily: data.themeFamily.present ? data.themeFamily.value : this.themeFamily,
      accentColor: data.accentColor.present ? data.accentColor.value : this.accentColor,
      notificationSettings: data.notificationSettings.present
          ? data.notificationSettings.value
          : this.notificationSettings,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      consentedAt: data.consentedAt.present ? data.consentedAt.value : this.consentedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      username: data.username.present ? data.username.value : this.username,
      avatarPath: data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      trainingStyle: data.trainingStyle.present ? data.trainingStyle.value : this.trainingStyle,
      sideStyles: data.sideStyles.present ? data.sideStyles.value : this.sideStyles,
      trainingLevel: data.trainingLevel.present ? data.trainingLevel.value : this.trainingLevel,
      goalMoves: data.goalMoves.present ? data.goalMoves.value : this.goalMoves,
      focusAreas: data.focusAreas.present ? data.focusAreas.value : this.focusAreas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('calorieTargetIsManual: $calorieTargetIsManual, ')
          ..write('units: $units, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('timezone: $timezone, ')
          ..write('theme: $theme, ')
          ..write('accent: $accent, ')
          ..write('themeFamily: $themeFamily, ')
          ..write('accentColor: $accentColor, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('consentedAt: $consentedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('username: $username, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('trainingStyle: $trainingStyle, ')
          ..write('sideStyles: $sideStyles, ')
          ..write('trainingLevel: $trainingLevel, ')
          ..write('goalMoves: $goalMoves, ')
          ..write('focusAreas: $focusAreas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    userId,
    displayName,
    heightCm,
    weightKg,
    birthYear,
    sex,
    activityLevel,
    goal,
    calorieTarget,
    calorieTargetIsManual,
    units,
    weekStartsOn,
    timezone,
    theme,
    accent,
    themeFamily,
    accentColor,
    notificationSettings,
    onboardingCompleted,
    consentedAt,
    createdAt,
    updatedAt,
    username,
    avatarPath,
    trainingStyle,
    sideStyles,
    trainingLevel,
    goalMoves,
    focusAreas,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.birthYear == this.birthYear &&
          other.sex == this.sex &&
          other.activityLevel == this.activityLevel &&
          other.goal == this.goal &&
          other.calorieTarget == this.calorieTarget &&
          other.calorieTargetIsManual == this.calorieTargetIsManual &&
          other.units == this.units &&
          other.weekStartsOn == this.weekStartsOn &&
          other.timezone == this.timezone &&
          other.theme == this.theme &&
          other.accent == this.accent &&
          other.themeFamily == this.themeFamily &&
          other.accentColor == this.accentColor &&
          other.notificationSettings == this.notificationSettings &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.consentedAt == this.consentedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.username == this.username &&
          other.avatarPath == this.avatarPath &&
          other.trainingStyle == this.trainingStyle &&
          other.sideStyles == this.sideStyles &&
          other.trainingLevel == this.trainingLevel &&
          other.goalMoves == this.goalMoves &&
          other.focusAreas == this.focusAreas);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> userId;
  final Value<String?> displayName;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<int?> birthYear;
  final Value<String?> sex;
  final Value<String?> activityLevel;
  final Value<String?> goal;
  final Value<int?> calorieTarget;
  final Value<bool> calorieTargetIsManual;
  final Value<String> units;
  final Value<String> weekStartsOn;
  final Value<String> timezone;
  final Value<String> theme;
  final Value<String> accent;
  final Value<String> themeFamily;
  final Value<String> accentColor;
  final Value<String> notificationSettings;
  final Value<bool> onboardingCompleted;
  final Value<String?> consentedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> username;
  final Value<String?> avatarPath;
  final Value<String?> trainingStyle;
  final Value<String?> sideStyles;
  final Value<String?> trainingLevel;
  final Value<String?> goalMoves;
  final Value<String?> focusAreas;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.calorieTargetIsManual = const Value.absent(),
    this.units = const Value.absent(),
    this.weekStartsOn = const Value.absent(),
    this.timezone = const Value.absent(),
    this.theme = const Value.absent(),
    this.accent = const Value.absent(),
    this.themeFamily = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.notificationSettings = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.consentedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.username = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.trainingStyle = const Value.absent(),
    this.sideStyles = const Value.absent(),
    this.trainingLevel = const Value.absent(),
    this.goalMoves = const Value.absent(),
    this.focusAreas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    this.displayName = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.calorieTargetIsManual = const Value.absent(),
    this.units = const Value.absent(),
    this.weekStartsOn = const Value.absent(),
    this.timezone = const Value.absent(),
    this.theme = const Value.absent(),
    this.accent = const Value.absent(),
    this.themeFamily = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.notificationSettings = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.consentedAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.username = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.trainingStyle = const Value.absent(),
    this.sideStyles = const Value.absent(),
    this.trainingLevel = const Value.absent(),
    this.goalMoves = const Value.absent(),
    this.focusAreas = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<int>? birthYear,
    Expression<String>? sex,
    Expression<String>? activityLevel,
    Expression<String>? goal,
    Expression<int>? calorieTarget,
    Expression<bool>? calorieTargetIsManual,
    Expression<String>? units,
    Expression<String>? weekStartsOn,
    Expression<String>? timezone,
    Expression<String>? theme,
    Expression<String>? accent,
    Expression<String>? themeFamily,
    Expression<String>? accentColor,
    Expression<String>? notificationSettings,
    Expression<bool>? onboardingCompleted,
    Expression<String>? consentedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? username,
    Expression<String>? avatarPath,
    Expression<String>? trainingStyle,
    Expression<String>? sideStyles,
    Expression<String>? trainingLevel,
    Expression<String>? goalMoves,
    Expression<String>? focusAreas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (birthYear != null) 'birth_year': birthYear,
      if (sex != null) 'sex': sex,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goal != null) 'goal': goal,
      if (calorieTarget != null) 'calorie_target': calorieTarget,
      if (calorieTargetIsManual != null) 'calorie_target_is_manual': calorieTargetIsManual,
      if (units != null) 'units': units,
      if (weekStartsOn != null) 'week_starts_on': weekStartsOn,
      if (timezone != null) 'timezone': timezone,
      if (theme != null) 'theme': theme,
      if (accent != null) 'accent': accent,
      if (themeFamily != null) 'theme_family': themeFamily,
      if (accentColor != null) 'accent_color': accentColor,
      if (notificationSettings != null) 'notification_settings': notificationSettings,
      if (onboardingCompleted != null) 'onboarding_completed': onboardingCompleted,
      if (consentedAt != null) 'consented_at': consentedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (username != null) 'username': username,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (trainingStyle != null) 'training_style': trainingStyle,
      if (sideStyles != null) 'side_styles': sideStyles,
      if (trainingLevel != null) 'training_level': trainingLevel,
      if (goalMoves != null) 'goal_moves': goalMoves,
      if (focusAreas != null) 'focus_areas': focusAreas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? displayName,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<int?>? birthYear,
    Value<String?>? sex,
    Value<String?>? activityLevel,
    Value<String?>? goal,
    Value<int?>? calorieTarget,
    Value<bool>? calorieTargetIsManual,
    Value<String>? units,
    Value<String>? weekStartsOn,
    Value<String>? timezone,
    Value<String>? theme,
    Value<String>? accent,
    Value<String>? themeFamily,
    Value<String>? accentColor,
    Value<String>? notificationSettings,
    Value<bool>? onboardingCompleted,
    Value<String?>? consentedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? username,
    Value<String?>? avatarPath,
    Value<String?>? trainingStyle,
    Value<String?>? sideStyles,
    Value<String?>? trainingLevel,
    Value<String?>? goalMoves,
    Value<String?>? focusAreas,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      birthYear: birthYear ?? this.birthYear,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      calorieTargetIsManual: calorieTargetIsManual ?? this.calorieTargetIsManual,
      units: units ?? this.units,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      timezone: timezone ?? this.timezone,
      theme: theme ?? this.theme,
      accent: accent ?? this.accent,
      themeFamily: themeFamily ?? this.themeFamily,
      accentColor: accentColor ?? this.accentColor,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      consentedAt: consentedAt ?? this.consentedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      trainingStyle: trainingStyle ?? this.trainingStyle,
      sideStyles: sideStyles ?? this.sideStyles,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      goalMoves: goalMoves ?? this.goalMoves,
      focusAreas: focusAreas ?? this.focusAreas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (calorieTarget.present) {
      map['calorie_target'] = Variable<int>(calorieTarget.value);
    }
    if (calorieTargetIsManual.present) {
      map['calorie_target_is_manual'] = Variable<bool>(calorieTargetIsManual.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (weekStartsOn.present) {
      map['week_starts_on'] = Variable<String>(weekStartsOn.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (accent.present) {
      map['accent'] = Variable<String>(accent.value);
    }
    if (themeFamily.present) {
      map['theme_family'] = Variable<String>(themeFamily.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<String>(accentColor.value);
    }
    if (notificationSettings.present) {
      map['notification_settings'] = Variable<String>(notificationSettings.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (consentedAt.present) {
      map['consented_at'] = Variable<String>(consentedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (trainingStyle.present) {
      map['training_style'] = Variable<String>(trainingStyle.value);
    }
    if (sideStyles.present) {
      map['side_styles'] = Variable<String>(sideStyles.value);
    }
    if (trainingLevel.present) {
      map['training_level'] = Variable<String>(trainingLevel.value);
    }
    if (goalMoves.present) {
      map['goal_moves'] = Variable<String>(goalMoves.value);
    }
    if (focusAreas.present) {
      map['focus_areas'] = Variable<String>(focusAreas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('calorieTargetIsManual: $calorieTargetIsManual, ')
          ..write('units: $units, ')
          ..write('weekStartsOn: $weekStartsOn, ')
          ..write('timezone: $timezone, ')
          ..write('theme: $theme, ')
          ..write('accent: $accent, ')
          ..write('themeFamily: $themeFamily, ')
          ..write('accentColor: $accentColor, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('consentedAt: $consentedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('username: $username, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('trainingStyle: $trainingStyle, ')
          ..write('sideStyles: $sideStyles, ')
          ..write('trainingLevel: $trainingLevel, ')
          ..write('goalMoves: $goalMoves, ')
          ..write('focusAreas: $focusAreas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Antrenman'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekKeyMeta = const VerificationMeta('weekKey');
  @override
  late final GeneratedColumn<String> weekKey = GeneratedColumn<String>(
    'week_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedKcalMeta = const VerificationMeta('estimatedKcal');
  @override
  late final GeneratedColumn<int> estimatedKcal = GeneratedColumn<int>(
    'estimated_kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    templateId,
    name,
    startedAt,
    endedAt,
    localDate,
    weekKey,
    estimatedKcal,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta, endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('week_key')) {
      context.handle(_weekKeyMeta, weekKey.isAcceptableOrUnknown(data['week_key']!, _weekKeyMeta));
    } else if (isInserting) {
      context.missing(_weekKeyMeta);
    }
    if (data.containsKey('estimated_kcal')) {
      context.handle(
        _estimatedKcalMeta,
        estimatedKcal.isAcceptableOrUnknown(data['estimated_kcal']!, _estimatedKcalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ended_at'],
      ),
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      weekKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_key'],
      )!,
      estimatedKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_kcal'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final String userId;
  final String? templateId;
  final String name;
  final String startedAt;
  final String? endedAt;
  final String localDate;
  final String weekKey;
  final int? estimatedKcal;
  final String status;
  final String createdAt;
  final String updatedAt;
  const WorkoutSession({
    required this.id,
    required this.userId,
    this.templateId,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.localDate,
    required this.weekKey,
    this.estimatedKcal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['name'] = Variable<String>(name);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['local_date'] = Variable<String>(localDate);
    map['week_key'] = Variable<String>(weekKey);
    if (!nullToAbsent || estimatedKcal != null) {
      map['estimated_kcal'] = Variable<int>(estimatedKcal);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      templateId: templateId == null && nullToAbsent ? const Value.absent() : Value(templateId),
      name: Value(name),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent ? const Value.absent() : Value(endedAt),
      localDate: Value(localDate),
      weekKey: Value(weekKey),
      estimatedKcal: estimatedKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedKcal),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      name: serializer.fromJson<String>(json['name']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      weekKey: serializer.fromJson<String>(json['weekKey']),
      estimatedKcal: serializer.fromJson<int?>(json['estimatedKcal']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'templateId': serializer.toJson<String?>(templateId),
      'name': serializer.toJson<String>(name),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'localDate': serializer.toJson<String>(localDate),
      'weekKey': serializer.toJson<String>(weekKey),
      'estimatedKcal': serializer.toJson<int?>(estimatedKcal),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    Value<String?> templateId = const Value.absent(),
    String? name,
    String? startedAt,
    Value<String?> endedAt = const Value.absent(),
    String? localDate,
    String? weekKey,
    Value<int?> estimatedKcal = const Value.absent(),
    String? status,
    String? createdAt,
    String? updatedAt,
  }) => WorkoutSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    templateId: templateId.present ? templateId.value : this.templateId,
    name: name ?? this.name,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    localDate: localDate ?? this.localDate,
    weekKey: weekKey ?? this.weekKey,
    estimatedKcal: estimatedKcal.present ? estimatedKcal.value : this.estimatedKcal,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      templateId: data.templateId.present ? data.templateId.value : this.templateId,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      weekKey: data.weekKey.present ? data.weekKey.value : this.weekKey,
      estimatedKcal: data.estimatedKcal.present ? data.estimatedKcal.value : this.estimatedKcal,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('localDate: $localDate, ')
          ..write('weekKey: $weekKey, ')
          ..write('estimatedKcal: $estimatedKcal, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    templateId,
    name,
    startedAt,
    endedAt,
    localDate,
    weekKey,
    estimatedKcal,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.templateId == this.templateId &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.localDate == this.localDate &&
          other.weekKey == this.weekKey &&
          other.estimatedKcal == this.estimatedKcal &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> templateId;
  final Value<String> name;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<String> localDate;
  final Value<String> weekKey;
  final Value<int?> estimatedKcal;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.weekKey = const Value.absent(),
    this.estimatedKcal = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String userId,
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    required String startedAt,
    this.endedAt = const Value.absent(),
    required String localDate,
    required String weekKey,
    this.estimatedKcal = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startedAt = Value(startedAt),
       localDate = Value(localDate),
       weekKey = Value(weekKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? templateId,
    Expression<String>? name,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<String>? localDate,
    Expression<String>? weekKey,
    Expression<int>? estimatedKcal,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (templateId != null) 'template_id': templateId,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (localDate != null) 'local_date': localDate,
      if (weekKey != null) 'week_key': weekKey,
      if (estimatedKcal != null) 'estimated_kcal': estimatedKcal,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? templateId,
    Value<String>? name,
    Value<String>? startedAt,
    Value<String?>? endedAt,
    Value<String>? localDate,
    Value<String>? weekKey,
    Value<int?>? estimatedKcal,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      localDate: localDate ?? this.localDate,
      weekKey: weekKey ?? this.weekKey,
      estimatedKcal: estimatedKcal ?? this.estimatedKcal,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (weekKey.present) {
      map['week_key'] = Variable<String>(weekKey.value);
    }
    if (estimatedKcal.present) {
      map['estimated_kcal'] = Variable<int>(estimatedKcal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('localDate: $localDate, ')
          ..write('weekKey: $weekKey, ')
          ..write('estimatedKcal: $estimatedKcal, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSetsTable extends SessionSets with TableInfo<$SessionSetsTable, SessionSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseOrderMeta = const VerificationMeta('exerciseOrder');
  @override
  late final GeneratedColumn<int> exerciseOrder = GeneratedColumn<int>(
    'exercise_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta('setIndex');
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    userId,
    exerciseId,
    exerciseOrder,
    setIndex,
    reps,
    durationSeconds,
    weightKg,
    completedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_order')) {
      context.handle(
        _exerciseOrderMeta,
        exerciseOrder.isAcceptableOrUnknown(data['exercise_order']!, _exerciseOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseOrderMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(_repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(data['duration_seconds']!, _durationSecondsMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, exerciseOrder, setIndex},
  ];
  @override
  SessionSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSet(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_order'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      reps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reps']),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionSetsTable createAlias(String alias) {
    return $SessionSetsTable(attachedDatabase, alias);
  }
}

class SessionSet extends DataClass implements Insertable<SessionSet> {
  final String id;
  final String sessionId;
  final String userId;
  final String exerciseId;
  final int exerciseOrder;
  final int setIndex;
  final int? reps;
  final int? durationSeconds;
  final double? weightKg;
  final String completedAt;
  final String updatedAt;
  const SessionSet({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setIndex,
    this.reps,
    this.durationSeconds,
    this.weightKg,
    required this.completedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_order'] = Variable<int>(exerciseOrder);
    map['set_index'] = Variable<int>(setIndex);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['completed_at'] = Variable<String>(completedAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SessionSetsCompanion toCompanion(bool nullToAbsent) {
    return SessionSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      userId: Value(userId),
      exerciseId: Value(exerciseId),
      exerciseOrder: Value(exerciseOrder),
      setIndex: Value(setIndex),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      weightKg: weightKg == null && nullToAbsent ? const Value.absent() : Value(weightKg),
      completedAt: Value(completedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionSet.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSet(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseOrder: serializer.fromJson<int>(json['exerciseOrder']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      completedAt: serializer.fromJson<String>(json['completedAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseOrder': serializer.toJson<int>(exerciseOrder),
      'setIndex': serializer.toJson<int>(setIndex),
      'reps': serializer.toJson<int?>(reps),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'weightKg': serializer.toJson<double?>(weightKg),
      'completedAt': serializer.toJson<String>(completedAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SessionSet copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? exerciseId,
    int? exerciseOrder,
    int? setIndex,
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    String? completedAt,
    String? updatedAt,
  }) => SessionSet(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseOrder: exerciseOrder ?? this.exerciseOrder,
    setIndex: setIndex ?? this.setIndex,
    reps: reps.present ? reps.value : this.reps,
    durationSeconds: durationSeconds.present ? durationSeconds.value : this.durationSeconds,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    completedAt: completedAt ?? this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionSet copyWithCompanion(SessionSetsCompanion data) {
    return SessionSet(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      exerciseOrder: data.exerciseOrder.present ? data.exerciseOrder.value : this.exerciseOrder,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSet(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseOrder: $exerciseOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('weightKg: $weightKg, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    userId,
    exerciseId,
    exerciseOrder,
    setIndex,
    reps,
    durationSeconds,
    weightKg,
    completedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSet &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseOrder == this.exerciseOrder &&
          other.setIndex == this.setIndex &&
          other.reps == this.reps &&
          other.durationSeconds == this.durationSeconds &&
          other.weightKg == this.weightKg &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt);
}

class SessionSetsCompanion extends UpdateCompanion<SessionSet> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> exerciseId;
  final Value<int> exerciseOrder;
  final Value<int> setIndex;
  final Value<int?> reps;
  final Value<int?> durationSeconds;
  final Value<double?> weightKg;
  final Value<String> completedAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SessionSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseOrder = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSetsCompanion.insert({
    required String id,
    required String sessionId,
    required String userId,
    required String exerciseId,
    required int exerciseOrder,
    required int setIndex,
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.weightKg = const Value.absent(),
    required String completedAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       userId = Value(userId),
       exerciseId = Value(exerciseId),
       exerciseOrder = Value(exerciseOrder),
       setIndex = Value(setIndex),
       completedAt = Value(completedAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionSet> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? exerciseId,
    Expression<int>? exerciseOrder,
    Expression<int>? setIndex,
    Expression<int>? reps,
    Expression<int>? durationSeconds,
    Expression<double>? weightKg,
    Expression<String>? completedAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseOrder != null) 'exercise_order': exerciseOrder,
      if (setIndex != null) 'set_index': setIndex,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (weightKg != null) 'weight_kg': weightKg,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? userId,
    Value<String>? exerciseId,
    Value<int>? exerciseOrder,
    Value<int>? setIndex,
    Value<int?>? reps,
    Value<int?>? durationSeconds,
    Value<double?>? weightKg,
    Value<String>? completedAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
      setIndex: setIndex ?? this.setIndex,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      weightKg: weightKg ?? this.weightKg,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseOrder.present) {
      map['exercise_order'] = Variable<int>(exerciseOrder.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseOrder: $exerciseOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('weightKg: $weightKg, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFoodsTable extends CustomFoods with TableInfo<$CustomFoodsTable, CustomFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameTrMeta = const VerificationMeta('nameTr');
  @override
  late final GeneratedColumn<String> nameTr = GeneratedColumn<String>(
    'name_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta('kcalPer100g');
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta('proteinPer100g');
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbPer100gMeta = const VerificationMeta('carbPer100g');
  @override
  late final GeneratedColumn<double> carbPer100g = GeneratedColumn<double>(
    'carb_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta('fatPer100g');
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _defaultServingGramsMeta = const VerificationMeta(
    'defaultServingGrams',
  );
  @override
  late final GeneratedColumn<double> defaultServingGrams = GeneratedColumn<double>(
    'default_serving_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta('servingLabel');
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('100 g'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    nameTr,
    category,
    kcalPer100g,
    proteinPer100g,
    carbPer100g,
    fatPer100g,
    defaultServingGrams,
    servingLabel,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name_tr')) {
      context.handle(_nameTrMeta, nameTr.isAcceptableOrUnknown(data['name_tr']!, _nameTrMeta));
    } else if (isInserting) {
      context.missing(_nameTrMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('kcal_per_100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(data['kcal_per_100g']!, _kcalPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per_100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(data['protein_per_100g']!, _proteinPer100gMeta),
      );
    }
    if (data.containsKey('carb_per_100g')) {
      context.handle(
        _carbPer100gMeta,
        carbPer100g.isAcceptableOrUnknown(data['carb_per_100g']!, _carbPer100gMeta),
      );
    }
    if (data.containsKey('fat_per_100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per_100g']!, _fatPer100gMeta),
      );
    }
    if (data.containsKey('default_serving_grams')) {
      context.handle(
        _defaultServingGramsMeta,
        defaultServingGrams.isAcceptableOrUnknown(
          data['default_serving_grams']!,
          _defaultServingGramsMeta,
        ),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(data['serving_label']!, _servingLabelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFood(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      nameTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_tr'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per_100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_100g'],
      )!,
      carbPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb_per_100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per_100g'],
      )!,
      defaultServingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_serving_grams'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomFoodsTable createAlias(String alias) {
    return $CustomFoodsTable(attachedDatabase, alias);
  }
}

class CustomFood extends DataClass implements Insertable<CustomFood> {
  final String id;
  final String userId;
  final String nameTr;
  final String category;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbPer100g;
  final double fatPer100g;
  final double defaultServingGrams;
  final String servingLabel;
  final String createdAt;
  final String updatedAt;
  const CustomFood({
    required this.id,
    required this.userId,
    required this.nameTr,
    required this.category,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
    required this.servingLabel,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name_tr'] = Variable<String>(nameTr);
    map['category'] = Variable<String>(category);
    map['kcal_per_100g'] = Variable<double>(kcalPer100g);
    map['protein_per_100g'] = Variable<double>(proteinPer100g);
    map['carb_per_100g'] = Variable<double>(carbPer100g);
    map['fat_per_100g'] = Variable<double>(fatPer100g);
    map['default_serving_grams'] = Variable<double>(defaultServingGrams);
    map['serving_label'] = Variable<String>(servingLabel);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CustomFoodsCompanion toCompanion(bool nullToAbsent) {
    return CustomFoodsCompanion(
      id: Value(id),
      userId: Value(userId),
      nameTr: Value(nameTr),
      category: Value(category),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbPer100g: Value(carbPer100g),
      fatPer100g: Value(fatPer100g),
      defaultServingGrams: Value(defaultServingGrams),
      servingLabel: Value(servingLabel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomFood.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFood(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      nameTr: serializer.fromJson<String>(json['nameTr']),
      category: serializer.fromJson<String>(json['category']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbPer100g: serializer.fromJson<double>(json['carbPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      defaultServingGrams: serializer.fromJson<double>(json['defaultServingGrams']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'nameTr': serializer.toJson<String>(nameTr),
      'category': serializer.toJson<String>(category),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbPer100g': serializer.toJson<double>(carbPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'defaultServingGrams': serializer.toJson<double>(defaultServingGrams),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CustomFood copyWith({
    String? id,
    String? userId,
    String? nameTr,
    String? category,
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbPer100g,
    double? fatPer100g,
    double? defaultServingGrams,
    String? servingLabel,
    String? createdAt,
    String? updatedAt,
  }) => CustomFood(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    nameTr: nameTr ?? this.nameTr,
    category: category ?? this.category,
    kcalPer100g: kcalPer100g ?? this.kcalPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbPer100g: carbPer100g ?? this.carbPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
    servingLabel: servingLabel ?? this.servingLabel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomFood copyWithCompanion(CustomFoodsCompanion data) {
    return CustomFood(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nameTr: data.nameTr.present ? data.nameTr.value : this.nameTr,
      category: data.category.present ? data.category.value : this.category,
      kcalPer100g: data.kcalPer100g.present ? data.kcalPer100g.value : this.kcalPer100g,
      proteinPer100g: data.proteinPer100g.present ? data.proteinPer100g.value : this.proteinPer100g,
      carbPer100g: data.carbPer100g.present ? data.carbPer100g.value : this.carbPer100g,
      fatPer100g: data.fatPer100g.present ? data.fatPer100g.value : this.fatPer100g,
      defaultServingGrams: data.defaultServingGrams.present
          ? data.defaultServingGrams.value
          : this.defaultServingGrams,
      servingLabel: data.servingLabel.present ? data.servingLabel.value : this.servingLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFood(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nameTr: $nameTr, ')
          ..write('category: $category, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbPer100g: $carbPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    nameTr,
    category,
    kcalPer100g,
    proteinPer100g,
    carbPer100g,
    fatPer100g,
    defaultServingGrams,
    servingLabel,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFood &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nameTr == this.nameTr &&
          other.category == this.category &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.carbPer100g == this.carbPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.defaultServingGrams == this.defaultServingGrams &&
          other.servingLabel == this.servingLabel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomFoodsCompanion extends UpdateCompanion<CustomFood> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> nameTr;
  final Value<String> category;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbPer100g;
  final Value<double> fatPer100g;
  final Value<double> defaultServingGrams;
  final Value<String> servingLabel;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const CustomFoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nameTr = const Value.absent(),
    this.category = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFoodsCompanion.insert({
    required String id,
    required String userId,
    required String nameTr,
    this.category = const Value.absent(),
    required double kcalPer100g,
    this.proteinPer100g = const Value.absent(),
    this.carbPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       nameTr = Value(nameTr),
       kcalPer100g = Value(kcalPer100g),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? nameTr,
    Expression<String>? category,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? carbPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? defaultServingGrams,
    Expression<String>? servingLabel,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nameTr != null) 'name_tr': nameTr,
      if (category != null) 'category': category,
      if (kcalPer100g != null) 'kcal_per_100g': kcalPer100g,
      if (proteinPer100g != null) 'protein_per_100g': proteinPer100g,
      if (carbPer100g != null) 'carb_per_100g': carbPer100g,
      if (fatPer100g != null) 'fat_per_100g': fatPer100g,
      if (defaultServingGrams != null) 'default_serving_grams': defaultServingGrams,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? nameTr,
    Value<String>? category,
    Value<double>? kcalPer100g,
    Value<double>? proteinPer100g,
    Value<double>? carbPer100g,
    Value<double>? fatPer100g,
    Value<double>? defaultServingGrams,
    Value<String>? servingLabel,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomFoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nameTr: nameTr ?? this.nameTr,
      category: category ?? this.category,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbPer100g: carbPer100g ?? this.carbPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
      servingLabel: servingLabel ?? this.servingLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nameTr.present) {
      map['name_tr'] = Variable<String>(nameTr.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per_100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per_100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbPer100g.present) {
      map['carb_per_100g'] = Variable<double>(carbPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per_100g'] = Variable<double>(fatPer100g.value);
    }
    if (defaultServingGrams.present) {
      map['default_serving_grams'] = Variable<double>(defaultServingGrams.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nameTr: $nameTr, ')
          ..write('category: $category, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbPer100g: $carbPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodEntriesTable extends FoodEntries with TableInfo<$FoodEntriesTable, FoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFoodIdMeta = const VerificationMeta('customFoodId');
  @override
  late final GeneratedColumn<String> customFoodId = GeneratedColumn<String>(
    'custom_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbMeta = const VerificationMeta('carb');
  @override
  late final GeneratedColumn<double> carb = GeneratedColumn<double>(
    'carb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isManualOverrideMeta = const VerificationMeta('isManualOverride');
  @override
  late final GeneratedColumn<bool> isManualOverride = GeneratedColumn<bool>(
    'is_manual_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta('loggedAt');
  @override
  late final GeneratedColumn<String> loggedAt = GeneratedColumn<String>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    localDate,
    meal,
    foodId,
    customFoodId,
    name,
    amount,
    unit,
    grams,
    kcal,
    protein,
    carb,
    fat,
    isManualOverride,
    loggedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(_mealMeta, meal.isAcceptableOrUnknown(data['meal']!, _mealMeta));
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta, foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('custom_food_id')) {
      context.handle(
        _customFoodIdMeta,
        customFoodId.isAcceptableOrUnknown(data['custom_food_id']!, _customFoodIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(_unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(_gramsMeta, grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta));
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(_kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta, protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    }
    if (data.containsKey('carb')) {
      context.handle(_carbMeta, carb.isAcceptableOrUnknown(data['carb']!, _carbMeta));
    }
    if (data.containsKey('fat')) {
      context.handle(_fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    }
    if (data.containsKey('is_manual_override')) {
      context.handle(
        _isManualOverrideMeta,
        isManualOverride.isAcceptableOrUnknown(data['is_manual_override']!, _isManualOverrideMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      meal: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}meal'])!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      ),
      customFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_food_id'],
      ),
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      unit: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      kcal: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kcal'])!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      carb: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}carb'])!,
      fat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      isManualOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual_override'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logged_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodEntriesTable createAlias(String alias) {
    return $FoodEntriesTable(attachedDatabase, alias);
  }
}

class FoodEntry extends DataClass implements Insertable<FoodEntry> {
  final String id;
  final String userId;
  final String localDate;
  final String meal;
  final String? foodId;
  final String? customFoodId;
  final String name;
  final double amount;
  final String unit;
  final double grams;
  final double kcal;
  final double protein;
  final double carb;
  final double fat;
  final bool isManualOverride;
  final String loggedAt;
  final String createdAt;
  final String updatedAt;
  const FoodEntry({
    required this.id,
    required this.userId,
    required this.localDate,
    required this.meal,
    this.foodId,
    this.customFoodId,
    required this.name,
    required this.amount,
    required this.unit,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.isManualOverride,
    required this.loggedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['local_date'] = Variable<String>(localDate);
    map['meal'] = Variable<String>(meal);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    if (!nullToAbsent || customFoodId != null) {
      map['custom_food_id'] = Variable<String>(customFoodId);
    }
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['unit'] = Variable<String>(unit);
    map['grams'] = Variable<double>(grams);
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['carb'] = Variable<double>(carb);
    map['fat'] = Variable<double>(fat);
    map['is_manual_override'] = Variable<bool>(isManualOverride);
    map['logged_at'] = Variable<String>(loggedAt);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      localDate: Value(localDate),
      meal: Value(meal),
      foodId: foodId == null && nullToAbsent ? const Value.absent() : Value(foodId),
      customFoodId: customFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(customFoodId),
      name: Value(name),
      amount: Value(amount),
      unit: Value(unit),
      grams: Value(grams),
      kcal: Value(kcal),
      protein: Value(protein),
      carb: Value(carb),
      fat: Value(fat),
      isManualOverride: Value(isManualOverride),
      loggedAt: Value(loggedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      meal: serializer.fromJson<String>(json['meal']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      customFoodId: serializer.fromJson<String?>(json['customFoodId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      unit: serializer.fromJson<String>(json['unit']),
      grams: serializer.fromJson<double>(json['grams']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      carb: serializer.fromJson<double>(json['carb']),
      fat: serializer.fromJson<double>(json['fat']),
      isManualOverride: serializer.fromJson<bool>(json['isManualOverride']),
      loggedAt: serializer.fromJson<String>(json['loggedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'localDate': serializer.toJson<String>(localDate),
      'meal': serializer.toJson<String>(meal),
      'foodId': serializer.toJson<String?>(foodId),
      'customFoodId': serializer.toJson<String?>(customFoodId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'unit': serializer.toJson<String>(unit),
      'grams': serializer.toJson<double>(grams),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'carb': serializer.toJson<double>(carb),
      'fat': serializer.toJson<double>(fat),
      'isManualOverride': serializer.toJson<bool>(isManualOverride),
      'loggedAt': serializer.toJson<String>(loggedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FoodEntry copyWith({
    String? id,
    String? userId,
    String? localDate,
    String? meal,
    Value<String?> foodId = const Value.absent(),
    Value<String?> customFoodId = const Value.absent(),
    String? name,
    double? amount,
    String? unit,
    double? grams,
    double? kcal,
    double? protein,
    double? carb,
    double? fat,
    bool? isManualOverride,
    String? loggedAt,
    String? createdAt,
    String? updatedAt,
  }) => FoodEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    localDate: localDate ?? this.localDate,
    meal: meal ?? this.meal,
    foodId: foodId.present ? foodId.value : this.foodId,
    customFoodId: customFoodId.present ? customFoodId.value : this.customFoodId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    unit: unit ?? this.unit,
    grams: grams ?? this.grams,
    kcal: kcal ?? this.kcal,
    protein: protein ?? this.protein,
    carb: carb ?? this.carb,
    fat: fat ?? this.fat,
    isManualOverride: isManualOverride ?? this.isManualOverride,
    loggedAt: loggedAt ?? this.loggedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FoodEntry copyWithCompanion(FoodEntriesCompanion data) {
    return FoodEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      customFoodId: data.customFoodId.present ? data.customFoodId.value : this.customFoodId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      unit: data.unit.present ? data.unit.value : this.unit,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      carb: data.carb.present ? data.carb.value : this.carb,
      fat: data.fat.present ? data.fat.value : this.fat,
      isManualOverride: data.isManualOverride.present
          ? data.isManualOverride.value
          : this.isManualOverride,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat, ')
          ..write('isManualOverride: $isManualOverride, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    localDate,
    meal,
    foodId,
    customFoodId,
    name,
    amount,
    unit,
    grams,
    kcal,
    protein,
    carb,
    fat,
    isManualOverride,
    loggedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.localDate == this.localDate &&
          other.meal == this.meal &&
          other.foodId == this.foodId &&
          other.customFoodId == this.customFoodId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.unit == this.unit &&
          other.grams == this.grams &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.carb == this.carb &&
          other.fat == this.fat &&
          other.isManualOverride == this.isManualOverride &&
          other.loggedAt == this.loggedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodEntriesCompanion extends UpdateCompanion<FoodEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> localDate;
  final Value<String> meal;
  final Value<String?> foodId;
  final Value<String?> customFoodId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> unit;
  final Value<double> grams;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> carb;
  final Value<double> fat;
  final Value<bool> isManualOverride;
  final Value<String> loggedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const FoodEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodId = const Value.absent(),
    this.customFoodId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
    this.isManualOverride = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodEntriesCompanion.insert({
    required String id,
    required String userId,
    required String localDate,
    required String meal,
    this.foodId = const Value.absent(),
    this.customFoodId = const Value.absent(),
    required String name,
    required double amount,
    required String unit,
    required double grams,
    required double kcal,
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
    this.isManualOverride = const Value.absent(),
    required String loggedAt,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       localDate = Value(localDate),
       meal = Value(meal),
       name = Value(name),
       amount = Value(amount),
       unit = Value(unit),
       grams = Value(grams),
       kcal = Value(kcal),
       loggedAt = Value(loggedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FoodEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? localDate,
    Expression<String>? meal,
    Expression<String>? foodId,
    Expression<String>? customFoodId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? unit,
    Expression<double>? grams,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? carb,
    Expression<double>? fat,
    Expression<bool>? isManualOverride,
    Expression<String>? loggedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (localDate != null) 'local_date': localDate,
      if (meal != null) 'meal': meal,
      if (foodId != null) 'food_id': foodId,
      if (customFoodId != null) 'custom_food_id': customFoodId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (grams != null) 'grams': grams,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (carb != null) 'carb': carb,
      if (fat != null) 'fat': fat,
      if (isManualOverride != null) 'is_manual_override': isManualOverride,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? localDate,
    Value<String>? meal,
    Value<String?>? foodId,
    Value<String?>? customFoodId,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? unit,
    Value<double>? grams,
    Value<double>? kcal,
    Value<double>? protein,
    Value<double>? carb,
    Value<double>? fat,
    Value<bool>? isManualOverride,
    Value<String>? loggedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoodEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      localDate: localDate ?? this.localDate,
      meal: meal ?? this.meal,
      foodId: foodId ?? this.foodId,
      customFoodId: customFoodId ?? this.customFoodId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carb: carb ?? this.carb,
      fat: fat ?? this.fat,
      isManualOverride: isManualOverride ?? this.isManualOverride,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (customFoodId.present) {
      map['custom_food_id'] = Variable<String>(customFoodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carb.present) {
      map['carb'] = Variable<double>(carb.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (isManualOverride.present) {
      map['is_manual_override'] = Variable<bool>(isManualOverride.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<String>(loggedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat, ')
          ..write('isManualOverride: $isManualOverride, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods with TableInfo<$FavoriteFoodsTable, FavoriteFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFoodIdMeta = const VerificationMeta('customFoodId');
  @override
  late final GeneratedColumn<String> customFoodId = GeneratedColumn<String>(
    'custom_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, foodId, customFoodId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta, foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('custom_food_id')) {
      context.handle(
        _customFoodIdMeta,
        customFoodId.isAcceptableOrUnknown(data['custom_food_id']!, _customFoodIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFood(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      ),
      customFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_food_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFood extends DataClass implements Insertable<FavoriteFood> {
  final String id;
  final String userId;
  final String? foodId;
  final String? customFoodId;
  final String createdAt;
  final String updatedAt;
  const FavoriteFood({
    required this.id,
    required this.userId,
    this.foodId,
    this.customFoodId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    if (!nullToAbsent || customFoodId != null) {
      map['custom_food_id'] = Variable<String>(customFoodId);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteFoodsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      id: Value(id),
      userId: Value(userId),
      foodId: foodId == null && nullToAbsent ? const Value.absent() : Value(foodId),
      customFoodId: customFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(customFoodId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteFood.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFood(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      customFoodId: serializer.fromJson<String?>(json['customFoodId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'foodId': serializer.toJson<String?>(foodId),
      'customFoodId': serializer.toJson<String?>(customFoodId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteFood copyWith({
    String? id,
    String? userId,
    Value<String?> foodId = const Value.absent(),
    Value<String?> customFoodId = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => FavoriteFood(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    foodId: foodId.present ? foodId.value : this.foodId,
    customFoodId: customFoodId.present ? customFoodId.value : this.customFoodId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteFood copyWithCompanion(FavoriteFoodsCompanion data) {
    return FavoriteFood(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      customFoodId: data.customFoodId.present ? data.customFoodId.value : this.customFoodId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFood(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('foodId: $foodId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, foodId, customFoodId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFood &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.foodId == this.foodId &&
          other.customFoodId == this.customFoodId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteFoodsCompanion extends UpdateCompanion<FavoriteFood> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> foodId;
  final Value<String?> customFoodId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const FavoriteFoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.customFoodId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    required String id,
    required String userId,
    this.foodId = const Value.absent(),
    this.customFoodId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? foodId,
    Expression<String>? customFoodId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (foodId != null) 'food_id': foodId,
      if (customFoodId != null) 'custom_food_id': customFoodId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteFoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? foodId,
    Value<String?>? customFoodId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return FavoriteFoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      customFoodId: customFoodId ?? this.customFoodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (customFoodId.present) {
      map['custom_food_id'] = Variable<String>(customFoodId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('foodId: $foodId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta('repeatRule');
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{"type":"once"}'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultTaskIdMeta = const VerificationMeta('defaultTaskId');
  @override
  late final GeneratedColumn<String> defaultTaskId = GeneratedColumn<String>(
    'default_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    note,
    time,
    repeatRule,
    startDate,
    defaultTaskId,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('time')) {
      context.handle(_timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('default_task_id')) {
      context.handle(
        _defaultTaskIdMeta,
        defaultTaskId.isAcceptableOrUnknown(data['default_task_id']!, _defaultTaskIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      time: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}time']),
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      defaultTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_task_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String userId;
  final String title;
  final String? note;
  final String? time;
  final String repeatRule;
  final String startDate;
  final String? defaultTaskId;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.note,
    this.time,
    required this.repeatRule,
    required this.startDate,
    this.defaultTaskId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<String>(time);
    }
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || defaultTaskId != null) {
      map['default_task_id'] = Variable<String>(defaultTaskId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      repeatRule: Value(repeatRule),
      startDate: Value(startDate),
      defaultTaskId: defaultTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultTaskId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      time: serializer.fromJson<String?>(json['time']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      startDate: serializer.fromJson<String>(json['startDate']),
      defaultTaskId: serializer.fromJson<String?>(json['defaultTaskId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'time': serializer.toJson<String?>(time),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'startDate': serializer.toJson<String>(startDate),
      'defaultTaskId': serializer.toJson<String?>(defaultTaskId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    Value<String?> note = const Value.absent(),
    Value<String?> time = const Value.absent(),
    String? repeatRule,
    String? startDate,
    Value<String?> defaultTaskId = const Value.absent(),
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    time: time.present ? time.value : this.time,
    repeatRule: repeatRule ?? this.repeatRule,
    startDate: startDate ?? this.startDate,
    defaultTaskId: defaultTaskId.present ? defaultTaskId.value : this.defaultTaskId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      time: data.time.present ? data.time.value : this.time,
      repeatRule: data.repeatRule.present ? data.repeatRule.value : this.repeatRule,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      defaultTaskId: data.defaultTaskId.present ? data.defaultTaskId.value : this.defaultTaskId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('time: $time, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('startDate: $startDate, ')
          ..write('defaultTaskId: $defaultTaskId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    note,
    time,
    repeatRule,
    startDate,
    defaultTaskId,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.note == this.note &&
          other.time == this.time &&
          other.repeatRule == this.repeatRule &&
          other.startDate == this.startDate &&
          other.defaultTaskId == this.defaultTaskId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> time;
  final Value<String> repeatRule;
  final Value<String> startDate;
  final Value<String?> defaultTaskId;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.time = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.startDate = const Value.absent(),
    this.defaultTaskId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.note = const Value.absent(),
    this.time = const Value.absent(),
    this.repeatRule = const Value.absent(),
    required String startDate,
    this.defaultTaskId = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? time,
    Expression<String>? repeatRule,
    Expression<String>? startDate,
    Expression<String>? defaultTaskId,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (time != null) 'time': time,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (startDate != null) 'start_date': startDate,
      if (defaultTaskId != null) 'default_task_id': defaultTaskId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? note,
    Value<String?>? time,
    Value<String>? repeatRule,
    Value<String>? startDate,
    Value<String?>? defaultTaskId,
    Value<bool>? isActive,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      note: note ?? this.note,
      time: time ?? this.time,
      repeatRule: repeatRule ?? this.repeatRule,
      startDate: startDate ?? this.startDate,
      defaultTaskId: defaultTaskId ?? this.defaultTaskId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (defaultTaskId.present) {
      map['default_task_id'] = Variable<String>(defaultTaskId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('time: $time, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('startDate: $startDate, ')
          ..write('defaultTaskId: $defaultTaskId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskCompletionsTable extends TaskCompletions
    with TableInfo<$TaskCompletionsTable, TaskCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, taskId, localDate, completedAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {taskId, localDate},
  ];
  @override
  TaskCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCompletion(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TaskCompletionsTable createAlias(String alias) {
    return $TaskCompletionsTable(attachedDatabase, alias);
  }
}

class TaskCompletion extends DataClass implements Insertable<TaskCompletion> {
  final String id;
  final String userId;
  final String taskId;
  final String localDate;
  final String completedAt;
  final String updatedAt;
  const TaskCompletion({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.localDate,
    required this.completedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<String>(taskId);
    map['local_date'] = Variable<String>(localDate);
    map['completed_at'] = Variable<String>(completedAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  TaskCompletionsCompanion toCompanion(bool nullToAbsent) {
    return TaskCompletionsCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      localDate: Value(localDate),
      completedAt: Value(completedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskCompletion.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCompletion(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      completedAt: serializer.fromJson<String>(json['completedAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String>(taskId),
      'localDate': serializer.toJson<String>(localDate),
      'completedAt': serializer.toJson<String>(completedAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  TaskCompletion copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? localDate,
    String? completedAt,
    String? updatedAt,
  }) => TaskCompletion(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    localDate: localDate ?? this.localDate,
    completedAt: completedAt ?? this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskCompletion copyWithCompanion(TaskCompletionsCompanion data) {
    return TaskCompletion(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('localDate: $localDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, taskId, localDate, completedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCompletion &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.localDate == this.localDate &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt);
}

class TaskCompletionsCompanion extends UpdateCompanion<TaskCompletion> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskId;
  final Value<String> localDate;
  final Value<String> completedAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const TaskCompletionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskCompletionsCompanion.insert({
    required String id,
    required String userId,
    required String taskId,
    required String localDate,
    required String completedAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       localDate = Value(localDate),
       completedAt = Value(completedAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskCompletion> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<String>? localDate,
    Expression<String>? completedAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (localDate != null) 'local_date': localDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskId,
    Value<String>? localDate,
    Value<String>? completedAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return TaskCompletionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      localDate: localDate ?? this.localDate,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('localDate: $localDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MuscleGroupsTable extends MuscleGroups with TableInfo<$MuscleGroupsTable, MuscleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameTrMeta = const VerificationMeta('nameTr');
  @override
  late final GeneratedColumn<String> nameTr = GeneratedColumn<String>(
    'name_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyRegionMeta = const VerificationMeta('bodyRegion');
  @override
  late final GeneratedColumn<String> bodyRegion = GeneratedColumn<String>(
    'body_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewMeta = const VerificationMeta('view');
  @override
  late final GeneratedColumn<String> view = GeneratedColumn<String>(
    'view',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, slug, nameTr, bodyRegion, view, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscle_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuscleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_tr')) {
      context.handle(_nameTrMeta, nameTr.isAcceptableOrUnknown(data['name_tr']!, _nameTrMeta));
    } else if (isInserting) {
      context.missing(_nameTrMeta);
    }
    if (data.containsKey('body_region')) {
      context.handle(
        _bodyRegionMeta,
        bodyRegion.isAcceptableOrUnknown(data['body_region']!, _bodyRegionMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyRegionMeta);
    }
    if (data.containsKey('view')) {
      context.handle(_viewMeta, view.isAcceptableOrUnknown(data['view']!, _viewMeta));
    } else if (isInserting) {
      context.missing(_viewMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuscleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleGroup(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      nameTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_tr'],
      )!,
      bodyRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_region'],
      )!,
      view: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}view'])!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MuscleGroupsTable createAlias(String alias) {
    return $MuscleGroupsTable(attachedDatabase, alias);
  }
}

class MuscleGroup extends DataClass implements Insertable<MuscleGroup> {
  final String id;
  final String slug;
  final String nameTr;
  final String bodyRegion;
  final String view;
  final int sortOrder;
  final String createdAt;
  const MuscleGroup({
    required this.id,
    required this.slug,
    required this.nameTr,
    required this.bodyRegion,
    required this.view,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['name_tr'] = Variable<String>(nameTr);
    map['body_region'] = Variable<String>(bodyRegion);
    map['view'] = Variable<String>(view);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MuscleGroupsCompanion toCompanion(bool nullToAbsent) {
    return MuscleGroupsCompanion(
      id: Value(id),
      slug: Value(slug),
      nameTr: Value(nameTr),
      bodyRegion: Value(bodyRegion),
      view: Value(view),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory MuscleGroup.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleGroup(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameTr: serializer.fromJson<String>(json['nameTr']),
      bodyRegion: serializer.fromJson<String>(json['bodyRegion']),
      view: serializer.fromJson<String>(json['view']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'nameTr': serializer.toJson<String>(nameTr),
      'bodyRegion': serializer.toJson<String>(bodyRegion),
      'view': serializer.toJson<String>(view),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MuscleGroup copyWith({
    String? id,
    String? slug,
    String? nameTr,
    String? bodyRegion,
    String? view,
    int? sortOrder,
    String? createdAt,
  }) => MuscleGroup(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    nameTr: nameTr ?? this.nameTr,
    bodyRegion: bodyRegion ?? this.bodyRegion,
    view: view ?? this.view,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  MuscleGroup copyWithCompanion(MuscleGroupsCompanion data) {
    return MuscleGroup(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameTr: data.nameTr.present ? data.nameTr.value : this.nameTr,
      bodyRegion: data.bodyRegion.present ? data.bodyRegion.value : this.bodyRegion,
      view: data.view.present ? data.view.value : this.view,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroup(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('bodyRegion: $bodyRegion, ')
          ..write('view: $view, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, nameTr, bodyRegion, view, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleGroup &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameTr == this.nameTr &&
          other.bodyRegion == this.bodyRegion &&
          other.view == this.view &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class MuscleGroupsCompanion extends UpdateCompanion<MuscleGroup> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> nameTr;
  final Value<String> bodyRegion;
  final Value<String> view;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<int> rowid;
  const MuscleGroupsCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameTr = const Value.absent(),
    this.bodyRegion = const Value.absent(),
    this.view = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MuscleGroupsCompanion.insert({
    required String id,
    required String slug,
    required String nameTr,
    required String bodyRegion,
    required String view,
    this.sortOrder = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       nameTr = Value(nameTr),
       bodyRegion = Value(bodyRegion),
       view = Value(view),
       createdAt = Value(createdAt);
  static Insertable<MuscleGroup> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? nameTr,
    Expression<String>? bodyRegion,
    Expression<String>? view,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameTr != null) 'name_tr': nameTr,
      if (bodyRegion != null) 'body_region': bodyRegion,
      if (view != null) 'view': view,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MuscleGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? nameTr,
    Value<String>? bodyRegion,
    Value<String>? view,
    Value<int>? sortOrder,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return MuscleGroupsCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameTr: nameTr ?? this.nameTr,
      bodyRegion: bodyRegion ?? this.bodyRegion,
      view: view ?? this.view,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameTr.present) {
      map['name_tr'] = Variable<String>(nameTr.value);
    }
    if (bodyRegion.present) {
      map['body_region'] = Variable<String>(bodyRegion.value);
    }
    if (view.present) {
      map['view'] = Variable<String>(view.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('bodyRegion: $bodyRegion, ')
          ..write('view: $view, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameTrMeta = const VerificationMeta('nameTr');
  @override
  late final GeneratedColumn<String> nameTr = GeneratedColumn<String>(
    'name_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackingMeta = const VerificationMeta('tracking');
  @override
  late final GeneratedColumn<String> tracking = GeneratedColumn<String>(
    'tracking',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metValueMeta = const VerificationMeta('metValue');
  @override
  late final GeneratedColumn<double> metValue = GeneratedColumn<double>(
    'met_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    nameTr,
    nameEn,
    equipment,
    type,
    tracking,
    metValue,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_tr')) {
      context.handle(_nameTrMeta, nameTr.isAcceptableOrUnknown(data['name_tr']!, _nameTrMeta));
    } else if (isInserting) {
      context.missing(_nameTrMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta, nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('tracking')) {
      context.handle(
        _trackingMeta,
        tracking.isAcceptableOrUnknown(data['tracking']!, _trackingMeta),
      );
    } else if (isInserting) {
      context.missing(_trackingMeta);
    }
    if (data.containsKey('met_value')) {
      context.handle(
        _metValueMeta,
        metValue.isAcceptableOrUnknown(data['met_value']!, _metValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metValueMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      nameTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_tr'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      tracking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking'],
      )!,
      metValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}met_value'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String slug;
  final String nameTr;
  final String nameEn;
  final String equipment;
  final String type;
  final String tracking;
  final double metValue;
  final bool isActive;
  final String createdAt;
  const Exercise({
    required this.id,
    required this.slug,
    required this.nameTr,
    required this.nameEn,
    required this.equipment,
    required this.type,
    required this.tracking,
    required this.metValue,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['name_tr'] = Variable<String>(nameTr);
    map['name_en'] = Variable<String>(nameEn);
    map['equipment'] = Variable<String>(equipment);
    map['type'] = Variable<String>(type);
    map['tracking'] = Variable<String>(tracking);
    map['met_value'] = Variable<double>(metValue);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      slug: Value(slug),
      nameTr: Value(nameTr),
      nameEn: Value(nameEn),
      equipment: Value(equipment),
      type: Value(type),
      tracking: Value(tracking),
      metValue: Value(metValue),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameTr: serializer.fromJson<String>(json['nameTr']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      equipment: serializer.fromJson<String>(json['equipment']),
      type: serializer.fromJson<String>(json['type']),
      tracking: serializer.fromJson<String>(json['tracking']),
      metValue: serializer.fromJson<double>(json['metValue']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'nameTr': serializer.toJson<String>(nameTr),
      'nameEn': serializer.toJson<String>(nameEn),
      'equipment': serializer.toJson<String>(equipment),
      'type': serializer.toJson<String>(type),
      'tracking': serializer.toJson<String>(tracking),
      'metValue': serializer.toJson<double>(metValue),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Exercise copyWith({
    String? id,
    String? slug,
    String? nameTr,
    String? nameEn,
    String? equipment,
    String? type,
    String? tracking,
    double? metValue,
    bool? isActive,
    String? createdAt,
  }) => Exercise(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    nameTr: nameTr ?? this.nameTr,
    nameEn: nameEn ?? this.nameEn,
    equipment: equipment ?? this.equipment,
    type: type ?? this.type,
    tracking: tracking ?? this.tracking,
    metValue: metValue ?? this.metValue,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameTr: data.nameTr.present ? data.nameTr.value : this.nameTr,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      type: data.type.present ? data.type.value : this.type,
      tracking: data.tracking.present ? data.tracking.value : this.tracking,
      metValue: data.metValue.present ? data.metValue.value : this.metValue,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('nameEn: $nameEn, ')
          ..write('equipment: $equipment, ')
          ..write('type: $type, ')
          ..write('tracking: $tracking, ')
          ..write('metValue: $metValue, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    nameTr,
    nameEn,
    equipment,
    type,
    tracking,
    metValue,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameTr == this.nameTr &&
          other.nameEn == this.nameEn &&
          other.equipment == this.equipment &&
          other.type == this.type &&
          other.tracking == this.tracking &&
          other.metValue == this.metValue &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> nameTr;
  final Value<String> nameEn;
  final Value<String> equipment;
  final Value<String> type;
  final Value<String> tracking;
  final Value<double> metValue;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameTr = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.equipment = const Value.absent(),
    this.type = const Value.absent(),
    this.tracking = const Value.absent(),
    this.metValue = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String slug,
    required String nameTr,
    required String nameEn,
    required String equipment,
    required String type,
    required String tracking,
    required double metValue,
    this.isActive = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       nameTr = Value(nameTr),
       nameEn = Value(nameEn),
       equipment = Value(equipment),
       type = Value(type),
       tracking = Value(tracking),
       metValue = Value(metValue),
       createdAt = Value(createdAt);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? nameTr,
    Expression<String>? nameEn,
    Expression<String>? equipment,
    Expression<String>? type,
    Expression<String>? tracking,
    Expression<double>? metValue,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameTr != null) 'name_tr': nameTr,
      if (nameEn != null) 'name_en': nameEn,
      if (equipment != null) 'equipment': equipment,
      if (type != null) 'type': type,
      if (tracking != null) 'tracking': tracking,
      if (metValue != null) 'met_value': metValue,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? nameTr,
    Value<String>? nameEn,
    Value<String>? equipment,
    Value<String>? type,
    Value<String>? tracking,
    Value<double>? metValue,
    Value<bool>? isActive,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameTr: nameTr ?? this.nameTr,
      nameEn: nameEn ?? this.nameEn,
      equipment: equipment ?? this.equipment,
      type: type ?? this.type,
      tracking: tracking ?? this.tracking,
      metValue: metValue ?? this.metValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameTr.present) {
      map['name_tr'] = Variable<String>(nameTr.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (tracking.present) {
      map['tracking'] = Variable<String>(tracking.value);
    }
    if (metValue.present) {
      map['met_value'] = Variable<double>(metValue.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('nameEn: $nameEn, ')
          ..write('equipment: $equipment, ')
          ..write('type: $type, ')
          ..write('tracking: $tracking, ')
          ..write('metValue: $metValue, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles
    with TableInfo<$ExerciseMusclesTable, ExerciseMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupIdMeta = const VerificationMeta('muscleGroupId');
  @override
  late final GeneratedColumn<String> muscleGroupId = GeneratedColumn<String>(
    'muscle_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscleGroupId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_group_id')) {
      context.handle(
        _muscleGroupIdMeta,
        muscleGroupId.isAcceptableOrUnknown(data['muscle_group_id']!, _muscleGroupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscleGroupId};
  @override
  ExerciseMuscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscle(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group_id'],
      )!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseMuscle extends DataClass implements Insertable<ExerciseMuscle> {
  final String exerciseId;
  final String muscleGroupId;
  final String role;
  const ExerciseMuscle({required this.exerciseId, required this.muscleGroupId, required this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['muscle_group_id'] = Variable<String>(muscleGroupId);
    map['role'] = Variable<String>(role);
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscleGroupId: Value(muscleGroupId),
      role: Value(role),
    );
  }

  factory ExerciseMuscle.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscle(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscleGroupId: serializer.fromJson<String>(json['muscleGroupId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscleGroupId': serializer.toJson<String>(muscleGroupId),
      'role': serializer.toJson<String>(role),
    };
  }

  ExerciseMuscle copyWith({String? exerciseId, String? muscleGroupId, String? role}) =>
      ExerciseMuscle(
        exerciseId: exerciseId ?? this.exerciseId,
        muscleGroupId: muscleGroupId ?? this.muscleGroupId,
        role: role ?? this.role,
      );
  ExerciseMuscle copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscle(
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      muscleGroupId: data.muscleGroupId.present ? data.muscleGroupId.value : this.muscleGroupId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscleGroupId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscle &&
          other.exerciseId == this.exerciseId &&
          other.muscleGroupId == this.muscleGroupId &&
          other.role == this.role);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscle> {
  final Value<String> exerciseId;
  final Value<String> muscleGroupId;
  final Value<String> role;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscleGroupId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({
    required String exerciseId,
    required String muscleGroupId,
    required String role,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscleGroupId = Value(muscleGroupId),
       role = Value(role);
  static Insertable<ExerciseMuscle> custom({
    Expression<String>? exerciseId,
    Expression<String>? muscleGroupId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleGroupId != null) 'muscle_group_id': muscleGroupId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? muscleGroupId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (muscleGroupId.present) {
      map['muscle_group_id'] = Variable<String>(muscleGroupId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleGroupId: $muscleGroupId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplatesTable extends WorkoutTemplates
    with TableInfo<$WorkoutTemplatesTable, WorkoutTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameTrMeta = const VerificationMeta('nameTr');
  @override
  late final GeneratedColumn<String> nameTr = GeneratedColumn<String>(
    'name_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    nameTr,
    description,
    level,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_tr')) {
      context.handle(_nameTrMeta, nameTr.isAcceptableOrUnknown(data['name_tr']!, _nameTrMeta));
    } else if (isInserting) {
      context.missing(_nameTrMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(data['description']!, _descriptionMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(_levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplate(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      nameTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_tr'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkoutTemplatesTable createAlias(String alias) {
    return $WorkoutTemplatesTable(attachedDatabase, alias);
  }
}

class WorkoutTemplate extends DataClass implements Insertable<WorkoutTemplate> {
  final String id;
  final String slug;
  final String nameTr;
  final String description;
  final String level;
  final int sortOrder;
  final String createdAt;
  const WorkoutTemplate({
    required this.id,
    required this.slug,
    required this.nameTr,
    required this.description,
    required this.level,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['name_tr'] = Variable<String>(nameTr);
    map['description'] = Variable<String>(description);
    map['level'] = Variable<String>(level);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  WorkoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplatesCompanion(
      id: Value(id),
      slug: Value(slug),
      nameTr: Value(nameTr),
      description: Value(description),
      level: Value(level),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplate(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameTr: serializer.fromJson<String>(json['nameTr']),
      description: serializer.fromJson<String>(json['description']),
      level: serializer.fromJson<String>(json['level']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'nameTr': serializer.toJson<String>(nameTr),
      'description': serializer.toJson<String>(description),
      'level': serializer.toJson<String>(level),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  WorkoutTemplate copyWith({
    String? id,
    String? slug,
    String? nameTr,
    String? description,
    String? level,
    int? sortOrder,
    String? createdAt,
  }) => WorkoutTemplate(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    nameTr: nameTr ?? this.nameTr,
    description: description ?? this.description,
    level: level ?? this.level,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkoutTemplate copyWithCompanion(WorkoutTemplatesCompanion data) {
    return WorkoutTemplate(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameTr: data.nameTr.present ? data.nameTr.value : this.nameTr,
      description: data.description.present ? data.description.value : this.description,
      level: data.level.present ? data.level.value : this.level,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplate(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('description: $description, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, nameTr, description, level, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplate &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameTr == this.nameTr &&
          other.description == this.description &&
          other.level == this.level &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class WorkoutTemplatesCompanion extends UpdateCompanion<WorkoutTemplate> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> nameTr;
  final Value<String> description;
  final Value<String> level;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<int> rowid;
  const WorkoutTemplatesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameTr = const Value.absent(),
    this.description = const Value.absent(),
    this.level = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplatesCompanion.insert({
    required String id,
    required String slug,
    required String nameTr,
    this.description = const Value.absent(),
    required String level,
    this.sortOrder = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       nameTr = Value(nameTr),
       level = Value(level),
       createdAt = Value(createdAt);
  static Insertable<WorkoutTemplate> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? nameTr,
    Expression<String>? description,
    Expression<String>? level,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameTr != null) 'name_tr': nameTr,
      if (description != null) 'description': description,
      if (level != null) 'level': level,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? nameTr,
    Value<String>? description,
    Value<String>? level,
    Value<int>? sortOrder,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkoutTemplatesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameTr: nameTr ?? this.nameTr,
      description: description ?? this.description,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameTr.present) {
      map['name_tr'] = Variable<String>(nameTr.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('description: $description, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplateExercisesTable extends WorkoutTemplateExercises
    with TableInfo<$WorkoutTemplateExercisesTable, WorkoutTemplateExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplateExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta('restSeconds');
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    exerciseId,
    orderIndex,
    sets,
    reps,
    durationSeconds,
    restSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_template_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplateExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(_setsMeta, sets.isAcceptableOrUnknown(data['sets']!, _setsMeta));
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(_repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(data['duration_seconds']!, _durationSecondsMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(data['rest_seconds']!, _restSecondsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {templateId, orderIndex},
  ];
  @override
  WorkoutTemplateExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplateExercise(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      sets: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sets'])!,
      reps: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reps']),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
    );
  }

  @override
  $WorkoutTemplateExercisesTable createAlias(String alias) {
    return $WorkoutTemplateExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutTemplateExercise extends DataClass implements Insertable<WorkoutTemplateExercise> {
  final String id;
  final String templateId;
  final String exerciseId;
  final int orderIndex;
  final int sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;
  const WorkoutTemplateExercise({
    required this.id,
    required this.templateId,
    required this.exerciseId,
    required this.orderIndex,
    required this.sets,
    this.reps,
    this.durationSeconds,
    required this.restSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    map['sets'] = Variable<int>(sets);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['rest_seconds'] = Variable<int>(restSeconds);
    return map;
  }

  WorkoutTemplateExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplateExercisesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      sets: Value(sets),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      restSeconds: Value(restSeconds),
    );
  }

  factory WorkoutTemplateExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplateExercise(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      sets: serializer.fromJson<int>(json['sets']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'sets': serializer.toJson<int>(sets),
      'reps': serializer.toJson<int?>(reps),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'restSeconds': serializer.toJson<int>(restSeconds),
    };
  }

  WorkoutTemplateExercise copyWith({
    String? id,
    String? templateId,
    String? exerciseId,
    int? orderIndex,
    int? sets,
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    int? restSeconds,
  }) => WorkoutTemplateExercise(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    sets: sets ?? this.sets,
    reps: reps.present ? reps.value : this.reps,
    durationSeconds: durationSeconds.present ? durationSeconds.value : this.durationSeconds,
    restSeconds: restSeconds ?? this.restSeconds,
  );
  WorkoutTemplateExercise copyWithCompanion(WorkoutTemplateExercisesCompanion data) {
    return WorkoutTemplateExercise(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present ? data.templateId.value : this.templateId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      orderIndex: data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      restSeconds: data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplateExercise(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, exerciseId, orderIndex, sets, reps, durationSeconds, restSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplateExercise &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.durationSeconds == this.durationSeconds &&
          other.restSeconds == this.restSeconds);
}

class WorkoutTemplateExercisesCompanion extends UpdateCompanion<WorkoutTemplateExercise> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int> sets;
  final Value<int?> reps;
  final Value<int?> durationSeconds;
  final Value<int> restSeconds;
  final Value<int> rowid;
  const WorkoutTemplateExercisesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplateExercisesCompanion.insert({
    required String id,
    required String templateId,
    required String exerciseId,
    required int orderIndex,
    required int sets,
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex),
       sets = Value(sets);
  static Insertable<WorkoutTemplateExercise> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<int>? durationSeconds,
    Expression<int>? restSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplateExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<int>? sets,
    Value<int?>? reps,
    Value<int?>? durationSeconds,
    Value<int>? restSeconds,
    Value<int>? rowid,
  }) {
    return WorkoutTemplateExercisesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplateExercisesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameTrMeta = const VerificationMeta('nameTr');
  @override
  late final GeneratedColumn<String> nameTr = GeneratedColumn<String>(
    'name_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta('kcalPer100g');
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta('proteinPer100g');
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbPer100gMeta = const VerificationMeta('carbPer100g');
  @override
  late final GeneratedColumn<double> carbPer100g = GeneratedColumn<double>(
    'carb_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta('fatPer100g');
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per_100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultServingGramsMeta = const VerificationMeta(
    'defaultServingGrams',
  );
  @override
  late final GeneratedColumn<double> defaultServingGrams = GeneratedColumn<double>(
    'default_serving_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta('servingLabel');
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    nameTr,
    category,
    kcalPer100g,
    proteinPer100g,
    carbPer100g,
    fatPer100g,
    defaultServingGrams,
    servingLabel,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(Insertable<Food> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_tr')) {
      context.handle(_nameTrMeta, nameTr.isAcceptableOrUnknown(data['name_tr']!, _nameTrMeta));
    } else if (isInserting) {
      context.missing(_nameTrMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('kcal_per_100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(data['kcal_per_100g']!, _kcalPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per_100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(data['protein_per_100g']!, _proteinPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('carb_per_100g')) {
      context.handle(
        _carbPer100gMeta,
        carbPer100g.isAcceptableOrUnknown(data['carb_per_100g']!, _carbPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_carbPer100gMeta);
    }
    if (data.containsKey('fat_per_100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per_100g']!, _fatPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('default_serving_grams')) {
      context.handle(
        _defaultServingGramsMeta,
        defaultServingGrams.isAcceptableOrUnknown(
          data['default_serving_grams']!,
          _defaultServingGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultServingGramsMeta);
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(data['serving_label']!, _servingLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      nameTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_tr'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per_100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_100g'],
      )!,
      carbPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb_per_100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per_100g'],
      )!,
      defaultServingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_serving_grams'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class Food extends DataClass implements Insertable<Food> {
  final String id;
  final String slug;
  final String nameTr;
  final String category;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbPer100g;
  final double fatPer100g;
  final double defaultServingGrams;
  final String servingLabel;
  final String source;
  final String createdAt;
  const Food({
    required this.id,
    required this.slug,
    required this.nameTr,
    required this.category,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
    required this.servingLabel,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['name_tr'] = Variable<String>(nameTr);
    map['category'] = Variable<String>(category);
    map['kcal_per_100g'] = Variable<double>(kcalPer100g);
    map['protein_per_100g'] = Variable<double>(proteinPer100g);
    map['carb_per_100g'] = Variable<double>(carbPer100g);
    map['fat_per_100g'] = Variable<double>(fatPer100g);
    map['default_serving_grams'] = Variable<double>(defaultServingGrams);
    map['serving_label'] = Variable<String>(servingLabel);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      slug: Value(slug),
      nameTr: Value(nameTr),
      category: Value(category),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbPer100g: Value(carbPer100g),
      fatPer100g: Value(fatPer100g),
      defaultServingGrams: Value(defaultServingGrams),
      servingLabel: Value(servingLabel),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Food.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameTr: serializer.fromJson<String>(json['nameTr']),
      category: serializer.fromJson<String>(json['category']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbPer100g: serializer.fromJson<double>(json['carbPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      defaultServingGrams: serializer.fromJson<double>(json['defaultServingGrams']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'nameTr': serializer.toJson<String>(nameTr),
      'category': serializer.toJson<String>(category),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbPer100g': serializer.toJson<double>(carbPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'defaultServingGrams': serializer.toJson<double>(defaultServingGrams),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Food copyWith({
    String? id,
    String? slug,
    String? nameTr,
    String? category,
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbPer100g,
    double? fatPer100g,
    double? defaultServingGrams,
    String? servingLabel,
    String? source,
    String? createdAt,
  }) => Food(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    nameTr: nameTr ?? this.nameTr,
    category: category ?? this.category,
    kcalPer100g: kcalPer100g ?? this.kcalPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbPer100g: carbPer100g ?? this.carbPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
    servingLabel: servingLabel ?? this.servingLabel,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameTr: data.nameTr.present ? data.nameTr.value : this.nameTr,
      category: data.category.present ? data.category.value : this.category,
      kcalPer100g: data.kcalPer100g.present ? data.kcalPer100g.value : this.kcalPer100g,
      proteinPer100g: data.proteinPer100g.present ? data.proteinPer100g.value : this.proteinPer100g,
      carbPer100g: data.carbPer100g.present ? data.carbPer100g.value : this.carbPer100g,
      fatPer100g: data.fatPer100g.present ? data.fatPer100g.value : this.fatPer100g,
      defaultServingGrams: data.defaultServingGrams.present
          ? data.defaultServingGrams.value
          : this.defaultServingGrams,
      servingLabel: data.servingLabel.present ? data.servingLabel.value : this.servingLabel,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('category: $category, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbPer100g: $carbPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    nameTr,
    category,
    kcalPer100g,
    proteinPer100g,
    carbPer100g,
    fatPer100g,
    defaultServingGrams,
    servingLabel,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameTr == this.nameTr &&
          other.category == this.category &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.carbPer100g == this.carbPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.defaultServingGrams == this.defaultServingGrams &&
          other.servingLabel == this.servingLabel &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> nameTr;
  final Value<String> category;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbPer100g;
  final Value<double> fatPer100g;
  final Value<double> defaultServingGrams;
  final Value<String> servingLabel;
  final Value<String> source;
  final Value<String> createdAt;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameTr = const Value.absent(),
    this.category = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    required String id,
    required String slug,
    required String nameTr,
    required String category,
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbPer100g,
    required double fatPer100g,
    required double defaultServingGrams,
    required String servingLabel,
    required String source,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       nameTr = Value(nameTr),
       category = Value(category),
       kcalPer100g = Value(kcalPer100g),
       proteinPer100g = Value(proteinPer100g),
       carbPer100g = Value(carbPer100g),
       fatPer100g = Value(fatPer100g),
       defaultServingGrams = Value(defaultServingGrams),
       servingLabel = Value(servingLabel),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<Food> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? nameTr,
    Expression<String>? category,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? carbPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? defaultServingGrams,
    Expression<String>? servingLabel,
    Expression<String>? source,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameTr != null) 'name_tr': nameTr,
      if (category != null) 'category': category,
      if (kcalPer100g != null) 'kcal_per_100g': kcalPer100g,
      if (proteinPer100g != null) 'protein_per_100g': proteinPer100g,
      if (carbPer100g != null) 'carb_per_100g': carbPer100g,
      if (fatPer100g != null) 'fat_per_100g': fatPer100g,
      if (defaultServingGrams != null) 'default_serving_grams': defaultServingGrams,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? nameTr,
    Value<String>? category,
    Value<double>? kcalPer100g,
    Value<double>? proteinPer100g,
    Value<double>? carbPer100g,
    Value<double>? fatPer100g,
    Value<double>? defaultServingGrams,
    Value<String>? servingLabel,
    Value<String>? source,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameTr: nameTr ?? this.nameTr,
      category: category ?? this.category,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbPer100g: carbPer100g ?? this.carbPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
      servingLabel: servingLabel ?? this.servingLabel,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameTr.present) {
      map['name_tr'] = Variable<String>(nameTr.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per_100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per_100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbPer100g.present) {
      map['carb_per_100g'] = Variable<double>(carbPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per_100g'] = Variable<double>(fatPer100g.value);
    }
    if (defaultServingGrams.present) {
      map['default_serving_grams'] = Variable<double>(defaultServingGrams.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameTr: $nameTr, ')
          ..write('category: $category, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbPer100g: $carbPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DefaultTasksTable extends DefaultTasks with TableInfo<$DefaultTasksTable, DefaultTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefaultTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleTrMeta = const VerificationMeta('titleTr');
  @override
  late final GeneratedColumn<String> titleTr = GeneratedColumn<String>(
    'title_tr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedTimeMeta = const VerificationMeta('suggestedTime');
  @override
  late final GeneratedColumn<String> suggestedTime = GeneratedColumn<String>(
    'suggested_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta('repeatRule');
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{"type":"daily"}'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    titleTr,
    category,
    suggestedTime,
    repeatRule,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'default_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DefaultTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(_slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title_tr')) {
      context.handle(_titleTrMeta, titleTr.isAcceptableOrUnknown(data['title_tr']!, _titleTrMeta));
    } else if (isInserting) {
      context.missing(_titleTrMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('suggested_time')) {
      context.handle(
        _suggestedTimeMeta,
        suggestedTime.isAcceptableOrUnknown(data['suggested_time']!, _suggestedTimeMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DefaultTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DefaultTask(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      titleTr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_tr'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      suggestedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_time'],
      ),
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DefaultTasksTable createAlias(String alias) {
    return $DefaultTasksTable(attachedDatabase, alias);
  }
}

class DefaultTask extends DataClass implements Insertable<DefaultTask> {
  final String id;
  final String slug;
  final String titleTr;
  final String category;
  final String? suggestedTime;
  final String repeatRule;
  final int sortOrder;
  final String createdAt;
  const DefaultTask({
    required this.id,
    required this.slug,
    required this.titleTr,
    required this.category,
    this.suggestedTime,
    required this.repeatRule,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['title_tr'] = Variable<String>(titleTr);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || suggestedTime != null) {
      map['suggested_time'] = Variable<String>(suggestedTime);
    }
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  DefaultTasksCompanion toCompanion(bool nullToAbsent) {
    return DefaultTasksCompanion(
      id: Value(id),
      slug: Value(slug),
      titleTr: Value(titleTr),
      category: Value(category),
      suggestedTime: suggestedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedTime),
      repeatRule: Value(repeatRule),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory DefaultTask.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DefaultTask(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      titleTr: serializer.fromJson<String>(json['titleTr']),
      category: serializer.fromJson<String>(json['category']),
      suggestedTime: serializer.fromJson<String?>(json['suggestedTime']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'titleTr': serializer.toJson<String>(titleTr),
      'category': serializer.toJson<String>(category),
      'suggestedTime': serializer.toJson<String?>(suggestedTime),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  DefaultTask copyWith({
    String? id,
    String? slug,
    String? titleTr,
    String? category,
    Value<String?> suggestedTime = const Value.absent(),
    String? repeatRule,
    int? sortOrder,
    String? createdAt,
  }) => DefaultTask(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    titleTr: titleTr ?? this.titleTr,
    category: category ?? this.category,
    suggestedTime: suggestedTime.present ? suggestedTime.value : this.suggestedTime,
    repeatRule: repeatRule ?? this.repeatRule,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  DefaultTask copyWithCompanion(DefaultTasksCompanion data) {
    return DefaultTask(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      titleTr: data.titleTr.present ? data.titleTr.value : this.titleTr,
      category: data.category.present ? data.category.value : this.category,
      suggestedTime: data.suggestedTime.present ? data.suggestedTime.value : this.suggestedTime,
      repeatRule: data.repeatRule.present ? data.repeatRule.value : this.repeatRule,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DefaultTask(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('titleTr: $titleTr, ')
          ..write('category: $category, ')
          ..write('suggestedTime: $suggestedTime, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, slug, titleTr, category, suggestedTime, repeatRule, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DefaultTask &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.titleTr == this.titleTr &&
          other.category == this.category &&
          other.suggestedTime == this.suggestedTime &&
          other.repeatRule == this.repeatRule &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class DefaultTasksCompanion extends UpdateCompanion<DefaultTask> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> titleTr;
  final Value<String> category;
  final Value<String?> suggestedTime;
  final Value<String> repeatRule;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<int> rowid;
  const DefaultTasksCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.titleTr = const Value.absent(),
    this.category = const Value.absent(),
    this.suggestedTime = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DefaultTasksCompanion.insert({
    required String id,
    required String slug,
    required String titleTr,
    required String category,
    this.suggestedTime = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       titleTr = Value(titleTr),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<DefaultTask> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? titleTr,
    Expression<String>? category,
    Expression<String>? suggestedTime,
    Expression<String>? repeatRule,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (titleTr != null) 'title_tr': titleTr,
      if (category != null) 'category': category,
      if (suggestedTime != null) 'suggested_time': suggestedTime,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DefaultTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? titleTr,
    Value<String>? category,
    Value<String?>? suggestedTime,
    Value<String>? repeatRule,
    Value<int>? sortOrder,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return DefaultTasksCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      titleTr: titleTr ?? this.titleTr,
      category: category ?? this.category,
      suggestedTime: suggestedTime ?? this.suggestedTime,
      repeatRule: repeatRule ?? this.repeatRule,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (titleTr.present) {
      map['title_tr'] = Variable<String>(titleTr.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (suggestedTime.present) {
      map['suggested_time'] = Variable<String>(suggestedTime.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefaultTasksCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('titleTr: $titleTr, ')
          ..write('category: $category, ')
          ..write('suggestedTime: $suggestedTime, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps with TableInfo<$OutboxOpsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [opId, key, type, payload, attempts, createdAt, seq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(_opIdMeta, opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta));
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String opId;
  final String key;
  final String type;
  final String payload;
  final int attempts;
  final int createdAt;
  final int seq;
  const OutboxRow({
    required this.opId,
    required this.key,
    required this.type,
    required this.payload,
    required this.attempts,
    required this.createdAt,
    required this.seq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['key'] = Variable<String>(key);
    map['type'] = Variable<String>(type);
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<int>(createdAt);
    map['seq'] = Variable<int>(seq);
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      opId: Value(opId),
      key: Value(key),
      type: Value(type),
      payload: Value(payload),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      seq: Value(seq),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      opId: serializer.fromJson<String>(json['opId']),
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      seq: serializer.fromJson<int>(json['seq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'key': serializer.toJson<String>(key),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<int>(createdAt),
      'seq': serializer.toJson<int>(seq),
    };
  }

  OutboxRow copyWith({
    String? opId,
    String? key,
    String? type,
    String? payload,
    int? attempts,
    int? createdAt,
    int? seq,
  }) => OutboxRow(
    opId: opId ?? this.opId,
    key: key ?? this.key,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    seq: seq ?? this.seq,
  );
  OutboxRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      key: data.key.present ? data.key.value : this.key,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      seq: data.seq.present ? data.seq.value : this.seq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('opId: $opId, ')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('seq: $seq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(opId, key, type, payload, attempts, createdAt, seq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.opId == this.opId &&
          other.key == this.key &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.seq == this.seq);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> opId;
  final Value<String> key;
  final Value<String> type;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<int> createdAt;
  final Value<int> seq;
  final Value<int> rowid;
  const OutboxOpsCompanion({
    this.opId = const Value.absent(),
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.seq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    required String opId,
    required String key,
    required String type,
    required String payload,
    this.attempts = const Value.absent(),
    required int createdAt,
    required int seq,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       key = Value(key),
       type = Value(type),
       payload = Value(payload),
       createdAt = Value(createdAt),
       seq = Value(seq);
  static Insertable<OutboxRow> custom({
    Expression<String>? opId,
    Expression<String>? key,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<int>? createdAt,
    Expression<int>? seq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (seq != null) 'seq': seq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? key,
    Value<String>? type,
    Value<String>? payload,
    Value<int>? attempts,
    Value<int>? createdAt,
    Value<int>? seq,
    Value<int>? rowid,
  }) {
    return OutboxOpsCompanion(
      opId: opId ?? this.opId,
      key: key ?? this.key,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      seq: seq ?? this.seq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('seq: $seq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetTableMeta = const VerificationMeta('targetTable');
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta('lastPulledAt');
  @override
  late final GeneratedColumn<int> lastPulledAt = GeneratedColumn<int>(
    'last_pulled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [targetTable, cursor, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_name')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(data['table_name']!, _targetTableMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(data['last_pulled_at']!, _lastPulledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetTable};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pulled_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String targetTable;
  final String cursor;
  final int lastPulledAt;
  const SyncCursor({required this.targetTable, required this.cursor, required this.lastPulledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_name'] = Variable<String>(targetTable);
    map['cursor'] = Variable<String>(cursor);
    map['last_pulled_at'] = Variable<int>(lastPulledAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      targetTable: Value(targetTable),
      cursor: Value(cursor),
      lastPulledAt: Value(lastPulledAt),
    );
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      targetTable: serializer.fromJson<String>(json['targetTable']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastPulledAt: serializer.fromJson<int>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetTable': serializer.toJson<String>(targetTable),
      'cursor': serializer.toJson<String>(cursor),
      'lastPulledAt': serializer.toJson<int>(lastPulledAt),
    };
  }

  SyncCursor copyWith({String? targetTable, String? cursor, int? lastPulledAt}) => SyncCursor(
    targetTable: targetTable ?? this.targetTable,
    cursor: cursor ?? this.cursor,
    lastPulledAt: lastPulledAt ?? this.lastPulledAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      targetTable: data.targetTable.present ? data.targetTable.value : this.targetTable,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastPulledAt: data.lastPulledAt.present ? data.lastPulledAt.value : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('targetTable: $targetTable, ')
          ..write('cursor: $cursor, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(targetTable, cursor, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.targetTable == this.targetTable &&
          other.cursor == this.cursor &&
          other.lastPulledAt == this.lastPulledAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> targetTable;
  final Value<String> cursor;
  final Value<int> lastPulledAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.targetTable = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String targetTable,
    required String cursor,
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : targetTable = Value(targetTable),
       cursor = Value(cursor);
  static Insertable<SyncCursor> custom({
    Expression<String>? targetTable,
    Expression<String>? cursor,
    Expression<int>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetTable != null) 'table_name': targetTable,
      if (cursor != null) 'cursor': cursor,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? targetTable,
    Value<String>? cursor,
    Value<int>? lastPulledAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      targetTable: targetTable ?? this.targetTable,
      cursor: cursor ?? this.cursor,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetTable.present) {
      map['table_name'] = Variable<String>(targetTable.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('targetTable: $targetTable, ')
          ..write('cursor: $cursor, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActiveWorkoutPlansTable extends ActiveWorkoutPlans
    with TableInfo<$ActiveWorkoutPlansTable, ActiveWorkoutPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveWorkoutPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planJsonMeta = const VerificationMeta('planJson');
  @override
  late final GeneratedColumn<String> planJson = GeneratedColumn<String>(
    'plan_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentExerciseIdMeta = const VerificationMeta(
    'currentExerciseId',
  );
  @override
  late final GeneratedColumn<String> currentExerciseId = GeneratedColumn<String>(
    'current_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restEndsAtMeta = const VerificationMeta('restEndsAt');
  @override
  late final GeneratedColumn<String> restEndsAt = GeneratedColumn<String>(
    'rest_ends_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    userId,
    planJson,
    currentExerciseId,
    restEndsAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_workout_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveWorkoutPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('plan_json')) {
      context.handle(
        _planJsonMeta,
        planJson.isAcceptableOrUnknown(data['plan_json']!, _planJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_planJsonMeta);
    }
    if (data.containsKey('current_exercise_id')) {
      context.handle(
        _currentExerciseIdMeta,
        currentExerciseId.isAcceptableOrUnknown(
          data['current_exercise_id']!,
          _currentExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('rest_ends_at')) {
      context.handle(
        _restEndsAtMeta,
        restEndsAt.isAcceptableOrUnknown(data['rest_ends_at']!, _restEndsAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  ActiveWorkoutPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveWorkoutPlan(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      planJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_json'],
      )!,
      currentExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_exercise_id'],
      ),
      restEndsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rest_ends_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActiveWorkoutPlansTable createAlias(String alias) {
    return $ActiveWorkoutPlansTable(attachedDatabase, alias);
  }
}

class ActiveWorkoutPlan extends DataClass implements Insertable<ActiveWorkoutPlan> {
  final String sessionId;
  final String userId;

  /// `PlannedExercise` listesi (JSON).
  final String planJson;
  final String? currentExerciseId;

  /// Dinlenmenin bittiği an (UTC ISO); dinlenme yoksa null.
  final String? restEndsAt;
  final String updatedAt;
  const ActiveWorkoutPlan({
    required this.sessionId,
    required this.userId,
    required this.planJson,
    this.currentExerciseId,
    this.restEndsAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['plan_json'] = Variable<String>(planJson);
    if (!nullToAbsent || currentExerciseId != null) {
      map['current_exercise_id'] = Variable<String>(currentExerciseId);
    }
    if (!nullToAbsent || restEndsAt != null) {
      map['rest_ends_at'] = Variable<String>(restEndsAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ActiveWorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return ActiveWorkoutPlansCompanion(
      sessionId: Value(sessionId),
      userId: Value(userId),
      planJson: Value(planJson),
      currentExerciseId: currentExerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentExerciseId),
      restEndsAt: restEndsAt == null && nullToAbsent ? const Value.absent() : Value(restEndsAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActiveWorkoutPlan.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveWorkoutPlan(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      planJson: serializer.fromJson<String>(json['planJson']),
      currentExerciseId: serializer.fromJson<String?>(json['currentExerciseId']),
      restEndsAt: serializer.fromJson<String?>(json['restEndsAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'planJson': serializer.toJson<String>(planJson),
      'currentExerciseId': serializer.toJson<String?>(currentExerciseId),
      'restEndsAt': serializer.toJson<String?>(restEndsAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  ActiveWorkoutPlan copyWith({
    String? sessionId,
    String? userId,
    String? planJson,
    Value<String?> currentExerciseId = const Value.absent(),
    Value<String?> restEndsAt = const Value.absent(),
    String? updatedAt,
  }) => ActiveWorkoutPlan(
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    planJson: planJson ?? this.planJson,
    currentExerciseId: currentExerciseId.present ? currentExerciseId.value : this.currentExerciseId,
    restEndsAt: restEndsAt.present ? restEndsAt.value : this.restEndsAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActiveWorkoutPlan copyWithCompanion(ActiveWorkoutPlansCompanion data) {
    return ActiveWorkoutPlan(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      planJson: data.planJson.present ? data.planJson.value : this.planJson,
      currentExerciseId: data.currentExerciseId.present
          ? data.currentExerciseId.value
          : this.currentExerciseId,
      restEndsAt: data.restEndsAt.present ? data.restEndsAt.value : this.restEndsAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveWorkoutPlan(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('planJson: $planJson, ')
          ..write('currentExerciseId: $currentExerciseId, ')
          ..write('restEndsAt: $restEndsAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, userId, planJson, currentExerciseId, restEndsAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveWorkoutPlan &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.planJson == this.planJson &&
          other.currentExerciseId == this.currentExerciseId &&
          other.restEndsAt == this.restEndsAt &&
          other.updatedAt == this.updatedAt);
}

class ActiveWorkoutPlansCompanion extends UpdateCompanion<ActiveWorkoutPlan> {
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> planJson;
  final Value<String?> currentExerciseId;
  final Value<String?> restEndsAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const ActiveWorkoutPlansCompanion({
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.planJson = const Value.absent(),
    this.currentExerciseId = const Value.absent(),
    this.restEndsAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveWorkoutPlansCompanion.insert({
    required String sessionId,
    required String userId,
    required String planJson,
    this.currentExerciseId = const Value.absent(),
    this.restEndsAt = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       userId = Value(userId),
       planJson = Value(planJson),
       updatedAt = Value(updatedAt);
  static Insertable<ActiveWorkoutPlan> custom({
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? planJson,
    Expression<String>? currentExerciseId,
    Expression<String>? restEndsAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (planJson != null) 'plan_json': planJson,
      if (currentExerciseId != null) 'current_exercise_id': currentExerciseId,
      if (restEndsAt != null) 'rest_ends_at': restEndsAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveWorkoutPlansCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? userId,
    Value<String>? planJson,
    Value<String?>? currentExerciseId,
    Value<String?>? restEndsAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActiveWorkoutPlansCompanion(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      planJson: planJson ?? this.planJson,
      currentExerciseId: currentExerciseId ?? this.currentExerciseId,
      restEndsAt: restEndsAt ?? this.restEndsAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (planJson.present) {
      map['plan_json'] = Variable<String>(planJson.value);
    }
    if (currentExerciseId.present) {
      map['current_exercise_id'] = Variable<String>(currentExerciseId.value);
    }
    if (restEndsAt.present) {
      map['rest_ends_at'] = Variable<String>(restEndsAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveWorkoutPlansCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('planJson: $planJson, ')
          ..write('currentExerciseId: $currentExerciseId, ')
          ..write('restEndsAt: $restEndsAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RestMemoryTable extends RestMemory with TableInfo<$RestMemoryTable, RestMemoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta('seconds');
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, exerciseId, seconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rest_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestMemoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('seconds')) {
      context.handle(_secondsMeta, seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta));
    } else if (isInserting) {
      context.missing(_secondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, exerciseId};
  @override
  RestMemoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestMemoryRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
    );
  }

  @override
  $RestMemoryTable createAlias(String alias) {
    return $RestMemoryTable(attachedDatabase, alias);
  }
}

class RestMemoryRow extends DataClass implements Insertable<RestMemoryRow> {
  final String userId;
  final String exerciseId;
  final int seconds;
  const RestMemoryRow({required this.userId, required this.exerciseId, required this.seconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['seconds'] = Variable<int>(seconds);
    return map;
  }

  RestMemoryCompanion toCompanion(bool nullToAbsent) {
    return RestMemoryCompanion(
      userId: Value(userId),
      exerciseId: Value(exerciseId),
      seconds: Value(seconds),
    );
  }

  factory RestMemoryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestMemoryRow(
      userId: serializer.fromJson<String>(json['userId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      seconds: serializer.fromJson<int>(json['seconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'seconds': serializer.toJson<int>(seconds),
    };
  }

  RestMemoryRow copyWith({String? userId, String? exerciseId, int? seconds}) => RestMemoryRow(
    userId: userId ?? this.userId,
    exerciseId: exerciseId ?? this.exerciseId,
    seconds: seconds ?? this.seconds,
  );
  RestMemoryRow copyWithCompanion(RestMemoryCompanion data) {
    return RestMemoryRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestMemoryRow(')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('seconds: $seconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, exerciseId, seconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestMemoryRow &&
          other.userId == this.userId &&
          other.exerciseId == this.exerciseId &&
          other.seconds == this.seconds);
}

class RestMemoryCompanion extends UpdateCompanion<RestMemoryRow> {
  final Value<String> userId;
  final Value<String> exerciseId;
  final Value<int> seconds;
  final Value<int> rowid;
  const RestMemoryCompanion({
    this.userId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.seconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestMemoryCompanion.insert({
    required String userId,
    required String exerciseId,
    required int seconds,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       exerciseId = Value(exerciseId),
       seconds = Value(seconds);
  static Insertable<RestMemoryRow> custom({
    Expression<String>? userId,
    Expression<String>? exerciseId,
    Expression<int>? seconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (seconds != null) 'seconds': seconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestMemoryCompanion copyWith({
    Value<String>? userId,
    Value<String>? exerciseId,
    Value<int>? seconds,
    Value<int>? rowid,
  }) {
    return RestMemoryCompanion(
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      seconds: seconds ?? this.seconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestMemoryCompanion(')
          ..write('userId: $userId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('seconds: $seconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(this);
  late final $SessionSetsTable sessionSets = $SessionSetsTable(this);
  late final $CustomFoodsTable customFoods = $CustomFoodsTable(this);
  late final $FoodEntriesTable foodEntries = $FoodEntriesTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskCompletionsTable taskCompletions = $TaskCompletionsTable(this);
  late final $MuscleGroupsTable muscleGroups = $MuscleGroupsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(this);
  late final $WorkoutTemplatesTable workoutTemplates = $WorkoutTemplatesTable(this);
  late final $WorkoutTemplateExercisesTable workoutTemplateExercises =
      $WorkoutTemplateExercisesTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $DefaultTasksTable defaultTasks = $DefaultTasksTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $ActiveWorkoutPlansTable activeWorkoutPlans = $ActiveWorkoutPlansTable(this);
  late final $RestMemoryTable restMemory = $RestMemoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    workoutSessions,
    sessionSets,
    customFoods,
    foodEntries,
    favoriteFoods,
    tasks,
    taskCompletions,
    muscleGroups,
    exercises,
    exerciseMuscles,
    workoutTemplates,
    workoutTemplateExercises,
    foods,
    defaultTasks,
    outboxOps,
    syncCursors,
    activeWorkoutPlans,
    restMemory,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String userId,
  Value<String?> displayName,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<int?> birthYear,
  Value<String?> sex,
  Value<String?> activityLevel,
  Value<String?> goal,
  Value<int?> calorieTarget,
  Value<bool> calorieTargetIsManual,
  Value<String> units,
  Value<String> weekStartsOn,
  Value<String> timezone,
  Value<String> theme,
  Value<String> accent,
  Value<String> themeFamily,
  Value<String> accentColor,
  Value<String> notificationSettings,
  Value<bool> onboardingCompleted,
  Value<String?> consentedAt,
  required String createdAt,
  required String updatedAt,
  Value<String?> username,
  Value<String?> avatarPath,
  Value<String?> trainingStyle,
  Value<String?> sideStyles,
  Value<String?> trainingLevel,
  Value<String?> goalMoves,
  Value<String?> focusAreas,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> userId,
  Value<String?> displayName,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<int?> birthYear,
  Value<String?> sex,
  Value<String?> activityLevel,
  Value<String?> goal,
  Value<int?> calorieTarget,
  Value<bool> calorieTargetIsManual,
  Value<String> units,
  Value<String> weekStartsOn,
  Value<String> timezone,
  Value<String> theme,
  Value<String> accent,
  Value<String> themeFamily,
  Value<String> accentColor,
  Value<String> notificationSettings,
  Value<bool> onboardingCompleted,
  Value<String?> consentedAt,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> username,
  Value<String?> avatarPath,
  Value<String?> trainingStyle,
  Value<String?> sideStyles,
  Value<String?> trainingLevel,
  Value<String?> goalMoves,
  Value<String?> focusAreas,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel =>
      $composableBuilder(column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calorieTarget =>
      $composableBuilder(column: $table.calorieTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get calorieTargetIsManual => $composableBuilder(
    column: $table.calorieTargetIsManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekStartsOn =>
      $composableBuilder(column: $table.weekStartsOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeFamily =>
      $composableBuilder(column: $table.themeFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accentColor =>
      $composableBuilder(column: $table.accentColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentedAt =>
      $composableBuilder(column: $table.consentedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath =>
      $composableBuilder(column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainingStyle =>
      $composableBuilder(column: $table.trainingStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sideStyles =>
      $composableBuilder(column: $table.sideStyles, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainingLevel =>
      $composableBuilder(column: $table.trainingLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalMoves =>
      $composableBuilder(column: $table.goalMoves, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get focusAreas =>
      $composableBuilder(column: $table.focusAreas, builder: (column) => ColumnFilters(column));
}

class $$ProfilesTableOrderingComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get calorieTargetIsManual => $composableBuilder(
    column: $table.calorieTargetIsManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekStartsOn =>
      $composableBuilder(column: $table.weekStartsOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeFamily =>
      $composableBuilder(column: $table.themeFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accentColor =>
      $composableBuilder(column: $table.accentColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentedAt =>
      $composableBuilder(column: $table.consentedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath =>
      $composableBuilder(column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainingStyle => $composableBuilder(
    column: $table.trainingStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sideStyles =>
      $composableBuilder(column: $table.sideStyles, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainingLevel => $composableBuilder(
    column: $table.trainingLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalMoves =>
      $composableBuilder(column: $table.goalMoves, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get focusAreas =>
      $composableBuilder(column: $table.focusAreas, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get activityLevel =>
      $composableBuilder(column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get calorieTarget =>
      $composableBuilder(column: $table.calorieTarget, builder: (column) => column);

  GeneratedColumn<bool> get calorieTargetIsManual =>
      $composableBuilder(column: $table.calorieTargetIsManual, builder: (column) => column);

  GeneratedColumn<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<String> get weekStartsOn =>
      $composableBuilder(column: $table.weekStartsOn, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => column);

  GeneratedColumn<String> get themeFamily =>
      $composableBuilder(column: $table.themeFamily, builder: (column) => column);

  GeneratedColumn<String> get accentColor =>
      $composableBuilder(column: $table.accentColor, builder: (column) => column);

  GeneratedColumn<String> get notificationSettings =>
      $composableBuilder(column: $table.notificationSettings, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted =>
      $composableBuilder(column: $table.onboardingCompleted, builder: (column) => column);

  GeneratedColumn<String> get consentedAt =>
      $composableBuilder(column: $table.consentedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get avatarPath =>
      $composableBuilder(column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<String> get trainingStyle =>
      $composableBuilder(column: $table.trainingStyle, builder: (column) => column);

  GeneratedColumn<String> get sideStyles =>
      $composableBuilder(column: $table.sideStyles, builder: (column) => column);

  GeneratedColumn<String> get trainingLevel =>
      $composableBuilder(column: $table.trainingLevel, builder: (column) => column);

  GeneratedColumn<String> get goalMoves =>
      $composableBuilder(column: $table.goalMoves, builder: (column) => column);

  GeneratedColumn<String> get focusAreas =>
      $composableBuilder(column: $table.focusAreas, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<int?> calorieTarget = const Value.absent(),
                Value<bool> calorieTargetIsManual = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<String> weekStartsOn = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<String> themeFamily = const Value.absent(),
                Value<String> accentColor = const Value.absent(),
                Value<String> notificationSettings = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> consentedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> trainingStyle = const Value.absent(),
                Value<String?> sideStyles = const Value.absent(),
                Value<String?> trainingLevel = const Value.absent(),
                Value<String?> goalMoves = const Value.absent(),
                Value<String?> focusAreas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                displayName: displayName,
                heightCm: heightCm,
                weightKg: weightKg,
                birthYear: birthYear,
                sex: sex,
                activityLevel: activityLevel,
                goal: goal,
                calorieTarget: calorieTarget,
                calorieTargetIsManual: calorieTargetIsManual,
                units: units,
                weekStartsOn: weekStartsOn,
                timezone: timezone,
                theme: theme,
                accent: accent,
                themeFamily: themeFamily,
                accentColor: accentColor,
                notificationSettings: notificationSettings,
                onboardingCompleted: onboardingCompleted,
                consentedAt: consentedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                username: username,
                avatarPath: avatarPath,
                trainingStyle: trainingStyle,
                sideStyles: sideStyles,
                trainingLevel: trainingLevel,
                goalMoves: goalMoves,
                focusAreas: focusAreas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> displayName = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<int?> calorieTarget = const Value.absent(),
                Value<bool> calorieTargetIsManual = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<String> weekStartsOn = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<String> themeFamily = const Value.absent(),
                Value<String> accentColor = const Value.absent(),
                Value<String> notificationSettings = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> consentedAt = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> username = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> trainingStyle = const Value.absent(),
                Value<String?> sideStyles = const Value.absent(),
                Value<String?> trainingLevel = const Value.absent(),
                Value<String?> goalMoves = const Value.absent(),
                Value<String?> focusAreas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                displayName: displayName,
                heightCm: heightCm,
                weightKg: weightKg,
                birthYear: birthYear,
                sex: sex,
                activityLevel: activityLevel,
                goal: goal,
                calorieTarget: calorieTarget,
                calorieTargetIsManual: calorieTargetIsManual,
                units: units,
                weekStartsOn: weekStartsOn,
                timezone: timezone,
                theme: theme,
                accent: accent,
                themeFamily: themeFamily,
                accentColor: accentColor,
                notificationSettings: notificationSettings,
                onboardingCompleted: onboardingCompleted,
                consentedAt: consentedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                username: username,
                avatarPath: avatarPath,
                trainingStyle: trainingStyle,
                sideStyles: sideStyles,
                trainingLevel: trainingLevel,
                goalMoves: goalMoves,
                focusAreas: focusAreas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder = WorkoutSessionsCompanion Function({
  required String id,
  required String userId,
  Value<String?> templateId,
  Value<String> name,
  required String startedAt,
  Value<String?> endedAt,
  required String localDate,
  required String weekKey,
  Value<int?> estimatedKcal,
  Value<String> status,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$WorkoutSessionsTableUpdateCompanionBuilder = WorkoutSessionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> templateId,
  Value<String> name,
  Value<String> startedAt,
  Value<String?> endedAt,
  Value<String> localDate,
  Value<String> weekKey,
  Value<int?> estimatedKcal,
  Value<String> status,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$WorkoutSessionsTableFilterComposer extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekKey =>
      $composableBuilder(column: $table.weekKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedKcal =>
      $composableBuilder(column: $table.estimatedKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekKey =>
      $composableBuilder(column: $table.weekKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedKcal => $composableBuilder(
    column: $table.estimatedKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get weekKey =>
      $composableBuilder(column: $table.weekKey, builder: (column) => column);

  GeneratedColumn<int> get estimatedKcal =>
      $composableBuilder(column: $table.estimatedKcal, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(_$AppDatabase db, $WorkoutSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> endedAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> weekKey = const Value.absent(),
                Value<int?> estimatedKcal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                userId: userId,
                templateId: templateId,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                localDate: localDate,
                weekKey: weekKey,
                estimatedKcal: estimatedKcal,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> templateId = const Value.absent(),
                Value<String> name = const Value.absent(),
                required String startedAt,
                Value<String?> endedAt = const Value.absent(),
                required String localDate,
                required String weekKey,
                Value<int?> estimatedKcal = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                userId: userId,
                templateId: templateId,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                localDate: localDate,
                weekKey: weekKey,
                estimatedKcal: estimatedKcal,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSession>(table),
                  BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$SessionSetsTableCreateCompanionBuilder = SessionSetsCompanion Function({
  required String id,
  required String sessionId,
  required String userId,
  required String exerciseId,
  required int exerciseOrder,
  required int setIndex,
  Value<int?> reps,
  Value<int?> durationSeconds,
  Value<double?> weightKg,
  required String completedAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$SessionSetsTableUpdateCompanionBuilder = SessionSetsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> userId,
  Value<String> exerciseId,
  Value<int> exerciseOrder,
  Value<int> setIndex,
  Value<int?> reps,
  Value<int?> durationSeconds,
  Value<double?> weightKg,
  Value<String> completedAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$SessionSetsTableFilterComposer extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exerciseOrder =>
      $composableBuilder(column: $table.exerciseOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SessionSetsTableOrderingComposer extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionSetsTableAnnotationComposer extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get exerciseOrder =>
      $composableBuilder(column: $table.exerciseOrder, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds =>
      $composableBuilder(column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSetsTable,
          SessionSet,
          $$SessionSetsTableFilterComposer,
          $$SessionSetsTableOrderingComposer,
          $$SessionSetsTableAnnotationComposer,
          $$SessionSetsTableCreateCompanionBuilder,
          $$SessionSetsTableUpdateCompanionBuilder,
          (SessionSet, BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSet>),
          SessionSet,
          PrefetchHooks Function()
        > {
  $$SessionSetsTableTableManager(_$AppDatabase db, $SessionSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> exerciseOrder = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> completedAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSetsCompanion(
                id: id,
                sessionId: sessionId,
                userId: userId,
                exerciseId: exerciseId,
                exerciseOrder: exerciseOrder,
                setIndex: setIndex,
                reps: reps,
                durationSeconds: durationSeconds,
                weightKg: weightKg,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String userId,
                required String exerciseId,
                required int exerciseOrder,
                required int setIndex,
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                required String completedAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                userId: userId,
                exerciseId: exerciseId,
                exerciseOrder: exerciseOrder,
                setIndex: setIndex,
                reps: reps,
                durationSeconds: durationSeconds,
                weightKg: weightKg,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionSetsTable, SessionSet>(table),
                  BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSet>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSetsTable,
      SessionSet,
      $$SessionSetsTableFilterComposer,
      $$SessionSetsTableOrderingComposer,
      $$SessionSetsTableAnnotationComposer,
      $$SessionSetsTableCreateCompanionBuilder,
      $$SessionSetsTableUpdateCompanionBuilder,
      (SessionSet, BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSet>),
      SessionSet,
      PrefetchHooks Function()
    >;
typedef $$CustomFoodsTableCreateCompanionBuilder = CustomFoodsCompanion Function({
  required String id,
  required String userId,
  required String nameTr,
  Value<String> category,
  required double kcalPer100g,
  Value<double> proteinPer100g,
  Value<double> carbPer100g,
  Value<double> fatPer100g,
  Value<double> defaultServingGrams,
  Value<String> servingLabel,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$CustomFoodsTableUpdateCompanionBuilder = CustomFoodsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> nameTr,
  Value<String> category,
  Value<double> kcalPer100g,
  Value<double> proteinPer100g,
  Value<double> carbPer100g,
  Value<double> fatPer100g,
  Value<double> defaultServingGrams,
  Value<String> servingLabel,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$CustomFoodsTableFilterComposer extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPer100g =>
      $composableBuilder(column: $table.proteinPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomFoodsTableOrderingComposer extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomFoodsTableAnnotationComposer extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => column);

  GeneratedColumn<double> get proteinPer100g =>
      $composableBuilder(column: $table.proteinPer100g, builder: (column) => column);

  GeneratedColumn<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => column);

  GeneratedColumn<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => column);

  GeneratedColumn<double> get defaultServingGrams =>
      $composableBuilder(column: $table.defaultServingGrams, builder: (column) => column);

  GeneratedColumn<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFoodsTable,
          CustomFood,
          $$CustomFoodsTableFilterComposer,
          $$CustomFoodsTableOrderingComposer,
          $$CustomFoodsTableAnnotationComposer,
          $$CustomFoodsTableCreateCompanionBuilder,
          $$CustomFoodsTableUpdateCompanionBuilder,
          (CustomFood, BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>),
          CustomFood,
          PrefetchHooks Function()
        > {
  $$CustomFoodsTableTableManager(_$AppDatabase db, $CustomFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CustomFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CustomFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> nameTr = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> kcalPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> defaultServingGrams = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion(
                id: id,
                userId: userId,
                nameTr: nameTr,
                category: category,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbPer100g: carbPer100g,
                fatPer100g: fatPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String nameTr,
                Value<String> category = const Value.absent(),
                required double kcalPer100g,
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> defaultServingGrams = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion.insert(
                id: id,
                userId: userId,
                nameTr: nameTr,
                category: category,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbPer100g: carbPer100g,
                fatPer100g: fatPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomFoodsTable, CustomFood>(table),
                  BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFoodsTable,
      CustomFood,
      $$CustomFoodsTableFilterComposer,
      $$CustomFoodsTableOrderingComposer,
      $$CustomFoodsTableAnnotationComposer,
      $$CustomFoodsTableCreateCompanionBuilder,
      $$CustomFoodsTableUpdateCompanionBuilder,
      (CustomFood, BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>),
      CustomFood,
      PrefetchHooks Function()
    >;
typedef $$FoodEntriesTableCreateCompanionBuilder = FoodEntriesCompanion Function({
  required String id,
  required String userId,
  required String localDate,
  required String meal,
  Value<String?> foodId,
  Value<String?> customFoodId,
  required String name,
  required double amount,
  required String unit,
  required double grams,
  required double kcal,
  Value<double> protein,
  Value<double> carb,
  Value<double> fat,
  Value<bool> isManualOverride,
  required String loggedAt,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$FoodEntriesTableUpdateCompanionBuilder = FoodEntriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> localDate,
  Value<String> meal,
  Value<String?> foodId,
  Value<String?> customFoodId,
  Value<String> name,
  Value<double> amount,
  Value<String> unit,
  Value<double> grams,
  Value<double> kcal,
  Value<double> protein,
  Value<double> carb,
  Value<double> fat,
  Value<bool> isManualOverride,
  Value<String> loggedAt,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$FoodEntriesTableFilterComposer extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carb =>
      $composableBuilder(column: $table.carb, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManualOverride => $composableBuilder(
    column: $table.isManualOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FoodEntriesTableOrderingComposer extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carb =>
      $composableBuilder(column: $table.carb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManualOverride => $composableBuilder(
    column: $table.isManualOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FoodEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carb =>
      $composableBuilder(column: $table.carb, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<bool> get isManualOverride =>
      $composableBuilder(column: $table.isManualOverride, builder: (column) => column);

  GeneratedColumn<String> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoodEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodEntriesTable,
          FoodEntry,
          $$FoodEntriesTableFilterComposer,
          $$FoodEntriesTableOrderingComposer,
          $$FoodEntriesTableAnnotationComposer,
          $$FoodEntriesTableCreateCompanionBuilder,
          $$FoodEntriesTableUpdateCompanionBuilder,
          (FoodEntry, BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntry>),
          FoodEntry,
          PrefetchHooks Function()
        > {
  $$FoodEntriesTableTableManager(_$AppDatabase db, $FoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String?> foodId = const Value.absent(),
                Value<String?> customFoodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carb = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<bool> isManualOverride = const Value.absent(),
                Value<String> loggedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion(
                id: id,
                userId: userId,
                localDate: localDate,
                meal: meal,
                foodId: foodId,
                customFoodId: customFoodId,
                name: name,
                amount: amount,
                unit: unit,
                grams: grams,
                kcal: kcal,
                protein: protein,
                carb: carb,
                fat: fat,
                isManualOverride: isManualOverride,
                loggedAt: loggedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String localDate,
                required String meal,
                Value<String?> foodId = const Value.absent(),
                Value<String?> customFoodId = const Value.absent(),
                required String name,
                required double amount,
                required String unit,
                required double grams,
                required double kcal,
                Value<double> protein = const Value.absent(),
                Value<double> carb = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<bool> isManualOverride = const Value.absent(),
                required String loggedAt,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion.insert(
                id: id,
                userId: userId,
                localDate: localDate,
                meal: meal,
                foodId: foodId,
                customFoodId: customFoodId,
                name: name,
                amount: amount,
                unit: unit,
                grams: grams,
                kcal: kcal,
                protein: protein,
                carb: carb,
                fat: fat,
                isManualOverride: isManualOverride,
                loggedAt: loggedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodEntriesTable, FoodEntry>(table),
                  BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodEntriesTable,
      FoodEntry,
      $$FoodEntriesTableFilterComposer,
      $$FoodEntriesTableOrderingComposer,
      $$FoodEntriesTableAnnotationComposer,
      $$FoodEntriesTableCreateCompanionBuilder,
      $$FoodEntriesTableUpdateCompanionBuilder,
      (FoodEntry, BaseReferences<_$AppDatabase, $FoodEntriesTable, FoodEntry>),
      FoodEntry,
      PrefetchHooks Function()
    >;
typedef $$FavoriteFoodsTableCreateCompanionBuilder = FavoriteFoodsCompanion Function({
  required String id,
  required String userId,
  Value<String?> foodId,
  Value<String?> customFoodId,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$FavoriteFoodsTableUpdateCompanionBuilder = FavoriteFoodsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> foodId,
  Value<String?> customFoodId,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$FavoriteFoodsTableFilterComposer extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FavoriteFoodsTableOrderingComposer extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteFoodsTableAnnotationComposer extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get customFoodId =>
      $composableBuilder(column: $table.customFoodId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteFoodsTable,
          FavoriteFood,
          $$FavoriteFoodsTableFilterComposer,
          $$FavoriteFoodsTableOrderingComposer,
          $$FavoriteFoodsTableAnnotationComposer,
          $$FavoriteFoodsTableCreateCompanionBuilder,
          $$FavoriteFoodsTableUpdateCompanionBuilder,
          (FavoriteFood, BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFood>),
          FavoriteFood,
          PrefetchHooks Function()
        > {
  $$FavoriteFoodsTableTableManager(_$AppDatabase db, $FavoriteFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FavoriteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> foodId = const Value.absent(),
                Value<String?> customFoodId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteFoodsCompanion(
                id: id,
                userId: userId,
                foodId: foodId,
                customFoodId: customFoodId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> foodId = const Value.absent(),
                Value<String?> customFoodId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteFoodsCompanion.insert(
                id: id,
                userId: userId,
                foodId: foodId,
                customFoodId: customFoodId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoriteFoodsTable, FavoriteFood>(table),
                  BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFood>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteFoodsTable,
      FavoriteFood,
      $$FavoriteFoodsTableFilterComposer,
      $$FavoriteFoodsTableOrderingComposer,
      $$FavoriteFoodsTableAnnotationComposer,
      $$FavoriteFoodsTableCreateCompanionBuilder,
      $$FavoriteFoodsTableUpdateCompanionBuilder,
      (FavoriteFood, BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFood>),
      FavoriteFood,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String userId,
  required String title,
  Value<String?> note,
  Value<String?> time,
  Value<String> repeatRule,
  required String startDate,
  Value<String?> defaultTaskId,
  Value<bool> isActive,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String?> note,
  Value<String?> time,
  Value<String> repeatRule,
  Value<String> startDate,
  Value<String?> defaultTaskId,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultTaskId =>
      $composableBuilder(column: $table.defaultTaskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultTaskId => $composableBuilder(
    column: $table.defaultTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get defaultTaskId =>
      $composableBuilder(column: $table.defaultTaskId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> time = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> defaultTaskId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                userId: userId,
                title: title,
                note: note,
                time: time,
                repeatRule: repeatRule,
                startDate: startDate,
                defaultTaskId: defaultTaskId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String?> time = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                required String startDate,
                Value<String?> defaultTaskId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                note: note,
                time: time,
                repeatRule: repeatRule,
                startDate: startDate,
                defaultTaskId: defaultTaskId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskCompletionsTableCreateCompanionBuilder = TaskCompletionsCompanion Function({
  required String id,
  required String userId,
  required String taskId,
  required String localDate,
  required String completedAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$TaskCompletionsTableUpdateCompanionBuilder = TaskCompletionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> taskId,
  Value<String> localDate,
  Value<String> completedAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$TaskCompletionsTableFilterComposer extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TaskCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaskCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TaskCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskCompletionsTable,
          TaskCompletion,
          $$TaskCompletionsTableFilterComposer,
          $$TaskCompletionsTableOrderingComposer,
          $$TaskCompletionsTableAnnotationComposer,
          $$TaskCompletionsTableCreateCompanionBuilder,
          $$TaskCompletionsTableUpdateCompanionBuilder,
          (TaskCompletion, BaseReferences<_$AppDatabase, $TaskCompletionsTable, TaskCompletion>),
          TaskCompletion,
          PrefetchHooks Function()
        > {
  $$TaskCompletionsTableTableManager(_$AppDatabase db, $TaskCompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> completedAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskCompletionsCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                localDate: localDate,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskId,
                required String localDate,
                required String completedAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskCompletionsCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                localDate: localDate,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskCompletionsTable, TaskCompletion>(table),
                  BaseReferences<_$AppDatabase, $TaskCompletionsTable, TaskCompletion>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskCompletionsTable,
      TaskCompletion,
      $$TaskCompletionsTableFilterComposer,
      $$TaskCompletionsTableOrderingComposer,
      $$TaskCompletionsTableAnnotationComposer,
      $$TaskCompletionsTableCreateCompanionBuilder,
      $$TaskCompletionsTableUpdateCompanionBuilder,
      (TaskCompletion, BaseReferences<_$AppDatabase, $TaskCompletionsTable, TaskCompletion>),
      TaskCompletion,
      PrefetchHooks Function()
    >;
typedef $$MuscleGroupsTableCreateCompanionBuilder = MuscleGroupsCompanion Function({
  required String id,
  required String slug,
  required String nameTr,
  required String bodyRegion,
  required String view,
  Value<int> sortOrder,
  required String createdAt,
  Value<int> rowid,
});
typedef $$MuscleGroupsTableUpdateCompanionBuilder = MuscleGroupsCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> nameTr,
  Value<String> bodyRegion,
  Value<String> view,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$MuscleGroupsTableFilterComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyRegion =>
      $composableBuilder(column: $table.bodyRegion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get view =>
      $composableBuilder(column: $table.view, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MuscleGroupsTableOrderingComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyRegion =>
      $composableBuilder(column: $table.bodyRegion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get view =>
      $composableBuilder(column: $table.view, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MuscleGroupsTableAnnotationComposer extends Composer<_$AppDatabase, $MuscleGroupsTable> {
  $$MuscleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => column);

  GeneratedColumn<String> get bodyRegion =>
      $composableBuilder(column: $table.bodyRegion, builder: (column) => column);

  GeneratedColumn<String> get view =>
      $composableBuilder(column: $table.view, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MuscleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuscleGroupsTable,
          MuscleGroup,
          $$MuscleGroupsTableFilterComposer,
          $$MuscleGroupsTableOrderingComposer,
          $$MuscleGroupsTableAnnotationComposer,
          $$MuscleGroupsTableCreateCompanionBuilder,
          $$MuscleGroupsTableUpdateCompanionBuilder,
          (MuscleGroup, BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup>),
          MuscleGroup,
          PrefetchHooks Function()
        > {
  $$MuscleGroupsTableTableManager(_$AppDatabase db, $MuscleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MuscleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MuscleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuscleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> nameTr = const Value.absent(),
                Value<String> bodyRegion = const Value.absent(),
                Value<String> view = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion(
                id: id,
                slug: slug,
                nameTr: nameTr,
                bodyRegion: bodyRegion,
                view: view,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String nameTr,
                required String bodyRegion,
                required String view,
                Value<int> sortOrder = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MuscleGroupsCompanion.insert(
                id: id,
                slug: slug,
                nameTr: nameTr,
                bodyRegion: bodyRegion,
                view: view,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MuscleGroupsTable, MuscleGroup>(table),
                  BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MuscleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuscleGroupsTable,
      MuscleGroup,
      $$MuscleGroupsTableFilterComposer,
      $$MuscleGroupsTableOrderingComposer,
      $$MuscleGroupsTableAnnotationComposer,
      $$MuscleGroupsTableCreateCompanionBuilder,
      $$MuscleGroupsTableUpdateCompanionBuilder,
      (MuscleGroup, BaseReferences<_$AppDatabase, $MuscleGroupsTable, MuscleGroup>),
      MuscleGroup,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  required String slug,
  required String nameTr,
  required String nameEn,
  required String equipment,
  required String type,
  required String tracking,
  required double metValue,
  Value<bool> isActive,
  required String createdAt,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> nameTr,
  Value<String> nameEn,
  Value<String> equipment,
  Value<String> type,
  Value<String> tracking,
  Value<double> metValue,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$ExercisesTableFilterComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tracking =>
      $composableBuilder(column: $table.tracking, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get metValue =>
      $composableBuilder(column: $table.metValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ExercisesTableOrderingComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tracking =>
      $composableBuilder(column: $table.tracking, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get metValue =>
      $composableBuilder(column: $table.metValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get tracking =>
      $composableBuilder(column: $table.tracking, builder: (column) => column);

  GeneratedColumn<double> get metValue =>
      $composableBuilder(column: $table.metValue, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
          Exercise,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> nameTr = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> tracking = const Value.absent(),
                Value<double> metValue = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                slug: slug,
                nameTr: nameTr,
                nameEn: nameEn,
                equipment: equipment,
                type: type,
                tracking: tracking,
                metValue: metValue,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String nameTr,
                required String nameEn,
                required String equipment,
                required String type,
                required String tracking,
                required double metValue,
                Value<bool> isActive = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                slug: slug,
                nameTr: nameTr,
                nameEn: nameEn,
                equipment: equipment,
                type: type,
                tracking: tracking,
                metValue: metValue,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
      Exercise,
      PrefetchHooks Function()
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder = ExerciseMusclesCompanion Function({
  required String exerciseId,
  required String muscleGroupId,
  required String role,
  Value<int> rowid,
});
typedef $$ExerciseMusclesTableUpdateCompanionBuilder = ExerciseMusclesCompanion Function({
  Value<String> exerciseId,
  Value<String> muscleGroupId,
  Value<String> role,
  Value<int> rowid,
});

class $$ExerciseMusclesTableFilterComposer extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get muscleGroupId =>
      $composableBuilder(column: $table.muscleGroupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));
}

class $$ExerciseMusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get muscleGroupId => $composableBuilder(
    column: $table.muscleGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));
}

class $$ExerciseMusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupId =>
      $composableBuilder(column: $table.muscleGroupId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscle,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscle, BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle>),
          ExerciseMuscle,
          PrefetchHooks Function()
        > {
  $$ExerciseMusclesTableTableManager(_$AppDatabase db, $ExerciseMusclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> muscleGroupId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String muscleGroupId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscleGroupId: muscleGroupId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMusclesTable, ExerciseMuscle>(table),
                  BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscle,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscle, BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle>),
      ExerciseMuscle,
      PrefetchHooks Function()
    >;
typedef $$WorkoutTemplatesTableCreateCompanionBuilder = WorkoutTemplatesCompanion Function({
  required String id,
  required String slug,
  required String nameTr,
  Value<String> description,
  required String level,
  Value<int> sortOrder,
  required String createdAt,
  Value<int> rowid,
});
typedef $$WorkoutTemplatesTableUpdateCompanionBuilder = WorkoutTemplatesCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> nameTr,
  Value<String> description,
  Value<String> level,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$WorkoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WorkoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkoutTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplate,
          $$WorkoutTemplatesTableFilterComposer,
          $$WorkoutTemplatesTableOrderingComposer,
          $$WorkoutTemplatesTableAnnotationComposer,
          $$WorkoutTemplatesTableCreateCompanionBuilder,
          $$WorkoutTemplatesTableUpdateCompanionBuilder,
          (WorkoutTemplate, BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate>),
          WorkoutTemplate,
          PrefetchHooks Function()
        > {
  $$WorkoutTemplatesTableTableManager(_$AppDatabase db, $WorkoutTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> nameTr = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion(
                id: id,
                slug: slug,
                nameTr: nameTr,
                description: description,
                level: level,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String nameTr,
                Value<String> description = const Value.absent(),
                required String level,
                Value<int> sortOrder = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion.insert(
                id: id,
                slug: slug,
                nameTr: nameTr,
                description: description,
                level: level,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutTemplatesTable, WorkoutTemplate>(table),
                  BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplatesTable,
      WorkoutTemplate,
      $$WorkoutTemplatesTableFilterComposer,
      $$WorkoutTemplatesTableOrderingComposer,
      $$WorkoutTemplatesTableAnnotationComposer,
      $$WorkoutTemplatesTableCreateCompanionBuilder,
      $$WorkoutTemplatesTableUpdateCompanionBuilder,
      (WorkoutTemplate, BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate>),
      WorkoutTemplate,
      PrefetchHooks Function()
    >;
typedef $$WorkoutTemplateExercisesTableCreateCompanionBuilder =
    WorkoutTemplateExercisesCompanion Function({
      required String id,
      required String templateId,
      required String exerciseId,
      required int orderIndex,
      required int sets,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<int> restSeconds,
      Value<int> rowid,
    });
typedef $$WorkoutTemplateExercisesTableUpdateCompanionBuilder =
    WorkoutTemplateExercisesCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> exerciseId,
      Value<int> orderIndex,
      Value<int> sets,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<int> restSeconds,
      Value<int> rowid,
    });

class $$WorkoutTemplateExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateExercisesTable> {
  $$WorkoutTemplateExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex =>
      $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnFilters(column));
}

class $$WorkoutTemplateExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateExercisesTable> {
  $$WorkoutTemplateExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex =>
      $composableBuilder(column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutTemplateExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateExercisesTable> {
  $$WorkoutTemplateExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId =>
      $composableBuilder(column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex =>
      $composableBuilder(column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds =>
      $composableBuilder(column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get restSeconds =>
      $composableBuilder(column: $table.restSeconds, builder: (column) => column);
}

class $$WorkoutTemplateExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplateExercisesTable,
          WorkoutTemplateExercise,
          $$WorkoutTemplateExercisesTableFilterComposer,
          $$WorkoutTemplateExercisesTableOrderingComposer,
          $$WorkoutTemplateExercisesTableAnnotationComposer,
          $$WorkoutTemplateExercisesTableCreateCompanionBuilder,
          $$WorkoutTemplateExercisesTableUpdateCompanionBuilder,
          (
            WorkoutTemplateExercise,
            BaseReferences<_$AppDatabase, $WorkoutTemplateExercisesTable, WorkoutTemplateExercise>,
          ),
          WorkoutTemplateExercise,
          PrefetchHooks Function()
        > {
  $$WorkoutTemplateExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplateExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplateExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplateExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplateExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplateExercisesCompanion(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                sets: sets,
                reps: reps,
                durationSeconds: durationSeconds,
                restSeconds: restSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String exerciseId,
                required int orderIndex,
                required int sets,
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplateExercisesCompanion.insert(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                sets: sets,
                reps: reps,
                durationSeconds: durationSeconds,
                restSeconds: restSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutTemplateExercisesTable, WorkoutTemplateExercise>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutTemplateExercisesTable,
                    WorkoutTemplateExercise
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutTemplateExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplateExercisesTable,
      WorkoutTemplateExercise,
      $$WorkoutTemplateExercisesTableFilterComposer,
      $$WorkoutTemplateExercisesTableOrderingComposer,
      $$WorkoutTemplateExercisesTableAnnotationComposer,
      $$WorkoutTemplateExercisesTableCreateCompanionBuilder,
      $$WorkoutTemplateExercisesTableUpdateCompanionBuilder,
      (
        WorkoutTemplateExercise,
        BaseReferences<_$AppDatabase, $WorkoutTemplateExercisesTable, WorkoutTemplateExercise>,
      ),
      WorkoutTemplateExercise,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  required String id,
  required String slug,
  required String nameTr,
  required String category,
  required double kcalPer100g,
  required double proteinPer100g,
  required double carbPer100g,
  required double fatPer100g,
  required double defaultServingGrams,
  required String servingLabel,
  required String source,
  required String createdAt,
  Value<int> rowid,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> nameTr,
  Value<String> category,
  Value<double> kcalPer100g,
  Value<double> proteinPer100g,
  Value<double> carbPer100g,
  Value<double> fatPer100g,
  Value<double> defaultServingGrams,
  Value<String> servingLabel,
  Value<String> source,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPer100g =>
      $composableBuilder(column: $table.proteinPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FoodsTableOrderingComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FoodsTableAnnotationComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameTr =>
      $composableBuilder(column: $table.nameTr, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g =>
      $composableBuilder(column: $table.kcalPer100g, builder: (column) => column);

  GeneratedColumn<double> get proteinPer100g =>
      $composableBuilder(column: $table.proteinPer100g, builder: (column) => column);

  GeneratedColumn<double> get carbPer100g =>
      $composableBuilder(column: $table.carbPer100g, builder: (column) => column);

  GeneratedColumn<double> get fatPer100g =>
      $composableBuilder(column: $table.fatPer100g, builder: (column) => column);

  GeneratedColumn<double> get defaultServingGrams =>
      $composableBuilder(column: $table.defaultServingGrams, builder: (column) => column);

  GeneratedColumn<String> get servingLabel =>
      $composableBuilder(column: $table.servingLabel, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
          Food,
          PrefetchHooks Function()
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> nameTr = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> kcalPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> defaultServingGrams = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                slug: slug,
                nameTr: nameTr,
                category: category,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbPer100g: carbPer100g,
                fatPer100g: fatPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String nameTr,
                required String category,
                required double kcalPer100g,
                required double proteinPer100g,
                required double carbPer100g,
                required double fatPer100g,
                required double defaultServingGrams,
                required String servingLabel,
                required String source,
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                slug: slug,
                nameTr: nameTr,
                category: category,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbPer100g: carbPer100g,
                fatPer100g: fatPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodsTable, Food>(table),
                  BaseReferences<_$AppDatabase, $FoodsTable, Food>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
      Food,
      PrefetchHooks Function()
    >;
typedef $$DefaultTasksTableCreateCompanionBuilder = DefaultTasksCompanion Function({
  required String id,
  required String slug,
  required String titleTr,
  required String category,
  Value<String?> suggestedTime,
  Value<String> repeatRule,
  Value<int> sortOrder,
  required String createdAt,
  Value<int> rowid,
});
typedef $$DefaultTasksTableUpdateCompanionBuilder = DefaultTasksCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> titleTr,
  Value<String> category,
  Value<String?> suggestedTime,
  Value<String> repeatRule,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$DefaultTasksTableFilterComposer extends Composer<_$AppDatabase, $DefaultTasksTable> {
  $$DefaultTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleTr =>
      $composableBuilder(column: $table.titleTr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedTime =>
      $composableBuilder(column: $table.suggestedTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DefaultTasksTableOrderingComposer extends Composer<_$AppDatabase, $DefaultTasksTable> {
  $$DefaultTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleTr =>
      $composableBuilder(column: $table.titleTr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedTime => $composableBuilder(
    column: $table.suggestedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DefaultTasksTableAnnotationComposer extends Composer<_$AppDatabase, $DefaultTasksTable> {
  $$DefaultTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get titleTr =>
      $composableBuilder(column: $table.titleTr, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get suggestedTime =>
      $composableBuilder(column: $table.suggestedTime, builder: (column) => column);

  GeneratedColumn<String> get repeatRule =>
      $composableBuilder(column: $table.repeatRule, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DefaultTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DefaultTasksTable,
          DefaultTask,
          $$DefaultTasksTableFilterComposer,
          $$DefaultTasksTableOrderingComposer,
          $$DefaultTasksTableAnnotationComposer,
          $$DefaultTasksTableCreateCompanionBuilder,
          $$DefaultTasksTableUpdateCompanionBuilder,
          (DefaultTask, BaseReferences<_$AppDatabase, $DefaultTasksTable, DefaultTask>),
          DefaultTask,
          PrefetchHooks Function()
        > {
  $$DefaultTasksTableTableManager(_$AppDatabase db, $DefaultTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DefaultTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DefaultTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefaultTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> titleTr = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> suggestedTime = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DefaultTasksCompanion(
                id: id,
                slug: slug,
                titleTr: titleTr,
                category: category,
                suggestedTime: suggestedTime,
                repeatRule: repeatRule,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String titleTr,
                required String category,
                Value<String?> suggestedTime = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DefaultTasksCompanion.insert(
                id: id,
                slug: slug,
                titleTr: titleTr,
                category: category,
                suggestedTime: suggestedTime,
                repeatRule: repeatRule,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DefaultTasksTable, DefaultTask>(table),
                  BaseReferences<_$AppDatabase, $DefaultTasksTable, DefaultTask>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DefaultTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DefaultTasksTable,
      DefaultTask,
      $$DefaultTasksTableFilterComposer,
      $$DefaultTasksTableOrderingComposer,
      $$DefaultTasksTableAnnotationComposer,
      $$DefaultTasksTableCreateCompanionBuilder,
      $$DefaultTasksTableUpdateCompanionBuilder,
      (DefaultTask, BaseReferences<_$AppDatabase, $DefaultTasksTable, DefaultTask>),
      DefaultTask,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  required String opId,
  required String key,
  required String type,
  required String payload,
  Value<int> attempts,
  required int createdAt,
  required int seq,
  Value<int> rowid,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<String> opId,
  Value<String> key,
  Value<String> type,
  Value<String> payload,
  Value<int> attempts,
  Value<int> createdAt,
  Value<int> seq,
  Value<int> rowid,
});

class $$OutboxOpsTableFilterComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));
}

class $$OutboxOpsTableOrderingComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));
}

class $$OutboxOpsTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion(
                opId: opId,
                key: key,
                type: type,
                payload: payload,
                attempts: attempts,
                createdAt: createdAt,
                seq: seq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String key,
                required String type,
                required String payload,
                Value<int> attempts = const Value.absent(),
                required int createdAt,
                required int seq,
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion.insert(
                opId: opId,
                key: key,
                type: type,
                payload: payload,
                attempts: attempts,
                createdAt: createdAt,
                seq: seq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion Function({
  required String targetTable,
  required String cursor,
  Value<int> lastPulledAt,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion Function({
  Value<String> targetTable,
  Value<String> cursor,
  Value<int> lastPulledAt,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetTable =>
      $composableBuilder(column: $table.targetTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetTable =>
      $composableBuilder(column: $table.targetTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetTable =>
      $composableBuilder(column: $table.targetTable, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> targetTable = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<int> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                targetTable: targetTable,
                cursor: cursor,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String targetTable,
                required String cursor,
                Value<int> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                targetTable: targetTable,
                cursor: cursor,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$ActiveWorkoutPlansTableCreateCompanionBuilder = ActiveWorkoutPlansCompanion Function({
  required String sessionId,
  required String userId,
  required String planJson,
  Value<String?> currentExerciseId,
  Value<String?> restEndsAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$ActiveWorkoutPlansTableUpdateCompanionBuilder = ActiveWorkoutPlansCompanion Function({
  Value<String> sessionId,
  Value<String> userId,
  Value<String> planJson,
  Value<String?> currentExerciseId,
  Value<String?> restEndsAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$ActiveWorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutPlansTable> {
  $$ActiveWorkoutPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planJson =>
      $composableBuilder(column: $table.planJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentExerciseId => $composableBuilder(
    column: $table.currentExerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restEndsAt =>
      $composableBuilder(column: $table.restEndsAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ActiveWorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutPlansTable> {
  $$ActiveWorkoutPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planJson =>
      $composableBuilder(column: $table.planJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentExerciseId => $composableBuilder(
    column: $table.currentExerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restEndsAt =>
      $composableBuilder(column: $table.restEndsAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ActiveWorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveWorkoutPlansTable> {
  $$ActiveWorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get planJson =>
      $composableBuilder(column: $table.planJson, builder: (column) => column);

  GeneratedColumn<String> get currentExerciseId =>
      $composableBuilder(column: $table.currentExerciseId, builder: (column) => column);

  GeneratedColumn<String> get restEndsAt =>
      $composableBuilder(column: $table.restEndsAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ActiveWorkoutPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveWorkoutPlansTable,
          ActiveWorkoutPlan,
          $$ActiveWorkoutPlansTableFilterComposer,
          $$ActiveWorkoutPlansTableOrderingComposer,
          $$ActiveWorkoutPlansTableAnnotationComposer,
          $$ActiveWorkoutPlansTableCreateCompanionBuilder,
          $$ActiveWorkoutPlansTableUpdateCompanionBuilder,
          (
            ActiveWorkoutPlan,
            BaseReferences<_$AppDatabase, $ActiveWorkoutPlansTable, ActiveWorkoutPlan>,
          ),
          ActiveWorkoutPlan,
          PrefetchHooks Function()
        > {
  $$ActiveWorkoutPlansTableTableManager(_$AppDatabase db, $ActiveWorkoutPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveWorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveWorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveWorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> planJson = const Value.absent(),
                Value<String?> currentExerciseId = const Value.absent(),
                Value<String?> restEndsAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorkoutPlansCompanion(
                sessionId: sessionId,
                userId: userId,
                planJson: planJson,
                currentExerciseId: currentExerciseId,
                restEndsAt: restEndsAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String userId,
                required String planJson,
                Value<String?> currentExerciseId = const Value.absent(),
                Value<String?> restEndsAt = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActiveWorkoutPlansCompanion.insert(
                sessionId: sessionId,
                userId: userId,
                planJson: planJson,
                currentExerciseId: currentExerciseId,
                restEndsAt: restEndsAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActiveWorkoutPlansTable, ActiveWorkoutPlan>(table),
                  BaseReferences<_$AppDatabase, $ActiveWorkoutPlansTable, ActiveWorkoutPlan>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActiveWorkoutPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveWorkoutPlansTable,
      ActiveWorkoutPlan,
      $$ActiveWorkoutPlansTableFilterComposer,
      $$ActiveWorkoutPlansTableOrderingComposer,
      $$ActiveWorkoutPlansTableAnnotationComposer,
      $$ActiveWorkoutPlansTableCreateCompanionBuilder,
      $$ActiveWorkoutPlansTableUpdateCompanionBuilder,
      (
        ActiveWorkoutPlan,
        BaseReferences<_$AppDatabase, $ActiveWorkoutPlansTable, ActiveWorkoutPlan>,
      ),
      ActiveWorkoutPlan,
      PrefetchHooks Function()
    >;
typedef $$RestMemoryTableCreateCompanionBuilder = RestMemoryCompanion Function({
  required String userId,
  required String exerciseId,
  required int seconds,
  Value<int> rowid,
});
typedef $$RestMemoryTableUpdateCompanionBuilder = RestMemoryCompanion Function({
  Value<String> userId,
  Value<String> exerciseId,
  Value<int> seconds,
  Value<int> rowid,
});

class $$RestMemoryTableFilterComposer extends Composer<_$AppDatabase, $RestMemoryTable> {
  $$RestMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => ColumnFilters(column));
}

class $$RestMemoryTableOrderingComposer extends Composer<_$AppDatabase, $RestMemoryTable> {
  $$RestMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => ColumnOrderings(column));
}

class $$RestMemoryTableAnnotationComposer extends Composer<_$AppDatabase, $RestMemoryTable> {
  $$RestMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId =>
      $composableBuilder(column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);
}

class $$RestMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestMemoryTable,
          RestMemoryRow,
          $$RestMemoryTableFilterComposer,
          $$RestMemoryTableOrderingComposer,
          $$RestMemoryTableAnnotationComposer,
          $$RestMemoryTableCreateCompanionBuilder,
          $$RestMemoryTableUpdateCompanionBuilder,
          (RestMemoryRow, BaseReferences<_$AppDatabase, $RestMemoryTable, RestMemoryRow>),
          RestMemoryRow,
          PrefetchHooks Function()
        > {
  $$RestMemoryTableTableManager(_$AppDatabase db, $RestMemoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RestMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RestMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestMemoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestMemoryCompanion(
                userId: userId,
                exerciseId: exerciseId,
                seconds: seconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String exerciseId,
                required int seconds,
                Value<int> rowid = const Value.absent(),
              }) => RestMemoryCompanion.insert(
                userId: userId,
                exerciseId: exerciseId,
                seconds: seconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestMemoryTable, RestMemoryRow>(table),
                  BaseReferences<_$AppDatabase, $RestMemoryTable, RestMemoryRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RestMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestMemoryTable,
      RestMemoryRow,
      $$RestMemoryTableFilterComposer,
      $$RestMemoryTableOrderingComposer,
      $$RestMemoryTableAnnotationComposer,
      $$RestMemoryTableCreateCompanionBuilder,
      $$RestMemoryTableUpdateCompanionBuilder,
      (RestMemoryRow, BaseReferences<_$AppDatabase, $RestMemoryTable, RestMemoryRow>),
      RestMemoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SessionSetsTableTableManager get sessionSets =>
      $$SessionSetsTableTableManager(_db, _db.sessionSets);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db, _db.customFoods);
  $$FoodEntriesTableTableManager get foodEntries =>
      $$FoodEntriesTableTableManager(_db, _db.foodEntries);
  $$FavoriteFoodsTableTableManager get favoriteFoods =>
      $$FavoriteFoodsTableTableManager(_db, _db.favoriteFoods);
  $$TasksTableTableManager get tasks => $$TasksTableTableManager(_db, _db.tasks);
  $$TaskCompletionsTableTableManager get taskCompletions =>
      $$TaskCompletionsTableTableManager(_db, _db.taskCompletions);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db, _db.muscleGroups);
  $$ExercisesTableTableManager get exercises => $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$WorkoutTemplatesTableTableManager get workoutTemplates =>
      $$WorkoutTemplatesTableTableManager(_db, _db.workoutTemplates);
  $$WorkoutTemplateExercisesTableTableManager get workoutTemplateExercises =>
      $$WorkoutTemplateExercisesTableTableManager(_db, _db.workoutTemplateExercises);
  $$FoodsTableTableManager get foods => $$FoodsTableTableManager(_db, _db.foods);
  $$DefaultTasksTableTableManager get defaultTasks =>
      $$DefaultTasksTableTableManager(_db, _db.defaultTasks);
  $$OutboxOpsTableTableManager get outboxOps => $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$ActiveWorkoutPlansTableTableManager get activeWorkoutPlans =>
      $$ActiveWorkoutPlansTableTableManager(_db, _db.activeWorkoutPlans);
  $$RestMemoryTableTableManager get restMemory =>
      $$RestMemoryTableTableManager(_db, _db.restMemory);
}
