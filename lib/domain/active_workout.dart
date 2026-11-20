/// Aktif antrenman kuralları: hareket sırası, set indeksi, sıradaki set,
/// ön doldurma. Sunucu kurallarını yansıtır. Saf Dart.
library;

/// Antrenman planındaki bir hareket.
class PlannedExercise {
  const PlannedExercise({
    required this.exerciseId,
    required this.tracking,
    required this.equipment,
    required this.targetSets,
    required this.restSeconds,
  });

  final String exerciseId;
  final String tracking;
  final String equipment;
  final int targetSets;
  final int restSeconds;

  Map<String, Object?> toJson() => {
    'exerciseId': exerciseId,
    'tracking': tracking,
    'equipment': equipment,
    'targetSets': targetSets,
    'restSeconds': restSeconds,
  };

  factory PlannedExercise.fromJson(Map<String, Object?> j) => PlannedExercise(
    exerciseId: j['exerciseId']! as String,
    tracking: j['tracking']! as String,
    equipment: j['equipment']! as String,
    targetSets: (j['targetSets']! as num).toInt(),
    restSeconds: (j['restSeconds']! as num).toInt(),
  );

  @override
  bool operator ==(Object other) =>
      other is PlannedExercise &&
      other.exerciseId == exerciseId &&
      other.tracking == tracking &&
      other.equipment == equipment &&
      other.targetSets == targetSets &&
      other.restSeconds == restSeconds;

  @override
  int get hashCode => Object.hash(exerciseId, tracking, equipment, targetSets, restSeconds);
}

/// Tamamlanmış bir set.
class LoggedSet {
  const LoggedSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setIndex,
    this.reps,
    this.durationSeconds,
    this.weightKg,
    required this.completedAt,
  });

  final String id;
  final String exerciseId;
  final int exerciseOrder;
  final int setIndex;
  final int? reps;
  final int? durationSeconds;
  final double? weightKg;
  final DateTime completedAt;

  @override
  bool operator ==(Object other) =>
      other is LoggedSet &&
      other.id == id &&
      other.exerciseId == exerciseId &&
      other.exerciseOrder == exerciseOrder &&
      other.setIndex == setIndex &&
      other.reps == reps &&
      other.durationSeconds == durationSeconds &&
      other.weightKg == weightKg &&
      other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    exerciseOrder,
    setIndex,
    reps,
    durationSeconds,
    weightKg,
    completedAt,
  );
}

/// Bir setin ön doldurulan değerleri.
class SetValues {
  const SetValues({this.weightKg, this.reps, this.durationSeconds});

  final double? weightKg;
  final int? reps;
  final int? durationSeconds;

  @override
  bool operator ==(Object other) =>
      other is SetValues &&
      other.weightKg == weightKg &&
      other.reps == reps &&
      other.durationSeconds == durationSeconds;

  @override
  int get hashCode => Object.hash(weightKg, reps, durationSeconds);
}

/// Sunucudaki `set_index` üst sınırı.
const int maxSetIndex = 50;

/// Değişmez aktif antrenman durumu; her değişiklik yeni nesne döndürür.
class ActiveWorkout {
  ActiveWorkout({
    required this.sessionId,
    required this.startedAt,
    required List<PlannedExercise> plan,
    required List<LoggedSet> sets,
    this.currentExerciseId,
  }) : plan = List.unmodifiable(plan),
       sets = List.unmodifiable(sets);

  final String sessionId;
  final DateTime startedAt;
  final List<PlannedExercise> plan;
  final List<LoggedSet> sets;
  final String? currentExerciseId;

  Iterable<LoggedSet> _of(String exerciseId) => sets.where((s) => s.exerciseId == exerciseId);

  /// Hareketin seti varsa onun sırası; yoksa en büyük sıra + 1 (set yoksa 0).
  int orderFor(String exerciseId) {
    for (final s in sets) {
      if (s.exerciseId == exerciseId) return s.exerciseOrder;
    }
    var max = -1;
    for (final s in sets) {
      if (s.exerciseOrder > max) max = s.exerciseOrder;
    }
    return max + 1;
  }

  int _maxIndex(String exerciseId) {
    var max = 0;
    for (final s in _of(exerciseId)) {
      if (s.setIndex > max) max = s.setIndex;
    }
    return max;
  }

  /// Sıradaki set indeksi: en büyük + 1 (set yoksa 1). 50'yi geçerse hata.
  int nextSetIndex(String exerciseId) {
    final next = _maxIndex(exerciseId) + 1;
    if (next > maxSetIndex) {
      throw StateError('Bir harekette en fazla $maxSetIndex set olur.');
    }
    return next;
  }

  int doneSets(String exerciseId) => _of(exerciseId).length;

  ActiveWorkout _copy({
    List<PlannedExercise>? plan,
    List<LoggedSet>? sets,
    String? currentExerciseId,
  }) => ActiveWorkout(
    sessionId: sessionId,
    startedAt: startedAt,
    plan: plan ?? this.plan,
    sets: sets ?? this.sets,
    currentExerciseId: currentExerciseId ?? this.currentExerciseId,
  );

  /// Aynı hareket varsa değişmez; yenisi planın sonuna eklenir ve seçilir.
  ActiveWorkout addExercise(PlannedExercise e) {
    if (plan.any((p) => p.exerciseId == e.exerciseId)) return this;
    return _copy(plan: [...plan, e], currentExerciseId: e.exerciseId);
  }

  ActiveWorkout select(String exerciseId) => _copy(currentExerciseId: exerciseId);

  /// Hareketin hedef set sayısını [delta] kadar değiştirir; hedef yapılan set sayısının
  /// (ve 1'in) altına inmez, [maxSetIndex]'i geçmez.
  ActiveWorkout changeTargetSets(String exerciseId, int delta) {
    final floor = doneSets(exerciseId) < 1 ? 1 : doneSets(exerciseId);
    return _copy(
      plan: [
        for (final p in plan)
          p.exerciseId == exerciseId
              ? PlannedExercise(
                  exerciseId: p.exerciseId,
                  tracking: p.tracking,
                  equipment: p.equipment,
                  targetSets: (p.targetSets + delta).clamp(floor, maxSetIndex),
                  restSeconds: p.restSeconds,
                )
              : p,
      ],
    );
  }

  ActiveWorkout logSet(LoggedSet s) => _copy(sets: [...sets, s]);

  ActiveWorkout replaceSet(LoggedSet s) =>
      _copy(sets: [for (final x in sets) x.id == s.id ? s : x]);

  ActiveWorkout removeSet(String setId) => _copy(
    sets: [
      for (final x in sets)
        if (x.id != setId) x,
    ],
  );

  /// Sıradaki (hareket, set indeksi); hepsi hedefte ise null.
  ({String exerciseId, int setIndex})? nextUp() {
    if (plan.isEmpty) return null;
    final cur = currentExerciseId;
    final curPlan = plan.where((p) => p.exerciseId == cur);
    if (curPlan.isNotEmpty && doneSets(cur!) < curPlan.first.targetSets) {
      return (exerciseId: cur, setIndex: nextSetIndex(cur));
    }
    final start = plan.indexWhere((p) => p.exerciseId == cur);
    for (var i = 1; i <= plan.length; i++) {
      final p = plan[(start + i) % plan.length];
      if (p.exerciseId == cur) continue;
      if (doneSets(p.exerciseId) < p.targetSets) {
        return (exerciseId: p.exerciseId, setIndex: nextSetIndex(p.exerciseId));
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is ActiveWorkout &&
      other.sessionId == sessionId &&
      other.startedAt == startedAt &&
      other.currentExerciseId == currentExerciseId &&
      _listEq(other.plan, plan) &&
      _listEq(other.sets, sets);

  @override
  int get hashCode => Object.hash(
    sessionId,
    startedAt,
    currentExerciseId,
    Object.hashAll(plan),
    Object.hashAll(sets),
  );
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

SetValues _valuesOf(LoggedSet s) =>
    SetValues(weightKg: s.weightKg, reps: s.reps, durationSeconds: s.durationSeconds);

/// Sıradaki set için ön doldurma: bu antrenmandaki son set; yoksa geçen
/// antrenmanın aynı indeksli seti; o da yoksa geçen antrenmanın son seti.
SetValues prefill(String exerciseId, ActiveWorkout w, List<LoggedSet> lastSessionSets) {
  LoggedSet? latest(Iterable<LoggedSet> xs) {
    LoggedSet? best;
    for (final s in xs) {
      if (best == null || s.setIndex > best.setIndex) best = s;
    }
    return best;
  }

  final current = latest(w._of(exerciseId));
  if (current != null) return _valuesOf(current);

  final last = lastSessionSets.where((s) => s.exerciseId == exerciseId);
  final nextIndex = w._maxIndex(exerciseId) + 1;
  for (final s in last) {
    if (s.setIndex == nextIndex) return _valuesOf(s);
  }
  final lastSet = latest(last);
  return lastSet == null ? const SetValues() : _valuesOf(lastSet);
}

/// Hedef set: şablon; yoksa son antrenmandaki set sayısı; yoksa 3.
int targetSetsFor({int? templateSets, int? lastSessionSetCount}) =>
    templateSets ?? lastSessionSetCount ?? 3;

/// Bu süreden uzun açık kalan antrenman "yarım kalmış" sayılır; açılışta "Bitir mi, sil mi?"
/// diye sorulur.
const staleWorkoutAge = Duration(hours: 24);

bool isStaleWorkout(DateTime startedAt, DateTime now) =>
    now.toUtc().difference(startedAt.toUtc()) > staleWorkoutAge;
