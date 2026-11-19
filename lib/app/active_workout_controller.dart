import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/active_workout.dart';
import '../domain/week.dart';
import 'profile_controller.dart';
import 'today_provider.dart' show defaultTimeZone;
import 'workout_providers.dart';

export 'workout_providers.dart' show DiscardedEmpty, Saved, WorkoutFinish;

/// Süren antrenman: bellekteki durum + her değişiklik anında diske (yerel + outbox).
/// İşlemler sırayla çalışır; hızlı iki dokunuş aynı set indeksini üretemez.
class ActiveWorkoutController extends AsyncNotifier<ActiveWorkout?> {
  Future<void> _queue = Future.value();

  @override
  Future<ActiveWorkout?> build() async {
    final userId = ref.watch(signedInUserIdProvider);
    if (userId == null) return null;
    return ref.read(workoutRepositoryProvider).loadActive(userId);
  }

  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  String get _userId {
    final id = ref.read(signedInUserIdProvider);
    if (id == null) throw StateError('Oturum yok');
    return id;
  }

  Future<T> _serial<T>(Future<T> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  Future<ActiveWorkout> _current() async {
    final w = await future;
    if (w == null) throw StateError('Süren antrenman yok');
    return w;
  }

  void _clearDrafts() => ref.read(focusDraftsProvider.notifier).clearAll();

  Future<void> start(List<PlannedExercise> plan, {String? templateId, String? name}) =>
      _serial(() async {
        final profile = await ref.read(profileProvider.future);
        final w = await _repo.start(
          userId: _userId,
          plan: plan,
          templateId: templateId,
          name: name ?? 'Antrenman',
          timeZone: profile?.timezone ?? defaultTimeZone,
          weekStartsOn: profile?.weekStartsOn ?? WeekStartsOn.monday,
        );
        _clearDrafts();
        state = AsyncData(w);
      });

  Future<void> _savePlan(ActiveWorkout w) async {
    state = AsyncData(w);
    await _repo.savePlan(w);
  }

  Future<void> select(String exerciseId) =>
      _serial(() async => _savePlan((await _current()).select(exerciseId)));

  Future<void> addExercise(PlannedExercise e) =>
      _serial(() async => _savePlan((await _current()).addExercise(e)));

  /// "+ Set": hedefi bir artırır (hedef bir sınır değildir).
  Future<void> addTargetSet(String exerciseId) => _serial(() async {
    final w = await _current();
    await _savePlan(
      ActiveWorkout(
        sessionId: w.sessionId,
        startedAt: w.startedAt,
        sets: w.sets,
        currentExerciseId: w.currentExerciseId,
        plan: [
          for (final p in w.plan)
            p.exerciseId == exerciseId
                ? PlannedExercise(
                    exerciseId: p.exerciseId,
                    tracking: p.tracking,
                    equipment: p.equipment,
                    targetSets: p.targetSets + 1,
                    restSeconds: p.restSeconds,
                  )
                : p,
        ],
      ),
    );
  });

  /// Seçili hareketin sıradaki setini yazar.
  Future<LoggedSet> completeSet(SetValues v) => _serial(() async {
    final w = await _current();
    final exerciseId = w.currentExerciseId;
    if (exerciseId == null) throw StateError('Seçili hareket yok');
    final s = await _repo.completeSet(w, exerciseId, v);
    state = AsyncData(w.logSet(s));
    ref.read(focusDraftsProvider.notifier).remove(exerciseId);
    return s;
  });

  /// Son tamamlanan seti siler ("Geri al").
  Future<void> undoLast() => _serial(() async {
    final w = await _current();
    if (w.sets.isEmpty) return;
    final last = w.sets.last;
    await _repo.deleteSet(last);
    state = AsyncData(w.removeSet(last.id));
  });

  Future<void> editSet(LoggedSet s) => _serial(() async {
    final w = await _current();
    await _repo.updateSet(s);
    state = AsyncData(w.replaceSet(s));
  });

  Future<void> deleteSet(LoggedSet s) => _serial(() async {
    final w = await _current();
    await _repo.deleteSet(s);
    state = AsyncData(w.removeSet(s.id));
  });

  /// Antrenmanı bitirir; set yoksa oturum silinir ([DiscardedEmpty]).
  Future<WorkoutFinish> finish() => _serial(() async {
    final w = await _current();
    final profile = await ref.read(profileProvider.future);
    final r = await _repo.finish(w, bodyWeightKg: profile?.weightKg);
    _clearDrafts();
    // Sonraki antrenmanın "geçen sefer"i ve son antrenmanlar listesi yenilensin.
    ref.invalidate(lastSessionSetsProvider);
    ref.invalidate(recentWorkoutsProvider);
    state = const AsyncData(null);
    return r;
  });

  Future<void> discard() => _serial(() async {
    final w = await _current();
    await _repo.discard(w.sessionId);
    _clearDrafts();
    state = const AsyncData(null);
  });
}

final activeWorkoutControllerProvider =
    AsyncNotifierProvider<ActiveWorkoutController, ActiveWorkout?>(ActiveWorkoutController.new);

/// Set tamamlanınca odak modu çağırır. Varsayılan boş; dinlenme (Görev 9) bunu değiştirir.
final onSetCompletedProvider = Provider<void Function(String exerciseId)>((ref) => (_) {});

/// Hareket başına –/+ ile değiştirilmiş ama henüz tamamlanmamış değerler (yalnızca bellekte).
/// Harekete geri dönünce bu değerler korunur.
class FocusDrafts extends Notifier<Map<String, SetValues>> {
  @override
  Map<String, SetValues> build() => const {};

  void put(String exerciseId, SetValues v) => state = {...state, exerciseId: v};

  void remove(String exerciseId) {
    if (!state.containsKey(exerciseId)) return;
    state = {...state}..remove(exerciseId);
  }

  void clearAll() => state = const {};
}

final focusDraftsProvider = NotifierProvider<FocusDrafts, Map<String, SetValues>>(FocusDrafts.new);
