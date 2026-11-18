import 'package:material_ui/material_ui.dart';

import '../components/mf_empty_state.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    required this.title,
    required this.icon,
    required this.message,
    super.key,
  });
  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: MfEmptyState(icon: icon, title: title, message: message),
    ),
  );
}
