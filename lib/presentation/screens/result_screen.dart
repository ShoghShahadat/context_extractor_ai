import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/result_controller.dart';
import '../theme/app_theme.dart';

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
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: SelectableText(
            controller.generatedCode,
            style: GoogleFonts.sourceCodePro(
              color: AppColors.textSecondary,
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
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'copy_button',
          onPressed: controller.copyToClipboard,
          label: const Text('کپی کل کد'),
          icon: const Icon(Iconsax.copy),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
