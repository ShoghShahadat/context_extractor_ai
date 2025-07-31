import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =================================================================
// بخش رنگ‌ها (Colors)
// =================================================================

/// کلاس نگهدارنده رنگ‌های اصلی و گرادیان‌ها
class AppColors {
  // گرادیان اصلی برنامه که در هر دو تم استفاده می‌شود
  static const Color primaryStart = Color(0xFF007AFF);
  static const Color primaryEnd = Color(0xFF00C6FF);
  static const Color onPrimary = Colors.white; // رنگ متن روی گرادیان

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// پالت رنگی اختصاصی برای تم تاریک (Dark Mode)
class AppColorsDark {
  static const Color background = Color(0xFF121212);
  static const Color sidebar = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color border = Color(0xFF333333);
}

/// پالت رنگی اختصاصی برای تم روشن (Light Mode)
class AppColorsLight {
  static const Color background = Color(0xFFF5F5F7);
  static const Color sidebar = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color border = Color(0xFFDCDCDC);
}

// =================================================================
// بخش تم (Theme)
// =================================================================

class AppTheme {
  /// متد اصلی برای ساخت تم بر اساس حالت (روشن/تاریک)
  static ThemeData _buildTheme({
    required bool isDark,
    required TextTheme baseTextTheme,
  }) {
    // <<< اصلاح کلیدی: دسترسی مستقیم به رنگ‌های استاتیک کلاس‌ها >>>
    final textTheme = GoogleFonts.vazirmatnTextTheme(baseTextTheme).apply(
      bodyColor:
          isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
      displayColor:
          isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
    );

    final baseTheme = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: AppColors.primaryStart,
      scaffoldBackgroundColor:
          isDark ? AppColorsDark.background : AppColorsLight.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColorsDark.background : AppColorsLight.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color:
              isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
        ),
        iconTheme: IconThemeData(
            color: isDark
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppColorsDark.surface : AppColorsLight.surface,
          foregroundColor:
              isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isDark ? AppColorsDark.border : AppColorsLight.border),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
              width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColorsDark.surface : AppColorsLight.background,
        hintStyle: textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
              width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryStart, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColorsDark.surface : AppColorsLight.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isDark ? AppColorsDark.border : AppColorsLight.border,
              width: 1),
        ),
      ),
      dividerColor: isDark ? AppColorsDark.border : AppColorsLight.border,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primaryStart,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryEnd,
        onSecondary: AppColors.onPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
        background:
            isDark ? AppColorsDark.background : AppColorsLight.background,
        onBackground:
            isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
        surface: isDark ? AppColorsDark.surface : AppColorsLight.surface,
        onSurface:
            isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
        // <<< جدید: تعریف رنگ‌های خاص در colorScheme برای دسترسی آسان >>>
        tertiary:
            isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
        outline: isDark ? AppColorsDark.border : AppColorsLight.border,
        surfaceVariant: isDark ? AppColorsDark.sidebar : AppColorsLight.sidebar,
      ),
    );

    return baseTheme;
  }

  /// دریافت تم تاریک پیکربندی شده
  static ThemeData getDarkTheme() {
    return _buildTheme(isDark: true, baseTextTheme: ThemeData.dark().textTheme);
  }

  /// دریافت تم روشن پیکربندی شده
  static ThemeData getLightTheme() {
    return _buildTheme(
        isDark: false, baseTextTheme: ThemeData.light().textTheme);
  }
}
