import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// کلیدهای مورد استفاده برای ذخیره‌سازی در حافظه
const String _apiKeysKey = 'settings_api_keys';
const String _excludedDirsKey = 'settings_excluded_dirs';

/// سرویسی برای مدیریت و ذخیره‌سازی دائمی تنظیمات برنامه.
class SettingsService {
  late SharedPreferences _prefs;

  // لیست‌های پیش‌فرض برای اولین اجرای برنامه
  final List<String> _defaultApiKeys = [];

  final List<String> _defaultExcludedDirs = [
    '.git', '.idea', 'build', 'dist', '.vscode', 'assets', 'web', 'test',
    '.dart_tool', 'linux', 'windows', 'macos', 'ios',
    'android', // Flutter/Dart specific
    'pycache', 'venv', 'node_modules'
  ];

  /// مقداردهی اولیه سرویس و خواندن اطلاعات از حافظه.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint("✅ SettingsService Initialized and Ready.");
  }

  // --- مدیریت کلیدهای API ---

  /// دریافت لیست کلیدهای API ذخیره شده.
  /// اگر لیستی ذخیره نشده باشد، لیست پیش‌فرض را برمی‌گرداند.
  List<String> getApiKeys() {
    return _prefs.getStringList(_apiKeysKey) ?? _defaultApiKeys;
  }

  /// ذخیره لیست جدید کلیدهای API.
  Future<void> saveApiKeys(List<String> keys) async {
    await _prefs.setStringList(_apiKeysKey, keys);
    debugPrint("API Keys saved: $keys");
  }

  // --- مدیریت پوشه‌های مستثنی ---

  /// دریافت لیست پوشه‌های مستثنی شده.
  /// اگر لیستی ذخیره نشده باشد، لیست پیش‌فرض را برمی‌گرداند.
  List<String> getExcludedDirs() {
    return _prefs.getStringList(_excludedDirsKey) ?? _defaultExcludedDirs;
  }

  /// ذخیره لیست جدید پوشه‌های مستثنی.
  Future<void> saveExcludedDirs(List<String> dirs) async {
    await _prefs.setStringList(_excludedDirsKey, dirs);
    debugPrint("Excluded Dirs saved: $dirs");
  }
}
