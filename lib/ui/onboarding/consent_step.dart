import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../components/mf_card.dart';
import 'kvkk_text.dart';
import 'onboarding_widgets.dart';

class ConsentStep extends StatelessWidget {
  const ConsentStep({
    required this.kvkk,
    required this.health,
    required this.onKvkk,
    required this.onHealth,
    required this.error,
    super.key,
  });
  final bool kvkk;
  final bool health;
  final ValueChanged<bool> onKvkk;
  final ValueChanged<bool> onHealth;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return StepShell(
      title: 'Hoş geldin!',
      subtitle: 'Başlamadan önce birkaç önemli bilgi.',
      children: [
        MfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services_outlined, color: t.warning, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sağlık ibaresi',
                    style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(healthDisclaimer, style: TextStyle(color: t.textMuted, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ConsentRow(
          checkKey: const Key('consent-kvkk'),
          value: kvkk,
          onChanged: onKvkk,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                key: const Key('kvkk-open'),
                onTap: () => showKvkkDialog(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    kvkkTitle,
                    style: TextStyle(
                      color: t.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Text("'ni okudum.", style: TextStyle(color: t.text)),
            ],
          ),
        ),
        _ConsentRow(
          checkKey: const Key('consent-health'),
          value: health,
          onChanged: onHealth,
          child: Text(explicitConsentText, style: TextStyle(color: t.text)),
        ),
        StepError(error),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.checkKey,
    required this.value,
    required this.onChanged,
    required this.child,
  });
  final Key checkKey;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox(key: checkKey, value: value, onChanged: (v) => onChanged(v ?? false)),
      Expanded(
        child: Padding(padding: const EdgeInsets.only(top: 4), child: child),
      ),
    ],
  );
}

Future<void> showKvkkDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text(kvkkTitle),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in kvkkSections) ...[
            Text(s.heading, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(s.body),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat'))],
  ),
);
