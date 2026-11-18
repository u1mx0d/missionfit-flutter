import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme_controller.dart';
import '../components/dot_grid.dart';
import '../theme/accents.dart';
import '../theme/mf_theme.dart';
import 'profile_widgets.dart';

/// Tema galerisi: aile (Profesyonel/Eğlenceli) × açık/koyu önizleme, vurgu ve görünüm modu.
/// Seçim anında uygulanır.
class ThemeGalleryScreen extends ConsumerWidget {
  const ThemeGalleryScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showSnack(context, profileSaveErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final t = mf(context);
    final dark = t.brightness == Brightness.dark;

    Widget family(ThemeFamily f, String title, String name) => _FamilySection(
      family: f,
      title: title,
      name: name,
      accent: sel.accent,
      selected: sel.family == f,
      onSelect: () => _run(context, () => controller.setFamily(f)),
    );

    return SubPage(
      title: 'Tema galerisi',
      children: [
        family(ThemeFamily.mono, 'Profesyonel', 'Mono'),
        const SizedBox(height: 24),
        family(ThemeFamily.canli, 'Eğlenceli', 'Canlı'),
        const SizedBox(height: 28),
        Text(
          'Vurgu rengi',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(sel.accent.label, style: TextStyle(color: t.textMuted)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final a in AccentColor.values)
              _AccentDot(
                accent: a,
                dark: dark,
                selected: sel.accent == a,
                onTap: () => _run(context, () => controller.setAccent(a)),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Görünüm',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeModeChoice>(
          key: const Key('theme-mode'),
          segments: const [
            ButtonSegment(value: ThemeModeChoice.system, label: Text('Sistem')),
            ButtonSegment(value: ThemeModeChoice.light, label: Text('Açık')),
            ButtonSegment(value: ThemeModeChoice.dark, label: Text('Koyu')),
          ],
          selected: {sel.mode},
          onSelectionChanged: (s) => _run(context, () => controller.setMode(s.first)),
        ),
      ],
    );
  }
}

class _FamilySection extends StatelessWidget {
  const _FamilySection({
    required this.family,
    required this.title,
    required this.name,
    required this.accent,
    required this.selected,
    required this.onSelect,
  });
  final ThemeFamily family;
  final String title;
  final String name;
  final AccentColor accent;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(color: t.textMuted)),
              if (selected) ...[
                const Spacer(),
                Icon(Icons.check_circle, color: t.accent, size: 20),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final b in const [Brightness.light, Brightness.dark]) ...[
              Expanded(
                child: ThemePreviewCard(
                  key: Key('theme-${family.name}-${b == Brightness.light ? 'light' : 'dark'}'),
                  preview: MfTheme.build(family, b, accent),
                  label: '$name ${b == Brightness.light ? 'açık' : 'koyu'}',
                  selected: selected,
                  onTap: onSelect,
                ),
              ),
              if (b == Brightness.light) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

/// [preview] temasıyla çizilmiş minik bir ekran: kart + hap çubuğu.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    required this.preview,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final MfTheme preview;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = preview;
    final current = mf(context);
    final flat = p.cardStyle == CardStyle.flat;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? current.accent : current.border, width: 2),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: flat ? p.surface : null,
                    gradient: flat
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [p.surface, p.surfaceMuted],
                          ),
                    border: flat ? Border.all(color: p.border) : null,
                    borderRadius: BorderRadius.circular(p.radius / 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1.850',
                        style: TextStyle(
                          fontFamily: p.numberFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text('kcal', style: TextStyle(fontSize: 11, color: p.textMuted)),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 6,
                          color: p.accent,
                          backgroundColor: p.border,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border.all(color: p.border),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 4; i++)
                      Container(
                        width: i == 0 ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == 0 ? p.accent : p.textMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.dark,
    required this.selected,
    required this.onTap,
  });
  final AccentColor accent;
  final bool dark;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final color = dark ? accent.darkTone : accent.lightTone;
    return Semantics(
      button: true,
      selected: selected,
      label: accent.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        key: Key('accent-${accent.name}'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? t.text : Colors.transparent, width: 3),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: 22,
                  color: dark ? const Color(0xFF0B0B0B) : const Color(0xFFFFFFFF),
                )
              : null,
        ),
      ),
    );
  }
}
