import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/settings_service.dart';

/// یک کنترلر سراسری برای مدیریت و جابجایی بین تم‌های برنامه.
class ThemeController extends GetxController {
  final SettingsService _settingsService = Get.find();

  // وضعیت فعلی تم برنامه را به صورت واکنشی نگهداری می‌کند.
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  @override
  void onInit() {
    super.onInit();
    // در زمان راه‌اندازی، آخرین تم ذخیره شده را بارگذاری می‌کند.
    _loadThemeFromSettings();
  }

  /// تم ذخیره شده در حافظه را می‌خواند و وضعیت کنترلر را به‌روز می‌کند.
  void _loadThemeFromSettings() {
    final savedTheme = _settingsService.getThemeMode();
    if (savedTheme == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
    // اعمال فوری تم در کل برنامه
    Get.changeThemeMode(themeMode.value);
    debugPrint("✅ Theme loaded from settings: ${themeMode.value}");
  }

  /// تم برنامه را تغییر داده و انتخاب جدید را در حافظه ذخیره می‌کند.
  Future<void> changeTheme(ThemeMode newThemeMode) async {
    if (themeMode.value == newThemeMode) return;

    themeMode.value = newThemeMode;
    // اعمال فوری تم در کل برنامه
    Get.changeThemeMode(newThemeMode);

    // ذخیره انتخاب جدید کاربر
    await _settingsService
        .saveThemeMode(newThemeMode == ThemeMode.light ? 'light' : 'dark');
    debugPrint("🎨 Theme changed and saved: ${newThemeMode.name}");
  }

  /// یک متد راحت برای جابجایی بین حالت روشن و تاریک.
  Future<void> toggleTheme() async {
    final newMode =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await changeTheme(newMode);
  }
}
