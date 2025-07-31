import 'dart:io';
import 'dart:ui'; // <<< جدید: برای استفاده از ImageFilter
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/file_service.dart';
import '../../core/services/history_service.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart'; // <<< جدید: ایمپورت تم

class HomeController extends GetxController {
  final FileService _fileService = Get.find();
  final HistoryService _historyService = Get.find();

  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'آماده برای شروع'.obs;
  final RxList<String> recentPaths = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    recentPaths.value = _historyService.getHistory();
  }

  Future<void> pickAndProcessProjectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;

    isLoading.value = true;
    _showProgressDialog('فایل "${file.name}"');
    try {
      final content = await File(file.path!).readAsString();
      _navigateToEditor(content);
    } catch (e) {
      _showErrorDialog('خطای بحرانی', 'مشکلی در پردازش فایل رخ داد: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndProcessProjectDirectory() async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) {
      return;
    }
    await processPath(directoryPath);
  }

  Future<void> processPath(String path) async {
    isLoading.value = true;
    _showProgressDialog('پوشه: $path');
    try {
      await _historyService.addPathToHistory(path);
      loadHistory();
      final content = await _fileService.processDirectory(path);
      _navigateToEditor(content);
    } catch (e) {
      _showErrorDialog('خطای بحرانی', 'مشکلی در پردازش پوشه رخ داد: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processPathFromHistory(String path) async {
    await processPath(path);
  }

  void _navigateToEditor(String fullContent) {
    final directoryTree = _fileService.extractDirectoryTree(fullContent);
    final pubspecContent =
        _fileService.extractFileContent(fullContent, 'pubspec.yaml');

    if (directoryTree.isEmpty) {
      _showErrorDialog('خطای تحلیل فایل',
          'ساختار فایل ورودی نامعتبر است یا نمودار درختی یافت نشد.');
      return;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.toNamed(
      AppPages.contextEditor,
      arguments: {
        'fullProjectContent': fullContent,
        'directoryTree': directoryTree,
        'pubspecContent': pubspecContent,
      },
    );
  }

  // <<< اصلاح کامل: بازنویسی دیالوگ با سبک Glassmorphism >>>
  void _showProgressDialog(String title) {
    statusMessage.value = 'در حال خواندن و ساختاربندی فایل‌ها...';
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent, // برای نمایش افکت شیشه
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: AppTheme.glassmorphism(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text('در حال پردازش',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 16),
                Obx(() => Text(statusMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)))),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog(String title, String message) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      middleText: message,
      middleTextStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      backgroundColor: AppColors.secondary.withOpacity(0.85),
      textConfirm: 'متوجه شدم',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () => Get.back(),
    );
  }
}
