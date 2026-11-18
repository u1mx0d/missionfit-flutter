import 'package:flutter_local_notifications/flutter_local_notifications.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart' show Importance;

enum PermissionState { granted, denied, unknown }

abstract interface class NotificationService {
  Future<void> init();
  Future<PermissionState> permission();
  Future<PermissionState> requestPermission();

  /// 5 sn bekleyip deneme bildirimini gösterir; çağıran beklememelidir (`unawaited`).
  Future<void> showTest();
  Future<void> cancelAll();
}

const taskChannelId = 'tasks';
const taskChannelName = 'Görev hatırlatmaları';
const testNotificationBody = 'MissionFit bildirimleri çalışıyor';

/// `android/app/src/main/res/drawable/ic_notification.png` (beyaz, şeffaf).
const notificationSmallIcon = 'ic_notification';

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
}

class PluginNotificationsPlatform implements NotificationsPlatform {
  PluginNotificationsPlatform([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> initialize(String smallIcon) async {
    await _plugin.initialize(
      settings: InitializationSettings(android: AndroidInitializationSettings(smallIcon)),
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
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._platform, {Future<void> Function(Duration)? delay})
    : _delay = delay ?? Future<void>.delayed;

  final NotificationsPlatform _platform;
  final Future<void> Function(Duration) _delay;

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
}
