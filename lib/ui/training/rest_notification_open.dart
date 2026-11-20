import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/active_workout_controller.dart';
import '../../app/profile_controller.dart';
import '../../app/providers.dart' show notificationServiceProvider;
import '../../app/today_provider.dart' show clockProvider;
import '../../data/notifications/rest_actions.dart' show RestPayload;
import '../../domain/active_workout.dart' show isStaleWorkout;
import '../router.dart';

const focusRoute = '/antrenman/odak';

/// Kimlik ve onboarding yönlendirmeleri bitmiş, uygulamanın içinde miyiz?
bool _settled(String location) =>
    location.isNotEmpty &&
    !authRoutes.contains(location) &&
    location != '/yukleniyor' &&
    location != '/onboarding';

/// Dinlenme bildirimine (geri sayım ya da "Dinlenme bitti") dokunulunca odak moduna döner:
/// uygulama bildirimle açıldıysa açılışta, açıksa dokunuş anında. Yönlendiriciyle yarışmaz:
/// istek, kimlik/onboarding yönlendirmeleri bitip uygulama içine gelinene ve süren antrenman
/// yüklenene kadar bekler. Süren antrenman yoksa, başkasınınsa ya da 24 saatten eskiyse
/// (o zaman "Bitir mi, sil mi?" sorulur) gidilmez. Bildirimsiz açılışta hiçbir şey yapmaz.
/// Uygulama kökü bunu izler.
final restNotificationOpenProvider = Provider<void>((ref) {
  final router = ref.watch(routerProvider);
  final notifications = ref.watch(notificationServiceProvider);
  RestPayload? pending;
  var disposed = false;
  var tapped = false;

  void check() {
    final p = pending;
    if (disposed || p == null) return;
    final location = router.routerDelegate.currentConfiguration.uri.path;
    if (!_settled(location)) return;
    final active = ref.read(activeWorkoutControllerProvider);
    if (!active.hasValue || active.isLoading) return;
    pending = null;
    final w = active.value;
    final userId = ref.read(signedInUserIdProvider);
    if (w == null || userId == null) return;
    if (p.sessionId != w.sessionId && p.userId != userId) return;
    if (isStaleWorkout(w.startedAt, ref.read(clockProvider)())) return;
    if (location != focusRoute) router.go(focusRoute);
  }

  // Değişiklik bildirimleri sırasında gezinilmez; bir sonraki mikro görevde bakılır.
  void schedule() => scheduleMicrotask(check);

  void request(String? raw) {
    final p = RestPayload.tryDecode(raw);
    if (p == null) return;
    pending = p;
    schedule();
  }

  router.routerDelegate.addListener(schedule);
  ref.listen(activeWorkoutControllerProvider, (_, _) => schedule());
  final sub = notifications.tappedPayloads.listen((raw) {
    tapped = true;
    request(raw);
  });
  ref.onDispose(() {
    disposed = true;
    router.routerDelegate.removeListener(schedule);
    unawaited(sub.cancel());
  });
  unawaited(
    notifications.launchPayload().then((raw) {
      // Açılış yükü, açılıştan sonraki bir dokunuşu ezmez.
      if (!tapped) request(raw);
    }, onError: (Object e) => debugPrint('Bildirim açılış bilgisi alınamadı: $e')),
  );
});
