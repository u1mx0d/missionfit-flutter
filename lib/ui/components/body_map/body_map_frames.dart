/// Maket kareleri: 72 ışıklı görüntü + 72 bölge kimliği haritası.
/// Bir kez çözülür, sağlayıcıda tutulur, sağlayıcı kapanınca bırakılır.
library;

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dir = 'assets/body_map';
const _shaderAsset = 'shaders/body_map.frag';

class BodyMapFrames {
  BodyMapFrames._(
    this._idBytes, {
    required this.width,
    required this.height,
    required this.stepDegrees,
    required this.shades,
    required this.ids,
  });

  /// Kare boyutu (px), manifestten.
  final int width;
  final int height;
  final double stepDegrees;

  /// Işıklı gri görüntüler (şeffaf zemin).
  final List<ui.Image> shades;

  /// Kimlik haritaları (R = G = B = kimlik × 17).
  final List<ui.Image> ids;

  /// Her kare için piksel başına bir bayt: bölge kimliği (0 cilt, 1–14, 15 boş).
  final List<Uint8List> _idBytes;

  int get frameCount => shades.length;

  static Future<BodyMapFrames> load(AssetBundle bundle) async {
    final manifest =
        jsonDecode(await bundle.loadString('$_dir/manifest.json')) as Map<String, dynamic>;
    final count = manifest['frames'] as int;
    final width = manifest['width'] as int;
    final height = manifest['height'] as int;
    final step = (manifest['stepDegrees'] as num).toDouble();

    Future<ui.Image> decode(String path) async {
      final data = await bundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    }

    Future<(ui.Image, ui.Image, Uint8List)> frame(int i) async {
      final n = i.toString().padLeft(3, '0');
      final (shade, id) = await (decode('$_dir/shade_$n.webp'), decode('$_dir/id_$n.png')).wait;
      final rgba = (await id.toByteData())!.buffer.asUint8List();
      final bytes = Uint8List(id.width * id.height);
      for (var p = 0; p < bytes.length; p++) {
        // Kırmızı kanal = kimlik × 17; yuvarlayarak güvenle böl.
        bytes[p] = (rgba[p * 4] + 8) ~/ 17;
      }
      return (shade, id, bytes);
    }

    final all = await Future.wait([for (var i = 0; i < count; i++) frame(i)]);
    return BodyMapFrames._(
      [for (final f in all) f.$3],
      width: width,
      height: height,
      stepDegrees: step,
      shades: [for (final f in all) f.$1],
      ids: [for (final f in all) f.$2],
    );
  }

  /// Görüntünün [size] içine sığdırılıp ortalandığı dikdörtgen (BoxFit.contain).
  Rect destRect(Size size) {
    final s = (size.width / width) < (size.height / height)
        ? size.width / width
        : size.height / height;
    final w = width * s, h = height * s;
    return Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h);
  }

  /// [localPos] noktasındaki bölge kimliği (0 cilt, 1–14 bölge); boşta −1.
  int regionAt(int frame, Offset localPos, Size size) {
    final r = destRect(size);
    if (r.isEmpty || !r.contains(localPos)) return -1;
    final x = ((localPos.dx - r.left) / r.width * width).floor().clamp(0, width - 1);
    final y = ((localPos.dy - r.top) / r.height * height).floor().clamp(0, height - 1);
    final id = _idBytes[frame % frameCount][y * width + x];
    return id > 14 ? -1 : id;
  }

  void dispose() {
    for (final i in shades) {
      i.dispose();
    }
    for (final i in ids) {
      i.dispose();
    }
  }
}

/// Kareler uygulama boyunca bir kez çözülür.
final bodyMapFramesProvider = FutureProvider<BodyMapFrames>((ref) async {
  final frames = await BodyMapFrames.load(rootBundle);
  ref.onDispose(frames.dispose);
  return frames;
});

/// Maket shader'ı; yüklenemezse (ör. test ortamı) null, bileşen düz kareye düşer.
final bodyMapProgramProvider = FutureProvider<ui.FragmentProgram?>((ref) async {
  try {
    return await ui.FragmentProgram.fromAsset(_shaderAsset);
  } catch (_) {
    return null;
  }
});
