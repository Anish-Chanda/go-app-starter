import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF3B82F6); // Blue
  static const Color secondary = Color(0xFF10B981); // Emerald

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Error/Success/Warning
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppFontSize {
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 30.0;
  static const double display = 36.0;
}

class AppFontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: AppFontSize.display,
            fontWeight: AppFontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: AppFontSize.xxxl,
            fontWeight: AppFontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          displaySmall: TextStyle(
            fontSize: AppFontSize.xxl,
            fontWeight: AppFontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: AppFontSize.xl,
            fontWeight: AppFontWeight.semiBold,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: AppFontSize.base,
            fontWeight: AppFontWeight.regular,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: AppFontSize.sm,
            fontWeight: AppFontWeight.regular,
            color: AppColors.textPrimary,
          ),
          labelLarge: TextStyle(
            fontSize: AppFontSize.base,
            fontWeight: AppFontWeight.medium,
            color: AppColors.textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: AppFontSize.xs,
            fontWeight: AppFontWeight.regular,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
        ),
      ),
    );
  }
}
