import 'package:material_ui/material_ui.dart';

import '../components/mf_button.dart';

/// "Google ile devam et". Yapılandırma yoksa ekran bunu hiç göstermez.
class GoogleButton extends StatelessWidget {
  const GoogleButton({required this.onPressed, super.key});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      MfButton(label: 'Google ile devam et', secondary: true, onPressed: onPressed);
}
