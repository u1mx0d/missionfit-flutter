import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/notifications/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlatform extends Mock implements NotificationsPlatform {}

void main() {
  setUpAll(() {
    registerFallbackValue(Importance.min);
    registerFallbackValue(Int64List(0));
  });
  late _MockPlatform platform;
  late List<Duration> delays;
  late LocalNotificationService service;

  setUp(() {
    platform = _MockPlatform();
    delays = [];
    when(() => platform.initialize(any())).thenAnswer((_) async {});
    when(
      () => platform.createChannel(
        id: any(named: 'id'),
        name: any(named: 'name'),
        importance: any(named: 'importance'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => platform.createAlertChannel(
        id: any(named: 'id'),
        name: any(named: 'name'),
        vibrationPattern: any(named: 'vibrationPattern'),
      ),
    ).thenAnswer((_) async {});
    when(() => platform.cancelAll()).thenAnswer((_) async {});
    when(
      () => platform.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        channelId: any(named: 'channelId'),
        channelName: any(named: 'channelName'),
      ),
    ).thenAnswer((_) async {});
    service = LocalNotificationService(platform, delay: (d) async => delays.add(d));
  });

  test('init tasks kanalını high önemle oluşturur', () async {
    await service.init();

    verify(() => platform.initialize(notificationSmallIcon)).called(1);
    verify(
      () => platform.createChannel(
        id: 'tasks',
        name: 'Görev hatırlatmaları',
        importance: Importance.high,
      ),
    ).called(1);
  });

  test('izin reddedilince PermissionState.denied', () async {
    when(() => platform.requestPermission()).thenAnswer((_) async => false);
    when(() => platform.areEnabled()).thenAnswer((_) async => false);

    expect(await service.requestPermission(), PermissionState.denied);
    expect(await service.permission(), PermissionState.denied);
  });

  test('izin verilince granted, bilinmiyorsa unknown', () async {
    when(() => platform.requestPermission()).thenAnswer((_) async => true);
    when(() => platform.areEnabled()).thenAnswer((_) async => null);

    expect(await service.requestPermission(), PermissionState.granted);
    expect(await service.permission(), PermissionState.unknown);
  });

  test('cancelAll eklentide cancelAll çağırır', () async {
    await service.cancelAll();

    verify(() => platform.cancelAll()).called(1);
  });

  test('showTest 5 sn sonra tasks kanalında bildirimi gösterir', () async {
    await service.showTest();

    expect(delays, [const Duration(seconds: 5)]);
    verify(
      () => platform.show(
        id: any(named: 'id'),
        title: 'MissionFit',
        body: 'MissionFit bildirimleri çalışıyor',
        channelId: 'tasks',
        channelName: 'Görev hatırlatmaları',
      ),
    ).called(1);
  });
}
