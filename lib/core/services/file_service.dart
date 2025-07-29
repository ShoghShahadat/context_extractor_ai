import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// سرویسی برای تحلیل و استخراج اطلاعات از فایل‌ها و پوشه‌های پروژه.
class FileService {
  // پسوندهای فایل‌های کدی که باید در خروجی گنجانده شوند
  static const _codeExtensions = {
    '.dart', '.yaml', '.json', '.md', '.txt', // General & Flutter
    '.js', '.ts', '.html', '.css', // Web
    '.py', '.java', '.kt', '.swift', // Other languages
    '.c', '.cpp', '.h', '.cs', '.go', '.rs', '.php'
  };

  // پوشه‌هایی که باید در پیمایش نادیده گرفته شوند
  static const _excludedDirs = {
    '.git', '.idea', 'build', 'dist', '.vscode',
    '.dart_tool', 'linux', 'windows', 'macos', 'ios',
    'android', // Flutter/Dart specific
    '__pycache__', 'venv', 'node_modules'
  };

  /// <<< قابلیت جدید: پردازش یک پوشه کامل >>>
  /// یک پوشه را پیمایش کرده و محتوای آن را به فرمت متنی استاندارد برنامه تبدیل می‌کند.
  Future<String> processDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception("پوشه انتخاب شده وجود ندارد: $directoryPath");
    }

    final List<File> codeFiles = [];
    final basePath = directory.path;

    // شروع پیمایش بازگشتی برای جمع‌آوری فایل‌ها
    await for (final entity
        in directory.list(recursive: true, followLinks: false)) {
      // نادیده گرفتن پوشه‌های مشخص شده
      if (entity is Directory &&
          _excludedDirs.contains(p.basename(entity.path))) {
        continue;
      }

      if (entity is File) {
        // فقط فایل‌هایی با پسوند مجاز را اضافه کن
        if (_codeExtensions.contains(p.extension(entity.path))) {
          // اطمینان از اینکه فایل در پوشه مستثنی شده قرار ندارد
          if (!_isPathInExcludedDir(entity.path, basePath)) {
            codeFiles.add(entity);
          }
        }
      }
    }

    // مرتب‌سازی فایل‌ها برای خروجی منظم
    codeFiles.sort((a, b) => a.path.compareTo(b.path));

    // ساخت خروجی نهایی
    final buffer = StringBuffer();

    // 1. نوشتن نمودار درختی
    buffer.writeln("_____________________________________");
    buffer.writeln("نمودار درختی دایرکتوری :");
    for (final file in codeFiles) {
      buffer.writeln(p.relative(file.path, from: basePath));
    }
    buffer.writeln("_____________________________________");
    buffer.writeln();

    // 2. نوشتن محتوای هر فایل
    for (var i = 0; i < codeFiles.length; i++) {
      final file = codeFiles[i];
      final relativePath = p.relative(file.path, from: basePath);
      buffer.writeln('فایل شماره:${i + 1}');
      buffer.writeln('/------------------------------------');
      buffer.writeln('مسیر فایل: $relativePath');
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

  /// یک تابع کمکی برای بررسی اینکه آیا مسیر یک فایل درون یکی از پوشه‌های مستثنی شده قرار دارد یا خیر
  bool _isPathInExcludedDir(String path, String basePath) {
    final relativePath = p.relative(path, from: basePath);
    final parts = p.split(relativePath);
    // اگر هر یک از بخش‌های مسیر در لیست پوشه‌های مستثنی شده باشد، true برمی‌گرداند
    return parts.any((part) => _excludedDirs.contains(part));
  }

  /// نمودار درختی دایرکتوری پروژه را از متن خام استخراج می‌کند.
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

  /// محتوای یک فایل خاص را بر اساس مسیر آن از متن خام استخراج می‌کند.
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
}
