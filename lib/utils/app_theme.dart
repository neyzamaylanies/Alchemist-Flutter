// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary         = Color(0xFF6366F1);
  static const Color primaryLight    = Color(0xFF818CF8);
  static const Color primaryLighter  = Color(0xFFA5B4FC);
  static const Color blueDeep        = Color(0xFF3B5BDB);
  static const Color blueMid         = Color(0xFF748FFC);
  static const Color blueLight       = Color(0xFFBAC8FF);
  static const Color bluePastel      = Color(0xFFE8EEFF);
  static const Color purpleDeep      = Color(0xFF6741D9);
  static const Color purpleMid       = Color(0xFF9775FA);
  static const Color purpleLight     = Color(0xFFB197FC);
  static const Color purplePastel    = Color(0xFFEEE5FF);

  // Light
  static const Color background      = Color(0xFFF5F4FF);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceVariant  = Color(0xFFEEEDFF);
  static const Color textPrimary     = Color(0xFF1E1B4B);
  static const Color textSecondary   = Color(0xFF6B7280);
  static const Color textMuted       = Color(0xFF9CA3AF);
  static const Color textOnDark      = Color(0xFFFFFFFF);
  static const Color textOnPrimary   = Color(0xFFFFFFFF);

  // Dark
  static const Color darkBg          = Color(0xFF0F0E1A);
  static const Color darkSurface     = Color(0xFF1A1830);
  static const Color darkSurfaceVar  = Color(0xFF252340);
  static const Color darkText        = Color(0xFFE8E6FF);
  static const Color darkTextSub     = Color(0xFF9CA3AF);
  static const Color darkBorder      = Color(0xFF2D2B4E);

  // Sidebar
  static const Color sidebarBg       = Color(0xFF0F0E1A);
  static const Color sidebarSelected = Color(0xFF1E1B33);
  static const Color navyDark        = Color(0xFF0F0E1A);
  static const Color sidebarText         = Color(0xFFE2E8F0);
  static const Color sidebarTextMuted    = Color(0xFF94A3B8);
  static const Color sidebarTextSelected = Color(0xFFFFFFFF);

  // Status
  static const Color success   = Color(0xFF2F9E44);
  static const Color warning   = Color(0xFFE67700);
  static const Color error     = Color(0xFFC92A2A);
  static const Color info      = Color(0xFF1971C2);
  static const Color kondisiBaik           = Color(0xFF2F9E44);
  static const Color kondisiRusakRingan    = Color(0xFFE67700);
  static const Color kondisiRusakBerat     = Color(0xFFC92A2A);
  static const Color kondisiDalamPerbaikan = Color(0xFF1971C2);

  static const String fontFamily = 'Poppins';

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF3730A3)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient periwinkleGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFFBAD7F2)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFFC4B5FD), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2F9E44), Color(0xFF237032)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFE67700), Color(0xFFCC6A00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFC92A2A), Color(0xFFB02020)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF1971C2), Color(0xFF1562A8)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryLight,
      surface: surface,
      error: error,
      onPrimary: textOnPrimary,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 11),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDD8FF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDD8FF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: error)),
      labelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, color: textSecondary),
      hintStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8E7FF)),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE8E7FF), thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: purpleMid,
      surface: darkSurface,
      error: Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSurface: darkText,
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
      iconTheme: IconThemeData(color: darkText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryLight,
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVar,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: darkBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryLight, width: 2)),
      labelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, color: Color(0xFF9CA3AF)),
      hintStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: Color(0xFF6B7280)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceVar,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: darkText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );

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

  static LinearGradient getKondisiGradient(String kondisi) {
    switch (kondisi.toUpperCase()) {
      case 'BAIK': return successGradient;
      case 'RUSAK_RINGAN': return warningGradient;
      case 'RUSAK_BERAT': return errorGradient;
      case 'DALAM_PERBAIKAN': return infoGradient;
      default: return primaryGradient;
    }
  }
}