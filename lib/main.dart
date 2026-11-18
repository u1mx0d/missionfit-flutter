import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'app/session_controller.dart';
import 'data/auth/secure_local_storage.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ortam değişkenleri geçersizse uygulama açılışta açık bir hatayla durur.
  final env = Env.fromEnvironment();
  tz_data.initializeTimeZones();
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      localStorage: SecureLocalStorage(),
    ),
  );
  runApp(const ProviderScope(child: MissionFitApp()));
}

class MissionFitApp extends ConsumerStatefulWidget {
  const MissionFitApp({super.key});

  @override
  ConsumerState<MissionFitApp> createState() => _MissionFitAppState();
}

class _MissionFitAppState extends ConsumerState<MissionFitApp> {
  SessionLifecycleObserver? _observer;

  @override
  void initState() {
    super.initState();
    _observer = SessionLifecycleObserver(ref.read(sessionControllerProvider.notifier));
    WidgetsBinding.instance.addObserver(_observer!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionControllerProvider);
    return const MaterialApp(
      title: 'MissionFit',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('MissionFit'))),
    );
  }
}
