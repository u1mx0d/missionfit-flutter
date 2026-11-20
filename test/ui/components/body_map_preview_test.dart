// Maket önizlemesi: BODY_MAP_PREVIEW_DIR verilirse dört tema (Mono/Canlı × açık/koyu)
// için 000 ve 036 karelerini tema zemininde PNG olarak yazar. Verilmezse atlanır.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/ui/components/body_map/body_map.dart';
import 'package:missionfit/ui/components/body_map/body_map_frames.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

const _levels = {
  'chest': 3,
  'lats': 3,
  'quads': 3,
  'shoulders': 2,
  'abs': 1,
  'biceps': 0,
  'triceps': 0,
  'forearms': 0,
  'obliques': 0,
  'traps': 0,
  'lower_back': 0,
  'glutes': 0,
  'hamstrings': 0,
  'calves': 0,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dir = Platform.environment['BODY_MAP_PREVIEW_DIR'];

  late BodyMapFrames frames;
  ui.FragmentProgram? program;

  setUpAll(() async {
    frames = await BodyMapFrames.load(rootBundle);
    try {
      program = await ui.FragmentProgram.fromAsset('shaders/body_map.frag');
    } catch (_) {
      program = null;
    }
  });

  tearDownAll(() => frames.dispose());

  for (final family in ThemeFamily.values) {
    for (final b in Brightness.values) {
      testWidgets('önizleme ${family.name} ${b.name}', (tester) async {
        if (dir == null || program == null) {
          markTestSkipped('BODY_MAP_PREVIEW_DIR yok ya da shader yüklenemedi');
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
                    child: ColoredBox(
                      color: theme.background,
                      child: const SizedBox(
                        width: 360,
                        height: 720,
                        child: BodyMap(levels: _levels),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        Future<void> save(String name) async {
          await tester.runAsync(() async {
            final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
            final png = await img.toByteData(format: ui.ImageByteFormat.png);
            img.dispose();
            final f = File('$dir/${family.name}-${b.name}-$name.png');
            await f.parent.create(recursive: true);
            await f.writeAsBytes(png!.buffer.asUint8List());
          });
        }

        await save('000');
        // Ekran okuyucu artırması 90° döndürür; azaltılmış harekette anında.
        final handle = tester.ensureSemantics();
        for (var i = 0; i < 2; i++) {
          tester.semantics.increase(find.semantics.byLabel('Kas haritası'));
          await tester.pump();
        }
        handle.dispose();
        final state = tester.state<BodyMapState>(find.byType(BodyMap));
        expect(state.frame, 36);
        await save('036');
      });
    }
  }
}
