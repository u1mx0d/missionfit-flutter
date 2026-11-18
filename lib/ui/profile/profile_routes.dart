import 'package:go_router/go_router.dart';

import 'body_goal_screen.dart';
import 'delete_account_screen.dart';
import 'edit_profile_screen.dart';
import 'password_screen.dart';
import 'theme_gallery_screen.dart';
import 'timezone_screen.dart';

export 'profile_screen.dart' show ProfileScreen;

/// `/profil` altındaki ayar sayfaları.
final profileSubRoutes = <RouteBase>[
  GoRoute(path: 'duzenle', builder: (_, _) => const EditProfileScreen()),
  GoRoute(path: 'vucut', builder: (_, _) => const BodyGoalScreen()),
  GoRoute(path: 'tema', builder: (_, _) => const ThemeGalleryScreen()),
  GoRoute(path: 'saat-dilimi', builder: (_, _) => const TimezoneScreen()),
  GoRoute(path: 'sifre', builder: (_, _) => const PasswordScreen()),
  GoRoute(path: 'hesap-sil', builder: (_, _) => const DeleteAccountScreen()),
];
