import 'package:material_ui/material_ui.dart';

import '../../domain/training_style.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';

/// Tarz kartı içeriği: ad, kısa açıklama, ikon (sıra ekrandaki sıradır).
const styleOptions = <(TrainingStyle, String, String, IconData)>[
  (TrainingStyle.calisthenics, 'Calisthenics', 'Vücut ağırlığı', Icons.sports_gymnastics),
  (TrainingStyle.bodybuilding, 'Vücut geliştirme', 'Kas kütlesi', Icons.fitness_center),
  (TrainingStyle.functional, 'Fonksiyonel', 'Çok yönlü güç', Icons.all_inclusive),
  (TrainingStyle.strength, 'Güç', 'Squat, bench, deadlift', Icons.bolt),
  (TrainingStyle.conditioning, 'Kondisyon', 'Koşu, HIIT', Icons.monitor_heart_outlined),
  (TrainingStyle.general, 'Genel form', 'Sağlıklı kalmak', Icons.favorite_border),
];

const levelLabels = <TrainingLevel, String>{
  TrainingLevel.beginner: 'Yeni',
  TrainingLevel.intermediate: 'Orta',
  TrainingLevel.advanced: 'İleri',
};

const focusAreaLabels = <FocusArea, String>{
  FocusArea.push: 'İtiş',
  FocusArea.pull: 'Çekiş',
  FocusArea.legs: 'Bacak',
  FocusArea.core: 'Core',
  FocusArea.mobility: 'Mobilite',
  FocusArea.conditioning: 'Kondisyon',
};

/// Küçük, büyük harfli bölüm etiketi ("Seviyen", "Hedef hareketler"...).
class PickerLabel extends StatelessWidget {
  const PickerLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: mf(context).textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}

/// 2 sütunlu tarz kartları. Dokunuş: boşsa ana, değilse yan tarz; seçiliyse kaldırır.
/// Ana olmayan seçili karta uzun basmak onu ana yapar. Ana kart "ANA" rozeti, yan tarzlar
/// onay işareti taşır (seçim yalnızca renkle gösterilmez).
class StyleGrid extends StatelessWidget {
  const StyleGrid({required this.value, required this.onChanged, super.key});
  final StyleSelection value;
  final ValueChanged<StyleSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < styleOptions.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _card(styleOptions[i])),
              const SizedBox(width: 8),
              Expanded(
                child: i + 1 < styleOptions.length
                    ? _card(styleOptions[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _card((TrainingStyle, String, String, IconData) o) {
    final (style, title, description, icon) = o;
    final isMain = value.main == style;
    final isSide = value.sides.contains(style);
    return _StyleCard(
      key: Key('style-${style.name}'),
      title: title,
      description: description,
      icon: icon,
      isMain: isMain,
      isSide: isSide,
      onTap: () => onChanged(value.tap(style)),
      onLongPress: isSide ? () => onChanged(value.makeMain(style)) : null,
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isMain,
    required this.isSide,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });
  final String title;
  final String description;
  final IconData icon;
  final bool isMain;
  final bool isSide;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final selected = isMain || isSide;
    final state = isMain
        ? 'Ana tarz'
        : isSide
        ? 'Yan tarz'
        : null;
    return Semantics(
      button: true,
      selected: selected,
      label: [title, description, ?state].join('. '),
      hint: isSide ? 'Ana tarz yapmak için uzun bas' : null,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius),
          onTap: onTap,
          // Ana/seçili olmayan kartta uzun basma yok sayılır (dokunuş gibi davranmaz).
          onLongPress: onLongPress ?? () {},
          child: Container(
            constraints: const BoxConstraints(minHeight: 88),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.radius),
              border: Border.all(color: selected ? t.accent : t.border, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: selected ? t.accent : t.text, size: 24),
                    const Spacer(),
                    if (isMain)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ANA',
                          style: TextStyle(
                            color: t.onAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else if (isSide)
                      Icon(Icons.check_circle, color: t.accent, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                ),
                Text(description, style: TextStyle(color: t.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Yeni / Orta / İleri seviye seçici (tek seçim). Seçili bölüm dolgu + onay işareti taşır.
class LevelSelector extends StatelessWidget {
  const LevelSelector({required this.value, required this.onChanged, super.key});
  final TrainingLevel? value;
  final ValueChanged<TrainingLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          for (final level in TrainingLevel.values) ...[
            if (level != TrainingLevel.values.first) const SizedBox(width: 4),
            Expanded(child: _segment(t, level)),
          ],
        ],
      ),
    );
  }

  Widget _segment(MfTheme t, TrainingLevel level) {
    final selected = value == level;
    final label = levelLabels[level]!;
    final fg = selected ? t.onAccent : t.text;
    final radius = BorderRadius.circular(t.radius > 4 ? t.radius - 4 : 0);
    return Semantics(
      key: Key('level-${level.name}'),
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(level),
      child: Material(
        color: selected ? t.accent : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onChanged(level),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[Icon(Icons.check, size: 18, color: fg), const SizedBox(width: 4)],
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Hedef hareketler" ve "Geliştirmek istediğin alanlar" çoklu seçim çipleri.
/// [options] sırası korunur (bkz. `goalOptionsFor`).
class GoalChips extends StatelessWidget {
  const GoalChips({
    required this.options,
    required this.goals,
    required this.areas,
    required this.onGoals,
    required this.onAreas,
    super.key,
  });
  final List<String> options;
  final Set<String> goals;
  final Set<FocusArea> areas;
  final ValueChanged<Set<String>> onGoals;
  final ValueChanged<Set<FocusArea>> onAreas;

  static Set<T> _toggle<T>(Set<T> s, T v) => s.contains(v) ? ({...s}..remove(v)) : {...s, v};

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PickerLabel('Hedef hareketler'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final key in options)
            _Chip(
              key: Key('goal-$key'),
              label: goalMoveLabels[key] ?? key,
              selected: goals.contains(key),
              onTap: () => onGoals(_toggle(goals, key)),
            ),
        ],
      ),
      const PickerLabel('Geliştirmek istediğin alanlar'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final area in FocusArea.values)
            _Chip(
              key: Key('area-${area.name}'),
              label: focusAreaLabels[area]!,
              selected: areas.contains(area),
              onTap: () => onAreas(_toggle(areas, area)),
            ),
        ],
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, super.key});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final shape = StadiumBorder(
      side: BorderSide(color: selected ? t.accent : t.border, width: selected ? 2 : 1.5),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: t.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.only(left: selected ? 12 : 16, right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, size: 18, color: t.accent),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: t.text,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
