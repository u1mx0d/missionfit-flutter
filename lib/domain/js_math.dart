/// JavaScript `Math.round` karşılığı: .5 her zaman +∞ yönüne yuvarlanır (Dart `round()` sıfırdan
/// uzaklaşır; negatif .5 değerlerde fark eder). RN'den taşınan hesaplar aynı sonucu versin diye.
int jsRound(num v) => (v + 0.5).floor();
