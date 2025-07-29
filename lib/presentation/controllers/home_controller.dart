import 'dart:io'; // <<< اصلاح: ایمپورت کتابخانه dart:io برای استفاده از کلاس File
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/file_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/history_service.dart';
import '../routes/app_pages.dart';

class HomeController extends GetxController {
  final FileService _fileService = Get.find();
  final GeminiService _geminiService = Get.find();
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

  /// انتخاب فایل متنی (عملکرد قبلی)
  Future<void> pickAndProcessProjectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }
    final file = result.files.single;

    isLoading.value = true;
    _showProgressDialog();

    try {
      statusMessage.value =
          'فایل "${file.name}" انتخاب شد. در حال خواندن محتوا...';
      // <<< اصلاح: استفاده از کلاس File که حالا به درستی ایمپورت شده >>>
      final content = await File(file.path!).readAsString();
      await _analyzeContent(content);
    } catch (e) {
      _showErrorDialog('خطای بحرانی', 'مشکلی در پردازش فایل رخ داد: $e');
    } finally {
      _closeDialogAndResetState();
    }
  }

  /// انتخاب پوشه پروژه
  Future<void> pickAndProcessProjectDirectory() async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath == null) {
      return;
    }

    await processPath(directoryPath);
  }

  /// پردازش یک مسیر از تاریخچه
  Future<void> processPathFromHistory(String path) async {
    await processPath(path);
  }

  /// متد مرکزی برای پردازش یک مسیر
  Future<void> processPath(String path) async {
    isLoading.value = true;
    _showProgressDialog();

    try {
      statusMessage.value = 'در حال پردازش پوشه: $path';
      await _historyService.addPathToHistory(path);
      loadHistory();

      final content = await _fileService.processDirectory(path);
      await _analyzeContent(content);
    } catch (e) {
      _showErrorDialog('خطای بحرانی', 'مشکلی در پردازش پوشه رخ داد: $e');
    } finally {
      _closeDialogAndResetState();
    }
  }

  /// منطق مشترک برای تحلیل محتوای تولید شده
  Future<void> _analyzeContent(String content) async {
    statusMessage.value = 'محتوا آماده شد. در حال استخراج ساختار پروژه...';
    final directoryTree = _fileService.extractDirectoryTree(content);
    final pubspecContent =
        _fileService.extractFileContent(content, 'pubspec.yaml');

    if (directoryTree.isEmpty) {
      _showErrorDialog('خطای تحلیل',
          'ساختار پروژه (نمودار درختی) یافت نشد. لطفاً ورودی را بررسی کنید.');
      return;
    }
    if (pubspecContent.isEmpty) {
      statusMessage.value = 'هشدار: فایل pubspec.yaml یافت نشد.';
    }

    statusMessage.value =
        'ساختار استخراج شد. در حال ارسال به هوش مصنوعی جمنای...';
    final screens = await _geminiService.analyzeProjectStructure(
        directoryTree, pubspecContent);

    if (screens.isNotEmpty) {
      statusMessage.value = 'تحلیل موفق! ${screens.length} صفحه شناسایی شد.';
      Get.back();
      Get.toNamed(
        AppPages.screenSelection,
        arguments: {
          'screens': screens,
          'content': content,
          'directoryTree': directoryTree,
        },
      );
    } else {
      _showErrorDialog(
          'تحلیل ناموفق', 'هیچ صفحه‌ای توسط هوش مصنوعی شناسایی نشد.');
    }
  }

  void _showProgressDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('در حال تحلیل پروژه...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Obx(() => Text(statusMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600))),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog(String title, String message) {
    if (Get.isDialogOpen ?? false) Get.back();
    Get.defaultDialog(
      title: title,
      titleStyle:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
      middleText: message,
      middleTextStyle: const TextStyle(fontSize: 16),
      backgroundColor: Colors.white,
      radius: 16,
      textConfirm: 'متوجه شدم',
      buttonColor: Colors.teal,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void _closeDialogAndResetState() {
    if (Get.isDialogOpen ?? false) Get.back();
    isLoading.value = false;
    statusMessage.value = 'آماده برای شروع';
  }
}
