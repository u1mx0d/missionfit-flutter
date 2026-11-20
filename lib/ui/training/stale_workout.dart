import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/active_workout_controller.dart';
import '../../app/today_provider.dart' show clockProvider;
import '../../domain/active_workout.dart';
import 'workout_summary_screen.dart' show routeAfterFinish;

/// "Bitir mi, sil mi?" diyaloğunun tekrar tekrar açılmasını önler: aynı anda tek diyalog,
/// kendiliğinden soru her oturum için uygulama açıkken bir kez.
class StaleWorkoutGate {
  bool _open = false;
  final _autoAsked = <String>{};
}

final staleWorkoutGateProvider = Provider<StaleWorkoutGate>((ref) => StaleWorkoutGate());

enum StaleOutcome {
  /// 24 saatten yeni: olduğu gibi devam edilir.
  fresh,

  /// Soruldu (bitirildi, silindi ya da diyalog kapatıldı) veya zaten soruluyor: devam edilmez.
  asked,
}

/// Aktif antrenman 24 saatten eskiyse "Bitir mi, sil mi?" diye sorar ve seçimi uygular.
/// [auto]: kullanıcı bir şey istemeden (açılışta) soruluyor; o oturum için bir kez sorulur.
Future<StaleOutcome> resolveStaleWorkout(
  BuildContext context,
  WidgetRef ref,
  ActiveWorkout w, {
  bool auto = false,
}) async {
  if (!isStaleWorkout(w.startedAt, ref.read(clockProvider)())) return StaleOutcome.fresh;
  final gate = ref.read(staleWorkoutGateProvider);
  if (gate._open) return StaleOutcome.asked;
  if (auto && !gate._autoAsked.add(w.sessionId)) return StaleOutcome.asked;
  gate._autoAsked.add(w.sessionId);
  gate._open = true;
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ctl = ref.read(activeWorkoutControllerProvider.notifier);
  final _StaleChoice? choice;
  try {
    choice = await showDialog<_StaleChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bitir mi, sil mi?'),
        content: const Text(
          'Bu antrenman 24 saatten uzun süredir açık. Bitirirsen yaptığın setler kaydedilir; '
          'silersen antrenman ve setleri silinir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _StaleChoice.discard),
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            child: const Text('Sil'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _StaleChoice.finish),
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
  } finally {
    gate._open = false;
  }
  try {
    switch (choice) {
      case _StaleChoice.finish:
        routeAfterFinish(router, messenger, w.sessionId, await ctl.finish());
      case _StaleChoice.discard:
        await ctl.discard();
        messenger.showSnackBar(const SnackBar(content: Text('Antrenman silindi.')));
      case null:
        break;
    }
  } catch (e) {
    debugPrint('Yarım antrenman kapatılamadı: $e');
    messenger.showSnackBar(const SnackBar(content: Text('İşlem yapılamadı. Tekrar dene.')));
  }
  return StaleOutcome.asked;
}

enum _StaleChoice { finish, discard }

/// Uygulama açılınca (hangi sekmede olursa olsun) 24 saatten eski aktif antrenmanı sorar.
/// Kabuk (`router.dart`) bunu sarmalar; soru her oturum için bir kez gelir.
class StaleWorkoutWatcher extends ConsumerStatefulWidget {
  const StaleWorkoutWatcher({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<StaleWorkoutWatcher> createState() => _StaleWorkoutWatcherState();
}

class _StaleWorkoutWatcherState extends ConsumerState<StaleWorkoutWatcher> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(activeWorkoutControllerProvider, (_, next) {
      final w = next.value;
      if (w == null) return;
      // Diyalog çizim sırasında açılamaz; kare bitince sorulur.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cur = ref.read(activeWorkoutControllerProvider).value;
        if (cur?.sessionId != w.sessionId) return;
        unawaited(resolveStaleWorkout(context, ref, w, auto: true));
      });
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
