import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/project_analysis.dart';
import '../controllers/screen_selection_controller.dart';

class ScreenSelectionScreen extends GetView<ScreenSelectionController> {
  const ScreenSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب صفحات مورد نظر'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجوی صفحه...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.filterScreens(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filteredScreens.isEmpty) {
                return const Center(
                    child: Text('صفحه‌ای با این نام یافت نشد.'));
              }
              return ListView.builder(
                itemCount: controller.filteredScreens.length,
                itemBuilder: (context, index) {
                  final screen = controller.filteredScreens[index];
                  return _buildScreenTile(screen);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isGenerating.value
                ? null
                : controller.generateFinalCode,
            label: Text(controller.generationStatus.value),
            icon: controller.isGenerating.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Iconsax.code_1),
          )),
    );
  }

  /// <<< ویجت اصلاح شده برای رفع مشکل عدم انتخاب >>>
  Widget _buildScreenTile(ProjectScreen screen) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // برای جلوگیری از بیرون زدن رنگ
      child: ExpansionTile(
        key: PageStorageKey(screen.screenName),
        // <<< اصلاح کلیدی: ساختن یک عنوان سفارشی برای حل تداخل کلیک >>>
        title: Row(
          children: [
            // Checkbox حالا در یک Row قرار دارد و کلیک آن به درستی کار می‌کند
            Obx(() => Checkbox(
                  value: screen.isSelected.value,
                  onChanged: (bool? value) {
                    controller.toggleSelection(screen);
                  },
                  activeColor: Colors.teal,
                )),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                screen.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // حذف کردن padding پیش‌فرض برای هماهنگی با ساختار جدید
        tilePadding: const EdgeInsets.only(left: 16.0),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.message_question,
                        size: 18, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        screen.explanation,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'فایل‌های مرتبط (${screen.relatedFiles.length + 1}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFileListItem(screen.screenName, isScreen: true),
                ...screen.relatedFiles.map((file) => _buildFileListItem(file)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFileListItem(String filePath, {bool isScreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
      child: Row(
        children: [
          Icon(
            isScreen ? Iconsax.monitor : Iconsax.document,
            size: 16,
            color: isScreen ? Colors.teal : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filePath.replaceAll(r'\', '/'),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: isScreen ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
