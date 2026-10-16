import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Цветовая палитра Scivo (ночь, золото, фиолет).
class AppColors {
  static const nightBg = Color(0xFF0F0E1A);
  static const nightCard = Color(0xFF1C1B2E);
  static const purpleLight = Color(0xFF8B7FD4);
  static const gold = Color(0xFFFFD700);
  static const textDark = Color(0xFF1A1A2E);
  static const successGreen = Color(0xFF4CAF50);
  static const errorRed = Color(0xFFF44336);
}

/// Градиент ночного фона.
final LinearGradient nightGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.nightBg, const Color(0xFF1A1830)],
);

class AppTheme {
  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.purpleLight,
        surface: AppColors.nightCard,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textDark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purpleLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.purpleLight, width: 2),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        labelStyle: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
      ),
    );
  }
}
