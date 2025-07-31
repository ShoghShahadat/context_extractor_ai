import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <<< جدید: برای مدیریت خطاهای پلتفرم
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find();

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

  /// ذخیره تمام تنظیمات در سرویس
  Future<void> saveSettings() async {
    await _settingsService.saveApiKeys(apiKeys);
    await _settingsService.saveExcludedDirs(excludedDirs);
    Get.snackbar(
      'موفقیت',
      'تنظیمات با موفقیت ذخیره شد.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // --- API Key Management ---
  void addApiKey() {
    final key = apiKeyController.text.trim();
    if (key.isNotEmpty && !apiKeys.contains(key)) {
      apiKeys.add(key);
      apiKeyController.clear();
    }
  }

  void removeApiKey(String key) {
    apiKeys.remove(key);
  }

  // --- Excluded Directory Management ---
  void addExcludedDir() {
    final dir = excludedDirController.text.trim();
    if (dir.isNotEmpty && !excludedDirs.contains(dir)) {
      excludedDirs.add(dir);
      excludedDirController.clear();
    }
  }

  void removeExcludedDir(String dir) {
    excludedDirs.remove(dir);
  }

  // <<< اصلاح کلیدی: افزودن مدیریت خطا برای پایداری بیشتر >>>
  Future<void> launchApiKeyUrl() async {
    final Uri url = Uri.parse('https://aistudio.google.com/apikey');
    try {
      // تلاش برای باز کردن لینک در یک برنامه خارجی (مرورگر پیش‌فرض)
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } on PlatformException catch (e) {
      // این بخش خطای MissingPluginException را مدیریت می‌کند
      debugPrint("Failed to launch URL: ${e.message}");
      Get.snackbar(
        'خطای پلتفرم',
        'امکان اجرای مرورگر وجود ندارد. لطفاً از نصب بودن برنامه و راه‌اندازی مجدد آن اطمینان حاصل کنید.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // مدیریت سایر خطاها
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
