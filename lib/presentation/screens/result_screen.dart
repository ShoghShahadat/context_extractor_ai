import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/result_controller.dart';

class ResultScreen extends GetView<ResultController> {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF282C34), // پس‌زمینه تیره شبیه ویرایشگر کد
      appBar: AppBar(
        title: const Text('کد نهایی تولید شده'),
        backgroundColor: const Color(0xFF21252B),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(16, 16, 16, 80), // فاصله برای دکمه‌ها
        child: SelectableText(
          controller.generatedCode,
          style: GoogleFonts.sourceCodePro(
            // فونت مناسب برای کد
            color: Colors.white,
            fontSize: 14,
            height: 1.5, // فاصله بین خطوط
          ),
        ),
      ),
      // <<< اصلاح کلیدی: استفاده از Row برای نمایش دو دکمه شناور >>>
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'save_button', // تگ منحصر به فرد
              onPressed: controller.saveToFile,
              label: const Text('ذخیره فایل'),
              icon: const Icon(Iconsax.save_2),
              backgroundColor: Colors.blue.shade600,
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: 'copy_button', // تگ منحصر به فرد
              onPressed: controller.copyToClipboard,
              label: const Text('کپی کل کد'),
              icon: const Icon(Iconsax.copy),
              backgroundColor: Colors.teal.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
