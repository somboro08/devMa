// lib/shared/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color rose = Color(0xFFE8739A);
  static const Color roseLight = Color(0xFFF5C0D3);
  static const Color rosePale = Color(0xFFFDF0F5);
  static const Color roseDark = Color(0xFFC04F78);
  static const Color roseDarker = Color(0xFF9A3A5E);

  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);

  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rose,
        primary: AppColors.rose,
        onPrimary: AppColors.white,
        secondary: AppColors.roseLight,
        background: AppColors.background,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        iconTheme: const IconThemeData(color: AppColors.gray700),
        toolbarHeight: 56,
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gray200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rose,
          side: const BorderSide(color: AppColors.rose),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.gray400),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.gray600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.rosePale,
        labelStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.roseDark),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.white,
        selectedIconTheme: const IconThemeData(color: AppColors.roseDark),
        unselectedIconTheme: const IconThemeData(color: AppColors.gray500),
        selectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.roseDark,
        ),
        unselectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.gray500,
        ),
        indicatorColor: AppColors.rosePale,
      ),
    );
  }
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gray800);
  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray800);
  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray800);
  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 13, color: AppColors.gray700);
  static TextStyle get bodyMuted => GoogleFonts.poppins(
        fontSize: 13, color: AppColors.gray500);
  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gray500);
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11, color: AppColors.gray400);
}
