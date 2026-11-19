import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Oturum yokken ilk ekran. İskelet; içeriği Görev 5'te doldurulur.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('MISSIONFIT')));
  }
}
