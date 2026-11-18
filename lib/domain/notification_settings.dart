/// Bildirim ayarları (profiles.notification_settings JSON'u).
/// RN `features/profile/notificationSettings.ts` karşılığı. Bozuk alanlar varsayılana düşer.
library;

const leadMinuteOptions = [0, 5, 10, 15, 30, 60];

class NotificationSettings {
  const NotificationSettings({required this.enabled, required this.taskLeadMinutes});
  final bool enabled;
  final int taskLeadMinutes;

  Map<String, Object> toJson() => {'enabled': enabled, 'task_lead_minutes': taskLeadMinutes};

  @override
  bool operator ==(Object other) =>
      other is NotificationSettings &&
      other.enabled == enabled &&
      other.taskLeadMinutes == taskLeadMinutes;
  @override
  int get hashCode => Object.hash(enabled, taskLeadMinutes);
}

const defaultNotificationSettings = NotificationSettings(enabled: true, taskLeadMinutes: 10);

NotificationSettings parseNotificationSettings(Object? value) {
  if (value is! Map) return defaultNotificationSettings;
  final e = value['enabled'];
  final l = value['task_lead_minutes'];
  return NotificationSettings(
    enabled: e is bool ? e : defaultNotificationSettings.enabled,
    taskLeadMinutes: l is int && l >= 0 && l <= 1440
        ? l
        : defaultNotificationSettings.taskLeadMinutes,
  );
}
