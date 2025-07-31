import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/result_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

// <<< اصلاح: حذف const از سازنده >>>
class ResultScreen extends GetView<ResultController> {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سند نهایی تولید شده'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant, // sidebar color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Get.theme.dividerColor),
          ),
          child: SelectableText(
            controller.generatedCode,
            style: GoogleFonts.sourceCodePro(
              color: Get.theme.colorScheme.tertiary, // textSecondary
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
      floatingActionButton: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'save_button',
          onPressed: controller.saveToFile,
          label: const Text('ذخیره فایل'),
          icon: const Icon(Iconsax.save_2),
          backgroundColor: Get.theme.colorScheme.surface,
          foregroundColor: Get.theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Get.theme.dividerColor),
          ),
        ),
        const SizedBox(width: 16),
        GradientButton(
          onPressed: controller.copyToClipboard,
          icon: const Icon(Iconsax.copy, color: AppColors.onPrimary),
          label: const Text(
            'کپی کل کد',
            style: TextStyle(color: AppColors.onPrimary),
          ),
        ),
      ],
    );
  }
}
