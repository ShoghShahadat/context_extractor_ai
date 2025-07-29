import 'package:context_extractor_ai/core/models/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/context_editor_controller.dart';

// <<< جدید: ویجت سفارشی برای نمایش درختواره >>>
class FileTreeView extends StatelessWidget {
  final List<TreeNode> nodes;
  final ContextEditorController controller;

  const FileTreeView(
      {super.key, required this.nodes, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return _buildNode(nodes[index]);
      },
    );
  }

  Widget _buildNode(TreeNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => controller.onNodeToggled(node),
          child: Container(
            padding: EdgeInsets.only(left: (20.0 * _getDepth(node))),
            child: Row(
              children: [
                if (node.isFile)
                  Checkbox(
                    value: controller.userFinalSelection.contains(node.path),
                    onChanged: (val) => controller.onNodeToggled(node),
                    activeColor: Colors.teal,
                  )
                else
                  Icon(
                    node.isExpanded
                        ? Iconsax.arrow_down_2
                        : Iconsax.arrow_right_3,
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Icon(
                  node.isFile ? Iconsax.document : Iconsax.folder,
                  size: 20,
                  color: node.isFile
                      ? Colors.blue.shade700
                      : Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontWeight:
                          controller.userFinalSelection.contains(node.path)
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (node.isExpanded && node.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: node.children.length,
              itemBuilder: (context, index) {
                return _buildNode(node.children[index]);
              },
            ),
          ),
      ],
    );
  }

  int _getDepth(TreeNode node) {
    int depth = 0;
    final parts = node.key.split(RegExp(r'[/\\]'));
    depth = parts.length - 1;
    return depth;
  }
}

class ContextEditorScreen extends GetView<ContextEditorController> {
  const ContextEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ویرایشگر هوشمند زمینه'),
        actions: [
          _buildGenerateButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlPanel(),
          const VerticalDivider(width: 1),
          _buildTreeViewPanel(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('۱. تعریف حوزه تمرکز', style: Get.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'به هوش مصنوعی بگویید روی کدام بخش یا قابلیت پروژه تمرکز کند.',
              style: Get.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.focusController,
              decoration: const InputDecoration(
                hintText: 'مثال: سیستم لاگین و احراز هویت',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.findFilesWithAi,
              icon: const Icon(Iconsax.magicpen),
              label: const Text('یافتن فایل‌های مرتبط با AI'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('۲. تعریف هدف نهایی', style: Get.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'دستورالعمل نهایی خود برای هوش مصنوعی را اینجا بنویسید.',
              style: Get.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.goalController,
              decoration: const InputDecoration(
                hintText: 'مثال: قابلیت ورود با گوگل را به این سیستم اضافه کن.',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const Spacer(),
            _buildStatusArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeViewPanel() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.grey.shade50,
        child: Obx(() {
          if (controller.treeNodes.isEmpty) {
            return const Center(
                child: Text('ساختار پروژه برای نمایش وجود ندارد.'));
          }
          // <<< اصلاح: استفاده از ویجت سفارشی جدید >>>
          return FileTreeView(
            nodes: controller.treeNodes,
            controller: controller,
          );
        }),
      ),
    );
  }

  Widget _buildStatusArea() {
    return Obx(() {
      final isLoading = controller.isAiFindingFiles.value ||
          controller.isGeneratingFinalCode.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SpinKitFadingCircle(color: Colors.teal, size: 24)
            else
              const Icon(Iconsax.info_circle, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.statusMessage.value,
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGenerateButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: controller.isGeneratingFinalCode.value
              ? null
              : controller.generateFinalCode,
          icon: controller.isGeneratingFinalCode.value
              ? const SizedBox.shrink()
              : const Icon(Iconsax.document_code),
          label: controller.isGeneratingFinalCode.value
              ? const Text('در حال تولید...')
              : const Text('تولید سند نهایی'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ));
  }
}
