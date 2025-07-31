import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// کلاس برای تعریف رنگ‌های اصلی برنامه
class AppColors {
  static const Color primary = Color(0xFF00B2FF); // آبی درخشان
  static const Color secondary = Color(0xFF1D2B64); // آبی تیره عمیق
  static const Color accent = Color(0xFF36D1DC); // فیروزه‌ای
  static const Color backgroundStart =
      Color(0xFF1A2980); // شروع گرادیان پس‌زمینه
  static const Color backgroundEnd =
      Color(0xFF26D0CE); // پایان گرادیان پس‌زمینه
  static const Color glassFill = Color(0xFFFFFFFF); // رنگ پایه شیشه
}

// کلاس برای تعریف گرادیان‌های برنامه
class AppGradients {
  static const LinearGradient background = LinearGradient(
    colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// کلاس اصلی برای تعریف تم برنامه
class AppTheme {
  // دکوریشن استاندارد برای ایجاد افکت شیشه‌ای
  static BoxDecoration glassmorphism(
      {Color color = AppColors.glassFill,
      double blur = 10.0,
      double opacity = 0.1,
      BorderRadius? borderRadius}) {
    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      color: color.withOpacity(opacity),
      border: Border.all(
        color: AppColors.glassFill.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }

  // متد اصلی برای دریافت تم تاریک و مدرن برنامه
  static ThemeData getTheme() {
    final baseTheme = ThemeData.dark();
    final textTheme = GoogleFonts.vazirmatnTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.secondary, // رنگ پس‌زمینه اصلی
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // شفاف برای نمایش گرادیان
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassFill.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.glassFill.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill.withOpacity(0.05),
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.secondary.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.glassFill.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerColor: AppColors.glassFill.withOpacity(0.2),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.secondary,
        onSurface: Colors.white,
        background: AppColors.secondary,
      ),
    );
  }
}
