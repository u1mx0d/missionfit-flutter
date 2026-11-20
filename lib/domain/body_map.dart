/// Antrenman maketi kuralları: bölge kimliği, yoğunluk kademesi, dönüş karesi.
/// Saf Dart.
library;

/// 14 bölge (sıra sabit; kimlik = sıra + 1, 0 = cilt, 255 = boş).
const List<String> bodyMapMuscles = [
  'chest',
  'shoulders',
  'biceps',
  'triceps',
  'forearms',
  'abs',
  'obliques',
  'traps',
  'lats',
  'lower_back',
  'glutes',
  'quads',
  'hamstrings',
  'calves',
];

/// Kas slug'ının bölge kimliği; bilinmeyen için 0.
int bodyMapRegionId(String muscleSlug) {
  final i = bodyMapMuscles.indexOf(muscleSlug);
  return i < 0 ? 0 : i + 1;
}

/// Ağırlıklı set sayısından maket kademesi (0–3): 0 / >0 ve <4 / 4–<10 / ≥10.
int bodyMapLevel(double weightedSets) {
  if (weightedSets.isNaN || weightedSets <= 0) return 0;
  if (weightedSets < 4) return 1;
  if (weightedSets < 10) return 2;
  return 3;
}

/// Dönüş açısına (derece) en yakın kare; negatif ve 360 üstü açılar sarar.
int frameForAngle(double degrees, {int frames = 72}) {
  final step = 360 / frames;
  final a = ((degrees % 360) + 360) % 360;
  return (a / step + 0.5).floor() % frames;
}

/// [ids] bölgelerinin toplam piksel sayısının en büyük olduğu kare. [counts]: kare başına
/// bölge kimliği → piksel sayısı (indeks = kimlik). Eşitlikte ilk kare; boş [ids] → 0.
int bestFrameFor(List<List<int>> counts, Iterable<int> ids) {
  var best = 0;
  var bestSum = -1;
  for (var f = 0; f < counts.length; f++) {
    final s = _sumOf(counts[f], ids);
    if (s > bestSum) {
      best = f;
      bestSum = s;
    }
  }
  return best;
}

int _sumOf(List<int> frameCounts, Iterable<int> ids) {
  var s = 0;
  for (final id in ids) {
    if (id >= 0 && id < frameCounts.length) s += frameCounts[id];
  }
  return s;
}

/// Bölgeler karede "görünür" mü: en iyi karedeki piksellerin en az %10'u bu karede
/// (kenardan görünen birkaç piksel ya da kırıntı görünür sayılmaz).
bool regionsVisibleIn(List<List<int>> counts, int frame, Iterable<int> ids) {
  final best = _sumOf(counts[bestFrameFor(counts, ids)], ids);
  if (best == 0) return true; // Hiçbir karede yok: döndürmenin anlamı yok.
  return _sumOf(counts[frame], ids) * 10 >= best;
}

/// [fromDegrees] açısından [frame] karesine en kısa yoldan varılan açı (derece, sarmalanmamış).
double angleTowardFrame(double fromDegrees, int frame, {int frames = 72}) {
  final target = frame * 360 / frames;
  var d = (target - fromDegrees) % 360;
  if (d > 180) d -= 360;
  return fromDegrees + d;
}
