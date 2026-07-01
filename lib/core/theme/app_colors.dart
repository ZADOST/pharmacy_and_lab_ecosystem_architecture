import 'package:flutter/material.dart';

class AppColors {
  // Psychological calming palette
  static const Color primaryTeal = Color(0xFF317B80);
  static const Color backgroundLight = Color(0xFFF4F7F6);
  static const Color successGreen = Color(0xFF88A096);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);

  static ThemeData get clinicalTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        secondary: successGreen,
        background: backgroundLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTeal),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}