import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';

/// Adım başlığı + alt başlık + içerik.
class StepShell extends StatelessWidget {
  const StepShell({required this.title, required this.subtitle, required this.children, super.key});
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: t.displayFont,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: t.textMuted)),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

class StepError extends StatelessWidget {
  const StepError(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        liveRegion: true,
        child: Text(message!, style: TextStyle(color: mf(context).danger)),
      ),
    );
  }
}

/// Tek seçimli seçenek kartı. Seçim kenarlık + işaret ikonuyla gösterilir (yalnızca renk değil).
class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    this.icon,
    super.key,
  });
  final String title;
  final String? description;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: description == null ? title : '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radius),
            border: Border.all(color: selected ? t.accent : t.border, width: 2),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: selected ? t.accent : t.textMuted),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                    ),
                    if (description != null)
                      Text(description!, style: TextStyle(color: t.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? t.accent : t.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
