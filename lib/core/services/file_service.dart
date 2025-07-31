import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'settings_service.dart'; // <<< جدید: ایمپورت سرویس تنظیمات

/// سرویسی برای تحلیل و استخراج اطلاعات از فایل‌ها و پوشه‌های پروژه.
class FileService extends GetxService {
  // <<< اصلاح: وابستگی به سرویس تنظیمات >>>
  final SettingsService _settingsService = Get.find();

  // پسوندهای فایل‌های کدی که باید در خروجی گنجانده شوند
  static const _codeExtensions = {
    '.dart', '.yaml', '.json', '.md', '.txt', // General & Flutter
    '.js', '.ts', '.html', '.css', // Web
    '.py', '.java', '.kt', '.swift', // Other languages
    '.c', '.cpp', '.h', '.cs', '.go', '.rs', '.php'
  };

  /// یک پوشه را پیمایش کرده و محتوای آن را به فرمت متنی استاندارد برنامه تبدیل می‌کند.
  Future<String> processDirectory(String directoryPath) async {
    // <<< اصلاح: خواندن لیست پوشه‌های مستثنی از سرویس تنظیمات >>>
    final excludedDirs = _settingsService.getExcludedDirs().toSet();

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception("پوشه انتخاب شده وجود ندارد: $directoryPath");
    }

    final List<File> codeFiles = [];
    final basePath = directory.path;

    await for (final entity
        in directory.list(recursive: true, followLinks: false)) {
      if (entity is Directory &&
          excludedDirs.contains(p.basename(entity.path))) {
        continue;
      }

      if (entity is File) {
        if (_codeExtensions.contains(p.extension(entity.path))) {
          if (!_isPathInExcludedDir(entity.path, basePath, excludedDirs)) {
            codeFiles.add(entity);
          }
        }
      }
    }

    codeFiles.sort((a, b) => a.path.compareTo(b.path));

    final buffer = StringBuffer();

    buffer.writeln("_____________________________________");
    buffer.writeln("نمودار درختی دایرکتوری :");
    for (final file in codeFiles) {
      buffer.writeln(p.relative(file.path, from: basePath));
    }
    buffer.writeln("_____________________________________");
    buffer.writeln();

    for (var i = 0; i < codeFiles.length; i++) {
      final file = codeFiles[i];
      final relativePath = p.relative(file.path, from: basePath);
      buffer.writeln('فایل شماره:${i + 1}');
      buffer.writeln('/------------------------------------');
      buffer.writeln('مسیر فایل:$relativePath');
      buffer.writeln('محتوای فایل:');
      try {
        final content = await file.readAsString();
        buffer.writeln(content);
      } catch (e) {
        buffer.writeln('[خطا در خواندن فایل: $e]');
      }
      buffer.writeln('------------------------------------/\n');
    }

    return buffer.toString();
  }

  bool _isPathInExcludedDir(
      String path, String basePath, Set<String> excludedDirs) {
    final relativePath = p.relative(path, from: basePath);
    final parts = p.split(relativePath);
    return parts.any((part) => excludedDirs.contains(part));
  }

  // ... (متدهای extractDirectoryTree, extractFileContent, parseProjectContent, extractImports بدون تغییر) ...
  String extractDirectoryTree(String fileContent) {
    try {
      final startIndex = fileContent.indexOf('نمودار درختی دایرکتوری :');
      final endIndex = fileContent.indexOf(
          '_____________________________________', startIndex);
      if (startIndex != -1 && endIndex != -1) {
        return fileContent.substring(startIndex, endIndex).trim();
      }
      return '';
    } catch (e) {
      debugPrint("Error extracting directory tree: $e");
      return '';
    }
  }

  String extractFileContent(String fullText, String filePath) {
    try {
      final forwardSlashPath = filePath.replaceAll(r'\', '/');
      final backwardSlashPath = filePath.replaceAll(r'/', r'\');

      final forwardMarker = 'مسیر فایل:$forwardSlashPath';
      final backwardMarker = 'مسیر فایل:$backwardSlashPath';

      var startIndex = fullText.indexOf(forwardMarker);
      if (startIndex == -1) {
        startIndex = fullText.indexOf(backwardMarker);
      }

      if (startIndex == -1) {
        debugPrint('File content not found for path: $filePath');
        return '// محتوای فایل "$filePath" یافت نشد.';
      }

      final contentStartIndex =
          fullText.indexOf('محتوای فایل:', startIndex) + 'محتوای فایل:'.length;

      final contentEndIndex = fullText.indexOf(
          '------------------------------------/', contentStartIndex);

      if (contentStartIndex > -1 && contentEndIndex > -1) {
        return fullText.substring(contentStartIndex, contentEndIndex).trim();
      }

      return '// خطایی در استخراج محتوای فایل "$filePath" رخ داد.';
    } catch (e) {
      debugPrint("Error extracting file content for $filePath: $e");
      return '// خطای استثنا در استخراج محتوای فایل "$filePath".';
    }
  }

  Map<String, String> parseProjectContent(String fullProjectContent) {
    final Map<String, String> filesMap = {};
    const separator = '/------------------------------------';
    final parts = fullProjectContent.split(separator);

    for (int i = 1; i < parts.length; i++) {
      final block = parts[i].trim();
      if (block.isEmpty) continue;

      try {
        final pathLineEnd = block.indexOf('\n');
        if (pathLineEnd == -1) continue;

        final pathLine = block.substring(0, pathLineEnd).trim();
        final filePath = pathLine.replaceFirst('مسیر فایل:', '').trim();

        const contentMarker = 'محتوای فایل:';
        final contentStartIndex = block.indexOf(contentMarker);
        if (contentStartIndex != -1) {
          final content = block
              .substring(contentStartIndex + contentMarker.length)
              .split('------------------------------------/')[0]
              .trim();

          if (filePath.isNotEmpty) {
            filesMap[filePath] = content;
          }
        }
      } catch (e) {
        debugPrint('Error parsing file block: $e');
      }
    }
    return filesMap;
  }

  String extractImports(String fileContent) {
    var importRegex = RegExp(r"^(import|export|part)\s+.*?;", multiLine: true);
    final matches = importRegex.allMatches(fileContent);
    if (matches.isEmpty) {
      return '';
    }
    return matches.map((m) => m.group(0)!).join('\n');
  }
}
