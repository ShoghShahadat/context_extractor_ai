import 'package:context_extractor_ai/core/models/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/context_editor_controller.dart';

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
        return _buildNode(nodes[index], context);
      },
    );
  }

  Widget _buildNode(TreeNode node, BuildContext context) {
    // <<< اصلاح: استفاده از رنگ‌های تم >>>
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    activeColor: colorScheme.primary,
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
                      ? colorScheme.secondary
                      : Colors.orange.shade400,
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
                return _buildNode(node.children[index], context);
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
          _buildControlPanel(context),
          const VerticalDivider(width: 1),
          _buildTreeViewPanel(context),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('۱. تعریف حوزه تمرکز',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'به هوش مصنوعی بگویید روی کدام بخش یا قابلیت پروژه تمرکز کند.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.focusController,
              decoration: const InputDecoration(
                hintText: 'مثال: سیستم لاگین و احراز هویت',
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
            Text('۲. تعریف هدف نهایی',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'دستورالعمل نهایی خود برای هوش مصنوعی را اینجا بنویسید.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.goalController,
              decoration: const InputDecoration(
                hintText: 'مثال: قابلیت ورود با گوگل را به این سیستم اضافه کن.',
              ),
              maxLines: 4,
            ),
            const Spacer(),
            _buildStatusArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeViewPanel(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        // <<< اصلاح: استفاده از رنگ پس‌زمینه تم >>>
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
        child: Obx(() {
          if (controller.treeNodes.isEmpty) {
            return const Center(
                child: Text('ساختار پروژه برای نمایش وجود ندارد.'));
          }
          return FileTreeView(
            nodes: controller.treeNodes,
            controller: controller,
          );
        }),
      ),
    );
  }

  Widget _buildStatusArea(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isLoading = controller.isAiFindingFiles.value ||
          controller.isGeneratingFinalCode.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // <<< اصلاح: استفاده از رنگ‌های تم >>>
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isLoading)
              SpinKitFadingCircle(color: theme.colorScheme.primary, size: 24)
            else
              Icon(Iconsax.info_circle,
                  color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.statusMessage.value,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ));
  }
}
