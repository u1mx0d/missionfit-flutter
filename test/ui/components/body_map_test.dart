import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/domain/body_map.dart';
import 'package:missionfit/ui/components/body_map/body_map.dart';
import 'package:missionfit/ui/components/body_map/body_map_frames.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

/// Ön karede (000) sol göğüs kasının ortası, kimlik haritasından ölçülmüş
/// piksel (150, 180); oran manifestteki boyuta göre hesaplanır.
const _chestPx = Offset(150, 180);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BodyMapFrames frames;
  late Map<String, dynamic> manifest;
  ui.FragmentProgram? program;

  setUpAll(() async {
    manifest = jsonDecode(
      await rootBundle.loadString('assets/body_map/manifest.json'),
    ) as Map<String, dynamic>;
    frames = await BodyMapFrames.load(rootBundle);
    try {
      program = await ui.FragmentProgram.fromAsset('shaders/body_map.frag');
    } catch (_) {
      program = null; // Shader bu ortamda yoksa boyama testi atlanır.
    }
  });

  tearDownAll(() => frames.dispose());

  Offset chestRatio() =>
      Offset(_chestPx.dx / (manifest['width'] as int), _chestPx.dy / (manifest['height'] as int));

  group('BodyMapFrames', () {
    test('gerçek varlıklardan 72 kare yükler', () {
      expect(frames.frameCount, 72);
      // Işıklı görüntü ve kimlik kare başına tek dokuda paketlenir.
      expect(frames.images, hasLength(72));
      expect(frames.images.first.width, manifest['width']);
      expect(frames.images.first.height, manifest['height']);
    });

    test('paketli doku: G = kimlik × 17, B = alfa (sis < 0,5 boş), A opak', () async {
      final data = (await frames.images[0].toByteData())!;
      int at(int x, int y, int c) => data.getUint8((y * 360 + x) * 4 + c);
      expect(at(150, 180, 1), 17); // göğüs
      expect(at(150, 180, 2), greaterThan(127));
      expect(at(150, 180, 3), 255);
      expect(at(1, 1, 1), 255); // boş
      expect(at(1, 1, 2), 0);
      // Kimliği boş olan her pikselde alfa sıfırlanmış olmalı ya da ≥ 0,5 kalmış olmalı.
      for (var p = 0; p < 360 * 720; p++) {
        final b = data.getUint8(p * 4 + 2);
        expect(b == 0 || b >= 128, isTrue);
      }
    });

    test('bölge piksel sayıları: kanat (lats) en çok arka yüzde görünür', () {
      expect(frames.regionPixels, hasLength(72));
      // Ön karede göğüs görünür.
      expect(frames.regionPixels[0][1], greaterThan(500));
      final lats = bodyMapRegionId('lats');
      final best = bestFrameFor(frames.regionPixels, [lats]);
      // Arka yüz: 180° ± 60° (kare 24–48).
      expect(bodyMapViewName(best * 5.0), anyOf('Arka', 'Sol yan', 'Sağ yan'));
      expect((best * 5 - 180).abs(), lessThanOrEqualTo(60));
      // Ön karede kanat görünmez sayılır, en iyi karede görünür.
      expect(regionsVisibleIn(frames.regionPixels, best, [lats]), isTrue);
    });

    test('regionAt: tek piksellik kırıntı sonucu değiştirmez (5×5 çoğunluk)', () {
      // Ön karede (111, 181) tek başına bir biceps (3) pikseli; çevresi çoğunlukla cilt.
      const size = Size(360, 720);
      expect(frames.regionAt(0, const Offset(111.5, 181.5), size), 0);
      // (134, 601) baldır kırıntısı: cilt 12, boş 12 → cilt (boş yalnız en kalabalıksa kazanır).
      expect(frames.regionAt(0, const Offset(134.5, 601.5), size), 0);
    });

    test('regionAt: ön karede göğüs → 1, köşe → −1', () {
      const size = Size(180, 360);
      final r = chestRatio();
      expect(frames.regionAt(0, Offset(r.dx * size.width, r.dy * size.height), size), 1);
      expect(frames.regionAt(0, const Offset(1, 1), size), -1);
      expect(frames.regionAt(0, const Offset(-5, 10), size), -1);
    });

    test('regionAt: geniş kutuda görüntü ortalanır (contain)', () {
      // 400×360: görüntü 180×360 olarak 110 px sağa kayar.
      const size = Size(400, 360);
      final r = chestRatio();
      final p = Offset(110 + r.dx * 180, r.dy * 360);
      expect(frames.regionAt(0, p, size), 1);
      expect(frames.regionAt(0, Offset(r.dx * 180, r.dy * 360), size), -1);
    });
  });

  group('keepAliveAfterLastListener', () {
    testWidgets('son dinleyiciden 30 sn sonra bırakır, arada dönülürse tutar', (tester) async {
      var disposed = 0;
      final p = Provider.autoDispose<int>((ref) {
        keepAliveAfterLastListener(ref, bodyMapKeepAlive);
        ref.onDispose(() => disposed++);
        return 1;
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      var sub = c.listen(p, (_, _) {});
      sub.close();
      await tester.pump(const Duration(seconds: 20));
      expect(disposed, 0);
      sub = c.listen(p, (_, _) {}); // geri dönüldü
      await tester.pump(const Duration(seconds: 60));
      expect(disposed, 0);
      sub.close();
      await tester.pump(const Duration(seconds: 31));
      expect(disposed, 1);
    });
  });

  group('tema', () {
    test('Mono → dots, Canlı → glow; copyWith ve lerp korur', () {
      for (final b in Brightness.values) {
        final mono = MfTheme.build(ThemeFamily.mono, b, AccentColor.kirmizi);
        final canli = MfTheme.build(ThemeFamily.canli, b, AccentColor.yesil);
        expect(mono.bodyMapStyle, BodyMapStyle.dots);
        expect(canli.bodyMapStyle, BodyMapStyle.glow);
        expect(mono.copyWith().bodyMapStyle, BodyMapStyle.dots);
        expect(mono.copyWith(bodyMapStyle: BodyMapStyle.glow).bodyMapStyle, BodyMapStyle.glow);
        expect(mono.lerp(canli, 0.2).bodyMapStyle, BodyMapStyle.dots);
        expect(mono.lerp(canli, 0.8).bodyMapStyle, BodyMapStyle.glow);
      }
    });
  });

  group('BodyMap', () {
    Widget wrap(Widget child, {bool reduce = false, BodyMapFrames? loaded}) => ProviderScope(
      overrides: [
        bodyMapFramesProvider.overrideWith((ref) => loaded ?? frames),
        // Test ortamında shader yok: düz ışıklı kareye düşer.
        bodyMapProgramProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: buildThemeData(
          MfTheme.build(ThemeFamily.mono, Brightness.dark, AccentColor.kirmizi),
        ),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 200, height: 400, child: child),
            ),
          ),
        ),
      ),
    );

    BodyMapState state(WidgetTester t) => t.state<BodyMapState>(find.byType(BodyMap));

    testWidgets('disableAnimations: dönmez, açı 0 kalır', (tester) async {
      await tester.pumpWidget(wrap(const BodyMap(levels: {'chest': 3}), reduce: true));
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        expect(state(tester).angle, 0);
      }
      expect(state(tester).frame, 0);
    });

    testWidgets('ilk gösterimde bir tur döner ve 000\'da durur', (tester) async {
      await tester.pumpWidget(wrap(const BodyMap(levels: {})));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(state(tester).angle, greaterThan(0));
      await tester.pumpAndSettle();
      expect(state(tester).frame, 0);
    });

    test('görünüm adları', () {
      expect(bodyMapViewName(0), 'Ön');
      expect(bodyMapViewName(90), 'Sol yan');
      expect(bodyMapViewName(180), 'Arka');
      expect(bodyMapViewName(270), 'Sağ yan');
      expect(bodyMapViewName(-90), 'Sağ yan');
      expect(bodyMapViewName(350), 'Ön');
    });

    testWidgets('dokunuş açılış turunu durdurur', (tester) async {
      await tester.pumpWidget(wrap(const BodyMap(levels: {})));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      final stopped = state(tester).angle;
      expect(stopped, greaterThan(0));
      await tester.pump(const Duration(seconds: 1));
      expect(state(tester).angle, stopped);
    });

    testWidgets('gizli sekmede (TickerMode kapalı) kareler dinlenmez', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bodyMapFramesProvider.overrideWith((ref) {
              builds++;
              return frames;
            }),
            bodyMapProgramProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: buildThemeData(
              MfTheme.build(ThemeFamily.mono, Brightness.dark, AccentColor.kirmizi),
            ),
            home: const TickerMode(
              enabled: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: 200, child: BodyMap(levels: {})),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(builds, 0);
      expect(find.byType(RawImage), findsNothing);
      expect(tester.getSize(find.byType(BodyMap)), const Size(200, 400));
    });

    testWidgets('sürükleme açıyı değiştirir', (tester) async {
      await tester.pumpWidget(wrap(const BodyMap(levels: {}), reduce: true));
      await tester.pump();
      await tester.drag(find.byType(BodyMap), const Offset(-60, 0));
      await tester.pumpAndSettle();
      expect(state(tester).angle, isNot(0));
      expect(state(tester).frame, isNot(0));
    });

    testWidgets('göğse dokununca onRegionTap(chest)', (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(wrap(BodyMap(levels: const {}, onRegionTap: taps.add), reduce: true));
      await tester.pump();
      final r = chestRatio();
      await tester.tapAt(Offset(r.dx * 200, r.dy * 400));
      await tester.pump();
      expect(taps, ['chest']);
      // Boş alana dokunuş bir şey çağırmaz.
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      expect(taps, ['chest']);
    });

    testWidgets('kas olmayan yere dokunuş onBackgroundTap', (tester) async {
      final taps = <String>[];
      var bg = 0;
      await tester.pumpWidget(
        wrap(
          BodyMap(levels: const {}, onRegionTap: taps.add, onBackgroundTap: () => bg++),
          reduce: true,
        ),
      );
      await tester.pump();
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      expect(bg, 1);
      expect(taps, isEmpty);
    });

    group('seçim', () {
      Widget map(Set<String> sel, {String? name}) =>
          BodyMap(levels: const {}, selectedRegions: sel, selectedName: name);

      testWidgets('azaltılmış harekette görünmeyen kas için en iyi kareye atlar', (tester) async {
        await tester.pumpWidget(wrap(map(const {}), reduce: true));
        await tester.pump();
        expect(state(tester).frame, 0);
        await tester.pumpWidget(wrap(map(const {'lats'}), reduce: true));
        await tester.pump(); // post-frame: atlama
        await tester.pump();
        final best = bestFrameFor(frames.regionPixels, [bodyMapRegionId('lats')]);
        expect(state(tester).frame, best);
        // Animasyonsuz: açı hemen hedefte, ara kare yok.
        expect(state(tester).angle, angleTowardFrame(0, best));
      });

      testWidgets('hareket açıkken en iyi kareye yumuşakça döner', (tester) async {
        await tester.pumpWidget(wrap(map(const {})));
        await tester.pumpAndSettle(); // açılış turu biter, 000
        await tester.pumpWidget(wrap(map(const {'lats'})));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final best = bestFrameFor(frames.regionPixels, [bodyMapRegionId('lats')]);
        expect(state(tester).frame, isNot(best)); // henüz yolda
        await tester.pump(const Duration(milliseconds: 600));
        expect(state(tester).frame, best);
      });

      testWidgets('görünen kas seçilince dönmez', (tester) async {
        await tester.pumpWidget(wrap(map(const {}), reduce: true));
        await tester.pump();
        await tester.pumpWidget(wrap(map(const {'chest'}), reduce: true));
        await tester.pump();
        await tester.pump();
        expect(state(tester).frame, 0);
      });

      testWidgets('ekran okuyucu değeri seçili kası söyler', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(wrap(map(const {'chest'}, name: 'Göğüs kası'), reduce: true));
        await tester.pump();
        expect(
          tester.getSemantics(find.bySemanticsLabel('Kas haritası')),
          matchesSemantics(
            label: 'Kas haritası',
            value: 'Ön. Seçili: Göğüs kası',
            increasedValue: 'Sol yan. Seçili: Göğüs kası',
            decreasedValue: 'Sağ yan. Seçili: Göğüs kası',
            isImage: true,
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );
        handle.dispose();
      });
    });

    testWidgets('Semantics etiketi parametreden gelir', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const BodyMap(levels: {}, semanticLabel: 'Bu haftanın kasları'), reduce: true),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Bu haftanın kasları'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('ekran okuyucu: değer görünüm adı, artır 90° döndürür', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(wrap(const BodyMap(levels: {}), reduce: true));
      await tester.pump();
      tester.semantics.increase(find.semantics.byLabel('Kas haritası'));
      await tester.pump();
      expect(state(tester).angle, 90);
      expect(state(tester).frame, 18);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Kas haritası')),
        matchesSemantics(
          label: 'Kas haritası',
          value: 'Sol yan',
          increasedValue: 'Arka',
          decreasedValue: 'Ön',
          isImage: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('kareler yüklenirken yerini koruyan boş kutu', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bodyMapFramesProvider.overrideWith((ref) => Completer<BodyMapFrames>().future),
            bodyMapProgramProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: buildThemeData(
              MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.yesil),
            ),
            home: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 200, child: BodyMap(levels: {})),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byType(BodyMap)), const Size(200, 400));
      expect(find.byType(RawImage), findsNothing);
    });

    for (final family in ThemeFamily.values) {
      for (final b in Brightness.values) {
        testWidgets('shader: göğüs vurgu renginde, köşe boş (${family.name} ${b.name})', (
          tester,
        ) async {
          if (program == null) {
            markTestSkipped('FragmentProgram bu ortamda yüklenemedi');
            return;
          }
          final theme = MfTheme.build(family, b, defaultAccentFor(family));
          final key = GlobalKey();
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                bodyMapFramesProvider.overrideWith((ref) => frames),
                bodyMapProgramProvider.overrideWith((ref) async => program),
              ],
              child: MaterialApp(
                theme: buildThemeData(theme),
                home: MediaQuery(
                  data: const MediaQueryData(disableAnimations: true),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: RepaintBoundary(
                      key: key,
                      child: const SizedBox(
                        width: 360,
                        height: 720,
                        child: BodyMap(levels: {'chest': 3}),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          final rgba = (await tester.runAsync(() async {
            final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
                .toImage();
            final bytes = await img.toByteData();
            img.dispose();
            return bytes!;
          }))!;
          List<int> px(int x, int y) => [
            for (var c = 0; c < 4; c++) rgba.getUint8((y * 360 + x) * 4 + c),
          ];
          // Göğüs bölgesinde birkaç noktadan en az biri vurguya yakın (nokta aralarında boşluk olabilir).
          final accent = theme.accent;
          var hit = false;
          for (var dy = -4; dy <= 4 && !hit; dy++) {
            for (var dx = -4; dx <= 4 && !hit; dx++) {
              final p = px(_chestPx.dx.toInt() + dx, _chestPx.dy.toInt() + dy);
              final dominant = accent.g > accent.r ? p[1] > p[0] + 20 : p[0] > p[1] + 20;
              hit = p[3] > 100 && dominant;
            }
          }
          expect(hit, isTrue);
          expect(px(1, 1)[3], 0);
        });
      }
    }

    // Açık temada maket koyu bir figür değil: Canlı'da taş açık, siluet kenarı zemine ≥ 3:1.
    testWidgets('açık Canlı: açık taş, siluet kenarı zemine ≥ 3:1', (tester) async {
      if (program == null) {
        markTestSkipped('FragmentProgram bu ortamda yüklenemedi');
        return;
      }
      final theme = MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.yesil);
      final rgba = await _renderOn(tester, frames, program!, theme, const {'chest': 3});
      final bg = theme.background.computeLuminance();
      double lum(int o) => Color.fromARGB(
        255,
        rgba.getUint8(o),
        rgba.getUint8(o + 1),
        rgba.getUint8(o + 2),
      ).computeLuminance();
      double ratio(double a, double b) =>
          (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
      // Cilt (kimlik 0) piksellerinin ortanca parlaklığı yüksek.
      final skin = <double>[];
      for (var y = 0; y < 720; y += 2) {
        for (var x = 0; x < 360; x += 2) {
          final id = frames.regionAt(0, Offset(x + 0.5, y + 0.5), const Size(360, 720));
          if (id == 0) skin.add(lum((y * 360 + x) * 4));
        }
      }
      skin.sort();
      expect(skin[skin.length ~/ 2], greaterThan(0.45));
      // Siluet kenarı: her satırda soldan zeminden ayrılan ilk pikselden sonraki 4 pikselde
      // zemine ≥ 3:1 bir kenar pikseli olur.
      var rows = 0, ok = 0;
      for (var y = 60; y < 700; y += 10) {
        var x = 0;
        while (x < 356 && ratio(lum((y * 360 + x) * 4), bg) < 1.15) {
          x++;
        }
        if (x >= 356) continue;
        rows++;
        var best = 0.0;
        for (var k = 0; k < 4; k++) {
          best = max(best, ratio(lum((y * 360 + x + k) * 4), bg));
        }
        if (best >= 3) ok++;
      }
      expect(rows, greaterThan(40));
      expect(ok / rows, greaterThan(0.9));
    });

    testWidgets('koyu ve açık Mono: boş noktalar tema rengiyle ayrışır', (tester) async {
      if (program == null) {
        markTestSkipped('FragmentProgram bu ortamda yüklenemedi');
        return;
      }
      for (final b in Brightness.values) {
        final theme = MfTheme.build(ThemeFamily.mono, b, AccentColor.kirmizi);
        final rgba = await _renderOn(tester, frames, program!, theme, const {});
        // Ön karede kafa bölgesinde en az bir nokta zemine ≥ 3:1.
        final bg = theme.background.computeLuminance();
        var best = 0.0;
        for (var y = 30; y < 80; y++) {
          for (var x = 160; x < 200; x++) {
            final o = (y * 360 + x) * 4;
            final l = Color.fromARGB(
              255,
              rgba.getUint8(o),
              rgba.getUint8(o + 1),
              rgba.getUint8(o + 2),
            ).computeLuminance();
            final r = (max(l, bg) + 0.05) / (min(l, bg) + 0.05);
            if (r > best) best = r;
          }
        }
        expect(best, greaterThanOrEqualTo(3), reason: b.name);
      }
    });
  });

  group('shader seçimi', () {
    Future<ByteData?> render(
      WidgetTester tester,
      ThemeFamily family, {
      Map<String, int> levels = const {},
      Set<String> selected = const {},
    }) async {
      final theme = MfTheme.build(family, Brightness.dark, defaultAccentFor(family));
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            bodyMapFramesProvider.overrideWith((ref) => frames),
            bodyMapProgramProvider.overrideWith((ref) async => program),
          ],
          child: MaterialApp(
            theme: buildThemeData(theme),
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                    width: 360,
                    height: 720,
                    child: BodyMap(levels: levels, selectedRegions: selected),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      return tester.runAsync(() async {
        final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage();
        final bytes = await img.toByteData();
        img.dispose();
        return bytes!;
      });
    }

    /// (x, y) çevresindeki 9×9 pencerede piksel parlaklıklarının toplamı (alfa × RGB).
    int energy(ByteData rgba, int cx, int cy) {
      var sum = 0;
      for (var y = cy - 4; y <= cy + 4; y++) {
        for (var x = cx - 4; x <= cx + 4; x++) {
          final o = (y * 360 + x) * 4;
          sum += rgba.getUint8(o) + rgba.getUint8(o + 1) + rgba.getUint8(o + 2);
        }
      }
      return sum;
    }

    /// Ön karede karın kasının ortası (kimlik haritasından aranır).
    Offset absCenter() {
      final abs = bodyMapRegionId('abs');
      for (var y = 250; y < 400; y++) {
        for (var x = 160; x < 200; x++) {
          if (frames.regionAt(0, Offset(x + 0.5, y + 0.5), const Size(360, 720)) == abs) {
            return Offset(x.toDouble(), y + 10.0);
          }
        }
      }
      throw StateError('karın bulunamadı');
    }

    for (final family in ThemeFamily.values) {
      testWidgets('seçili kas seviyesi 0 olsa da vurguda yanar, diğerleri sönükleşir '
          '(${family.name})', (tester) async {
        if (program == null) {
          markTestSkipped('FragmentProgram bu ortamda yüklenemedi');
          return;
        }
        final c = _chestPx;
        final a = absCenter();
        final plain = (await render(tester, family, levels: const {'abs': 3}))!;
        final sel = (await render(
          tester,
          family,
          levels: const {'abs': 3},
          selected: const {'chest'},
        ))!;
        // Göğüs (seviye 0) seçilince vurgu renginde yanar.
        final accent = MfTheme.build(family, Brightness.dark, defaultAccentFor(family)).accent;
        int accentPixels(ByteData rgba) {
          var n = 0;
          for (var y = c.dy.toInt() - 6; y <= c.dy.toInt() + 6; y++) {
            for (var x = c.dx.toInt() - 6; x <= c.dx.toInt() + 6; x++) {
              final o = (y * 360 + x) * 4;
              final r = rgba.getUint8(o), g = rgba.getUint8(o + 1);
              final dominant = accent.g > accent.r ? g > r + 20 : r > g + 20;
              if (rgba.getUint8(o + 3) > 100 && dominant) n++;
            }
          }
          return n;
        }

        // (Canlı'da komşu karının ışıması birkaç pikseli zaten boyayabilir.)
        expect(accentPixels(sel), greaterThan(accentPixels(plain) + 20));
        // Seçili olmayan karın (seviye 3) sönükleşir.
        expect(
          energy(sel, a.dx.toInt(), a.dy.toInt()),
          lessThan(energy(plain, a.dx.toInt(), a.dy.toInt())),
        );
      });
    }
  });

  test('packFramePixels: ışık × alfa, kimlik, sis eşiği, 4 bit kimlik', () {
    // 3 piksel: bölge 1 (alfa 255), bölge 14 (alfa 100 → boş), boş 15.
    final shade = Uint8List.fromList([200, 0, 0, 255, 90, 0, 0, 100, 0, 0, 0, 0]);
    final id = Uint8List.fromList([17, 0, 0, 255, 238, 0, 0, 255, 255, 0, 0, 255]);
    final (packed, nibbles, counts) = packFramePixels(shade, id, 3);
    expect(packed, [200, 17, 255, 255, 0, 238, 0, 255, 0, 255, 0, 255]);
    expect(nibbles, [1 | 14 << 4, 15]);
    expect(counts, hasLength(16));
    expect(counts[1], 1);
    expect(counts[14], 1);
    expect(counts[15], 1);
    expect(counts.reduce((a, b) => a + b), 3);
  });
}

/// Maketi tema zemininde (opak) 360 × 720 boyar, RGBA baytlarını döndürür.
Future<ByteData> _renderOn(
  WidgetTester tester,
  BodyMapFrames frames,
  ui.FragmentProgram program,
  MfTheme theme,
  Map<String, int> levels,
) async {
  tester.view
    ..physicalSize = const Size(400, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        bodyMapFramesProvider.overrideWith((ref) => frames),
        bodyMapProgramProvider.overrideWith((ref) async => program),
      ],
      child: MaterialApp(
        theme: buildThemeData(theme),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: theme.background,
                child: SizedBox(width: 360, height: 720, child: BodyMap(levels: levels)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return (await tester.runAsync(() async {
    final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
    final bytes = await img.toByteData();
    img.dispose();
    return bytes!;
  }))!;
}
