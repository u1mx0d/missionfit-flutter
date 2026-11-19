import 'package:material_ui/material_ui.dart';

import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';

/// Odak modunun alttaki hareket şeridi.

bool _mono(MfTheme t) => t.family == ThemeFamily.mono;

class RailItem {
  const RailItem({required this.id, required this.name, required this.complete});
  final String id;
  final String name;
  final bool complete;
}

/// Alttaki hareket şeridi: sırasız geçiş ve "+ Ekle".
class ExerciseRail extends StatelessWidget {
  const ExerciseRail({
    required this.items,
    required this.currentId,
    required this.onSelect,
    required this.onAdd,
    super.key,
  });

  final List<RailItem> items;
  final String? currentId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = _mono(t);

    Widget chip({
      required Key key,
      required String text,
      required bool on,
      required VoidCallback onTap,
      IconData? icon,
      String? semantic,
    }) {
      final bg = on ? t.text : (mono ? Colors.transparent : t.surfaceMuted);
      final fg = on ? t.background : t.text;
      return Padding(
        key: key,
        padding: const EdgeInsets.only(right: 6),
        child: Semantics(
          button: true,
          selected: on,
          label: semantic,
          child: Material(
            color: bg,
            shape: StadiumBorder(side: mono && !on ? BorderSide(color: t.border) : BorderSide.none),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: fg,
                        fontSize: 13,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // "+ Ekle" sağda sabit durur; uzun listede de her an erişilir.
    return Row(
      key: const Key('rail'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final it in items)
                  _KeepVisible(
                    active: it.id == currentId,
                    child: chip(
                      key: Key('rail-${it.id}'),
                      text: it.name,
                      on: it.id == currentId,
                      icon: it.complete ? Icons.check_rounded : null,
                      semantic: it.complete ? '${it.name}, tamamlandı' : null,
                      onTap: () => onSelect(it.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
        chip(key: const Key('rail-add'), text: '+ Ekle', on: false, onTap: onAdd),
      ],
    );
  }
}

/// Seçili çip şeritte görünür alana kaydırılır.
class _KeepVisible extends StatefulWidget {
  const _KeepVisible({required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<_KeepVisible> createState() => _KeepVisibleState();
}

class _KeepVisibleState extends State<_KeepVisible> {
  void _reveal() {
    if (!widget.active) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final still = MediaQuery.disableAnimationsOf(context);
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: still ? Duration.zero : const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(_KeepVisible old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _reveal();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
