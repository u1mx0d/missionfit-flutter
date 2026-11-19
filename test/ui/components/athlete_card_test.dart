import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:missionfit/ui/components/athlete_card.dart';
import 'package:missionfit/ui/theme/accents.dart';
import 'package:missionfit/ui/theme/app_theme.dart';
import 'package:missionfit/ui/theme/mf_theme.dart';

Widget _wrap(
  Widget child, {
  ThemeFamily family = ThemeFamily.canli,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: buildThemeData(MfTheme.build(family, brightness, AccentColor.yesil)),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final family in ThemeFamily.values) {
    for (final b in Brightness.values) {
      testWidgets('her mod hatasız çizilir ($family, $b)', (tester) async {
        for (final mode in AthleteCardMode.values) {
          await tester.pumpWidget(
            _wrap(
              AthleteCard(
                mode: mode,
                data: const AthleteCardData(displayName: 'Alperen', username: 'alperen'),
              ),
              family: family,
              brightness: b,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('SPORCU KİMLİĞİ'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('empty: yer tutucu var, damga yok', (tester) async {
    await tester.pumpWidget(_wrap(const AthleteCard(mode: AthleteCardMode.empty)));
    await tester.pumpAndSettle();
    expect(find.text('····'), findsWidgets);
    expect(find.text('AKTİF'), findsNothing);
    expect(find.text('KOD BEKLENİYOR'), findsNothing);
  });

  testWidgets('filling: e-posta ve şifre onayı', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AthleteCard(
          mode: AthleteCardMode.filling,
          data: AthleteCardData(email: 'a@b.com', passwordOk: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('✓ Şifre'), findsOneWidget);
  });

  testWidgets('awaitingCode ve active damgaları', (tester) async {
    await tester.pumpWidget(_wrap(const AthleteCard(mode: AthleteCardMode.awaitingCode)));
    await tester.pumpAndSettle();
    expect(find.text('KOD BEKLENİYOR'), findsOneWidget);
    await tester.pumpWidget(_wrap(const AthleteCard(mode: AthleteCardMode.active)));
    await tester.pumpAndSettle();
    expect(find.text('AKTİF'), findsOneWidget);
  });

  testWidgets('saved: ad, kullanıcı adı, üyelik tarihi', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AthleteCard(
          mode: AthleteCardMode.saved,
          data: AthleteCardData(
            displayName: 'Alperen',
            username: 'alperen',
            memberSince: DateTime(2026, 11, 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alperen'), findsOneWidget);
    expect(find.text('@alperen'), findsOneWidget);
    expect(find.text('Üye: Kasım 2026'), findsOneWidget);
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
  });

  testWidgets('saved: başlık yedekleri (kullanıcı adı, e-posta)', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AthleteCard(
          mode: AthleteCardMode.saved,
          data: AthleteCardData(username: 'alperen', email: 'a@b.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('@alperen'), findsOneWidget);
    await tester.pumpWidget(
      _wrap(
        const AthleteCard(
          mode: AthleteCardMode.saved,
          data: AthleteCardData(email: 'a@b.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('a@b.com'), findsOneWidget);
  });

  testWidgets('sample: örnek sporcu', (tester) async {
    await tester.pumpWidget(_wrap(const AthleteCard(mode: AthleteCardMode.sample)));
    await tester.pumpAndSettle();
    expect(find.text('MissionFit sporcusu'), findsOneWidget);
  });

  testWidgets('onRemove: düğme yalnız verilirse var ve çağrılır', (tester) async {
    await tester.pumpWidget(_wrap(const AthleteCard(mode: AthleteCardMode.saved)));
    expect(find.byKey(const Key('athlete-card-remove')), findsNothing);
    var n = 0;
    await tester.pumpWidget(_wrap(AthleteCard(mode: AthleteCardMode.saved, onRemove: () => n++)));
    await tester.tap(find.byKey(const Key('athlete-card-remove')));
    expect(n, 1);
  });

  testWidgets('onAvatarTap: avatar dokunulabilir', (tester) async {
    var n = 0;
    await tester.pumpWidget(
      _wrap(
        AthleteCard(
          mode: AthleteCardMode.active,
          data: const AthleteCardData(displayName: 'Alperen'),
          onAvatarTap: () => n++,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('athlete-card-avatar')));
    expect(n, 1);
  });

  testWidgets('avatarUrl varsa mevcut avatar anahtarı çalışır', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AthleteCard(
          mode: AthleteCardMode.saved,
          data: AthleteCardData(displayName: 'Alperen', avatarUrl: 'https://x.test/a.png'),
        ),
      ),
    );
    expect(find.byKey(const Key('avatar-url')), findsOneWidget);
  });
}
