/// 3B kaslı atlet maketi: 72 karelik dönüş, tema stiline göre shader ile boyanır.
/// Sürükleyince döner, ilk gösterimde bir tur atar, dokununca bölgeyi bildirir.
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/body_map.dart';
import '../../theme/mf_theme.dart';
import '../dot_grid.dart';
import 'body_map_frames.dart';

export '../../theme/mf_theme.dart' show BodyMapStyle;

/// Kare oranı (360 × 720); kareler yüklenmeden yer ayırmak için.
const double bodyMapAspectRatio = 0.5;

/// Mono nokta aralığı (mantıksal px).
const double bodyMapDotPitch = 3.0;

/// Sürüklemede piksel başına dönüş (derece).
const double _degPerPx = 0.6;
const Duration _introDuration = Duration(milliseconds: 2400);

class BodyMap extends ConsumerStatefulWidget {
  const BodyMap({
    required this.levels,
    this.onRegionTap,
    this.semanticLabel = 'Kas haritası',
    super.key,
  });

  /// Kas slug'ı → seviye (0–3).
  final Map<String, int> levels;
  final ValueChanged<String>? onRegionTap;
  final String semanticLabel;

  @override
  ConsumerState<BodyMap> createState() => BodyMapState();
}

class BodyMapState extends ConsumerState<BodyMap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController.unbounded(vsync: this)
    ..addListener(_onTick);
  int _frame = 0;
  bool _introStarted = false;
  ui.FragmentShader? _shader;
  ui.FragmentProgram? _shaderProgram;

  /// Geçerli açı (derece, sarmalanmamış).
  @visibleForTesting
  double get angle => _ctrl.value;

  /// Gösterilen kare.
  @visibleForTesting
  int get frame => _frame;

  int _frameCount = 72;

  void _onTick() {
    final f = frameForAngle(_ctrl.value, frames: _frameCount);
    // Yalnızca kare değişince yeniden çizilir.
    if (f != _frame) setState(() => _frame = f);
  }

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _maybeStartIntro() {
    if (_introStarted) return;
    _introStarted = true;
    if (_reduceMotion) return;
    _ctrl
        .animateTo(360, duration: _introDuration, curve: Curves.easeInOutCubic)
        .whenCompleteOrCancel(() {
          if (mounted && _ctrl.value == 360) _ctrl.value = 0;
        });
  }

  void _onDragStart(DragStartDetails _) => _ctrl.stop();

  void _onDragUpdate(DragUpdateDetails d) {
    // Parmak sağa → ön yüz sağa döner (açı azalır; açı yukarıdan saat yönünde artar).
    _ctrl.value -= d.delta.dx * _degPerPx;
  }

  void _onDragEnd(DragEndDetails d) {
    final v = -d.velocity.pixelsPerSecond.dx * _degPerPx;
    if (_reduceMotion || v.abs() < 1) return;
    // Bırakınca sürtünmeyle yumuşakça durur.
    _ctrl.animateWith(FrictionSimulation(0.05, _ctrl.value, v));
  }

  void _rotateBy(double degrees) {
    _ctrl.stop();
    final target = ((_ctrl.value + degrees) / 45).round() * 45.0;
    if (_reduceMotion) {
      _ctrl.value = target;
    } else {
      _ctrl.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onTapUp(TapUpDetails d, BodyMapFrames frames, Size size) {
    final cb = widget.onRegionTap;
    if (cb == null) return;
    final id = frames.regionAt(_frame, d.localPosition, size);
    if (id >= 1 && id <= bodyMapMuscles.length) cb(bodyMapMuscles[id - 1]);
  }

  ui.FragmentShader? _shaderFor(ui.FragmentProgram? program) {
    if (program != _shaderProgram) {
      _shader?.dispose();
      _shader = program?.fragmentShader();
      _shaderProgram = program;
    }
    return _shader;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = ref.watch(bodyMapFramesProvider).value;
    final program = ref.watch(bodyMapProgramProvider).value;

    Widget child;
    if (frames == null) {
      // Kareler yüklenirken yerini koruyan boş kutu.
      child = const SizedBox.expand();
    } else {
      _frameCount = frames.frameCount;
      if (!_introStarted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeStartIntro();
        });
      }
      final shader = _shaderFor(program);
      child = LayoutBuilder(
        builder: (context, c) {
          final size = c.biggest;
          final image = shader == null
              ? RawImage(image: frames.shades[_frame], fit: BoxFit.contain)
              : CustomPaint(
                  size: size,
                  painter: _BodyMapPainter(
                    shader: shader,
                    frames: frames,
                    frame: _frame,
                    levels: _levelList(widget.levels),
                    colors: _BodyMapColors.of(mf(context)),
                  ),
                );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onTapUp: (d) => _onTapUp(d, frames, size),
            child: RepaintBoundary(child: image),
          );
        },
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      excludeSemantics: true,
      // Sürüklemeye alternatif: ekran okuyucuda artır/azalt 45° döndürür.
      onIncrease: frames == null ? null : () => _rotateBy(45),
      onDecrease: frames == null ? null : () => _rotateBy(-45),
      child: AspectRatio(aspectRatio: bodyMapAspectRatio, child: child),
    );
  }
}

/// 15 elemanlı seviye listesi (indeks = bölge kimliği, 0 = cilt).
List<double> _levelList(Map<String, int> levels) {
  final out = List<double>.filled(15, 0);
  levels.forEach((slug, lv) {
    final id = bodyMapRegionId(slug);
    if (id > 0) out[id] = lv.clamp(0, 3).toDouble();
  });
  return out;
}

@immutable
class _BodyMapColors {
  const _BodyMapColors(this.style, this.accent, this.base, this.off);

  factory _BodyMapColors.of(MfTheme t) {
    final dark = t.brightness == Brightness.dark;
    return _BodyMapColors(
      t.bodyMapStyle,
      t.accent,
      t.bodyMapStyle == BodyMapStyle.glow
          // Heykel taşı: koyu zeminde açık gri, açık zeminde orta gri.
          ? (dark ? const Color(0xFFA8AAA9) : const Color(0xFF8C908E))
          // Nokta-matris: alfa = en düşük nokta opaklığı (açık zeminde daha yüksek).
          : Color.fromRGBO(0, 0, 0, dark ? 0 : 0.45),
      // Boş noktalar: ışık değeri saydamlığa çevrilir, en parlak yer yazı rengine yaklaşır.
      t.text,
    );
  }

  final BodyMapStyle style;
  final Color accent;
  final Color base;
  final Color off;

  @override
  bool operator ==(Object other) =>
      other is _BodyMapColors &&
      other.style == style &&
      other.accent == accent &&
      other.base == base &&
      other.off == off;

  @override
  int get hashCode => Object.hash(style, accent, base, off);
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.shader,
    required this.frames,
    required this.frame,
    required this.levels,
    required this.colors,
  });

  final ui.FragmentShader shader;
  final BodyMapFrames frames;
  final int frame;
  final List<double> levels;
  final _BodyMapColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final dest = frames.destRect(size);
    if (dest.isEmpty) return;
    var i = 0;
    void f(double v) => shader.setFloat(i++, v);
    void color(Color c) {
      f(c.r);
      f(c.g);
      f(c.b);
      f(c.a);
    }

    f(dest.width);
    f(dest.height);
    color(colors.accent);
    color(colors.base);
    color(colors.off);
    f(colors.style == BodyMapStyle.dots ? 0 : 1);
    f(bodyMapDotPitch);
    levels.forEach(f);
    shader
      ..setImageSampler(0, frames.shades[frame], filterQuality: FilterQuality.low)
      ..setImageSampler(1, frames.ids[frame], filterQuality: FilterQuality.none);

    canvas
      ..save()
      ..translate(dest.left, dest.top)
      ..drawRect(Offset.zero & dest.size, Paint()..shader = shader)
      ..restore();
  }

  @override
  bool shouldRepaint(_BodyMapPainter old) =>
      old.frame != frame ||
      old.frames != frames ||
      old.shader != shader ||
      old.colors != colors ||
      !listEquals(old.levels, levels);
}
