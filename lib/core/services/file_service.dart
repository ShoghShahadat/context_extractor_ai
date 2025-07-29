import 'package:flutter/foundation.dart';

/// سرویسی برای تحلیل و استخراج اطلاعات از فایل متنی پروژه.
class FileService {
  /// نمودار درختی دایرکتوری پروژه را از متن خام استخراج می‌کند.
  String extractDirectoryTree(String fileContent) {
    try {
      final startIndex = fileContent.indexOf('نمودار درختی دایرکتوری :');
      final endIndex = fileContent.indexOf(
          '_____________________________________', startIndex);
      if (startIndex != -1 && endIndex != -1) {
        // استخراج متن بین دو نشانگر و حذف خطوط خالی اضافی
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
      // <<< اصلاح کلیدی: کنترل هر دو نوع جداکننده مسیر ( / و \ ) >>>
      // این کار باعث می‌شود برنامه هم در ویندوز و هم در سایر سیستم‌عامل‌ها به درستی کار کند.
      final forwardSlashPath = filePath.replaceAll(r'\', '/');
      final backwardSlashPath = filePath.replaceAll(r'/', r'\');

      final forwardMarker = 'مسیر فایل:$forwardSlashPath';
      final backwardMarker = 'مسیر فایل:$backwardSlashPath';

      // ابتدا با مارکر استاندارد (/) جستجو کن
      var startIndex = fullText.indexOf(forwardMarker);
      // اگر پیدا نشد، با مارکر ویندوز (\) جستجو کن
      if (startIndex == -1) {
        startIndex = fullText.indexOf(backwardMarker);
      }

      if (startIndex == -1) {
        debugPrint('File content not found for path: $filePath');
        return '// محتوای فایل "$filePath" یافت نشد.';
      }

      // پیدا کردن ابتدای محتوای فایل بعد از خط "محتوای فایل:"
      final contentStartIndex =
          fullText.indexOf('محتوای فایل:', startIndex) + 'محتوای فایل:'.length;

      // پیدا کردن انتهای محتوای فایل قبل از جداکننده بعدی
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
