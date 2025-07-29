import 'dart:convert'; // برای استفاده از utf8
import 'dart:typed_data'; // برای تبدیل رشته به بایت
import 'package:clipboard/clipboard.dart';
// وارد کردن پکیج با یک نام مستعار (fs) برای خوانایی
import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultController extends GetxController {
  // کد نهایی که از صفحه قبل دریافت می‌شود
  late final String generatedCode;

  @override
  void onInit() {
    super.onInit();
    // دریافت کد از آرگومان‌های مسیر
    generatedCode = Get.arguments as String? ?? 'کدی برای نمایش وجود ندارد.';
  }

  /// کپی کردن کد در کلیپ‌بورد و نمایش پیام موفقیت
  void copyToClipboard() {
    FlutterClipboard.copy(generatedCode).then((_) {
      Get.snackbar(
        'موفقیت!',
        'کد با موفقیت در کلیپ‌بورد شما کپی شد.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// قابلیت جدید: ذخیره کد نهایی در یک فایل متنی
  Future<void> saveToFile() async {
    try {
      // نام پیشنهادی برای فایل خروجی
      const String fileName = 'generated_context.txt';

      // <<< اصلاح ۱: استفاده از نوع صحیح FileSaveLocation? برای متغیر >>>
      final fs.FileSaveLocation? result = await fs.getSaveLocation(
        suggestedName: fileName,
      );

      // اگر کاربر پنجره را بست، نتیجه null خواهد بود
      if (result == null) {
        Get.snackbar('لغو شد', 'عملیات ذخیره فایل توسط شما لغو شد.');
        return;
      }

      final Uint8List fileData = utf8.encode(generatedCode);

      final fs.XFile textFile = fs.XFile.fromData(
        fileData,
        name: fileName,
        mimeType: 'text/plain',
      );

      // <<< اصلاح ۲: استفاده از result.path برای دسترسی به مسیر رشته‌ای >>>
      await textFile.saveTo(result.path);

      Get.snackbar(
        'ذخیره شد!',
        'فایل با موفقیت در مسیر "${result.path}" ذخیره گردید.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطا در ذخیره',
        'مشکلی در ذخیره فایل رخ داد: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
