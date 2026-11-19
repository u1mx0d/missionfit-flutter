/// Antrenman tarzı kuralları: ana/yan tarz seçimi, hedef hareket listeleri, doğrulama.
/// Enum ↔ sunucu dizgisi için `.name` kullanılır.
library;

enum TrainingStyle { calisthenics, bodybuilding, functional, strength, conditioning, general }

enum TrainingLevel { beginner, intermediate, advanced }

enum FocusArea { push, pull, legs, core, mobility, conditioning }

/// Tarza göre hedef hareket anahtarları (sıra ekrandaki sıradır).
/// Sunucu tam olarak bu 24 anahtara izin verir.
const Map<TrainingStyle, List<String>> goalMovesByStyle = {
  TrainingStyle.calisthenics: [
    'first_pullup',
    'muscle_up',
    'handstand',
    'front_lever',
    'pistol_squat',
    'l_sit',
    'planche',
  ],
  TrainingStyle.bodybuilding: [
    'bench_up',
    'squat_up',
    'deadlift_up',
    'bigger_arms',
    'wider_back',
    'shoulders',
  ],
  TrainingStyle.functional: ['first_pullup', 'rope_climb', 'box_jump', 'kb_swing', 'get_up'],
  TrainingStyle.strength: ['squat_up', 'bench_up', 'deadlift_up', 'ohp_up'],
  TrainingStyle.conditioning: ['run_5k', 'run_10k', 'hiit_endurance'],
  TrainingStyle.general: ['consistency', 'flexibility', 'posture'],
};

/// Hedef hareket anahtarı → Türkçe etiket.
const Map<String, String> goalMoveLabels = {
  'first_pullup': 'İlk barfiks',
  'muscle_up': 'Muscle-up',
  'handstand': 'Handstand',
  'front_lever': 'Front lever',
  'pistol_squat': 'Pistol squat',
  'l_sit': 'L-sit',
  'planche': 'Planche',
  'bench_up': "Bench press'i artırmak",
  'squat_up': "Squat'ı artırmak",
  'deadlift_up': "Deadlift'i artırmak",
  'bigger_arms': 'Daha güçlü kollar',
  'wider_back': 'Daha geniş sırt',
  'shoulders': 'Omuz gelişimi',
  'rope_climb': 'Halat tırmanışı',
  'box_jump': 'Box jump',
  'kb_swing': 'Kettlebell swing',
  'get_up': 'Turkish get-up',
  'ohp_up': "Overhead press'i artırmak",
  'run_5k': '5 km koşu',
  'run_10k': '10 km koşu',
  'hiit_endurance': 'HIIT dayanıklılığı',
  'consistency': 'Düzenli antrenman',
  'flexibility': 'Esneklik',
  'posture': 'Duruş',
};

/// Ana tarz + yan tarzlar. Değişmez; her işlem yeni nesne döner.
class StyleSelection {
  const StyleSelection({this.main, this.sides = const []});

  final TrainingStyle? main;
  final List<TrainingStyle> sides;

  /// Dokunuş: boşsa ana olur; seçiliyse kaldırır (ana kalkarsa ilk yan tarz ana olur);
  /// değilse yan tarz olarak eklenir.
  StyleSelection tap(TrainingStyle s) {
    if (s == main) {
      if (sides.isEmpty) return const StyleSelection();
      return StyleSelection(main: sides.first, sides: sides.sublist(1));
    }
    if (sides.contains(s)) {
      return StyleSelection(main: main, sides: [...sides]..remove(s));
    }
    if (main == null) return StyleSelection(main: s, sides: sides);
    return StyleSelection(main: main, sides: [...sides, s]);
  }

  /// Seçili yan tarzı ana yapar; eski ana yan listenin başına geçer.
  /// Yan tarz değilse (ana ya da seçili değil) hiçbir şey değişmez.
  StyleSelection makeMain(TrainingStyle s) {
    if (!sides.contains(s)) return this;
    return StyleSelection(main: s, sides: [?main, ...sides.where((x) => x != s)]);
  }
}

/// Hedef hareket seçenekleri: önce ana tarzın listesi, sonra yan tarzların yeni olanları
/// (tekrarlar bir kez). `keep`: önceden kaydedilmiş olup listede olmayanlar sona eklenir.
List<String> goalOptionsFor(StyleSelection s, {Iterable<String> keep = const []}) {
  final out = <String>[];
  for (final style in [?s.main, ...s.sides]) {
    for (final key in goalMovesByStyle[style]!) {
      if (!out.contains(key)) out.add(key);
    }
  }
  for (final key in keep) {
    if (!out.contains(key)) out.add(key);
  }
  return out;
}

String? validateStyle(StyleSelection s, TrainingLevel? level) {
  if (s.main == null) return 'Ana tarzını seç.';
  if (level == null) return 'Seviyeni seç.';
  return null;
}
