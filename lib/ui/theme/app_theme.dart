/// [MfTheme] → Material [ThemeData]. Standart bileşenler (metin alanı, düğme, iletişim kutusu)
/// tema renklerini buradan alır; özel bileşenler doğrudan [MfTheme] okur.
library;

import 'package:material_ui/material_ui.dart';

import 'mf_theme.dart';

ThemeData buildThemeData(MfTheme t) {
  final scheme = ColorScheme(
    brightness: t.brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    secondary: t.accent,
    onSecondary: t.onAccent,
    error: t.danger,
    onError: t.onAccent,
    surface: t.surface,
    onSurface: t.text,
    onSurfaceVariant: t.textMuted,
    surfaceContainerHighest: t.surfaceMuted,
    outline: t.border,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: t.brightness,
    colorScheme: scheme,
    fontFamily: t.bodyFont,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius));
  return base.copyWith(
    scaffoldBackgroundColor: t.background,
    textTheme: base.textTheme.apply(
      fontFamily: t.bodyFont,
      bodyColor: t.text,
      displayColor: t.text,
    ),
    dividerColor: t.border,
    cardTheme: CardThemeData(color: t.surface, shape: shape, elevation: 0),
    dialogTheme: DialogThemeData(backgroundColor: t.surface, shape: shape),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radius / 1.5),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radius / 1.5),
        borderSide: BorderSide(color: t.accent, width: 1.5),
      ),
    ),
    extensions: [t],
  );
}
