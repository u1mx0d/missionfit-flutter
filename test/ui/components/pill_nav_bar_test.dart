import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/ui/components/pill_nav_bar.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

const _items = [
  PillNavItem(label: 'Bugün', icon: Icons.home),
  PillNavItem(label: 'Antrenman', icon: Icons.fitness_center),
  PillNavItem(label: 'Kalori', icon: Icons.restaurant),
];

Widget _host(int index, ValueChanged<int> onTap) => MaterialApp(
  theme: buildThemeData(MfTheme.build(ThemeFamily.canli, Brightness.light, AccentColor.yesil)),
  home: Scaffold(
    body: Stack(
      children: [PillNavBar(index: index, onTap: onTap, items: _items)],
    ),
  ),
);

void main() {
  testWidgets('PillNavBar: yalnızca aktif sekmenin etiketi görünür', (tester) async {
    await tester.pumpWidget(_host(1, (_) {}));
    expect(find.text('Antrenman'), findsOneWidget);
    expect(find.text('Bugün'), findsNothing);
    expect(find.text('Kalori'), findsNothing);
  });

  testWidgets('PillNavBar: dokununca onTap doğru index ile çağrılır', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(0, taps.add));
    await tester.tap(find.byIcon(Icons.restaurant));
    await tester.tap(find.byIcon(Icons.fitness_center));
    expect(taps, [2, 1]);
  });

  testWidgets('PillNavBar: etiketsiz sekmelerin semantics etiketi var', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(0, (_) {}));
    expect(find.bySemanticsLabel('Antrenman'), findsOneWidget);
    expect(find.bySemanticsLabel('Kalori'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('PillNavBar: kenarlardan 16 px içeride yüzer', (tester) async {
    await tester.pumpWidget(_host(0, (_) {}));
    final rect = tester.getRect(find.byType(PillNavBar));
    expect(rect.left, 16);
    expect(tester.view.physicalSize.width / tester.view.devicePixelRatio - rect.right, 16);
  });
}
