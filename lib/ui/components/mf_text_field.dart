import 'package:material_ui/material_ui.dart';

class MfTextField extends StatelessWidget {
  const MfTextField({
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.suffix,
    this.enabled = true,
    this.autofillHints,
    super.key,
  });
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final bool enabled;

  /// Otomatik doldurma ipuçları (ör. `AutofillHints.email`).
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    onChanged: onChanged,
    enabled: enabled,
    autofillHints: autofillHints,
    decoration: InputDecoration(labelText: label, errorText: errorText, suffixIcon: suffix),
  );
}
