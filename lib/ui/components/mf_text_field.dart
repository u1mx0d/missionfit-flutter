import 'package:material_ui/material_ui.dart';

class MfTextField extends StatelessWidget {
  const MfTextField({
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    super.key,
  });
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, errorText: errorText),
  );
}
