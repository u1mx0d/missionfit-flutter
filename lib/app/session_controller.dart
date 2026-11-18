import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth/secure_local_storage.dart';
import 'providers.dart';

class SessionState {
  const SessionState({
    this.userId,
    this.syncing = false,
    this.lastError,
    this.initialPullDone = false,
    this.initialPullFailed = false,
    this.userCheckFailed = false,
  });
  final String? userId;
  final bool syncing;

  /// Son eşitleme hatası; uygulama çevrimdışı çalışmaya devam eder.
  final Object? lastError;

  /// Bu kullanıcı için sunucudan ilk çekme başarıyla bitti mi (oturum başına).
  final bool initialPullDone;

  /// İlk çekme denendi ve başarısız oldu (henüz hiç başarılı olmadı).
  final bool initialPullFailed;

  /// Kullanıcı değişimi kontrolü başarısız oldu; `userId` null kalır, `retry` ile denenir.
  final bool userCheckFailed;

  SessionState copyWith({
    Object? userId = _keep,
    bool? syncing,
    Object? lastError = _keep,
    bool? initialPullDone,
    bool? initialPullFailed,
    bool? userCheckFailed,
  }) => SessionState(
    userId: identical(userId, _keep) ? this.userId : userId as String?,
    syncing: syncing ?? this.syncing,
    lastError: identical(lastError, _keep) ? this.lastError : lastError,
    initialPullDone: initialPullDone ?? this.initialPullDone,
    initialPullFailed: initialPullFailed ?? this.initialPullFailed,
    userCheckFailed: userCheckFailed ?? this.userCheckFailed,
  );
}

const Object _keep = Object();

/// Çıkışta çalışan kancalar (örn. bildirimleri iptal etme; sonraki görevlerde eklenir).
///
/// Kancalar denetleyicinin sırası içinde çalışır; `handleSession`/`onResumed` veya sıraya
/// girip bekleyen başka bir şey çağırmamalıdır (kilitlenme).
final signedOutHooksProvider = Provider<List<Future<void> Function()>>(
  (ref) => [
    // Önceki kullanıcının zamanlanmış bildirimleri çıkışta temizlenir.
    () => ref.read(notificationServiceProvider).cancelAll(),
  ],
);

/// Periyodik eşitleme zamanlayıcısı üreticisi; testlerde değiştirilir.
typedef PeriodicTimerFactory = Timer Function(Duration period, void Function() tick);

final periodicTimerFactoryProvider = Provider<PeriodicTimerFactory>(
  (ref) =>
      (period, tick) => Timer.periodic(period, (_) => tick()),
);

const syncInterval = Duration(seconds: 60);

class SessionController extends Notifier<SessionState> {
  Timer? _timer;
  String? _knownUserId;

  /// Oturumdaki ama kontrolü henüz başarılamamış kullanıcı (`retry` için).
  String? _pendingUserId;
  Future<void> _queue = Future.value();

  @override
  SessionState build() {
    ref.listen<AsyncValue<Session?>>(authStateProvider, (_, next) {
      if (next.hasValue) unawaited(handleSession(next.requireValue));
    }, fireImmediately: true);
    _timer = ref.read(periodicTimerFactoryProvider)(syncInterval, () => unawaited(periodicTick()));
    ref.onDispose(() => _timer?.cancel());
    return const SessionState();
  }

  /// Tüm oturum ve eşitleme işleri tek sırada çalışır; böylece çıkış/kullanıcı değişimi
  /// süren bir eşitlemeyi bekler ve eşitleme, temizlik bitmeden başlamaz.
  Future<void> _enqueue(Future<void> Function() job) {
    final next = _queue.then((_) => job());
    _queue = next.catchError((_) {});
    return next;
  }

  /// Oturum değişimini sıraya koyar.
  Future<void> handleSession(Session? session) => _enqueue(() => _handle(session?.user.id));

  /// Çıkıştan sonra yazılan değer; sonraki her girişte son kullanıcıdan farklı sayılır.
  static const signedOutMarker = 'signed-out';

  Future<void> _handle(String? userId) async {
    if (userId == null) {
      _pendingUserId = null;
      // Açılışta oturum yoksa silinecek bir şey yok; yalnızca açık oturumdan çıkışta temizle.
      if (_knownUserId == null) {
        if (state.userCheckFailed) state = const SessionState();
        return;
      }
      _knownUserId = null;
      await _signedOut();
      return;
    }
    if (userId == _knownUserId) return;
    _pendingUserId = userId;
    if (state.userCheckFailed) state = state.copyWith(userCheckFailed: false, lastError: null);
    try {
      final store = ref.read(keyValueStoreProvider);
      final db = ref.read(databaseProvider);
      final last = await store.read(SecureLocalStorage.lastUserIdKey);
      // last == null da temizler: keystore sıfırlanırsa (resetOnError) önceki kullanıcının
      // kaydı silinmiş olabilir. Taze kurulumda veritabanı zaten boştur, ek maliyet yoktur.
      if (last != userId) await db.clearAllUserData();
      await store.write(SecureLocalStorage.lastUserIdKey, userId);
    } catch (e, st) {
      // Güvenli kapanış: kullanıcı doğrulanamadı, eşitleme yok; eldeki yerel veri silinir.
      debugPrint('Kullanıcı değişimi kontrolü başarısız: $e\n$st');
      _knownUserId = null;
      state = SessionState(lastError: e, userCheckFailed: true);
      try {
        await ref.read(databaseProvider).clearAllUserData();
      } catch (e2, st2) {
        debugPrint('Güvenli kapanışta temizlik başarısız: $e2\n$st2');
      }
      return;
    }
    _knownUserId = userId;
    _pendingUserId = null;
    // Yeni kullanıcı: ilk çekme bayrakları sıfırlanır (yönlendirici buna göre bekler).
    state = SessionState(userId: userId);
    await _sync(catalogs: true);
  }

  Future<void> _signedOut() async {
    state = const SessionState();
    try {
      await ref.read(databaseProvider).clearAllUserData();
      await ref
          .read(keyValueStoreProvider)
          .write(SecureLocalStorage.lastUserIdKey, signedOutMarker);
    } catch (e, st) {
      debugPrint('Çıkışta temizlik başarısız: $e\n$st');
      state = state.copyWith(lastError: e);
    }
    for (final hook in ref.read(signedOutHooksProvider)) {
      try {
        await hook();
      } catch (e, st) {
        debugPrint('Çıkış kancası başarısız: $e\n$st');
      }
    }
  }

  /// Önce gönderip çeker (profil dahil), sonra katalogları indirir. Katalog hatası çekmeyi
  /// asla engellemez; ilk başarılı çekme `initialPullDone` olarak işaretlenir.
  Future<void> _sync({bool catalogs = false}) async {
    if (state.userId == null) return;
    state = state.copyWith(syncing: true);
    final engine = ref.read(syncEngineProvider);
    Object? error;
    try {
      await engine.syncNow();
      state = state.copyWith(initialPullDone: true, initialPullFailed: false);
    } catch (e, st) {
      // Çevrimdışı açılış: hata durumda tutulur, arayüze fırlatılmaz.
      debugPrint('Eşitleme başarısız: $e\n$st');
      error = e;
      if (!state.initialPullDone) state = state.copyWith(initialPullFailed: true);
    }
    if (catalogs) {
      try {
        await engine.downloadCatalogs();
      } catch (e, st) {
        debugPrint('Katalog indirme başarısız: $e\n$st');
        error ??= e;
      }
    }
    state = state.copyWith(syncing: false, lastError: error);
  }

  /// Açılış ekranındaki "Tekrar dene": kullanıcı kontrolü başarısızsa onu, değilse ilk
  /// çekmeyi yeniden dener.
  Future<void> retry() => _enqueue(() async {
    final pending = _pendingUserId;
    if (state.userId == null && pending != null) {
      await _handle(pending);
      return;
    }
    if (state.userId == null) return;
    if (!state.initialPullDone) state = state.copyWith(initialPullFailed: false);
    await _sync(catalogs: !state.initialPullDone);
  });

  /// Uygulama öne gelince her zaman eşitler.
  Future<void> onResumed() => _enqueue(_sync);

  /// 60 sn'lik zamanlayıcı: yalnızca bekleyen işlem varsa.
  Future<void> periodicTick() => _enqueue(() async {
    if (state.userId == null) return;
    try {
      final pending = await ref.read(outboxProvider).pendingCount().first;
      if (pending > 0) await _sync();
    } catch (e, st) {
      debugPrint('Periyodik eşitleme başarısız: $e\n$st');
    }
  });
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

/// Uygulama öne gelince denetleyiciyi tetikler.
class SessionLifecycleObserver extends WidgetsBindingObserver {
  SessionLifecycleObserver(this._controller);
  final SessionController _controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_controller.onResumed());
  }
}
