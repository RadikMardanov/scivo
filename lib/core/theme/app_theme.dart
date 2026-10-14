import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const purple = Color(0xFF7248D8);
  static const purpleLight = Color(0xFF9B7BFF);
  static const gold = Color(0xFFFFD700);
  static const night = Color(0xFF1B1F4B);
  static const nightCard = Color(0xFF2A2F6B);
  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFFF6B6B);

  static const nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2E2177), night, Color(0xFF0F1230)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.purple,
        secondary: AppColors.gold,
        surface: AppColors.nightCard,
      ),
    );

    final textTheme = GoogleFonts.quicksandTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.night,
      textTheme: textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 56),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
