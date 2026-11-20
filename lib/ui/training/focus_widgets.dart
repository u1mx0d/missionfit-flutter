import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/today_provider.dart' show clockProvider;
import '../../domain/active_workout.dart';
import '../../domain/turkish_text.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';

/// Odak modunun çevre parçaları: üst bar, ilerleme çubuğu, set noktaları, geçen süre,
/// "geçen sefer" notu ve ana düğme.

bool _mono(MfTheme t) => t.family == ThemeFamily.mono;

/// Üstteki hareket ilerlemesi: biten, şimdiki ve bekleyen hareketler.
class ExerciseProgress extends StatelessWidget {
  const ExerciseProgress({required this.done, required this.current, super.key});

  /// Her hareket için hedefe ulaşıldı mı.
  final List<bool> done;
  final int current;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    return Semantics(
      label: 'Hareket ${current + 1} / ${done.length}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < done.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: i == current ? 6 : 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == current
                      ? (mono ? t.accent : t.text)
                      : done[i]
                      ? (mono ? t.text : t.accent)
                      : t.border,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Set noktaları: biten (dolu, dokununca düzenlenir), şimdiki (çerçeveli), bekleyen.
/// Set sayısı yanındaki [SetCountStepper] ile değişir.
class SetDots extends StatelessWidget {
  const SetDots({required this.done, required this.target, required this.onEdit, super.key});

  final List<LoggedSet> done;
  final int target;
  final ValueChanged<LoggedSet> onEdit;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    final total = done.length >= target ? done.length : target;

    Widget dot(int i) {
      final isDone = i < done.length;
      final isCurrent = i == done.length;
      final fill = isDone ? (mono ? t.text : t.accent) : (mono ? null : t.surfaceMuted);
      final fg = isDone
          ? (mono ? t.background : t.onAccent)
          : isCurrent
          ? t.text
          : t.textMuted;
      final border = isCurrent
          ? Border.all(color: mono ? t.accent : t.text, width: 2)
          : mono && !isDone
          ? Border.all(color: t.border)
          : null;
      final circle = Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: fill, border: border),
        child: Text(
          '${i + 1}',
          style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      );
      final label = isDone
          ? 'Set ${i + 1}, tamamlandı, düzenle'
          : isCurrent
          ? 'Set ${i + 1}, sıradaki'
          : 'Set ${i + 1}';
      return Semantics(
        label: label,
        button: isDone,
        excludeSemantics: true,
        child: InkResponse(
          onTap: isDone ? () => onEdit(done[i]) : null,
          radius: 24,
          child: SizedBox(width: 48, height: 48, child: Center(child: circle)),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [for (var i = 0; i < total; i++) dot(i)],
    );
  }
}

/// "SET 2/3" yazısı ve iki yanında set sayısını azaltan/artıran küçük düğmeler
/// (dokunma alanı 48 dp). Düğme null ise pasif.
class SetCountStepper extends StatelessWidget {
  const SetCountStepper({
    required this.caption,
    required this.onRemove,
    required this.onAdd,
    super.key,
  });

  final String caption;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    Widget button(String glyph, String label, VoidCallback? onTap, Key key) => Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        key: key,
        onTap: onTap,
        radius: 24,
        excludeFromSemantics: true,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onTap == null ? t.border : t.textMuted),
              ),
              child: Text(
                glyph,
                style: TextStyle(
                  color: onTap == null ? t.textMuted : t.text,
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button('–', 'set sayısını azalt', onRemove, const Key('set-count-minus')),
        Text(
          mono ? turkishUpper(caption) : caption,
          style: TextStyle(color: t.textMuted, fontSize: 12, letterSpacing: mono ? 1.4 : 0),
        ),
        button('+', 'set sayısını artır', onAdd, const Key('set-count-plus')),
      ],
    );
  }
}

/// "Geçen sefer: 60 × 8 · …" notu. Canlı temada önünde artış ikonu (süs) durur.
class LastTimeNote extends StatelessWidget {
  const LastTimeNote({required this.text, required this.trend, super.key});
  final String text;
  final bool trend;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: mono ? t.surface : t.accent.withValues(alpha: 0.12),
        border: mono ? Border.all(color: t.border) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!mono && trend) ...[
            Icon(Icons.trending_up_rounded, size: 16, color: t.text),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.text, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Antrenmanın geçen süresi; saniyede bir güncellenir.
class ElapsedClock extends ConsumerStatefulWidget {
  const ElapsedClock({required this.startedAt, required this.mono, super.key});
  final DateTime startedAt;
  final bool mono;

  @override
  ConsumerState<ElapsedClock> createState() => _ElapsedClockState();
}

class _ElapsedClockState extends ConsumerState<ElapsedClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final d = ref.read(clockProvider)().difference(widget.startedAt);
    final s = d.isNegative ? 0 : d.inSeconds;
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    String two(int x) => x.toString().padLeft(2, '0');
    final text = widget.mono
        ? '${two(h)}:${two(m)}:${two(sec)}'
        : h > 0
        ? '$h:${two(m)}:${two(sec)}'
        : '$m:${two(sec)}';
    return Semantics(
      label: 'Antrenman süresi ${h > 0 ? '$h saat ' : ''}$m dakika',
      excludeSemantics: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: t.textMuted,
          fontSize: 13,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class NoActiveWorkout extends StatelessWidget {
  const NoActiveWorkout({required this.onBack, super.key});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Süren antrenman yok.', style: TextStyle(color: t.text, fontSize: 16)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
              child: const Text('Antrenman sekmesine dön'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Üst bar: "Antrenmanı bitir" (×), geçen süre, "Tüm liste".
class FocusTopBar extends StatelessWidget {
  const FocusTopBar({
    required this.startedAt,
    required this.onClose,
    required this.onList,
    super.key,
  });
  final DateTime startedAt;
  final VoidCallback onClose;
  final VoidCallback? onList;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    final style = IconButton.styleFrom(
      backgroundColor: mono ? t.surface : t.surfaceMuted,
      foregroundColor: t.text,
      minimumSize: const Size(48, 48),
    );
    return Row(
      children: [
        IconButton(
          tooltip: 'Antrenmanı bitir',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          style: style,
        ),
        Expanded(
          child: ElapsedClock(startedAt: startedAt, mono: mono),
        ),
        IconButton(
          tooltip: 'Tüm liste',
          onPressed: onList,
          icon: const Icon(Icons.format_list_bulleted_rounded),
          style: style,
        ),
      ],
    );
  }
}

/// 60 dp ana düğme (başparmağın uzandığı altta).
class FocusCta extends StatelessWidget {
  const FocusCta({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        shape: const StadiumBorder(),
        backgroundColor: t.accent,
        foregroundColor: t.onAccent,
        disabledBackgroundColor: t.surfaceMuted,
        disabledForegroundColor: t.textMuted,
        textStyle: TextStyle(
          fontFamily: t.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: _mono(t) ? 1.2 : 0,
        ),
      ),
      child: Text(label),
    );
  }
}
