import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Ekranın kendiliğinden kapanmasını engeller (odak ve dinlenme ekranları).
/// Kilit tuşu yine çalışır. Testlerde sahtesiyle değiştirilir.
abstract interface class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();

  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // Eklenti yoksa (ör. desteklenmeyen platform) ekran normal davranır.
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }
}

final screenAwakeProvider = Provider<ScreenAwake>((ref) => const WakelockScreenAwake());
