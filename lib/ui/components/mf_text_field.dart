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
    this.textInputAction,
    this.onSubmitted,
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

  /// Klavyedeki eylem düğmesi (ör. sonraki alana geç ya da gönder).
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    onChanged: onChanged,
    enabled: enabled,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(labelText: label, errorText: errorText, suffixIcon: suffix),
  );
}
