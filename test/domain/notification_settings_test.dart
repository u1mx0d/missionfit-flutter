import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/notification_settings.dart';

void main() {
  group('parseNotificationSettings', () {
    test('geçerli değer', () {
      expect(
        parseNotificationSettings({'enabled': false, 'task_lead_minutes': 30}),
        const NotificationSettings(enabled: false, taskLeadMinutes: 30),
      );
    });

    test('eksik/bozuk alanlar varsayılana düşer', () {
      expect(parseNotificationSettings(null), defaultNotificationSettings);
      expect(
        parseNotificationSettings({'enabled': 'evet', 'task_lead_minutes': -5}),
        defaultNotificationSettings,
      );
      expect(parseNotificationSettings({'task_lead_minutes': 2.5}), defaultNotificationSettings);
    });

    test('gidiş-dönüş', () {
      const s = NotificationSettings(enabled: true, taskLeadMinutes: 15);
      expect(parseNotificationSettings(s.toJson()), s);
    });
  });
}
