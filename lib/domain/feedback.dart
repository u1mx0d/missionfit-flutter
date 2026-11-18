/// Haftalık geri bildirim ve şablon önerisi (algoritma 5). RN `src/domain/feedback.ts` karşılığı.
///
/// Çalışılmayan bölgeleri suçlamadan söyler ve bu bölgeleri en çok kapsayan şablonu önerir
/// (kullanıcı seviyesinin üstündeki şablonlar elenir; elenince boş kalırsa filtre uygulanmaz).
library;

import 'format.dart';
import 'js_math.dart';
import 'muscle_coverage.dart';

const regionLabels = <BodyRegion, String>{
  BodyRegion.chest: 'göğüs',
  BodyRegion.back: 'sırt',
  BodyRegion.shoulders: 'omuz',
  BodyRegion.arms: 'kol',
  BodyRegion.core: 'karın',
  BodyRegion.legs: 'bacak',
};

enum Level { beginner, intermediate, advanced }

const levelLabels = <Level, String>{
  Level.beginner: 'Başlangıç',
  Level.intermediate: 'Orta',
  Level.advanced: 'İleri',
};

class TemplateForSuggestion {
  const TemplateForSuggestion({
    required this.id,
    required this.nameTr,
    required this.level,
    required this.exercises,
  });
  final String id;
  final String nameTr;
  final Level level;
  final List<({String exerciseId, int sets})> exercises;
}

class Suggestion {
  const Suggestion({
    required this.templateId,
    required this.nameTr,
    required this.coversRegions,
    required this.score,
    required this.message,
  });
  final String templateId;
  final String nameTr;

  /// Şablonun kapsadığı, bu hafta çalışılmamış bölgeler
  final List<BodyRegion> coversRegions;
  final double score;
  final String message;
}

class Feedback {
  const Feedback({required this.untrainedRegions, required this.message, this.suggestion});
  final List<BodyRegion> untrainedRegions;
  final String message;
  final Suggestion? suggestion;
}

Suggestion? suggestTemplate({
  required Coverage coverage,
  required List<TemplateForSuggestion> templates,
  required List<ExerciseMuscle> exerciseMuscles,
  required List<MuscleInfo> muscles,
  Level? userLevel,
}) {
  final regionWeight = {
    for (final r in bodyRegions)
      r: switch (coverage.regions[r]?.status ?? CoverageStatus.none) {
        CoverageStatus.none => 1.0,
        CoverageStatus.low => 0.5,
        CoverageStatus.adequate => 0.0,
      },
  };
  if (!regionWeight.values.any((w) => w == 1)) return null;

  final byExercise = indexExerciseMuscles(exerciseMuscles);
  final muscleRegion = {for (final m in muscles) m.slug: m.region};

  var pool = templates;
  if (userLevel != null) {
    final filtered = pool.where((t) => t.level.index <= userLevel.index).toList();
    if (filtered.isNotEmpty) pool = filtered;
  }

  final ranked =
      [for (final t in pool) _score(t, byExercise, muscleRegion, regionWeight)]
          .where((x) => x.covered.isNotEmpty)
          .toList()
        ..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          if (byScore != 0) return byScore;
          final byCovered = b.covered.length - a.covered.length;
          if (byCovered != 0) return byCovered;
          final bySets = a.totalSets - b.totalSets;
          if (bySets != 0) return bySets;
          // RN: localeCompare('tr'); burada kod noktası sırası (yalnızca tam eşitlikte devreye girer).
          return a.t.nameTr.compareTo(b.t.nameTr);
        });

  if (ranked.isEmpty) return null;
  final best = ranked.first;
  final regionText = joinTurkish([for (final r in best.covered) regionLabels[r]!]);
  final noun = best.covered.length == 1 ? 'bölgesini' : 'bölgelerini';
  return Suggestion(
    templateId: best.t.id,
    nameTr: best.t.nameTr,
    coversRegions: best.covered,
    score: jsRound(best.score * 10) / 10,
    message: '"${best.t.nameTr}" antrenmanı $regionText $noun çalıştırır.',
  );
}

({TemplateForSuggestion t, double score, int totalSets, List<BodyRegion> covered}) _score(
  TemplateForSuggestion template,
  Map<String, List<ExerciseMuscle>> byExercise,
  Map<String, BodyRegion> muscleRegion,
  Map<BodyRegion, double> regionWeight,
) {
  var score = 0.0;
  var totalSets = 0;
  final covered = <BodyRegion>{};
  for (final ex in template.exercises) {
    totalSets += ex.sets;
    for (final e in byExercise[ex.exerciseId] ?? const <ExerciseMuscle>[]) {
      final region = muscleRegion[e.muscle];
      if (region == null) continue;
      final w = regionWeight[region] ?? 0;
      if (w == 0) continue;
      final roleW = e.role == MuscleRole.primary
          ? defaultThresholds.primaryWeight
          : defaultThresholds.secondaryWeight;
      score += ex.sets * roleW * w;
      if (w == 1) covered.add(region);
    }
  }
  return (
    t: template,
    score: score,
    totalSets: totalSets,
    covered: [
      for (final r in bodyRegions)
        if (covered.contains(r)) r,
    ],
  );
}

Feedback buildFeedback({
  required Coverage coverage,
  required List<TemplateForSuggestion> templates,
  required List<ExerciseMuscle> exerciseMuscles,
  required List<MuscleInfo> muscles,
  Level? userLevel,
}) {
  Suggestion? suggest() => suggestTemplate(
    coverage: coverage,
    templates: templates,
    exerciseMuscles: exerciseMuscles,
    muscles: muscles,
    userLevel: userLevel,
  );
  final untrained = [
    for (final r in bodyRegions)
      if (coverage.regions[r]?.status == CoverageStatus.none) r,
  ];

  if (coverage.totalSets == 0) {
    return Feedback(
      untrainedRegions: untrained,
      message: 'Bu hafta henüz antrenman kaydın yok. Hazır olduğunda kısa bir antrenmanla başlayabilirsin.',
      suggestion: suggest(),
    );
  }
  if (untrained.isEmpty) {
    return Feedback(
      untrainedRegions: untrained,
      message: 'Bu hafta tüm bölgeleri çalıştın. Harika bir denge!',
    );
  }
  final list = joinTurkish([for (final r in untrained) regionLabels[r]!]);
  return Feedback(
    untrainedRegions: untrained,
    message: 'Bu hafta henüz $list çalışmadın.',
    suggestion: suggest(),
  );
}
