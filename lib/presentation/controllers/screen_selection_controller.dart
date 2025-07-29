import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/project_analysis.dart';
import '../../core/services/file_service.dart';
import '../../core/services/gemini_service.dart';
import '../routes/app_pages.dart';

class ScreenSelectionController extends GetxController {
  final FileService _fileService = Get.find();
  final GeminiService _geminiService = Get.find();

  late final List<ProjectScreen> allScreens;
  late final String fullProjectContent;
  late final String directoryTree;

  final RxList<ProjectScreen> filteredScreens = <ProjectScreen>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isGenerating = false.obs;
  final RxString generationStatus = 'تولید کد زمینه'.obs;

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
    if (query.isEmpty) {
      filteredScreens.assignAll(allScreens);
    } else {
      filteredScreens.assignAll(allScreens.where((screen) =>
          screen.displayName.toLowerCase().contains(query.toLowerCase()) ||
          screen.screenName.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void toggleSelection(ProjectScreen screen) {
    screen.isSelected.toggle();
  }

  /// <<< متد جدید برای مدیریت باز و بسته شدن آیتم‌ها >>>
  void toggleExpansion(ProjectScreen screen) {
    screen.isExpanded.toggle();
  }

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
      final String aiHeader =
          await _geminiService.generateAiHeader(selectedScreens, directoryTree);

      generationStatus.value = 'در حال تجمیع فایل‌ها...';
      await Future.delayed(const Duration(milliseconds: 200));

      final StringBuffer codeBuffer = StringBuffer();
      codeBuffer.writeln(aiHeader);
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
