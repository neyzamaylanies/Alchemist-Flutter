// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════════
  // ALCHEMIST — Analogous Pastel Biru-Ungu
  // HCI Principles: konsisten, tidak norak,
  // warna fungsional bukan dekoratif
  // ═══════════════════════════════════════════

  // Sidebar — navy gelap (biru tua)
  static const Color sidebarBg       = Color(0xFF0F0E1A); // navy hampir hitam
  static const Color sidebarSelected = Color(0xFF1E1B33); // navy medium
  static const Color navyDark        = Color(0xFF0F0E1A);

  // Primary — periwinkle (biru-ungu)
  static const Color primary         = Color(0xFF6366F1); // indigo
  static const Color primaryLight    = Color(0xFF818CF8); // indigo muda
  static const Color primaryLighter  = Color(0xFFA5B4FC); // indigo sangat muda

  // Biru pastel (analogous ke kiri dari primary)
  static const Color blueDeep        = Color(0xFF3B5BDB); // biru tua
  static const Color blueMid         = Color(0xFF748FFC); // biru-periwinkle
  static const Color blueLight       = Color(0xFFBAC8FF); // biru pastel
  static const Color bluePastel      = Color(0xFFE8EEFF); // biru sangat muda

  // Ungu pastel (analogous ke kanan dari primary)
  static const Color purpleDeep      = Color(0xFF6741D9); // ungu tua
  static const Color purpleMid       = Color(0xFF9775FA); // ungu medium
  static const Color purpleLight     = Color(0xFFB197FC); // ungu pastel
  static const Color purplePastel    = Color(0xFFEEE5FF); // ungu sangat muda

  // Background — lavender sangat tipis
  static const Color background      = Color(0xFFF5F4FF);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceVariant  = Color(0xFFEEEDFF);

  // Text
  static const Color textPrimary     = Color(0xFF1E1B4B); // navy untuk teks
  static const Color textSecondary   = Color(0xFF6B7280);
  static const Color textMuted       = Color(0xFF9CA3AF);
  static const Color textOnDark      = Color(0xFFFFFFFF);
  static const Color textOnPrimary   = Color(0xFFFFFFFF);

  // Sidebar text
  static const Color sidebarText         = Color(0xFFE2E8F0);
  static const Color sidebarTextMuted    = Color(0xFF94A3B8);
  static const Color sidebarTextSelected = Color(0xFFFFFFFF);

  // Status — tetap pakai warna semantik tapi lebih muted
  // (merah/hijau untuk status kondisi TIDAK bisa diganti biru-ungu
  //  karena melanggar prinsip HCI — warna merah = bahaya, hijau = aman)
  static const Color success   = Color(0xFF2F9E44); // hijau muted
  static const Color warning   = Color(0xFFE67700); // oranye muted
  static const Color error     = Color(0xFFC92A2A); // merah muted
  static const Color info      = Color(0xFF1971C2); // biru muted

  // Kondisi alat — warna semantik yang muted
  static const Color kondisiBaik           = Color(0xFF2F9E44);
  static const Color kondisiRusakRingan    = Color(0xFFE67700);
  static const Color kondisiRusakBerat     = Color(0xFFC92A2A);
  static const Color kondisiDalamPerbaikan = Color(0xFF1971C2);

  static const String fontFamily = 'Poppins';

  // ═══════════════════════════════════════════
  // STAT CARD GRADIENTS — semua analogous biru-ungu
  // Setiap card punya tone berbeda tapi tetap
  // dalam family yang sama (tidak norak)
  // ═══════════════════════════════════════════

  // ═══════════════════════════════════════════
  // STAT CARD GRADIENTS — analogous biru-ungu
  // Navy → Ungu tua → Indigo → Sky blue → Biru pastel → Ungu pastel → Putih
  // ═══════════════════════════════════════════

  // Card 1: Total Peralatan — navy → ungu tua ke arah biru
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card 2: Alat Tersedia — indigo → sky blue
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card 3: Alat Rusak — ungu tua → indigo
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card 4: Total Transaksi — sky blue → biru pastel
  static const LinearGradient periwinkleGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFFBAD7F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card 5: Mahasiswa Aktif — ungu pastel → putih
  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFFC4B5FD), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Untuk kondisi (tetap semantik karena HCI)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2F9E44), Color(0xFF237032)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFE67700), Color(0xFFCC6A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFC92A2A), Color(0xFFB02020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF1971C2), Color(0xFF1562A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
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
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: textOnPrimary,
      elevation: 2,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE8E7FF), thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.white),
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