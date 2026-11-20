/// 3B kaslı atlet maketi: 72 karelik dönüş, tema stiline göre shader ile boyanır.
/// Sürükleyince döner, ilk gösterimde bir tur atar, dokununca bölgeyi bildirir.
/// Seçili bölgeler tam vurguda yanar (kenarı ince çizgiyle), diğerleri sönükleşir; seçili
/// bölge o an görünmüyorsa maket en iyi göründüğü kareye döner.
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
const Duration _revealDuration = Duration(milliseconds: 500);

/// Seçili bölge kenarının nabız yarı süresi (tam tur 1,2 sn).
const Duration _pulseHalf = Duration(milliseconds: 600);

class BodyMap extends ConsumerStatefulWidget {
  const BodyMap({
    required this.levels,
    this.onRegionTap,
    this.onBackgroundTap,
    this.selectedRegions = const {},
    this.selectedName,
    this.semanticLabel = 'Kas haritası',
    super.key,
  });

  /// Kas slug'ı → seviye (0–3).
  final Map<String, int> levels;
  final ValueChanged<String>? onRegionTap;

  /// Kas olmayan yere (cilt ya da boşluk) dokunuş.
  final VoidCallback? onBackgroundTap;

  /// Seçili kas slug'ları (bir kas ya da bir bölgenin bütün kasları).
  final Set<String> selectedRegions;

  /// Seçimin ekran okuyucudaki adı ("Ön kol"); değerde "Seçili: Ön kol" olarak okunur.
  final String? selectedName;
  final String semanticLabel;

  @override
  ConsumerState<BodyMap> createState() => BodyMapState();
}

class BodyMapState extends ConsumerState<BodyMap> with TickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController.unbounded(vsync: this)
    ..addListener(_onTick);

  /// Seçili bölge kenarının nabzı (0–1); yalnızca seçim varken ve shader'la çizilirken döner.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: _pulseHalf,
    value: 1,
  );

  /// Görünürlüğü en son denetlenen seçim (aynı seçim için yeniden döndürülmez).
  Set<int> _revealed = const {};
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

  /// Gösterilen karenin açısı (derece).
  double get _shownAngle => _frame * 360 / _frameCount;

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
    final target = ((_ctrl.value + degrees) / 90).round() * 90.0;
    if (_reduceMotion) {
      _ctrl.value = target;
    } else {
      _ctrl.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onTapUp(TapUpDetails d, BodyMapFrames frames, Size size) {
    // Dokunuş da açılış turunu (ve savurmayı) durdurur.
    _ctrl.stop();
    final id = frames.regionAt(_frame, d.localPosition, size);
    if (id >= 1 && id <= bodyMapMuscles.length) {
      widget.onRegionTap?.call(bodyMapMuscles[id - 1]);
    } else {
      widget.onBackgroundTap?.call();
    }
  }

  Set<int> get _selectedIds => {
    for (final slug in widget.selectedRegions)
      if (bodyMapRegionId(slug) > 0) bodyMapRegionId(slug),
  };

  /// Seçim değiştiyse ve seçili bölgeler bu karede (neredeyse) görünmüyorsa en iyi
  /// göründükleri kareye döner; azaltılmış harekette atlar.
  void _revealSelection(BodyMapFrames frames) {
    final ids = _selectedIds;
    if (setEquals(ids, _revealed)) return;
    _revealed = ids;
    if (ids.isEmpty || regionsVisibleIn(frames.regionPixels, _frame, ids)) return;
    final best = bestFrameFor(frames.regionPixels, ids);
    final target = angleTowardFrame(_ctrl.value, best, frames: _frameCount);
    _introStarted = true; // Açılış turu henüz başlamadıysa artık başlamaz.
    _ctrl.stop();
    if (_reduceMotion) {
      _ctrl.value = target;
    } else {
      _ctrl.animateTo(target, duration: _revealDuration, curve: Curves.easeInOutCubic);
    }
  }

  /// Nabız yalnızca seçim varken, shader'la çizilirken ve hareket azaltılmamışken döner.
  void _syncPulse({required bool active}) {
    if (active && !_reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating || _pulse.value != 1) {
      _pulse
        ..stop()
        ..value = 1;
    }
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
    _pulse.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sekme kabuğu (IndexedStack) gizli dalı TickerMode(false) ile sarar; görünmezken
    // sağlayıcı dinlenmez, böylece kareler bekleme süresinden sonra bırakılır.
    final visible = TickerMode.valuesOf(context).enabled;
    final frames = visible ? ref.watch(bodyMapFramesProvider).value : null;
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
      final selected = _selectedIds;
      _syncPulse(active: shader != null && selected.isNotEmpty);
      if (!setEquals(selected, _revealed)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _revealSelection(frames);
        });
      }
      child = LayoutBuilder(
        builder: (context, c) {
          final size = c.biggest;
          final image = shader == null
              ? ColorFiltered(
                  colorFilter: _packedToGray,
                  child: RawImage(image: frames.images[_frame], fit: BoxFit.contain),
                )
              : CustomPaint(
                  size: size,
                  painter: _BodyMapPainter(
                    shader: shader,
                    frames: frames,
                    frame: _frame,
                    levels: _levelList(widget.levels),
                    selected: _selectedList(selected),
                    pulse: _pulse,
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

    final sel = widget.selectedName;
    String viewValue(double a) =>
        sel == null ? bodyMapViewName(a) : '${bodyMapViewName(a)}. Seçili: $sel';
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      excludeSemantics: true,
      value: viewValue(_shownAngle),
      increasedValue: frames == null ? null : viewValue(_shownAngle + 90),
      decreasedValue: frames == null ? null : viewValue(_shownAngle - 90),
      // Sürüklemeye alternatif: ekran okuyucuda artır/azalt 90° döndürür.
      onIncrease: frames == null ? null : () => _rotateBy(90),
      onDecrease: frames == null ? null : () => _rotateBy(-90),
      child: AspectRatio(aspectRatio: bodyMapAspectRatio, child: child),
    );
  }
}

/// Açının görünüm adı. Açı yukarıdan saat yönünde artar: 90° sol yan, 270° sağ yan.
String bodyMapViewName(double degrees) {
  final a = ((degrees % 360) + 360) % 360;
  return const ['Ön', 'Sol yan', 'Arka', 'Sağ yan'][((a + 45) ~/ 90) % 4];
}

/// Shader yokken paketli dokudan gri görüntü: RGB = R (ışık), A = B (alfa).
const _packedToGray = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0, //
  1, 0, 0, 0, 0, //
  1, 0, 0, 0, 0, //
  0, 0, 1, 0, 0, //
]);

/// 15 elemanlı seviye listesi (indeks = bölge kimliği, 0 = cilt).
List<double> _levelList(Map<String, int> levels) {
  final out = List<double>.filled(15, 0);
  levels.forEach((slug, lv) {
    final id = bodyMapRegionId(slug);
    if (id > 0) out[id] = lv.clamp(0, 3).toDouble();
  });
  return out;
}

/// 15 elemanlı seçim bayrakları (indeks = bölge kimliği; 1 = seçili).
List<double> _selectedList(Set<int> ids) => [for (var i = 0; i < 15; i++) ids.contains(i) ? 1 : 0];

@immutable
class _BodyMapColors {
  const _BodyMapColors(this.style, this.accent, this.base, this.off, this.offFloor);

  factory _BodyMapColors.of(MfTheme t) {
    final dark = t.brightness == Brightness.dark;
    return _BodyMapColors(
      t.bodyMapStyle,
      t.accent,
      // Heykel taşı (Canlı): koyu zeminde açık gri, açık zeminde orta gri.
      dark ? const Color(0xFFA8AAA9) : const Color(0xFF8C908E),
      // Boş noktalar: ışık değeri saydamlığa çevrilir, en parlak yer yazı rengine yaklaşır.
      t.text,
      // Açık zeminde boş noktaların en düşük opaklığı; dolu noktalara uygulanmaz.
      dark ? 0 : 0.45,
    );
  }

  final BodyMapStyle style;
  final Color accent;
  final Color base;
  final Color off;
  final double offFloor;

  @override
  bool operator ==(Object other) =>
      other is _BodyMapColors &&
      other.style == style &&
      other.accent == accent &&
      other.base == base &&
      other.off == off &&
      other.offFloor == offFloor;

  @override
  int get hashCode => Object.hash(style, accent, base, off, offFloor);
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.shader,
    required this.frames,
    required this.frame,
    required this.levels,
    required this.selected,
    required this.pulse,
    required this.colors,
  }) : super(repaint: pulse);

  final ui.FragmentShader shader;
  final BodyMapFrames frames;
  final int frame;
  final List<double> levels;
  final List<double> selected;
  final Animation<double> pulse;
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
    f(colors.offFloor);
    levels.forEach(f);
    selected.forEach(f);
    f(selected.any((x) => x > 0) ? 1 : 0);
    f(pulse.value);
    shader
      // Aynı paketli doku iki kez bağlanır: ışık bilineer, kimlik en yakın komşu.
      ..setImageSampler(0, frames.images[frame], filterQuality: FilterQuality.low)
      ..setImageSampler(1, frames.images[frame], filterQuality: FilterQuality.none);

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
      old.pulse != pulse ||
      !listEquals(old.levels, levels) ||
      !listEquals(old.selected, selected);
}
