import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// App Colour Palette — mirrors the React theme
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF030d1a);
  static const Color surface = Color(0xFF0a1628);
  static const Color surfaceAlt = Color(0xFF0d2040);

  static const Color accent = Color(0xFF00ffaa);
  static const Color blue = Color(0xFF4488ff);
  static const Color amber = Color(0xFFffaa00);
  static const Color red = Color(0xFFff4444);
  static const Color pink = Color(0xFFff4488);
  static const Color muted = Color(0xFF8899aa);

  static const Color accentDim = Color(0x1A00ffaa);
  static const Color blueDim = Color(0x1A4488ff);
  static const Color border = Color(0x2600ffaa);
  static const Color borderBlue = Color(0x264488ff);
}

String get appFontFamily => GoogleFonts.spaceMono().fontFamily!;

// ─────────────────────────────────────────────
// ThemeData
// ─────────────────────────────────────────────
final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: GoogleFonts.spaceMono().fontFamily,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    secondary: AppColors.blue,
    surface: AppColors.surface,
    onSurface: Colors.white,
  ),
  textTheme: GoogleFonts.spaceMonoTextTheme(
    const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: AppColors.muted),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceAlt,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  dividerColor: AppColors.border,
);
