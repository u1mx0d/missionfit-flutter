import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/active_workout.dart';
import '../../domain/dates.dart';
import '../../domain/week.dart';
import '../../domain/workout_kcal.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import '../sync/outbox_queue.dart';

/// Antrenmanı bitirmenin sonucu.
sealed class WorkoutFinish {
  const WorkoutFinish();
}

/// Oturum kaydedildi. Kilo bilinmiyorsa [kcal] null'dır (sunucuya da `estimated_kcal` null).
final class Saved extends WorkoutFinish {
  const Saved(this.kcal);
  final int? kcal;

  @override
  bool operator ==(Object other) => other is Saved && other.kcal == kcal;
  @override
  int get hashCode => kcal.hashCode;
}

/// Hiç set yoktu; oturum silindi, kaydedilmedi.
final class DiscardedEmpty extends WorkoutFinish {
  const DiscardedEmpty();
  @override
  bool operator ==(Object other) => other is DiscardedEmpty;
  @override
  int get hashCode => 0;
}

String _iso(DateTime t) => t.toUtc().toIso8601String();
DateTime _parse(String s) => DateTime.parse(s).toUtc();

/// Sunucu `weight_kg numeric(5,1)`: 0,1 hassasiyet.
double? _roundWeight(double? kg) => kg == null ? null : (kg * 10).round() / 10;

/// Antrenman yazımı: yerel drift satırı + aynı transaction'da outbox işlemi.
/// Plan ve dinlenme hafızası yalnızca yereldedir (senkronlanmaz).
class WorkoutRepository {
  WorkoutRepository(this._db, this._outbox, {DateTime Function()? clock, String Function()? newId})
    : _clock = clock ?? DateTime.now,
      _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final DateTime Function() _clock;
  final String Function() _newId;
  int _counter = 0;

  Future<void> _enqueue(String table, String id, String action, Map<String, Object?> payload) {
    final now = _clock();
    return _outbox.enqueue(
      OutboxOp(
        opId: '$table-$id-${now.microsecondsSinceEpoch}-${_counter++}',
        key: '$table:$id',
        type: '$table.$action',
        payload: payload,
        attempts: 0,
        createdAt: now.millisecondsSinceEpoch,
      ),
    );
  }

  // `created_at`/`updated_at` sunucuda damgalanır; yüke girmez.
  Map<String, Object?> _sessionPayload(WorkoutSession r) => {
    'id': r.id,
    'user_id': r.userId,
    'template_id': r.templateId,
    'name': r.name,
    'started_at': r.startedAt,
    'ended_at': r.endedAt,
    'local_date': r.localDate,
    'week_key': r.weekKey,
    'estimated_kcal': r.estimatedKcal,
    'status': r.status,
  };

  Map<String, Object?> _setPayload(SessionSet r) => {
    'id': r.id,
    'session_id': r.sessionId,
    'user_id': r.userId,
    'exercise_id': r.exerciseId,
    'exercise_order': r.exerciseOrder,
    'set_index': r.setIndex,
    'reps': r.reps,
    'duration_seconds': r.durationSeconds,
    'weight_kg': r.weightKg,
    'completed_at': r.completedAt,
  };

  /// Sunucu `ended_at >= started_at` ister; saat geri alınmışsa başlangıç kullanılır.
  String _endFor(String startedAt, DateTime now) {
    final start = _parse(startedAt);
    return _iso(now.isBefore(start) ? start : now);
  }

  Future<WorkoutSession?> _session(String id) =>
      (_db.select(_db.workoutSessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<WorkoutSession> _requireSession(String id) async {
    final s = await _session(id);
    if (s == null) throw StateError('Antrenman oturumu bulunamadı: $id');
    return s;
  }

  Future<void> _writeSession(WorkoutSession r) async {
    await _db.into(_db.workoutSessions).insertOnConflictUpdate(r);
    await _enqueue('workout_sessions', r.id, 'upsert', _sessionPayload(r));
  }

  Future<void> _writeSet(SessionSet r) async {
    await _db.into(_db.sessionSets).insertOnConflictUpdate(r);
    await _enqueue('session_sets', r.id, 'upsert', _setPayload(r));
  }

  /// Yeni oturum açar. Yerelde açık kalmış başka `active` oturum varsa (ör. başka telefondan
  /// senkronla gelmiş) önce `abandoned` yapılır; outbox'ta yeni oturumdan önce durur, böylece
  /// sunucudaki "kullanıcı başına tek aktif" kuralı yeni oturumu reddetmez.
  Future<ActiveWorkout> start({
    required String userId,
    required List<PlannedExercise> plan,
    String? templateId,
    String name = 'Antrenman',
    required String timeZone,
    required WeekStartsOn weekStartsOn,
  }) => _db.transaction(() async {
    final now = _clock().toUtc();
    final nowIso = _iso(now);

    final stale = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.userId.equals(userId) & t.status.equals('active'))).get();
    for (final s in stale) {
      await _writeSession(
        s.copyWith(
          status: 'abandoned',
          endedAt: Value(_endFor(s.startedAt, now)),
          updatedAt: nowIso,
        ),
      );
      await (_db.delete(_db.activeWorkoutPlans)..where((t) => t.sessionId.equals(s.id))).go();
    }

    final id = _newId();
    final localDate = localDateInZone(now, timeZone);
    await _writeSession(
      WorkoutSession(
        id: id,
        userId: userId,
        templateId: templateId,
        name: name,
        startedAt: nowIso,
        endedAt: null,
        localDate: localDate,
        weekKey: weekKeyOf(localDate, weekStartsOn),
        estimatedKcal: null,
        status: 'active',
        createdAt: nowIso,
        updatedAt: nowIso,
      ),
    );
    final w = ActiveWorkout(
      sessionId: id,
      startedAt: now,
      plan: plan,
      sets: const [],
      currentExerciseId: plan.isEmpty ? null : plan.first.exerciseId,
    );
    await _upsertPlan(w, userId, nowIso);
    return w;
  });

  Future<void> _upsertPlan(ActiveWorkout w, String userId, String nowIso) => _db
      .into(_db.activeWorkoutPlans)
      .insertOnConflictUpdate(
        ActiveWorkoutPlansCompanion.insert(
          sessionId: w.sessionId,
          userId: userId,
          planJson: jsonEncode([for (final p in w.plan) p.toJson()]),
          currentExerciseId: Value(w.currentExerciseId),
          updatedAt: nowIso,
        ),
      );

  /// Kullanıcının yereldeki aktif oturumu; plan satırı yoksa (senkronla gelmiş) plan boştur.
  Future<ActiveWorkout?> loadActive(String userId) async {
    final session =
        await (_db.select(_db.workoutSessions)
              ..where((t) => t.userId.equals(userId) & t.status.equals('active'))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (session == null) return null;
    final planRow = await (_db.select(
      _db.activeWorkoutPlans,
    )..where((t) => t.sessionId.equals(session.id))).getSingleOrNull();
    final rows =
        await (_db.select(_db.sessionSets)
              ..where((t) => t.sessionId.equals(session.id))
              ..orderBy([
                (t) => OrderingTerm.asc(t.completedAt),
                (t) => OrderingTerm.asc(t.exerciseOrder),
                (t) => OrderingTerm.asc(t.setIndex),
              ]))
            .get();
    return ActiveWorkout(
      sessionId: session.id,
      startedAt: _parse(session.startedAt),
      plan: planRow == null ? const [] : _decodePlan(planRow.planJson),
      sets: [for (final r in rows) _toLogged(r)],
      currentExerciseId: planRow?.currentExerciseId,
    );
  }

  List<PlannedExercise> _decodePlan(String json) => [
    for (final e in jsonDecode(json) as List)
      PlannedExercise.fromJson((e as Map).cast<String, Object?>()),
  ];

  LoggedSet _toLogged(SessionSet r) => LoggedSet(
    id: r.id,
    exerciseId: r.exerciseId,
    exerciseOrder: r.exerciseOrder,
    setIndex: r.setIndex,
    reps: r.reps,
    durationSeconds: r.durationSeconds,
    weightKg: r.weightKg,
    completedAt: _parse(r.completedAt),
  );

  /// Plan ve seçili hareketi yerelde saklar (dinlenme bitişine dokunmaz).
  Future<void> savePlan(ActiveWorkout w) => _db.transaction(() async {
    final s = await _requireSession(w.sessionId);
    await _upsertPlan(w, s.userId, _iso(_clock()));
  });

  void _validate(int? reps, int? durationSeconds, double? weightKg) {
    if (reps == null && durationSeconds == null) {
      throw ArgumentError('Sette tekrar ya da süre olmalı.');
    }
    if (reps != null && (reps < 1 || reps > 500)) {
      throw ArgumentError.value(reps, 'reps', '1–500 olmalı');
    }
    if (durationSeconds != null && (durationSeconds < 1 || durationSeconds > 86400)) {
      throw ArgumentError.value(durationSeconds, 'durationSeconds', '1–86400 olmalı');
    }
    if (weightKg != null && (weightKg < 0 || weightKg > 1000)) {
      throw ArgumentError.value(weightKg, 'weightKg', '0–1000 olmalı');
    }
  }

  /// Seti tamamlar: sıra ve indeks [ActiveWorkout] kurallarından gelir.
  Future<LoggedSet> completeSet(ActiveWorkout w, String exerciseId, SetValues v) async {
    final weight = _roundWeight(v.weightKg);
    _validate(v.reps, v.durationSeconds, weight);
    final order = w.orderFor(exerciseId);
    final index = w.nextSetIndex(exerciseId);
    return _db.transaction(() async {
      final session = await _requireSession(w.sessionId);
      final now = _clock().toUtc();
      final nowIso = _iso(now);
      final row = SessionSet(
        id: _newId(),
        sessionId: w.sessionId,
        userId: session.userId,
        exerciseId: exerciseId,
        exerciseOrder: order,
        setIndex: index,
        reps: v.reps,
        durationSeconds: v.durationSeconds,
        weightKg: weight,
        completedAt: nowIso,
        updatedAt: nowIso,
      );
      await _writeSet(row);
      return _toLogged(row);
    });
  }

  /// Setin değerlerini değiştirir (aynı id; outbox'ta aynı key tek işlem olarak kalır).
  Future<void> updateSet(LoggedSet s) async {
    final weight = _roundWeight(s.weightKg);
    _validate(s.reps, s.durationSeconds, weight);
    await _db.transaction(() async {
      final old = await (_db.select(
        _db.sessionSets,
      )..where((t) => t.id.equals(s.id))).getSingleOrNull();
      if (old == null) throw StateError('Set bulunamadı: ${s.id}');
      await _writeSet(
        old.copyWith(
          reps: Value(s.reps),
          durationSeconds: Value(s.durationSeconds),
          weightKg: Value(weight),
          completedAt: _iso(s.completedAt),
          updatedAt: _iso(_clock()),
        ),
      );
    });
  }

  /// Seti siler. Silme işlemi outbox'a yazılır; aynı indeksle sonradan gelen setin
  /// yazımı bundan sonra durur, sunucudaki benzersizlik çakışmaz.
  Future<void> deleteSet(LoggedSet s) => _db.transaction(() async {
    final old = await (_db.select(
      _db.sessionSets,
    )..where((t) => t.id.equals(s.id))).getSingleOrNull();
    await (_db.delete(_db.sessionSets)..where((t) => t.id.equals(s.id))).go();
    await _enqueue('session_sets', s.id, 'delete', {
      'id': s.id,
      // Oturum atılırsa bekleyen set işlemlerini bulmak için.
      if (old != null) 'session_id': old.sessionId,
    });
  });

  /// Antrenmanı bitirir. Hiç set yoksa oturum silinir ve [DiscardedEmpty] döner.
  Future<WorkoutFinish> finish(
    ActiveWorkout w, {
    required double? bodyWeightKg,
  }) => _db.transaction(() async {
    final session = await _requireSession(w.sessionId);
    final rows = await (_db.select(
      _db.sessionSets,
    )..where((t) => t.sessionId.equals(w.sessionId))).get();
    if (rows.isEmpty) {
      await _discard(w.sessionId);
      return const DiscardedEmpty();
    }

    final exerciseIds = rows.map((r) => r.exerciseId).toSet();
    final exercises = await (_db.select(_db.exercises)..where((t) => t.id.isIn(exerciseIds))).get();
    final metOf = {for (final e in exercises) e.id: e.metValue};
    final mets = [
      // Katalogda olmayan hareket ortalamaya girmez.
      for (final r in rows) ?metOf[r.exerciseId],
    ];

    final now = _clock().toUtc();
    final endedAt = _endFor(session.startedAt, now);
    final result = estimateWorkoutKcal(
      startedAt: _parse(session.startedAt),
      endedAt: _parse(endedAt),
      weightKg: bodyWeightKg,
      completedSetMets: mets,
    );
    final kcal = switch (result) {
      KcalOk(:final kcal) => kcal,
      KcalMissingWeight() => null,
    };

    await _writeSession(
      session.copyWith(
        status: 'completed',
        endedAt: Value(endedAt),
        estimatedKcal: Value(kcal),
        updatedAt: _iso(now),
      ),
    );
    await (_db.delete(_db.activeWorkoutPlans)..where((t) => t.sessionId.equals(w.sessionId))).go();
    return Saved(kcal);
  });

  /// Oturumu ve setlerini siler. Sunucuda setler cascade ile silinir; outbox'ta tek
  /// `workout_sessions.delete` kalır (bu oturumun bekleyen set işlemleri atılır).
  Future<void> discard(String sessionId) => _db.transaction(() => _discard(sessionId));

  Future<void> _discard(String sessionId) async {
    for (final op in await _outbox.pending()) {
      if (op.type.startsWith('session_sets.') && op.payload['session_id'] == sessionId) {
        await _outbox.remove(op.opId);
      }
    }
    await (_db.delete(_db.sessionSets)..where((t) => t.sessionId.equals(sessionId))).go();
    await (_db.delete(_db.activeWorkoutPlans)..where((t) => t.sessionId.equals(sessionId))).go();
    await (_db.delete(_db.workoutSessions)..where((t) => t.id.equals(sessionId))).go();
    await _enqueue('workout_sessions', sessionId, 'delete', {'id': sessionId});
  }

  /// Dinlenmenin bitiş anı (yalnızca yerel); null dinlenmeyi temizler.
  Future<void> setRestEnd(String sessionId, DateTime? endsAt) =>
      (_db.update(_db.activeWorkoutPlans)..where((t) => t.sessionId.equals(sessionId))).write(
        ActiveWorkoutPlansCompanion(
          restEndsAt: Value(endsAt == null ? null : _iso(endsAt)),
          updatedAt: Value(_iso(_clock())),
        ),
      );

  /// Kayıtlı dinlenme bitişi (UTC); yoksa null.
  Future<DateTime?> restEndFor(String sessionId) async {
    final row = await (_db.select(
      _db.activeWorkoutPlans,
    )..where((t) => t.sessionId.equals(sessionId))).getSingleOrNull();
    final v = row?.restEndsAt;
    return v == null ? null : _parse(v);
  }

  /// Hareket için son kullanılan dinlenme süresi (saniye); yoksa null.
  Future<int?> restSecondsFor(String userId, String exerciseId) async {
    final row = await (_db.select(
      _db.restMemory,
    )..where((t) => t.userId.equals(userId) & t.exerciseId.equals(exerciseId))).getSingleOrNull();
    return row?.seconds;
  }

  Future<void> rememberRest(String userId, String exerciseId, int seconds) => _db
      .into(_db.restMemory)
      .insertOnConflictUpdate(
        RestMemoryCompanion.insert(userId: userId, exerciseId: exerciseId, seconds: seconds),
      );
}
