import 'package:material_ui/material_ui.dart';

import '../theme/mf_theme.dart';
import 'onboarding_widgets.dart';

class ThemeStep extends StatelessWidget {
  const ThemeStep({
    required this.family,
    required this.mode,
    required this.onFamily,
    required this.onMode,
    super.key,
  });
  final ThemeFamily family;
  final ThemeModeChoice mode;
  final ValueChanged<ThemeFamily> onFamily;
  final ValueChanged<ThemeModeChoice> onMode;

  @override
  Widget build(BuildContext context) {
    // Önizleme, o anda geçerli açık/koyu görünümle çizilir.
    final brightness = switch (mode) {
      ThemeModeChoice.light => Brightness.light,
      ThemeModeChoice.dark => Brightness.dark,
      ThemeModeChoice.system => MediaQuery.platformBrightnessOf(context),
    };
    return StepShell(
      title: 'Görünüm',
      subtitle: 'Dilediğin zaman Profil > Ayarlar bölümünden değiştirebilirsin.',
      children: [
        _FamilyCard(
          key: const Key('theme-canli'),
          title: 'Canlı',
          description: 'Renkli, yumuşak köşeli ve gradyanlı kartlar.',
          family: ThemeFamily.canli,
          brightness: brightness,
          selected: family == ThemeFamily.canli,
          onTap: () => onFamily(ThemeFamily.canli),
        ),
        const SizedBox(height: 12),
        _FamilyCard(
          key: const Key('theme-mono'),
          title: 'Mono',
          description: 'Sade, noktalı ızgara ve düz kartlar.',
          family: ThemeFamily.mono,
          brightness: brightness,
          selected: family == ThemeFamily.mono,
          onTap: () => onFamily(ThemeFamily.mono),
        ),
        const SizedBox(height: 20),
        SegmentedButton<ThemeModeChoice>(
          segments: const [
            ButtonSegment(value: ThemeModeChoice.light, label: Text('Açık')),
            ButtonSegment(value: ThemeModeChoice.dark, label: Text('Koyu')),
            ButtonSegment(value: ThemeModeChoice.system, label: Text('Sistem')),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onMode(s.first),
        ),
      ],
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.title,
    required this.description,
    required this.family,
    required this.brightness,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String title;
  final String description;
  final ThemeFamily family;
  final Brightness brightness;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Her kart kendi ailesinin renkleriyle çizilir; seçili olan canlı olarak tüm uygulamaya yansır.
    final p = MfTheme.build(family, brightness, defaultAccentFor(family));
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(p.radius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: BorderRadius.circular(p.radius),
            border: Border.all(color: selected ? p.accent : p.border, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: p.surface,
                  gradient: p.cardStyle == CardStyle.gradient
                      ? LinearGradient(colors: [p.surface, p.surfaceMuted])
                      : null,
                  borderRadius: BorderRadius.circular(p.radius / 2),
                  border: p.cardStyle == CardStyle.flat ? Border.all(color: p.border) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      width: 40,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      width: 28,
                      decoration: BoxDecoration(
                        color: p.textMuted,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: p.displayFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    Text(description, style: TextStyle(color: p.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? p.accent : p.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
