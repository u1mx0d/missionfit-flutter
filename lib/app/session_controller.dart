import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth/secure_local_storage.dart';
import 'providers.dart';

class SessionState {
  const SessionState({this.userId, this.syncing = false, this.lastError});
  final String? userId;
  final bool syncing;

  /// Son eşitleme hatası; uygulama çevrimdışı çalışmaya devam eder.
  final Object? lastError;

  SessionState copyWith({Object? userId = _keep, bool? syncing, Object? lastError = _keep}) =>
      SessionState(
        userId: identical(userId, _keep) ? this.userId : userId as String?,
        syncing: syncing ?? this.syncing,
        lastError: identical(lastError, _keep) ? this.lastError : lastError,
      );
}

const Object _keep = Object();

/// Çıkışta çalışan kancalar (örn. bildirimleri iptal etme; sonraki görevlerde eklenir).
///
/// Kancalar denetleyicinin sırası içinde çalışır; `handleSession`/`onResumed` veya sıraya
/// girip bekleyen başka bir şey çağırmamalıdır (kilitlenme).
final signedOutHooksProvider = Provider<List<Future<void> Function()>>((ref) => []);

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
      // Açılışta oturum yoksa silinecek bir şey yok; yalnızca açık oturumdan çıkışta temizle.
      if (_knownUserId == null) return;
      _knownUserId = null;
      await _signedOut();
      return;
    }
    if (userId == _knownUserId) return;
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
      state = SessionState(lastError: e);
      try {
        await ref.read(databaseProvider).clearAllUserData();
      } catch (e2, st2) {
        debugPrint('Güvenli kapanışta temizlik başarısız: $e2\n$st2');
      }
      return;
    }
    _knownUserId = userId;
    state = state.copyWith(userId: userId);
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

  Future<void> _sync({bool catalogs = false}) async {
    if (state.userId == null) return;
    state = state.copyWith(syncing: true);
    try {
      final engine = ref.read(syncEngineProvider);
      if (catalogs) await engine.downloadCatalogs();
      await engine.syncNow();
      state = state.copyWith(syncing: false, lastError: null);
    } catch (e, st) {
      // Çevrimdışı açılış: hata durumda tutulur, arayüze fırlatılmaz.
      debugPrint('Eşitleme başarısız: $e\n$st');
      state = state.copyWith(syncing: false, lastError: e);
    }
  }

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
