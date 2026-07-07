import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF001E40);       // Deep Corporate Blue
  static const Color secondaryColor = Color(0xFF005CBA);     // Action Blue
  static const Color backgroundColor = Color(0xFFF7F9FB);    // Light Slate Canvas
  static const Color surfaceColor = Color(0xFFF7F9FB);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color outlineColor = Color(0xFF737780);
  static const Color outlineVariantColor = Color(0xFFC3C6D1);

  // Status Colors (Recruitment stages)
  static const Color appliedBg = Color(0xFFE0ECFC);
  static const Color appliedText = Color(0xFF005CBA);
  static const Color shortlistedBg = Color(0xFFE2F6EA);
  static const Color shortlistedText = Color(0xFF1B874B);
  static const Color rejectedBg = Color(0xFFFCE8E6);
  static const Color rejectedText = Color(0xFFC5221F);

  // Typography TextStyles (Inter Font Family)
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 57.0,
    fontWeight: FontWeight.bold,
    height: 64 / 57,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    height: 40 / 32,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    height: 36 / 28,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 24 / 16,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  // Light Theme Configuration (optimized for Web)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: Color(0xFF191C1E),
        onSurfaceVariant: Color(0xFF43474F),
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 1,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: outlineVariantColor, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        prefixIconColor: Color(0xFF43474F),
        suffixIconColor: Color(0xFF43474F),
        labelStyle: bodyMd.copyWith(color: Color(0xFF43474F)),
        hintStyle: bodyMd.copyWith(color: outlineColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: outlineVariantColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: outlineVariantColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: secondaryColor, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: labelLg.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: secondaryColor, width: 1.5),
          textStyle: labelLg.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
