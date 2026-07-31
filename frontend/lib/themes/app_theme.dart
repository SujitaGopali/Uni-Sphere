import 'package:flutter/material.dart';
import 'package:uni_sphere/themes/app_colors.dart';

class AppTheme {
  static const String fontRegular = 'Montserrat Regular';
  static const String fontBold = 'Montserrat Bold';
  static const String fontExtraBold = 'Montserrat Extra Bold';

  /// Legacy aliases — prefer [AppColors] tokens.
  static const Color primary = AppColors.mBlueDark;
  static const Color background = AppColors.canvas;
  static const Color textDark = AppColors.onDark;
  static const Color textMuted = AppColors.muted;
  static const Color accent = AppColors.mBlueLight;

  /// Marketing / auth / landing — white canvas + blue CTAs.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: const ColorScheme.light(
          primary: AppColors.mBlueDark,
          secondary: AppColors.mBlueLight,
          surface: AppColors.canvas,
          error: AppColors.mRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.body,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.onDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: fontBold,
            fontSize: 18,
            color: AppColors.onDark,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.mBlueDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontFamily: fontBold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mBlueLight, width: 1.5),
          ),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontFamily: fontExtraBold,
            fontSize: 28,
            color: AppColors.onDark,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontBold,
            fontSize: 22,
            color: AppColors.onDark,
          ),
          titleLarge: TextStyle(
            fontFamily: fontBold,
            fontSize: 18,
            color: AppColors.onDark,
          ),
          titleMedium: TextStyle(
            fontFamily: fontBold,
            fontSize: 16,
            color: AppColors.bodyStrong,
          ),
          bodyLarge: TextStyle(
            fontFamily: fontRegular,
            fontSize: 15,
            color: AppColors.body,
          ),
          bodyMedium: TextStyle(
            fontFamily: fontRegular,
            fontSize: 14,
            color: AppColors.muted,
          ),
        ),
      );

  /// Post-login student experience — charcoal + cyan.
  static ThemeData get dashboard => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dashBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.dashAccent,
          secondary: AppColors.dashFun,
          surface: AppColors.dashCard,
          error: AppColors.mRed,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: AppColors.dashText,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.dashHeader,
          foregroundColor: AppColors.dashText,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: fontBold,
            fontSize: 18,
            color: AppColors.dashText,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dashAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontFamily: fontBold, fontSize: 15),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.dashSidebar,
          selectedItemColor: Colors.black,
          unselectedItemColor: AppColors.dashMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontFamily: fontBold, fontSize: 11),
          unselectedLabelStyle:
              TextStyle(fontFamily: fontRegular, fontSize: 11),
        ),
        dividerColor: AppColors.dashBorder,
        cardColor: AppColors.dashCard,
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontFamily: fontExtraBold,
            fontSize: 28,
            color: AppColors.dashText,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontBold,
            fontSize: 22,
            color: AppColors.dashText,
          ),
          titleLarge: TextStyle(
            fontFamily: fontBold,
            fontSize: 18,
            color: AppColors.dashText,
          ),
          titleMedium: TextStyle(
            fontFamily: fontBold,
            fontSize: 16,
            color: AppColors.dashText,
          ),
          bodyLarge: TextStyle(
            fontFamily: fontRegular,
            fontSize: 15,
            color: AppColors.dashText,
          ),
          bodyMedium: TextStyle(
            fontFamily: fontRegular,
            fontSize: 14,
            color: AppColors.dashMuted,
          ),
        ),
      );
}
