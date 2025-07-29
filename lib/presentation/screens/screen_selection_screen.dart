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
                  return _buildCustomExpansionTile(screen);
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

  /// <<< ویجت سفارشی و نهایی برای حل قطعی مشکل کلیک >>>
  Widget _buildCustomExpansionTile(ProjectScreen screen) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // هدر سفارشی که کلیک آن فقط برای باز و بسته کردن است
            InkWell(
              onTap: () => controller.toggleExpansion(screen),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // چک‌باکس که حالا کلیک آن به درستی کار می‌کند
                    Checkbox(
                      value: screen.isSelected.value,
                      onChanged: (bool? value) {
                        controller.toggleSelection(screen);
                      },
                      activeColor: Colors.teal,
                    ),
                    Expanded(
                      child: Text(
                        screen.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    // آیکون برای نمایش وضعیت
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        screen.isExpanded.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // محتوای بازشونده با انیمیشن
            AnimatedCrossFade(
              firstChild: Container(), // حالت بسته
              secondChild: _buildExpansionContent(screen), // حالت باز
              crossFadeState: screen.isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  /// ویجت کمکی برای محتوای داخلی
  Widget _buildExpansionContent(ProjectScreen screen) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
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
                      fontStyle: FontStyle.italic, color: Colors.grey.shade700),
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
    );
  }

  /// ویجت کمکی برای نمایش هر فایل در لیست
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
