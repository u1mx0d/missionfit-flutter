import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/active_workout_controller.dart';
import '../../app/rest_timer.dart';
import '../../app/today_provider.dart' show clockProvider;
import '../../domain/turkish_text.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';
import 'focus_steppers.dart' show formatSeconds;

/// Dinlenme ekranı: odak modunun üstünde tam ekran açılır. Büyük geri sayım
/// (Mono: 60 noktalı halka, Canlı: yeşil halka), ±15 sn, sıradaki set, Atla.
class RestScreen extends ConsumerWidget {
  const RestScreen({required this.onEditLast, super.key});

  /// "Son seti düzenle": sayaç durur, odak modu son seti açar.
  final VoidCallback onEditLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    final rest = ref.watch(restTimerProvider);
    if (rest == null) return const SizedBox.shrink();
    final w = ref.watch(activeWorkoutControllerProvider).value;
    final timer = ref.read(restTimerProvider.notifier);
    String up(String s) => mono ? turkishUpper(s) : s;

    final plan = w?.plan.where((p) => p.exerciseId == rest.exerciseId).firstOrNull;
    final done = w?.doneSets(rest.exerciseId) ?? 0;
    final target = math.max(plan?.targetSets ?? done, done);
    final doneCaption = 'Set $done/$target bitti';

    final content = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          mono ? 'DİNLENME' : 'Dinlen',
                          style: TextStyle(
                            color: mono ? t.textMuted : t.text,
                            fontSize: mono ? 12 : 16,
                            fontWeight: mono ? FontWeight.w500 : FontWeight.w700,
                            letterSpacing: mono ? 1.7 : 0,
                          ),
                        ),
                      ),
                      Text(
                        up(doneCaption),
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 12,
                          letterSpacing: mono ? 1.2 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Center(child: _RestClock(rest: rest)),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _AdjustButton(
                              label: up('–15 sn'),
                              semanticLabel: 'Dinlenmeyi 15 saniye kısalt',
                              onPressed: () => unawaited(timer.adjust(-15)),
                            ),
                            _AdjustButton(
                              label: up('+15 sn'),
                              semanticLabel: 'Dinlenmeyi 15 saniye uzat',
                              onPressed: () => unawaited(timer.adjust(15)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _NextCard(),
                        // 2b: "geçen hafta şöyleydin" motivasyon satırının yeri (şimdilik boş).
                        const SizedBox(key: Key('rest-motivation'), height: 56),
                        Center(
                          child: TextButton.icon(
                            onPressed: onEditLast,
                            style: TextButton.styleFrom(
                              foregroundColor: t.text,
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(
                              'Son seti düzenle',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: t.bodyFont,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: t.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => unawaited(timer.skip()),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    shape: const StadiumBorder(),
                    // Ters renk: odak modunun vurgulu "Seti tamamla"sından ayrışır.
                    backgroundColor: t.text,
                    foregroundColor: t.background,
                    textStyle: TextStyle(
                      fontFamily: t.bodyFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: mono ? 1.2 : 0,
                    ),
                  ),
                  child: Text(up('Atla'), semanticsLabel: 'Dinlenmeyi atla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Material(
      color: t.background,
      child: mono || t.gradientTop == null
          ? MfBackground(child: content)
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.45),
                  radius: 0.95,
                  colors: [t.gradientTop!, t.background],
                ),
              ),
              child: content,
            ),
    );
  }
}

/// "kalan 1 dakika 12 saniye" (ekran okuyucu).
String restSemantics(int seconds) {
  final m = seconds ~/ 60, s = seconds % 60;
  final parts = [if (m > 0) '$m dakika', if (s > 0 || m == 0) '$s saniye'];
  return 'kalan ${parts.join(' ')}';
}

/// Halka + kalan süre. Normalde halka her karede akar; "Hareketi azalt" açıkken
/// saniyede bir adım atar ve sürekli kare istenmez. Süre dolunca dinlenme kapanır.
class _RestClock extends ConsumerStatefulWidget {
  const _RestClock({required this.rest});
  final RestState rest;

  @override
  ConsumerState<_RestClock> createState() => _RestClockState();
}

class _RestClockState extends ConsumerState<_RestClock> with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Timer? _timer;
  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    _ticker?.dispose();
    _ticker = null;
    _timer?.cancel();
    _timer = null;
    if (reduced) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      _ticker = createTicker((_) => _tick())..start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    if (widget.rest.remaining(ref.read(clockProvider)()) == Duration.zero) {
      unawaited(ref.read(restTimerProvider.notifier).finishIfDue());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    final rest = widget.rest;
    final left = rest.remaining(ref.read(clockProvider)());
    final secs = (left.inMilliseconds + 999) ~/ 1000;
    final total = rest.totalSeconds;
    final progress = (_reduced ?? false) ? secs / total : left.inMilliseconds / (total * 1000);
    final size = math.min(210.0, MediaQuery.sizeOf(context).width - 32);

    return Semantics(
      label: restSemantics(secs),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RestRing(progress: progress.clamp(0.0, 1.0), mono: mono),
            Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatSeconds(secs),
                      style: TextStyle(
                        fontFamily: t.numberFont,
                        color: t.text,
                        fontSize: 56,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: mono ? 0 : -1.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'KALAN · ${formatSeconds(total)}',
                      style: TextStyle(color: t.textMuted, fontSize: 11, letterSpacing: 1.8),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Geri sayım halkası; [progress] kalan oran (1 = dolu, 0 = bitti).
class RestRing extends StatelessWidget {
  const RestRing({required this.progress, required this.mono, super.key});
  final double progress;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return CustomPaint(
      painter: _RingPainter(
        progress: progress,
        mono: mono,
        on: t.accent,
        off: mono ? Color.lerp(t.border, t.textMuted, 0.35)! : t.text.withValues(alpha: 0.12),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.mono,
    required this.on,
    required this.off,
  });
  final double progress;
  final bool mono;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 210;
    final c = size.center(Offset.zero);
    final r = 92 * k;
    if (mono) {
      // 60 nokta: kalan süre kadarı vurgu renginde ve büyük; sınırdaki nokta kısmen.
      final lit = progress * 60;
      final paint = Paint();
      for (var i = 0; i < 60; i++) {
        final f = (lit - i).clamp(0.0, 1.0);
        final a = -math.pi / 2 + i * 2 * math.pi / 60;
        paint.color = Color.lerp(off, on, f)!;
        canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * r,
          (2.4 + (4.2 - 2.4) * f) * k,
          paint,
        );
      }
      return;
    }
    final stroke = 12 * k;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = off,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = on,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.mono != mono || old.on != on || old.off != off;
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({required this.label, required this.semanticLabel, required this.onPressed});
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(104, 56),
        shape: const StadiumBorder(),
        foregroundColor: t.text,
        backgroundColor: mono ? t.surface : t.text.withValues(alpha: 0.08),
        side: mono ? BorderSide(color: t.border) : BorderSide.none,
        textStyle: TextStyle(
          fontFamily: t.bodyFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: mono ? 1 : 0,
        ),
      ),
      child: Text(label, semanticsLabel: semanticLabel),
    );
  }
}

/// "Sıradaki · Set 3/4 — Bench Press · 62,5 × 8".
class _NextCard extends ConsumerWidget {
  const _NextCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    final next = ref.watch(restNextProvider);
    final n = next.value;
    final caption = n == null ? 'Sıradaki' : 'Sıradaki · Set ${n.setNumber}/${n.targetSets}';
    final title = n != null
        ? n.label
        : next.isLoading
        ? '…'
        : 'Hedeflenen setler tamam';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: mono ? t.surface : t.text.withValues(alpha: 0.06),
        border: mono ? Border.all(color: t.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mono ? turkishUpper(caption) : caption,
            style: TextStyle(color: t.textMuted, fontSize: 12, letterSpacing: mono ? 1.2 : 0),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: t.text, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
