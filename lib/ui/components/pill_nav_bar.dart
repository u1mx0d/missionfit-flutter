import 'package:material_ui/material_ui.dart';

import 'dot_grid.dart';

class PillNavItem {
  const PillNavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

const pillNavHeight = 64.0;
const pillNavInset = 16.0;
const _animation = Duration(milliseconds: 250);

/// Ekranın altında kenarlardan 16 px içeride yüzen hap şeklinde sekme çubuğu.
/// Aktif öğe ikon + etiketle vurgu renginde bir hapta; diğerleri yalnızca ikon.
/// Yerleşim bir [Stack] içinde kullanılır.
class PillNavBar extends StatelessWidget {
  const PillNavBar({required this.index, required this.onTap, required this.items, super.key});
  final int index;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: pillNavInset,
      right: pillNavInset,
      bottom: pillNavInset + bottom,
      height: pillNavHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(pillNavHeight),
          border: Border.all(color: t.border),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _Item(item: items[i], active: i == index, onTap: () => onTap(i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.active, required this.onTap});
  final PillNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final color = active ? t.onAccent : t.textMuted;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _animation,
          curve: Curves.easeOutCubic,
          height: pillNavHeight - 16,
          constraints: const BoxConstraints(minWidth: 48),
          padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
          decoration: BoxDecoration(
            color: active ? t.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(pillNavHeight),
          ),
          child: AnimatedSize(
            duration: _animation,
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: color),
                if (active) ...[
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
