import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // متد saveSettings دیگر مورد نیاز نیست چون ذخیره به صورت خودکار انجام می‌شود.

  // --- API Key Management ---
  Future<void> addApiKey() async {
    final key = apiKeyController.text.trim();
    if (key.isNotEmpty && !apiKeys.contains(key)) {
      apiKeys.add(key);
      apiKeyController.clear();
      // <<< اصلاح کلیدی: ذخیره خودکار لیست پس از افزودن >>>
      await _settingsService.saveApiKeys(apiKeys);
      Get.snackbar('موفقیت', 'کلید API با موفقیت اضافه و ذخیره شد.');
    }
  }

  Future<void> removeApiKey(String key) async {
    apiKeys.remove(key);
    // <<< اصلاح کلیدی: ذخیره خودکار لیست پس از حذف >>>
    await _settingsService.saveApiKeys(apiKeys);
    Get.snackbar('موفقیت', 'کلید API با موفقیت حذف و ذخیره شد.');
  }

  // --- Excluded Directory Management ---
  Future<void> addExcludedDir() async {
    final dir = excludedDirController.text.trim();
    if (dir.isNotEmpty && !excludedDirs.contains(dir)) {
      excludedDirs.add(dir);
      excludedDirController.clear();
      // <<< اصلاح کلیدی: ذخیره خودکار لیست پس از افزودن >>>
      await _settingsService.saveExcludedDirs(excludedDirs);
      Get.snackbar('موفقیت', 'پوشه با موفقیت اضافه و ذخیره شد.');
    }
  }

  Future<void> removeExcludedDir(String dir) async {
    excludedDirs.remove(dir);
    // <<< اصلاح کلیدی: ذخیره خودکار لیست پس از حذف >>>
    await _settingsService.saveExcludedDirs(excludedDirs);
    Get.snackbar('موفقیت', 'پوشه با موفقیت حذف و ذخیره شد.');
  }

  Future<void> launchApiKeyUrl() async {
    final Uri url = Uri.parse('https://aistudio.google.com/apikey');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to launch URL: ${e.message}");
      Get.snackbar(
        'خطای پلتفرم',
        'امکان اجرای مرورگر وجود ندارد. لطفاً از نصب بودن برنامه و راه‌اندازی مجدد آن اطمینان حاصل کنید.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
