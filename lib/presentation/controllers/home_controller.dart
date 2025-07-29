import 'dart:convert';
import 'package:file_selector/file_selector.dart'; // <<< جایگزینی: ایمپورت پکیج جدید
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/services/file_service.dart';
import '../../core/services/gemini_service.dart';
import '../routes/app_pages.dart';

class HomeController extends GetxController {
  final FileService _fileService = Get.find();
  final GeminiService _geminiService = Get.find();

  final RxBool isLoading = false.obs;
  final RxString statusMessage = 'آماده برای شروع'.obs;

  /// متد اصلی برای انتخاب فایل و شروع فرآیند تحلیل با پکیج جدید
  Future<void> pickAndProcessProjectFile() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Text Files',
      extensions: <String>['txt'],
    );

    debugPrint('[LOG] Calling official file_selector...');
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      debugPrint('[LOG] File selection was cancelled by the user.');
      // نیازی به نمایش دیالوگ نیست، چون کاربر خودش لغو کرده است.
      return;
    }

    isLoading.value = true;
    _showProgressDialog();

    try {
      statusMessage.value =
          'فایل "${file.name}" انتخاب شد. در حال خواندن محتوا...';
      debugPrint('[LOG] File picked: ${file.name}. Reading content...');
      final content = await file.readAsString();

      await _analyzeContent(content);
    } catch (e) {
      debugPrint("[CRITICAL ERROR] in file processing: $e");
      _showErrorDialog('خطای بحرانی', 'مشکلی در پردازش فایل رخ داد: $e');
    } finally {
      _closeDialogAndResetState();
    }
  }

  /// منطق تحلیل که بدون تغییر باقی مانده است
  Future<void> _analyzeContent(String content) async {
    statusMessage.value = 'محتوا خوانده شد. در حال استخراج ساختار پروژه...';
    debugPrint('[LOG] Content read. Extracting project structure...');
    final directoryTree = _fileService.extractDirectoryTree(content);
    final pubspecContent =
        _fileService.extractFileContent(content, 'pubspec.yaml');

    if (directoryTree.isEmpty || pubspecContent.isEmpty) {
      _showErrorDialog('خطای تحلیل فایل',
          'ساختار فایل ورودی نامعتبر است یا فایل pubspec.yaml یافت نشد.');
      return;
    }

    statusMessage.value =
        'ساختار استخراج شد. در حال ارسال به هوش مصنوعی جمنای...';
    debugPrint('[LOG] Structure extracted. Sending to Gemini AI...');
    final screens = await _geminiService.analyzeProjectStructure(
        directoryTree, pubspecContent);

    if (screens.isNotEmpty) {
      statusMessage.value = 'تحلیل موفق! ${screens.length} صفحه شناسایی شد.';
      debugPrint('[LOG] Analysis successful. Found ${screens.length} screens.');
      Get.back(); // بستن دیالوگ پیشرفت
      Get.toNamed(
        AppPages.screenSelection,
        arguments: {
          'screens': screens,
          'content': content,
        },
      );
    } else {
      _showErrorDialog('تحلیل ناموفق',
          'هیچ صفحه‌ای توسط هوش مصنوعی شناسایی نشد. لطفاً ساختار فایل front.txt را بررسی کنید.');
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
