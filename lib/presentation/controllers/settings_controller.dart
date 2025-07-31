import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/settings_service.dart';
import 'theme_controller.dart'; // <<< جدید: ایمپورت کنترلر تم

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find();
  // <<< جدید: دسترسی به کنترلر تم >>>
  final ThemeController themeController = Get.find();

  // --- State Variables ---
  final RxList<String> apiKeys = <String>[].obs;
  final RxList<String> excludedDirs = <String>[].obs;

  // --- TextEditing Controllers ---
  late final TextEditingController apiKeyController;
  late final TextEditingController excludedDirController;

  @override
  void onInit() {
    super.onInit();
    apiKeyController = TextEditingController();
    excludedDirController = TextEditingController();
    loadSettings();
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    excludedDirController.dispose();
    super.onClose();
  }

  /// بارگذاری تنظیمات از سرویس
  void loadSettings() {
    apiKeys.assignAll(_settingsService.getApiKeys());
    excludedDirs.assignAll(_settingsService.getExcludedDirs());
  }

  // --- API Key Management ---
  Future<void> addApiKey() async {
    final key = apiKeyController.text.trim();
    if (key.isNotEmpty && !apiKeys.contains(key)) {
      apiKeys.add(key);
      apiKeyController.clear();
      await _settingsService.saveApiKeys(apiKeys);
      Get.snackbar('موفقیت', 'کلید API با موفقیت اضافه و ذخیره شد.');
    }
  }

  Future<void> removeApiKey(String key) async {
    apiKeys.remove(key);
    await _settingsService.saveApiKeys(apiKeys);
    Get.snackbar('موفقیت', 'کلید API با موفقیت حذف و ذخیره شد.');
  }

  // --- Excluded Directory Management ---
  Future<void> addExcludedDir() async {
    final dir = excludedDirController.text.trim();
    if (dir.isNotEmpty && !excludedDirs.contains(dir)) {
      excludedDirs.add(dir);
      excludedDirController.clear();
      await _settingsService.saveExcludedDirs(excludedDirs);
      Get.snackbar('موفقیت', 'پوشه با موفقیت اضافه و ذخیره شد.');
    }
  }

  Future<void> removeExcludedDir(String dir) async {
    excludedDirs.remove(dir);
    await _settingsService.saveExcludedDirs(excludedDirs);
    Get.snackbar('موفقیت', 'پوشه با موفقیت حذف و ذخیره شد.');
  }

  // --- Theme Management (جدید) ---

  /// متدی برای جابجایی حالت تم که از ThemeController استفاده می‌کند.
  void toggleTheme(bool isDark) {
    themeController.changeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  // --- Other Methods ---
  Future<void> launchApiKeyUrl() async {
    final Uri url = Uri.parse('https://aistudio.google.com/apikey');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      Get.snackbar(
        'خطا',
        'یک خطای پیش‌بینی نشده در باز کردن لینک رخ داد.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
