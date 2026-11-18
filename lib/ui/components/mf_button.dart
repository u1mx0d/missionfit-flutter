import 'package:material_ui/material_ui.dart';

import 'dot_grid.dart';

class MfButton extends StatelessWidget {
  const MfButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.loading = false,
    this.danger = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool loading;

  /// Geri alınamaz işlemler için kırmızı dolgu.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius));
    final child = loading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w600));
    final onTap = loading ? null : onPressed;
    const size = Size.fromHeight(52);
    return secondary
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: size,
              shape: shape,
              side: BorderSide(color: t.border),
              foregroundColor: t.text,
            ),
            child: child,
          )
        : FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: size,
              shape: shape,
              backgroundColor: danger ? t.danger : t.accent,
              foregroundColor: t.onAccent,
            ),
            child: child,
          );
  }
}
