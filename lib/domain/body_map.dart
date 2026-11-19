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
