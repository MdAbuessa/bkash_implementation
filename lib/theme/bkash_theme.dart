import 'package:flutter/material.dart';

class BkashTheme {
  // Signature bKash Brand Colors
  static const Color primaryPink = Color(0xFFE2136E);
  static const Color darkPink = Color(0xFFC20D5D);
  static const Color deepMagenta = Color(0xFF940544);
  static const Color lightPinkBg = Color(0xFFFFF0F5);
  static const Color softPinkContainer = Color(0xFFFDE8F0);
  
  // Real bKash Neutral Surface Colors
  static const Color bgLight = Color(0xFFF4F5F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFC);
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF6E6E6E);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Status Colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFFAB00);
  static const Color errorRed = Color(0xFFFF3D00);

  // Brand Gradients
  static const LinearGradient bkashGradient = LinearGradient(
    colors: [Color(0xFFE2136E), Color(0xFFD10056)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFFE2136E), Color(0xFF940544)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Real bKash Light Theme Data
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryPink,
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        secondary: darkPink,
        surface: cardWhite,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPink,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
