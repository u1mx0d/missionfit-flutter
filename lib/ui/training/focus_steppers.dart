import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../domain/units.dart';
import '../../domain/weight_step.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';

/// Odak modunun değer girişi: 60 dp –/+ düğmesi (basılı tutunca hızlanır), değer satırı,
/// süre alanı (kronometreli) ve adım kuralları. Klavye hiç açılmaz.

bool _mono(MfTheme t) => t.family == ThemeFamily.mono;

/// 62.5 → "62,5", 60.0 → "60" (Türkçe ondalık virgül).
String formatAmount(double v) {
  final r = (v * 10).round() / 10;
  return r == r.truncateToDouble()
      ? r.toInt().toString()
      : r.toStringAsFixed(1).replaceAll('.', ',');
}

/// 45 → "0:45", 125 → "2:05", 3725 → "1:02:05".
String formatSeconds(int s) {
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final ss = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}

/// 60 dp –/+ düğmesi. Dokununca bir adım; basılı tutunca hızlanarak tekrarlar.
class RepeatButton extends StatefulWidget {
  const RepeatButton({
    required this.semanticLabel,
    required this.glyph,
    required this.onStep,
    super.key,
  });

  final String semanticLabel;
  final String glyph;
  final VoidCallback? onStep;

  static const size = 60.0;

  @override
  State<RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<RepeatButton> {
  Timer? _timer;
  int _repeats = 0;
  bool _pressed = false;

  void _schedule() {
    // İlk birkaç adım yavaş, sonra hızlı: kısa düzeltme de uzun yol da rahat.
    final delay = Duration(milliseconds: _repeats < 6 ? 150 : 60);
    _timer = Timer(delay, () {
      if (!mounted || widget.onStep == null) return _stop();
      widget.onStep!();
      _repeats++;
      _schedule();
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _repeats = 0;
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  void _press(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final enabled = widget.onStep != null;
    final mono = _mono(t);
    final bg = _pressed ? (mono ? t.surfaceMuted : t.border) : (mono ? t.surface : t.surfaceMuted);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: widget.onStep,
      excludeSemantics: true,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTapDown: enabled ? (_) => _press(true) : null,
        onTapCancel: () => _press(false),
        onTapUp: (_) => _press(false),
        onTap: widget.onStep,
        onLongPressStart: enabled
            ? (_) {
                _press(true);
                widget.onStep!();
                _schedule();
              }
            : null,
        onLongPressEnd: (_) => _stop(),
        onLongPressCancel: _stop,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: RepeatButton.size,
          height: RepeatButton.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: mono ? Border.all(color: t.border) : null,
          ),
          child: Text(
            widget.glyph,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: enabled ? t.text : t.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// "–  62,5 KG  +" satırı. [valueText] boşsa "–" gösterilir.
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    required this.valueKey,
    required this.valueText,
    required this.unit,
    required this.noun,
    required this.onStep,
    super.key,
  });

  final Key valueKey;
  final String? valueText;
  final String unit;

  /// Semantik ad için: "ağırlığı", "tekrarı", "süreyi".
  final String noun;

  /// null: –/+ pasif (ör. kronometre çalışırken).
  final void Function(int direction)? onStep;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);
    final step = onStep;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          RepeatButton(
            semanticLabel: '$noun azalt',
            glyph: '–',
            onStep: step == null ? null : () => step(-1),
          ),
          Expanded(
            child: Semantics(
              label: '${valueText ?? 'boş'} $unit',
              excludeSemantics: true,
              child: Column(
                children: [
                  Text(
                    valueText ?? '–',
                    key: valueKey,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: t.numberFont,
                      fontSize: 44,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: mono ? 0 : -1.2,
                      color: valueText == null ? t.textMuted : t.text,
                    ),
                  ),
                  Text(
                    unit.toUpperCase(),
                    style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: t.textMuted),
                  ),
                ],
              ),
            ),
          ),
          RepeatButton(
            semanticLabel: '$noun artır',
            glyph: '+',
            onStep: step == null ? null : () => step(1),
          ),
        ],
      ),
    );
  }
}

/// Süre alanı: –/+ 5 sn ve "Başlat" ile sayan kronometre; durdurunca süre alana yazılır.
class DurationField extends StatefulWidget {
  const DurationField({
    required this.seconds,
    required this.onChanged,
    required this.clock,
    this.valueKey = const Key('value-duration'),
    super.key,
  });

  final int? seconds;
  final ValueChanged<int?> onChanged;
  final DateTime Function() clock;
  final Key valueKey;

  @override
  State<DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  DateTime? _startedAt;
  Timer? _ticker;
  int _elapsed = 0;

  int _now() => widget.clock().difference(_startedAt!).inSeconds;

  void _start() {
    setState(() {
      _startedAt = widget.clock();
      _elapsed = 0;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = _now());
    });
  }

  void _stopWatch() {
    _ticker?.cancel();
    _ticker = null;
    final s = _now();
    setState(() => _startedAt = null);
    widget.onChanged(s < 1 ? widget.seconds : s);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _step(int dir) {
    final cur = widget.seconds;
    if (cur == null) {
      if (dir > 0) widget.onChanged(5);
      return;
    }
    widget.onChanged((cur + dir * 5).clamp(5, 86400));
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final running = _startedAt != null;
    final shown = running ? _elapsed : widget.seconds;
    return Column(
      children: [
        ValueStepper(
          valueKey: widget.valueKey,
          valueText: shown == null ? null : formatSeconds(shown),
          unit: 'süre',
          noun: 'süreyi',
          onStep: running ? null : _step,
        ),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: running ? _stopWatch : _start,
            icon: Icon(running ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 20),
            label: Text(running ? 'Durdur' : 'Başlat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: t.text,
              side: BorderSide(color: t.border),
              minimumSize: const Size(120, 48),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ağırlık –/+: boş alan "+" ile ilk adımdan başlar; 0–1000 kg arası.
double? nextWeight(double? kg, int direction, String equipment, WeightUnit unit) {
  if (kg == null) return direction > 0 ? stepWeight(0, 1, equipment, unit) : null;
  final next = stepWeight(kg, direction, equipment, unit);
  return next > 1000 ? kg : next;
}

/// Tekrar –/+: boş alan "+" ile 1'den başlar; 1–500 arası.
int? nextReps(int? reps, int direction) {
  if (reps == null) return direction > 0 ? 1 : null;
  return (reps + direction).clamp(1, 500);
}
