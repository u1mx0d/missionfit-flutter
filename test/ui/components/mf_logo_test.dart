import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/ui/components/mf_logo.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildThemeData(MfTheme.build(ThemeFamily.canli, Brightness.dark, AccentColor.yesil)),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('M hücreleri', () {
    expect(mLogoCells.toSet(), {
      (0, 0),
      (0, 1),
      (0, 2),
      (0, 3),
      (0, 4),
      (1, 1),
      (3, 1),
      (4, 0),
      (4, 1),
      (4, 2),
      (4, 3),
      (4, 4),
    });
    expect(mLogoCells.length, 12);
  });

  testWidgets('semantik etiket ve progress 0/1 çizilir', (tester) async {
    for (final p in [0.0, 0.5, 0.9, 1.0]) {
      await tester.pumpWidget(_wrap(MfLogo(progress: p)));
      expect(find.bySemanticsLabel('MissionFit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
