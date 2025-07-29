import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/project_analysis.dart';
import '../../core/services/file_service.dart';
import '../routes/app_pages.dart';

class ScreenSelectionController extends GetxController {
  final FileService _fileService = Get.find();

  // داده‌های دریافت شده از HomeController
  late final List<ProjectScreen> allScreens;
  late final String fullProjectContent;

  final RxList<ProjectScreen> filteredScreens = <ProjectScreen>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    // دریافت آرگومان‌ها از صفحه قبلی
    final args = Get.arguments as Map<String, dynamic>;
    allScreens = args['screens'] as List<ProjectScreen>;
    fullProjectContent = args['content'] as String;

    // در ابتدا همه اسکرین‌ها نمایش داده می‌شوند
    filteredScreens.assignAll(allScreens);
  }

  /// فیلتر کردن لیست صفحات بر اساس جستجوی کاربر
  void filterScreens(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredScreens.assignAll(allScreens);
    } else {
      // جستجو در نام نمایشی و مسیر کامل فایل
      filteredScreens.assignAll(allScreens.where((screen) =>
          screen.displayName.toLowerCase().contains(query.toLowerCase()) ||
          screen.screenName.toLowerCase().contains(query.toLowerCase())));
    }
  }

  /// تغییر وضعیت انتخاب یک صفحه
  void toggleSelection(ProjectScreen screen) {
    screen.isSelected.toggle();
  }

  /// تولید کد نهایی و هدایت به صفحه نتیجه
  void generateFinalCode() {
    isGenerating.value = true;

    // استفاده از Future.delayed برای نمایش بهتر انیمیشن لودینگ
    Future.delayed(const Duration(milliseconds: 500), () {
      final List<ProjectScreen> selectedScreens =
          allScreens.where((s) => s.isSelected.value).toList();

      if (selectedScreens.isEmpty) {
        Get.snackbar('خطا', 'لطفاً حداقل یک صفحه را برای استخراج انتخاب کنید.');
        isGenerating.value = false;
        return;
      }

      final StringBuffer codeBuffer = StringBuffer();
      final Set<String> includedFiles = {};

      // اضافه کردن pubspec.yaml به عنوان اولین فایل
      final pubspecContent =
          _fileService.extractFileContent(fullProjectContent, 'pubspec.yaml');
      _appendFileToBuffer(codeBuffer, 'pubspec.yaml', pubspecContent);
      includedFiles.add('pubspec.yaml');

      // اضافه کردن main.dart همیشه
      if (!includedFiles.contains('lib/main.dart')) {
        final mainContent = _fileService.extractFileContent(
            fullProjectContent, 'lib/main.dart');
        _appendFileToBuffer(codeBuffer, 'lib/main.dart', mainContent);
        includedFiles.add('lib/main.dart');
      }

      for (var screen in selectedScreens) {
        // ۱. اضافه کردن فایل اصلی اسکرین
        if (!includedFiles.contains(screen.screenName)) {
          final screenContent = _fileService.extractFileContent(
              fullProjectContent, screen.screenName);
          _appendFileToBuffer(codeBuffer, screen.screenName, screenContent);
          includedFiles.add(screen.screenName);
        }

        // ۲. اضافه کردن فایل‌های مرتبط
        for (var relatedFile in screen.relatedFiles) {
          if (!includedFiles.contains(relatedFile)) {
            final fileContent = _fileService.extractFileContent(
                fullProjectContent, relatedFile);
            _appendFileToBuffer(codeBuffer, relatedFile, fileContent);
            includedFiles.add(relatedFile);
          }
        }
      }

      isGenerating.value = false;

      // هدایت به صفحه نتیجه و ارسال کد نهایی
      Get.toNamed(AppPages.result, arguments: codeBuffer.toString());
    });
  }

  /// متد کمکی برای اضافه کردن محتوای فایل به بافر با فرمت مشخص
  void _appendFileToBuffer(StringBuffer buffer, String path, String content) {
    buffer.writeln('/------------------------------------');
    buffer.writeln('مسیر فایل: $path');
    buffer.writeln('محتوای فایل:');
    buffer.writeln(content);
    buffer.writeln('------------------------------------/\n');
  }
}
