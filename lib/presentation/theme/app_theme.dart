import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// فلسفه جدید: مینیمالیسم حرفه‌ای با تمرکز بر وضوح
class AppColors {
  static const Color background = Color(0xFF121212); // پس‌زمینه اصلی تیره
  static const Color sidebar = Color(0xFF1A1A1A); // پس‌زمینه نوار کناری
  static const Color surface = Color(0xFF242424); // رنگ سطوح و کارت‌ها
  static const Color primary =
      Color(0xFF007AFF); // آبی درخشان به عنوان رنگ تأکیدی
  static const Color onPrimary = Colors.white;

  static const Color textPrimary = Color(0xFFEAEAEA); // رنگ متن اصلی
  static const Color textSecondary = Color(0xFF9E9E9E); // رنگ متن ثانویه
  static const Color border = Color(0xFF333333); // رنگ بوردرها
}

class AppTheme {
  static ThemeData getTheme() {
    final baseTheme = ThemeData.dark();
    final textTheme = GoogleFonts.vazirmatnTextTheme(baseTheme.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return baseTheme.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerColor: AppColors.border,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
      ),
    );
  }
}
