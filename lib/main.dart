import 'package:material_ui/material_ui.dart';

import 'env.dart';

void main() {
  // Ortam değişkenleri geçersizse uygulama açılışta açık bir hatayla durur.
  Env.fromEnvironment();
  runApp(const MissionFitApp());
}

class MissionFitApp extends StatelessWidget {
  const MissionFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MissionFit',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('MissionFit'))),
    );
  }
}
