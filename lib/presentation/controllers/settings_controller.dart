import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}
