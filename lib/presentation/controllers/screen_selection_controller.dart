import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/project_analysis.dart';
import '../../core/services/file_service.dart';
import '../../core/services/gemini_service.dart'; // <<< جدید: برای استفاده از سرویس جمنای
import '../routes/app_pages.dart';

class ScreenSelectionController extends GetxController {
  final FileService _fileService = Get.find();
  final GeminiService _geminiService =
      Get.find(); // <<< جدید: تزریق سرویس جمنای

  late final List<ProjectScreen> allScreens;
  late final String fullProjectContent;
  late final String directoryTree;

  final RxList<ProjectScreen> filteredScreens = <ProjectScreen>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isGenerating = false.obs;
  final RxString generationStatus =
      'تولید کد زمینه'.obs; // <<< جدید: برای نمایش وضعیت

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    allScreens = args['screens'] as List<ProjectScreen>;
    fullProjectContent = args['content'] as String;
    directoryTree = args['directoryTree'] as String;

    filteredScreens.assignAll(allScreens);
  }

  void filterScreens(String query) {
    // ... (بدون تغییر)
  }

  void toggleSelection(ProjectScreen screen) {
    // ... (بدون تغییر)
  }

  /// <<< اصلاح کلیدی: متد تولید کد حالا کاملاً هوشمند است >>>
  Future<void> generateFinalCode() async {
    final List<ProjectScreen> selectedScreens =
        allScreens.where((s) => s.isSelected.value).toList();

    if (selectedScreens.isEmpty) {
      Get.snackbar('خطا', 'لطفاً حداقل یک صفحه را برای استخراج انتخاب کنید.');
      return;
    }

    isGenerating.value = true;
    generationStatus.value = 'در حال تولید مقدمه هوشمند...';

    try {
      // ۱. تولید مقدمه توسط هوش مصنوعی
      final String aiHeader =
          await _geminiService.generateAiHeader(selectedScreens, directoryTree);

      generationStatus.value = 'در حال تجمیع فایل‌ها...';
      await Future.delayed(
          const Duration(milliseconds: 200)); // تاخیر برای نمایش پیام

      // ۲. تجمیع کدها
      final StringBuffer codeBuffer = StringBuffer();
      codeBuffer.writeln(aiHeader); // اضافه کردن مقدمه هوشمند
      codeBuffer.writeln('\n');

      final Set<String> includedFiles = {};

      final pubspecContent =
          _fileService.extractFileContent(fullProjectContent, 'pubspec.yaml');
      _appendFileToBuffer(codeBuffer, 'pubspec.yaml', pubspecContent);
      includedFiles.add('pubspec.yaml');

      for (var screen in selectedScreens) {
        if (!includedFiles.contains(screen.screenName)) {
          final screenContent = _fileService.extractFileContent(
              fullProjectContent, screen.screenName);
          _appendFileToBuffer(codeBuffer, screen.screenName, screenContent);
          includedFiles.add(screen.screenName);
        }

        for (var relatedFile in screen.relatedFiles) {
          if (!includedFiles.contains(relatedFile)) {
            final fileContent = _fileService.extractFileContent(
                fullProjectContent, relatedFile);
            _appendFileToBuffer(codeBuffer, relatedFile, fileContent);
            includedFiles.add(relatedFile);
          }
        }
      }

      // ۳. هدایت به صفحه نتیجه
      Get.toNamed(AppPages.result, arguments: codeBuffer.toString());
    } catch (e) {
      Get.snackbar('خطا', 'مشکلی در تولید کد رخ داد: $e');
    } finally {
      isGenerating.value = false;
      generationStatus.value = 'تولید کد زمینه';
    }
  }

  void _appendFileToBuffer(StringBuffer buffer, String path, String content) {
    buffer.writeln('/------------------------------------');
    buffer.writeln('مسیر فایل: $path');
    buffer.writeln('محتوای فایل:');
    buffer.writeln(content);
    buffer.writeln('------------------------------------/\n');
  }
}
