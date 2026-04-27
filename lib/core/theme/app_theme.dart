import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0F0E0D);
  static const bgCard = Color(0xFF1A1714);
  static const bgSurface = Color(0xFF221F1B);
  static const gold = Color(0xFFC9A96E);
  static const goldLight = Color(0xFFE8D9C0);
  static const goldDim = Color(0xFF7A6030);
  static const textPrimary = Color(0xFFE8D9C0);
  static const textSecondary = Color(0xFF9A8C7A);
  static const textMuted = Color(0xFF5A5048);
  static const divider = Color(0xFF2A2520);
  static const error = Color(0xFFE24B4A);
  static const success = Color(0xFF4A8C50);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        surface: AppColors.bgCard,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.dmSans(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: AppColors.textMuted,
          fontSize: 10,
          letterSpacing: 0.08,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      dividerColor: AppColors.divider,
    );
  }
}