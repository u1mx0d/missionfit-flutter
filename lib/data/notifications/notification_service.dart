import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

export 'package:flutter_local_notifications/flutter_local_notifications.dart' show Importance;

enum PermissionState { granted, denied, unknown }

abstract interface class NotificationService {
  Future<void> init();
  Future<PermissionState> permission();
  Future<PermissionState> requestPermission();

  /// 5 sn bekleyip deneme bildirimini gösterir; çağıran beklememelidir (`unawaited`).
  Future<void> showTest();
  Future<void> cancelAll();

  /// Dinlenme: kilit ekranında geri sayan, sessiz, sürekli bildirim ("+15 sn", "Atla").
  /// [payload] bildirim eylemine geri döner (arka plan işleyicisi bununla çalışır).
  Future<void> showRest({required DateTime endsAt, required String nextLabel, String? payload});

  /// Dinlenme bitişinde tam zamanlı, titreşimli bildirim. Aynı kimliği kullanır; geri sayımın
  /// yerine geçer.
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel});

  /// Geri sayımı ve bekleyen bitiş alarmını kaldırır.
  Future<void> cancelRest();
}

const taskChannelId = 'tasks';
const taskChannelName = 'Görev hatırlatmaları';
const testNotificationBody = 'MissionFit bildirimleri çalışıyor';

/// `android/app/src/main/res/drawable/ic_notification.png` (beyaz, şeffaf).
const notificationSmallIcon = 'ic_notification';

const restChannelId = 'rest';
const restChannelName = 'Dinlenme';

/// Geri sayım ve bitiş bildirimi aynı kimliği paylaşır: bitiş, geri sayımın yerine geçer;
/// tek `cancel` ikisini (ve bekleyen alarmı) birden kaldırır.
const restNotificationId = 9100;
const restActionPlus15 = 'rest_plus15';
const restActionSkip = 'rest_skip';

/// Dinlenme bitince güçlü titreşim (bekle, titre, ...; ms).
final restVibrationPattern = Int64List.fromList([0, 700, 250, 700, 250, 1000]);

/// Bildirimdeki bir eylem düğmesi.
class NotificationActionSpec {
  const NotificationActionSpec(this.id, this.label, {required this.cancelsNotification});
  final String id;
  final String label;
  final bool cancelsNotification;
}

/// Geri sayan kronometreli, sürekli ve sessiz bildirim.
class CountdownNotification {
  const CountdownNotification({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.title,
    required this.body,
    required this.endsAt,
    required this.timeoutAfter,
    required this.actions,
    this.payload,
  });
  final int id;
  final String channelId;
  final String channelName;
  final String title;
  final String body;
  final DateTime endsAt;

  /// Alarm gelmezse (ör. izin yok) sayaç eksiye akmasın diye bildirim bu süre sonunda kalkar.
  final Duration timeoutAfter;
  final List<NotificationActionSpec> actions;
  final String? payload;
}

/// Tam zamanlı (Doze'da da) gösterilecek titreşimli bildirim.
class ScheduledAlert {
  const ScheduledAlert({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.title,
    required this.body,
    required this.at,
    required this.vibrationPattern,
  });
  final int id;
  final String channelId;
  final String channelName;
  final String title;
  final String body;
  final DateTime at;
  final Int64List vibrationPattern;
}

/// flutter_local_notifications eklentisinin ince sarmalayıcısı; testler bunu taklit eder.
abstract interface class NotificationsPlatform {
  Future<void> initialize(String smallIcon);
  Future<void> createChannel({
    required String id,
    required String name,
    required Importance importance,
  });
  Future<bool?> areEnabled();
  Future<bool?> requestPermission();
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  });
  Future<void> cancelAll();

  /// Yüksek önemli, sessiz (ses yok), titreşim desenli kanal.
  Future<void> createAlertChannel({
    required String id,
    required String name,
    required Int64List vibrationPattern,
  });
  Future<void> showCountdown(CountdownNotification n);
  Future<void> scheduleExact(ScheduledAlert n);

  /// Gösterilen bildirimi ve aynı kimlikle bekleyen alarmı iptal eder.
  Future<void> cancel(int id);
}

class PluginNotificationsPlatform implements NotificationsPlatform {
  /// [onBackgroundResponse] üst düzey (`@pragma('vm:entry-point')`) bir fonksiyon olmalı:
  /// "+15 sn"/"Atla" uygulama kapalıyken ayrı bir isolate'ta onu çağırır.
  PluginNotificationsPlatform({FlutterLocalNotificationsPlugin? plugin, this.onBackgroundResponse})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> initialize(String smallIcon) async {
    await _plugin.initialize(
      settings: InitializationSettings(android: AndroidInitializationSettings(smallIcon)),
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
  }

  @override
  Future<void> createChannel({
    required String id,
    required String name,
    required Importance importance,
  }) async {
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(id, name, importance: importance),
    );
  }

  @override
  Future<bool?> areEnabled() async => _android?.areNotificationsEnabled();

  @override
  Future<bool?> requestPermission() async => _android?.requestNotificationsPermission();

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> createAlertChannel({
    required String id,
    required String name,
    required Int64List vibrationPattern,
  }) async {
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        id,
        name,
        importance: Importance.high,
        playSound: false,
        vibrationPattern: vibrationPattern,
      ),
    );
  }

  // Kanal ayarları (önem, ses, desen) yalnızca kanal yoksa kullanılır; `createAlertChannel`
  // ile aynı tutulur. Simge açıkça verilir: arka plan isolate'ında `initialize` çağrılmaz.
  AndroidNotificationDetails _alertDetails({
    required String channelId,
    required String channelName,
    required Int64List vibrationPattern,
    bool silent = false,
    bool ongoing = false,
    int? when,
    Duration? timeoutAfter,
    List<AndroidNotificationAction>? actions,
  }) => AndroidNotificationDetails(
    channelId,
    channelName,
    icon: notificationSmallIcon,
    importance: Importance.high,
    priority: Priority.high,
    playSound: false,
    vibrationPattern: vibrationPattern,
    silent: silent,
    onlyAlertOnce: silent,
    ongoing: ongoing,
    autoCancel: !ongoing,
    showWhen: true,
    when: when,
    usesChronometer: when != null,
    chronometerCountDown: when != null,
    timeoutAfter: timeoutAfter?.inMilliseconds,
    visibility: NotificationVisibility.public,
    actions: actions,
  );

  @override
  Future<void> showCountdown(CountdownNotification n) async {
    await _plugin.show(
      id: n.id,
      title: n.title,
      body: n.body,
      payload: n.payload,
      notificationDetails: NotificationDetails(
        android: _alertDetails(
          channelId: n.channelId,
          channelName: n.channelName,
          vibrationPattern: restVibrationPattern,
          silent: true,
          ongoing: true,
          when: n.endsAt.millisecondsSinceEpoch,
          timeoutAfter: n.timeoutAfter,
          actions: [
            for (final a in n.actions)
              AndroidNotificationAction(
                a.id,
                a.label,
                cancelNotification: a.cancelsNotification,
                showsUserInterface: false,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> scheduleExact(ScheduledAlert n) async {
    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
      androidScheduleMode: mode,
      notificationDetails: NotificationDetails(
        android: _alertDetails(
          channelId: n.channelId,
          channelName: n.channelName,
          vibrationPattern: n.vibrationPattern,
          // Bitiş bildirimi bir dakika sonra kendiliğinden kalkar.
          timeoutAfter: const Duration(minutes: 1),
        ),
      ),
    );
    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      // Tam alarm izni geri alınmışsa birkaç dakika gecikebilen alarmla yine haber verilir.
      if (e.code != 'exact_alarms_not_permitted') rethrow;
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService(
    this._platform, {
    Future<void> Function(Duration)? delay,
    DateTime Function()? clock,
  }) : _delay = delay ?? Future<void>.delayed,
       _clock = clock ?? DateTime.now;

  final NotificationsPlatform _platform;
  final Future<void> Function(Duration) _delay;
  final DateTime Function() _clock;

  static const _testId = 9001;
  static const testDelay = Duration(seconds: 5);

  @override
  Future<void> init() async {
    await _platform.initialize(notificationSmallIcon);
    await _platform.createChannel(
      id: taskChannelId,
      name: taskChannelName,
      importance: Importance.high,
    );
    await _platform.createAlertChannel(
      id: restChannelId,
      name: restChannelName,
      vibrationPattern: restVibrationPattern,
    );
  }

  @override
  Future<PermissionState> permission() async => _state(await _platform.areEnabled());

  @override
  Future<PermissionState> requestPermission() async => _state(await _platform.requestPermission());

  PermissionState _state(bool? granted) => switch (granted) {
    true => PermissionState.granted,
    false => PermissionState.denied,
    null => PermissionState.unknown,
  };

  // Eklentinin zonedSchedule'ı Android 12+ ta tam alarm izni ister; inexact ise gecikebilir.
  // Uygulama açıkken 5 sn bekleyip `show` kullanmak izinsiz ve zamanında çalışır.
  @override
  Future<void> showTest() async {
    await _delay(testDelay);
    await _platform.show(
      id: _testId,
      title: 'MissionFit',
      body: testNotificationBody,
      channelId: taskChannelId,
      channelName: taskChannelName,
    );
  }

  @override
  Future<void> cancelAll() => _platform.cancelAll();

  @override
  Future<void> showRest({required DateTime endsAt, required String nextLabel, String? payload}) {
    final left = endsAt.difference(_clock());
    return _platform.showCountdown(
      CountdownNotification(
        id: restNotificationId,
        channelId: restChannelId,
        channelName: restChannelName,
        title: 'Dinlenme',
        body: nextLabel,
        endsAt: endsAt,
        timeoutAfter: (left.isNegative ? Duration.zero : left) + const Duration(seconds: 2),
        payload: payload,
        actions: const [
          NotificationActionSpec(restActionPlus15, '+15 sn', cancelsNotification: false),
          NotificationActionSpec(restActionSkip, 'Atla', cancelsNotification: true),
        ],
      ),
    );
  }

  @override
  Future<void> scheduleRestEnd(DateTime endsAt, {String? nextLabel}) => _platform.scheduleExact(
    ScheduledAlert(
      id: restNotificationId,
      channelId: restChannelId,
      channelName: restChannelName,
      title: 'Dinlenme bitti',
      body: nextLabel ?? 'Sıradaki sete geç.',
      at: endsAt,
      vibrationPattern: restVibrationPattern,
    ),
  );

  @override
  Future<void> cancelRest() => _platform.cancel(restNotificationId);
}
