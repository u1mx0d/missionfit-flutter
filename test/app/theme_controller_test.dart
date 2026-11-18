import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/app/profile_controller.dart';
import 'package:missionfit/app/providers.dart';
import 'package:missionfit/app/theme_controller.dart';
import 'package:missionfit/data/db/database.dart';
import 'package:missionfit/data/profile/profile_repository.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed({String accent = 'yesil', String family = 'canli', String theme = 'system'}) =>
      db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              userId: 'u1',
              createdAt: 'x',
              updatedAt: 'x',
              accentColor: Value(accent),
              themeFamily: Value(family),
              theme: Value(theme),
            ),
          );

  Future<ProviderContainer> make([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(sp),
        signedInUserIdProvider.overrideWithValue('u1'),
      ],
    );
    addTearDown(c.dispose);
    // Dinleyicisiz StreamProvider duraklatılır (Riverpod 3); gerçek uygulamada UI dinler.
    c.listen(profileProvider, (_, _) {});
    return c;
  }

  test('setFamily(mono) dokunulmamış vurguyu kirmizi yapar', () async {
    await seed();
    final c = await make();
    await c.read(profileProvider.future);
    c.read(themeControllerProvider);
    await c.read(themeControllerProvider.notifier).setFamily(ThemeFamily.mono);
    expect(c.read(themeControllerProvider).family, ThemeFamily.mono);
    expect(c.read(themeControllerProvider).accent, AccentColor.kirmizi);
    final ops = await OutboxRepository(db).pending();
    expect(ops.single.payload['accent_color'], 'kirmizi');
    expect(ops.single.payload['theme_family'], 'mono');
  });

  test('kullanıcı vurguyu seçtiyse setFamily vurguyu korur', () async {
    await seed();
    final c = await make();
    await c.read(profileProvider.future);
    final n = c.read(themeControllerProvider.notifier);
    await n.setAccent(AccentColor.mor);
    await n.setFamily(ThemeFamily.mono);
    expect(c.read(themeControllerProvider).accent, AccentColor.mor);
  });

  test('açılışta profil yüklenmeden yerel önbellek kullanılır', () async {
    final c = await make({'theme_family': 'mono', 'theme_mode': 'dark', 'theme_accent': 'mor'});
    final s = c.read(themeControllerProvider);
    expect(s.family, ThemeFamily.mono);
    expect(s.mode, ThemeModeChoice.dark);
    expect(s.accent, AccentColor.mor);
  });

  test('sunucudaki değer farklıysa sunucu kazanır', () async {
    await seed(family: 'mono', accent: 'mavi', theme: 'light');
    final c = await make({'theme_family': 'canli', 'theme_mode': 'dark', 'theme_accent': 'mor'});
    c.read(themeControllerProvider);
    await c.read(profileProvider.future);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(themeControllerProvider);
    expect(s.family, ThemeFamily.mono);
    expect(s.mode, ThemeModeChoice.light);
    expect(s.accent, AccentColor.mavi);
  });

  test('bilinmeyen sunucu değerleri çökmeden varsayılana düşer', () async {
    await seed(family: 'uzay', accent: 'bilinmeyen', theme: 'x');
    final c = await make();
    c.read(themeControllerProvider);
    await c.read(profileProvider.future);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(themeControllerProvider);
    expect(s.family, ThemeFamily.canli);
    expect(s.accent, AccentColor.yesil);
    expect(s.mode, ThemeModeChoice.system);
  });

  test('onboardedProvider yerel bayrak ya da profil bayrağı', () async {
    await seed();
    final c = await make();
    await c.read(profileProvider.future);
    expect(c.read(onboardedProvider), isFalse);
    final c2 = await make({'onboarded.u1': true});
    expect(c2.read(onboardedProvider), isTrue);
  });

  test('profil satırı yokken seçim geri alınır ve hata fırlar', () async {
    final c = await make();
    final n = c.read(themeControllerProvider.notifier);
    await expectLater(n.setAccent(AccentColor.mor), throwsA(isA<ProfileNotReadyException>()));
    expect(c.read(themeControllerProvider).accent, AccentColor.yesil);
    final prefs = c.read(sharedPreferencesProvider);
    expect(prefs.getString('theme_accent'), 'yesil');
    expect(prefs.getBool('accent_customized'), isNull);
  });
}
