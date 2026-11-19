import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'app/known_accounts.dart';
import 'app/profile_controller.dart';
import 'app/providers.dart';
import 'data/notifications/notification_service.dart';
import 'app/session_controller.dart';
import 'data/auth/secure_local_storage.dart';
import 'app/theme_controller.dart';
import 'env.dart';
import 'ui/router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/mf_theme.dart';

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
  // Yerel diskten okunur; ağ beklenmez, ilk karede kayıtlı tema kullanılır.
  final prefs = await SharedPreferences.getInstance();
  final notifications = LocalNotificationService(PluginNotificationsPlatform());
  try {
    await notifications.init();
  } catch (e, st) {
    // Bildirim kurulumu açılışı engellememeli.
    debugPrint('Bildirim kurulumu başarısız: $e\n$st');
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const MissionFitApp(),
    ),
  );
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
    ref.watch(knownAccountSyncProvider);
    final sel = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MissionFit',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildThemeData(MfTheme.build(sel.family, Brightness.light, sel.accent)),
      darkTheme: buildThemeData(MfTheme.build(sel.family, Brightness.dark, sel.accent)),
      themeMode: switch (sel.mode) {
        ThemeModeChoice.light => ThemeMode.light,
        ThemeModeChoice.dark => ThemeMode.dark,
        ThemeModeChoice.system => ThemeMode.system,
      },
    );
  }
}
