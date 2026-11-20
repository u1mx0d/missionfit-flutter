/// Maket kareleri: 72 ışıklı görüntü + 72 bölge kimliği haritası, kare başına tek
/// dokuda paketlenir. Sağlayıcıda tutulur, maket görünmez olunca bırakılır.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dir = 'assets/body_map';
const _shaderAsset = 'shaders/body_map.frag';

class BodyMapFrames {
  BodyMapFrames._(
    this._idNibbles,
    this.regionPixels, {
    required this.width,
    required this.height,
    required this.stepDegrees,
    required this.images,
  });

  /// Kare boyutu (px), manifestten.
  final int width;
  final int height;
  final double stepDegrees;

  /// Kare başına tek opak RGBA doku (ışıklı görüntü ve kimlik birlikte):
  /// R = ışık × alfa (önceden çarpılmış), G = kimlik × 17, B = alfa, A = 255.
  /// Doku opak tutulur; böylece motorun alfa çarpması kimlik kanalını bozamaz.
  final List<ui.Image> images;

  /// Kare başına piksel başına 4 bit kimlik (0 cilt, 1–14 bölge, 15 boş).
  final List<Uint8List> _idNibbles;

  /// Kare başına bölge piksel sayıları (indeks = kimlik 0–15); paketlerken sayılır.
  /// Listeden seçilen kasın en iyi göründüğü kareyi bulmak için.
  final List<Uint32List> regionPixels;

  int get frameCount => images.length;

  /// Aynı anda çözülen kare sayısı (bellek tepe değerini sınırlar).
  static const loadConcurrency = 8;

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

    Future<Uint8List> pixels(String path) async {
      final img = await decode(path);
      try {
        final data = await img.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
        return data!.buffer.asUint8List();
      } finally {
        img.dispose();
      }
    }

    Future<(ui.Image, Uint8List, Uint32List)> frame(int i) async {
      final n = i.toString().padLeft(3, '0');
      final (shade, id) = await (pixels('$_dir/shade_$n.webp'), pixels('$_dir/id_$n.png')).wait;
      // Piksel paketleme (kare başına ~260 bin piksel) ana isolate'ı kilitlemesin diye
      // ayrı isolate'ta yapılır; ilk açılışta takılma olmaz.
      final (packed, nibbles, counts) = await _packInIsolate(shade, id, width * height);
      final image = await _fromPixels(packed, width, height);
      return (image, nibbles, counts);
    }

    // Sınırlı eşzamanlılık: en çok [loadConcurrency] kare aynı anda.
    final results = List<(ui.Image, Uint8List, Uint32List)?>.filled(count, null);
    var next = 0;
    Future<void> worker() async {
      while (next < count) {
        final i = next++;
        results[i] = await frame(i);
      }
    }

    try {
      await Future.wait([for (var w = 0; w < loadConcurrency; w++) worker()]);
    } catch (_) {
      for (final r in results) {
        r?.$1.dispose();
      }
      rethrow;
    }
    return BodyMapFrames._(
      [for (final r in results) r!.$2],
      [for (final r in results) r!.$3],
      width: width,
      height: height,
      stepDegrees: step,
      images: [for (final r in results) r!.$1],
    );
  }

  static Future<ui.Image> _fromPixels(Uint8List bytes, int w, int h) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, w, h, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }

  int _idAt(int frame, int x, int y) {
    final p = y * width + x;
    final b = _idNibbles[frame][p >> 1];
    return p.isEven ? b & 15 : b >> 4;
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
  /// Tek piksellik kırıntılar sonucu değiştirmesin diye 5×5 pencerede çoğunluk alınır;
  /// boş (15) yalnızca en kalabalıksa kazanır, eşitlikte merkezdeki kimlik öne geçer.
  int regionAt(int frame, Offset localPos, Size size) {
    final r = destRect(size);
    if (r.isEmpty || !r.contains(localPos)) return -1;
    final f = frame % frameCount;
    final cx = ((localPos.dx - r.left) / r.width * width).floor().clamp(0, width - 1);
    final cy = ((localPos.dy - r.top) / r.height * height).floor().clamp(0, height - 1);
    final counts = List<int>.filled(16, 0);
    for (var y = cy - 2; y <= cy + 2; y++) {
      if (y < 0 || y >= height) continue;
      for (var x = cx - 2; x <= cx + 2; x++) {
        if (x < 0 || x >= width) continue;
        counts[_idAt(f, x, y)]++;
      }
    }
    final center = _idAt(f, cx, cy);
    var best = center == 15 ? -1 : center;
    var bestCount = best < 0 ? 0 : counts[best];
    for (var id = 0; id < 15; id++) {
      if (counts[id] > bestCount) {
        best = id;
        bestCount = counts[id];
      }
    }
    if (best < 0 || counts[15] > bestCount) return -1;
    return best;
  }

  void dispose() {
    for (final i in images) {
      i.dispose();
    }
  }
}

/// Işıklı görüntü ve kimlik haritası piksellerinden (düz RGBA) kare dokusunu, 4 bitlik
/// kimlik tablosunu ve bölge başına piksel sayılarını (indeks = kimlik) üretir.
/// Saf fonksiyon: [Isolate.run] içinde çalışır.
(Uint8List, Uint8List, Uint32List) packFramePixels(Uint8List shade, Uint8List id, int px) {
  final packed = Uint8List(px * 4);
  final nibbles = Uint8List((px + 1) >> 1);
  final counts = Uint32List(16);
  for (var p = 0; p < px; p++) {
    final o = p * 4;
    // Kırmızı kanal = kimlik × 17; yuvarlayarak böl.
    final rid = (id[o] + 8) ~/ 17;
    nibbles[p >> 1] |= p.isEven ? rid : rid << 4;
    counts[rid]++;
    // WebP kenarındaki soluk alfa sisi (< 0,5) boş sayılır.
    final a = shade[o + 3] < 128 ? 0 : shade[o + 3];
    packed[o] = shade[o] * a ~/ 255;
    packed[o + 1] = id[o];
    packed[o + 2] = a;
    packed[o + 3] = 255;
  }
  return (packed, nibbles, counts);
}

// Üst düzey: isolate'a gönderilen kapanış yalnızca bu parametreleri taşır (yükleyicinin
// görüntü listesi gibi gönderilemeyen yerel değişkenlerini değil).
Future<(Uint8List, Uint8List, Uint32List)> _packInIsolate(Uint8List shade, Uint8List id, int px) =>
    Isolate.run(() => packFramePixels(shade, id, px));

/// Dinleyici kalmayınca bu süre sonra kareler bırakılır (sekmeler arası hızlı geçişte
/// yeniden çözmemek için).
const bodyMapKeepAlive = Duration(seconds: 30);

/// Dinleyici kalmayınca [delay] sonra sağlayıcıyı bırakır; o arada yeni dinleyici
/// gelirse bırakılmaz.
void keepAliveAfterLastListener(Ref ref, Duration delay) {
  final link = ref.keepAlive();
  Timer? timer;
  ref
    ..onCancel(() => timer = Timer(delay, link.close))
    ..onResume(() => timer?.cancel())
    ..onDispose(() => timer?.cancel());
}

/// Kareler bir kez çözülür; maket görünmez olunca [bodyMapKeepAlive] sonra bırakılır.
final bodyMapFramesProvider = FutureProvider.autoDispose<BodyMapFrames>((ref) async {
  keepAliveAfterLastListener(ref, bodyMapKeepAlive);
  var disposed = false;
  ref.onDispose(() => disposed = true);
  final frames = await BodyMapFrames.load(rootBundle);
  // Yükleme sürerken sağlayıcı kapandıysa dokular hemen bırakılır.
  if (disposed) {
    frames.dispose();
  } else {
    ref.onDispose(frames.dispose);
  }
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
