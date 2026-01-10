import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens/app_colors.dart';

/// The main theme data for the Bingo App.
final ThemeData bingoTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.surface,
  fontFamily: GoogleFonts.inter().fontFamily, // Default body font
  // Color Scheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.text,
    secondary: AppColors.secondary,
    onSecondary: AppColors.text,
    surface: AppColors.card,
    onSurface: AppColors.text,
    error: AppColors.error,
    onError: AppColors.text,
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: GoogleFonts.fredoka(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ), // H1
    displayMedium: GoogleFonts.fredoka(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ), // H2
    displaySmall: GoogleFonts.fredoka(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ), // H3
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ), // Body
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    // Special style for the big drawn number
    headlineLarge: GoogleFonts.fredoka(
      fontSize: 120,
      fontWeight: FontWeight.bold,
      height: 1.0,
    ),
    headlineMedium: GoogleFonts.fredoka(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      height: 1.0,
    ), // Number
  ),

  // Default ElevatedButton style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
      elevation: 0,
      side: const BorderSide(color: AppColors.outline, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  ),

  // Default Card style
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: AppColors.outline, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);
