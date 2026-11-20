import 'package:drift/drift.dart';

import '../../domain/active_workout.dart';
import '../../domain/body_map.dart';
import '../../domain/muscle_coverage.dart';
import '../../domain/turkish_text.dart';
import '../../domain/week.dart';
import '../db/database.dart' hide ExerciseMuscle;

DateTime _utc(String s) => DateTime.parse(s).toUtc();

BodyRegion _region(String s) =>
    BodyRegion.values.firstWhere((r) => r.name == s, orElse: () => BodyRegion.core);

/// Haftalık maket verisi: 14 kas için ağırlıklı set, kademe (0–3) ve son çalışılan gün.
class WeeklyBodyMap {
  const WeeklyBodyMap({
    required this.muscleSets,
    required this.levels,
    required this.lastWorked,
    required this.regionsWorked,
    required this.totalSets,
  });

  static final empty = WeeklyBodyMap(
    muscleSets: {for (final m in bodyMapMuscles) m: 0.0},
    levels: {for (final m in bodyMapMuscles) m: 0},
    lastWorked: {for (final m in bodyMapMuscles) m: null},
    regionsWorked: 0,
    totalSets: 0,
  );

  final Map<String, double> muscleSets;
  final Map<String, int> levels;
  final Map<String, LocalDate?> lastWorked;
  final int regionsWorked;
  final int totalSets;
}

class RecentWorkout {
  const RecentWorkout({
    required this.sessionId,
    required this.name,
    required this.startedAt,
    required this.exerciseIds,
    required this.setCount,
  });

  final String sessionId;
  final String name;
  final DateTime startedAt;
  final List<String> exerciseIds;
  final int setCount;
}

class ExerciseOption {
  const ExerciseOption({
    required this.id,
    required this.nameTr,
    required this.tracking,
    required this.equipment,
    this.lastDoneAt,
    this.region,
  });

  final String id;
  final String nameTr;
  final String tracking;
  final String equipment;
  final DateTime? lastDoneAt;

  /// Birincil kasın üst bölgesi (yalnızca [WorkoutQueries.exercisesByIds] doldurur).
  final BodyRegion? region;
}

/// Kas grubu: slug, Türkçe adı ve listedeki üst bölgesi.
class MuscleGroupOption {
  const MuscleGroupOption({required this.slug, required this.nameTr, required this.region});
  final String slug;
  final String nameTr;
  final BodyRegion region;
}

/// Hazır program (şablon) özeti.
class TemplateOption {
  const TemplateOption({
    required this.id,
    required this.nameTr,
    required this.description,
    required this.level,
    required this.exerciseCount,
  });
  final String id;
  final String nameTr;
  final String description;
  final String level;
  final int exerciseCount;
}

/// Antrenman sekmesinin okuma sorguları (yazım: `WorkoutRepository`).
class WorkoutQueries {
  WorkoutQueries(this._db);
  final AppDatabase _db;

  /// Sayılan oturumlar: tamamlanan ve süren. Terk edilenler sayılmaz.
  static const _counted = ['completed', 'active'];

  Stream<WeeklyBodyMap> watchWeek(String userId, WeekWindow window) {
    final q =
        _db.select(_db.sessionSets).join([
          innerJoin(
            _db.workoutSessions,
            _db.workoutSessions.id.equalsExp(_db.sessionSets.sessionId),
          ),
        ])..where(
          _db.sessionSets.userId.equals(userId) &
              _db.workoutSessions.status.isIn(_counted) &
              _db.workoutSessions.localDate.isBiggerOrEqualValue(window.start) &
              _db.workoutSessions.localDate.isSmallerOrEqualValue(window.end),
        );
    return q.watch().asyncMap((rows) async {
      final sets = [
        for (final r in rows)
          CoverageSet(r.read(_db.sessionSets.exerciseId)!, r.read(_db.workoutSessions.localDate)!),
      ];
      return _build(sets, window);
    });
  }

  Future<WeeklyBodyMap> _build(List<CoverageSet> sets, DateRange window) async {
    final groups = await _db.select(_db.muscleGroups).get();
    final slugById = {for (final g in groups) g.id: g.slug};
    final muscles = [for (final g in groups) MuscleInfo(g.slug, _region(g.bodyRegion))];
    final em = [
      for (final r in await _db.select(_db.exerciseMuscles).get())
        if (slugById[r.muscleGroupId] != null)
          ExerciseMuscle(
            r.exerciseId,
            slugById[r.muscleGroupId]!,
            r.role == 'primary' ? MuscleRole.primary : MuscleRole.secondary,
          ),
    ];
    final cov = muscleCoverage(sets: sets, exerciseMuscles: em, muscles: muscles, window: window);

    final byExercise = indexExerciseMuscles(em);
    final last = <String, LocalDate>{};
    for (final s in sets) {
      for (final e in byExercise[s.exerciseId] ?? const <ExerciseMuscle>[]) {
        final cur = last[e.muscle];
        if (cur == null || s.localDate.compareTo(cur) > 0) last[e.muscle] = s.localDate;
      }
    }

    final muscleSets = {for (final m in bodyMapMuscles) m: cov.muscles[m]?.sets ?? 0.0};
    return WeeklyBodyMap(
      muscleSets: muscleSets,
      levels: {for (final e in muscleSets.entries) e.key: bodyMapLevel(e.value)},
      lastWorked: {for (final m in bodyMapMuscles) m: last[m]},
      regionsWorked: cov.regions.values.where((r) => r.sets > 0).length,
      totalSets: cov.totalSets,
    );
  }

  /// Hareketin en son tamamlanan oturumdaki setleri (`setIndex` sırasıyla).
  Future<List<LoggedSet>> lastSessionSets(
    String userId,
    String exerciseId, {
    String? excludingSessionId,
  }) async {
    final s = _db.workoutSessions;
    final t = _db.sessionSets;
    final latest =
        await (_db.select(s)
              ..where(
                (r) =>
                    r.userId.equals(userId) &
                    r.status.equals('completed') &
                    (excludingSessionId == null
                        ? const Constant(true)
                        : r.id.equals(excludingSessionId).not()) &
                    r.id.isInQuery(
                      _db.selectOnly(t)
                        ..addColumns([t.sessionId])
                        ..where(t.exerciseId.equals(exerciseId) & t.userId.equals(userId)),
                    ),
              )
              ..orderBy([(r) => OrderingTerm.desc(r.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (latest == null) return const [];
    final rows =
        await (_db.select(t)
              ..where((r) => r.sessionId.equals(latest.id) & r.exerciseId.equals(exerciseId))
              ..orderBy([(r) => OrderingTerm.asc(r.setIndex)]))
            .get();
    return [
      for (final r in rows)
        LoggedSet(
          id: r.id,
          exerciseId: r.exerciseId,
          exerciseOrder: r.exerciseOrder,
          setIndex: r.setIndex,
          reps: r.reps,
          durationSeconds: r.durationSeconds,
          weightKg: r.weightKg,
          completedAt: _utc(r.completedAt),
        ),
    ];
  }

  Future<List<RecentWorkout>> recent(String userId, {int limit = 3}) async {
    final sessions =
        await (_db.select(_db.workoutSessions)
              ..where((r) => r.userId.equals(userId) & r.status.equals('completed'))
              ..orderBy([(r) => OrderingTerm.desc(r.startedAt)])
              ..limit(limit))
            .get();
    if (sessions.isEmpty) return const [];
    final sets =
        await (_db.select(_db.sessionSets)
              ..where((r) => r.sessionId.isIn(sessions.map((e) => e.id)))
              ..orderBy([(r) => OrderingTerm.asc(r.exerciseOrder)]))
            .get();
    return [
      for (final se in sessions)
        () {
          final mine = sets.where((x) => x.sessionId == se.id).toList();
          return RecentWorkout(
            sessionId: se.id,
            name: se.name,
            startedAt: _utc(se.startedAt),
            exerciseIds: [
              ...{for (final x in mine) x.exerciseId},
            ],
            setCount: mine.length,
          );
        }(),
    ];
  }

  Future<Map<String, DateTime>> _lastDone(String userId) async {
    final rows = await (_db.select(_db.sessionSets)..where((r) => r.userId.equals(userId))).get();
    final out = <String, DateTime>{};
    for (final r in rows) {
      final t = _utc(r.completedAt);
      final cur = out[r.exerciseId];
      if (cur == null || t.isAfter(cur)) out[r.exerciseId] = t;
    }
    return out;
  }

  ExerciseOption _option(Exercise e, Map<String, DateTime> done) => ExerciseOption(
    id: e.id,
    nameTr: e.nameTr,
    tracking: e.tracking,
    equipment: e.equipment,
    lastDoneAt: done[e.id],
  );

  /// Önce kullanıcının yaptıkları (son yapılan başta), sonra katalog (ada göre).
  Future<List<ExerciseOption>> exercisesForRegion(String userId, BodyRegion region) async {
    final groupIds = (await (_db.select(
      _db.muscleGroups,
    )..where((g) => g.bodyRegion.equals(region.name))).get()).map((g) => g.id).toList();
    final links = await (_db.select(
      _db.exerciseMuscles,
    )..where((r) => r.muscleGroupId.isIn(groupIds))).get();
    final primaryIds = {
      for (final r in links)
        if (r.role == 'primary') r.exerciseId,
    };
    final exIds = {for (final r in links) r.exerciseId};
    final exercises = await (_db.select(
      _db.exercises,
    )..where((e) => e.id.isIn(exIds) & e.isActive.equals(true))).get();
    final done = await _lastDone(userId);
    final opts = [for (final e in exercises) _option(e, done)];
    opts.sort((a, b) {
      final da = a.lastDoneAt, db = b.lastDoneAt;
      if (da != null && db != null) return db.compareTo(da);
      if (da != null) return -1;
      if (db != null) return 1;
      final pa = primaryIds.contains(a.id), pb = primaryIds.contains(b.id);
      if (pa != pb) return pa ? -1 : 1;
      return turkishKey(a.nameTr).compareTo(turkishKey(b.nameTr));
    });
    return opts;
  }

  Future<List<ExerciseOption>> searchExercises(String query) async {
    final key = turkishKey(query);
    final all =
        await (_db.select(_db.exercises)
              ..where((e) => e.isActive.equals(true))
              ..orderBy([(e) => OrderingTerm.asc(e.nameTr)]))
            .get();
    return [
      for (final e in all)
        if (turkishKey(e.nameTr).contains(key) || turkishKey(e.nameEn).contains(key))
          _option(e, const {}),
    ];
  }

  /// Verilen hareketler (aktif olmayanlar da): ad, takip, ekipman ve birincil kasın bölgesi.
  Future<Map<String, ExerciseOption>> exercisesByIds(Iterable<String> ids) async {
    final idList = ids.toSet();
    if (idList.isEmpty) return const {};
    final exercises = await (_db.select(_db.exercises)..where((e) => e.id.isIn(idList))).get();
    final em = _db.exerciseMuscles;
    final mg = _db.muscleGroups;
    final rows = await (_db.select(em).join([
      innerJoin(mg, mg.id.equalsExp(em.muscleGroupId)),
    ])..where(em.exerciseId.isIn(idList) & em.role.equals('primary'))).get();
    final regionOf = <String, BodyRegion>{};
    for (final r in rows) {
      regionOf.putIfAbsent(r.read(em.exerciseId)!, () => _region(r.read(mg.bodyRegion)!));
    }
    return {
      for (final e in exercises)
        e.id: ExerciseOption(
          id: e.id,
          nameTr: e.nameTr,
          tracking: e.tracking,
          equipment: e.equipment,
          region: regionOf[e.id],
        ),
    };
  }

  Future<List<PlannedExercise>> templatePlan(String templateId) async {
    final te = _db.workoutTemplateExercises;
    final rows =
        await (_db.select(te).join([
                innerJoin(_db.exercises, _db.exercises.id.equalsExp(te.exerciseId)),
              ])
              ..where(te.templateId.equals(templateId))
              ..orderBy([OrderingTerm.asc(te.orderIndex)]))
            .get();
    return [
      for (final r in rows)
        PlannedExercise(
          exerciseId: r.read(te.exerciseId)!,
          tracking: r.read(_db.exercises.tracking)!,
          equipment: r.read(_db.exercises.equipment)!,
          targetSets: r.read(te.sets)!,
          restSeconds: r.read(te.restSeconds)!,
        ),
    ];
  }

  /// Kas grupları (`sortOrder` sırasıyla).
  Future<List<MuscleGroupOption>> muscleGroups() async {
    final rows = await (_db.select(
      _db.muscleGroups,
    )..orderBy([(g) => OrderingTerm.asc(g.sortOrder)])).get();
    return [
      for (final g in rows)
        MuscleGroupOption(slug: g.slug, nameTr: g.nameTr, region: _region(g.bodyRegion)),
    ];
  }

  /// Hazır programlar (`sortOrder` sırasıyla) ve hareket sayıları.
  Future<List<TemplateOption>> templates() async {
    final rows = await (_db.select(
      _db.workoutTemplates,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    final counts = <String, int>{};
    for (final r in await _db.select(_db.workoutTemplateExercises).get()) {
      counts[r.templateId] = (counts[r.templateId] ?? 0) + 1;
    }
    return [
      for (final t in rows)
        TemplateOption(
          id: t.id,
          nameTr: t.nameTr,
          description: t.description,
          level: t.level,
          exerciseCount: counts[t.id] ?? 0,
        ),
    ];
  }
}
