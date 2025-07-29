import 'dart:io'; // <<< اصلاح: ایمپورت برای استفاده از کلاس File
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart'; // <<< اصلاح: استفاده از پکیج file_picker
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

  /// <<< اصلاح کامل: بازنویسی منطق ذخیره فایل با استفاده از file_picker >>>
  Future<void> saveToFile() async {
    try {
      // نام پیشنهادی برای فایل خروجی
      const String fileName = 'generated_context.txt';

      // باز کردن دیالوگ ذخیره فایل و گرفتن مسیر از کاربر
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'لطفاً مسیر ذخیره فایل را انتخاب کنید:',
        fileName: fileName,
      );

      // اگر کاربر پنجره را بست، مسیر null خواهد بود
      if (outputPath == null) {
        Get.snackbar('لغو شد', 'عملیات ذخیره فایل توسط شما لغو شد.');
        return;
      }

      // ایجاد یک فایل در مسیر انتخاب شده و نوشتن محتوا در آن
      final file = File(outputPath);
      await file.writeAsString(generatedCode);

      Get.snackbar(
        'ذخیره شد!',
        'فایل با موفقیت در مسیر "$outputPath" ذخیره گردید.',
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
