/// Antrenmanda yakılan kalori tahmini (algoritma 2). RN `src/domain/workoutKcal.ts` karşılığı.
///
/// kcal = ortalama MET × kilo × saat. MET, tamamlanan setlerle ağırlıklı ortalamadır. Süre
/// başlangıçtan hesaplanır ve en çok 4 saattir (unutulan açık oturum). Hiç set yoksa 0.
library;

import 'js_math.dart';

const maxSessionHours = 4;

sealed class KcalResult {
  const KcalResult();
}

final class KcalOk extends KcalResult {
  const KcalOk({
    required this.kcal,
    required this.averageMet,
    required this.durationSeconds,
    required this.durationCapped,
  });
  final int kcal;
  final double averageMet;
  final int durationSeconds;

  /// Süre [maxSessionHours]'u aştı ve sınırlandı
  final bool durationCapped;

  @override
  bool operator ==(Object o) =>
      o is KcalOk &&
      o.kcal == kcal &&
      o.averageMet == averageMet &&
      o.durationSeconds == durationSeconds &&
      o.durationCapped == durationCapped;
  @override
  int get hashCode => Object.hash(kcal, averageMet, durationSeconds, durationCapped);
}

final class KcalMissingWeight extends KcalResult {
  const KcalMissingWeight();
  @override
  bool operator ==(Object o) => o is KcalMissingWeight;
  @override
  int get hashCode => 0;
}

int elapsedSeconds(DateTime startedAt, DateTime now) {
  final s = now.difference(startedAt).inMilliseconds / 1000;
  return s < 0 ? 0 : s.floor();
}

KcalResult estimateWorkoutKcal({
  required DateTime startedAt,
  required DateTime endedAt,
  required double? weightKg,
  required List<double> completedSetMets,
}) {
  if (weightKg == null || weightKg <= 0) return const KcalMissingWeight();

  final raw = elapsedSeconds(startedAt, endedAt);
  const maxSeconds = maxSessionHours * 3600;
  final duration = raw < maxSeconds ? raw : maxSeconds;
  final capped = raw > maxSeconds;

  final valid = completedSetMets.where((m) => m.isFinite && m > 0).toList();
  // Hiç set tamamlanmadıysa tahmin 0: oturum açık kalmış olabilir, egzersiz kanıtı yok.
  if (valid.isEmpty) {
    return KcalOk(kcal: 0, averageMet: 0, durationSeconds: duration, durationCapped: capped);
  }
  final avg = valid.reduce((a, b) => a + b) / valid.length;
  return KcalOk(
    kcal: jsRound(avg * weightKg * (duration / 3600)),
    averageMet: jsRound(avg * 10) / 10,
    durationSeconds: duration,
    durationCapped: capped,
  );
}
