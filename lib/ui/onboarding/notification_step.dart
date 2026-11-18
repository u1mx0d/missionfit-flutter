import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../components/mf_card.dart';
import 'onboarding_widgets.dart';

class NotificationStep extends StatelessWidget {
  const NotificationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    Widget bullet(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: t.text)),
          ),
        ],
      ),
    );
    return StepShell(
      title: 'Hatırlatmalar',
      subtitle: 'Görevlerini zamanında hatırlatalım mı?',
      children: [
        MfCard(
          child: Column(
            children: [
              bullet(
                Icons.alarm,
                'Belirlediğin saatte su içme, vitamin gibi görevlerini hatırlatırız.',
              ),
              bullet(
                Icons.cloud_off,
                'Bildirimler telefonunda planlanır, internet olmadan da çalışır.',
              ),
              bullet(Icons.tune, "Profil > Bildirimler'den istediğin zaman kapatabilirsin."),
            ],
          ),
        ),
      ],
    );
  }
}
