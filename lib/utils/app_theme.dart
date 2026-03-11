// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════════
  // ANALOGOUS PASTEL COLOR SCHEME
  // Biru-Ungu pastel + Navy AppBar
  // Pattern: Analogous (Tinted/Pastel variant)
  // ═══════════════════════════════════════════

  // AppBar & Sidebar — tetap dark navy
  static const Color navyDark = Color(0xFF1E1B4B);
  static const Color navyMedium = Color(0xFF312E81);

  // Primary — periwinkle (tombol, aksi utama)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryLighter = Color(0xFFA5B4FC);

  // Accent — violet/ungu
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);

  // Background — lavender sangat muda
  static const Color background = Color(0xFFF0EFFF);
  static const Color surface = Color(0xFFFAFAFF);
  static const Color surfaceVariant = Color(0xFFEEEDFF);

  // Text
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // Kondisi alat
  static const Color kondisiBaik = Color(0xFF059669);
  static const Color kondisiRusakRingan = Color(0xFFD97706);
  static const Color kondisiRusakBerat = Color(0xFFDC2626);
  static const Color kondisiDalamPerbaikan = Color(0xFF0284C7);

  static const String fontFamily = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: textOnPrimary, letterSpacing: 0.5),
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryLight,
      tertiary: primaryLighter,
      surface: surface,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    textTheme: textTheme,

    // AppBar — navy gelap
    appBarTheme: const AppBarTheme(
      backgroundColor: navyDark,
      foregroundColor: textOnDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textOnDark),
      iconTheme: IconThemeData(color: textOnDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4D4F5))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD4D4F5))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: error)),
      labelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, color: textSecondary),
      hintStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: Color(0xFFB0B0D8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0DFFF), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: textOnPrimary,
      elevation: 2,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      labelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: primary),
      side: const BorderSide(color: Color(0xFFD4D4F5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFFE8E7FF), thickness: 1),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: navyDark,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: navyDark,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.5)),
      selectedLabelTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      unselectedLabelTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
      indicatorColor: Colors.white.withValues(alpha: 0.15),
    ),
  );

  // ═══════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════

  static Color getKondisiColor(String kondisi) {
    switch (kondisi.toUpperCase()) {
      case 'BAIK': return kondisiBaik;
      case 'RUSAK_RINGAN': return kondisiRusakRingan;
      case 'RUSAK_BERAT': return kondisiRusakBerat;
      case 'DALAM_PERBAIKAN': return kondisiDalamPerbaikan;
      default: return textSecondary;
    }
  }

  static String getKondisiLabel(String kondisi) {
    switch (kondisi.toUpperCase()) {
      case 'BAIK': return 'Baik';
      case 'RUSAK_RINGAN': return 'Rusak Ringan';
      case 'RUSAK_BERAT': return 'Rusak Berat';
      case 'DALAM_PERBAIKAN': return 'Dalam Perbaikan';
      default: return kondisi;
    }
  }
}