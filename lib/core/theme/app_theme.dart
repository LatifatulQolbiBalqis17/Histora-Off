import 'package:flutter/material.dart';

abstract final class HistoraColors {
  static const pearl = Color(0xFFF7F8F8);
  static const paper = Color(0xFFFFFFFF);
  static const mist = Color(0xFFDCE8EC);
  static const gold = Color(0xFFE4BC32);
  static const bronze = gold;
  static const bronzeStrong = Color(0xFFC49A17);
  static const cyan = Color(0xFF12B9D0);
  static const ocean = Color(0xFF086E98);
  static const navy = Color(0xFF06243D);
  static const moss = ocean;
  static const forest = navy;
  static const ink = Color(0xFF08263F);
  static const muted = Color(0xFF637682);
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFC0392B);

  // Varian yang tetap terbaca di atas permukaan terang (kartu putih) maupun
  // gelap (kartu navy). Emas murni E4BC32 hampir tak terlihat di atas putih.
  static const goldDeep = Color(0xFF8A6500);
  static const dangerSoft = Color(0xFFFF8A7A);
  static const successSoft = Color(0xFF6FD99A);

  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
  static Color accentOn(BuildContext c) => _dark(c) ? gold : goldDeep;
  static Color dangerOn(BuildContext c) => _dark(c) ? dangerSoft : danger;
  static Color successOn(BuildContext c) =>
      _dark(c) ? successSoft : const Color(0xFF1F7A43);
}

abstract final class AppTheme {
  static ThemeData get light => _make(Brightness.light);
  static ThemeData get dark => _make(Brightness.dark);
  static ThemeData _make(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF041827) : HistoraColors.pearl;
    final surface = dark ? const Color(0xFF08263F) : HistoraColors.paper;
    final fg = dark ? const Color(0xFFF7F8F8) : HistoraColors.ink;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: HistoraColors.ocean,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: dark ? HistoraColors.cyan : HistoraColors.ocean,
          onPrimary: Colors.white,
          secondary: HistoraColors.gold,
          onSecondary: HistoraColors.ink,
          error: HistoraColors.danger,
          surface: surface,
          onSurface: fg,
          outline: dark ? const Color(0xFF376175) : const Color(0xFFC6D7DE),
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 42,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.06,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'serif',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        titleLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: fg),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: fg),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: .82),
        foregroundColor: fg,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: .90),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline.withValues(alpha: .55)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: .94),
        indicatorColor: scheme.secondary.withValues(alpha: .25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: .94),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: .5)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: scheme.outline.withValues(alpha: .55)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: HistoraColors.ink,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
