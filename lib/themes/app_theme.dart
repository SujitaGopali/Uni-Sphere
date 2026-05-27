import 'package:flutter/material.dart';

class AppTheme {
  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color primary    = Color(0xFF6259E8);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark   = Color(0xFF1E1E1E);
  static const Color textMuted  = Color(0xFF9E9E9E);
  static const Color accent     = Color(0xFFFFBF00);

  // ── Font families (matches classwork4 pubspec.yaml) ───────────────────────
  static const String fontRegular   = 'Montserrat Regular';
  static const String fontBold      = 'Montserrat Bold';
  static const String fontExtraBold = 'Montserrat Extra Bold';

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontBold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFFBDBDBD),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: TextStyle(
        fontFamily: fontBold,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontRegular,
        fontSize: 12,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: fontBold,
          fontSize: 16,
        ),
      ),
    ),

    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: fontExtraBold,
        fontSize: 28,
        color: textDark,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontBold,
        fontSize: 22,
        color: textDark,
      ),
      titleLarge: TextStyle(
        fontFamily: fontBold,
        fontSize: 18,
        color: textDark,
      ),
      titleMedium: TextStyle(
        fontFamily: fontBold,
        fontSize: 16,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontRegular,
        fontSize: 15,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontRegular,
        fontSize: 14,
        color: textMuted,
      ),
    ),
  );
}