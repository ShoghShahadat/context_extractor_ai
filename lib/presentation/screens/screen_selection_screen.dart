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
        title: const Text('انتخاب صفحات و تعریف هدف'),
      ),
      body: Column(
        children: [
          // <<< بخش جدید: فیلد ورود هدف کاربر >>>
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: controller.goalController,
              decoration: InputDecoration(
                labelText: 'هدف شما از این زمینه چیست؟',
                hintText: 'مثال: افزودن قابلیت جستجو به صفحه لیست محصولات...',
                prefixIcon: const Icon(Iconsax.buliding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.teal.withOpacity(0.05),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                padding:
                    const EdgeInsets.only(bottom: 100), // فاصله برای دکمه شناور
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
            InkWell(
              onTap: () => controller.toggleExpansion(screen),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
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
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: _buildExpansionContent(screen),
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
