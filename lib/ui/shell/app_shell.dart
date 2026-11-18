import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../components/pill_nav_bar.dart';

const shellTabs = [
  PillNavItem(label: 'Bugün', icon: Icons.home),
  PillNavItem(label: 'Antrenman', icon: Icons.fitness_center),
  PillNavItem(label: 'Kalori', icon: Icons.restaurant),
  PillNavItem(label: 'Görevler', icon: Icons.check_circle),
  PillNavItem(label: 'Profil', icon: Icons.person),
];

/// 5 dallı kabuk: tema zemini + dal içerikleri + yüzen hap çubuğu.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Ekranlar, yüzen çubuğun altında kalmasın diye alt boşluğu otomatik alır.
    final barSpace = pillNavHeight + pillNavInset * 2;
    return Stack(
      children: [
        MfBackground(
          child: MediaQuery(
            data: mq.copyWith(padding: mq.padding.copyWith(bottom: mq.padding.bottom + barSpace)),
            child: navigationShell,
          ),
        ),
        PillNavBar(
          index: navigationShell.currentIndex,
          items: shellTabs,
          onTap: (i) =>
              navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        ),
      ],
    );
  }
}
