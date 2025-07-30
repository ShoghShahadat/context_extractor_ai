import 'package:context_extractor_ai/core/models/chat_message.dart';
import 'package:context_extractor_ai/core/models/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/context_editor_controller.dart';

// <<< ویجت جدید برای نمایش حباب پیام در چت >>>
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.sender == MessageSender.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Iconsax.cpu, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary.withOpacity(0.8)
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Iconsax.user, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}

class FileTreeView extends StatelessWidget {
  final List<TreeNode> nodes;
  final ContextEditorController controller;

  const FileTreeView(
      {super.key, required this.nodes, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(child: Text("ساختار درختی برای نمایش وجود ندارد."));
    }
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return _buildNode(nodes[index], context, 0);
      },
    );
  }

  Widget _buildNode(TreeNode node, BuildContext context, int depth) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = controller.userFinalSelection.contains(node.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => controller.onNodeToggled(node),
          child: Container(
            padding: EdgeInsets.only(left: (20.0 * depth), right: 8),
            height: 40,
            child: Row(
              children: [
                if (node.isFile)
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) => controller.onNodeToggled(node),
                    activeColor: colorScheme.primary,
                    visualDensity: VisualDensity.compact,
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
                  node.isFile ? Iconsax.document_1 : Iconsax.folder,
                  size: 20,
                  color: node.isFile
                      ? colorScheme.secondary
                      : Colors.orange.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (node.isExpanded && node.children.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: node.children.length,
            itemBuilder: (context, index) {
              return _buildNode(node.children[index], context, depth + 1);
            },
          ),
      ],
    );
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
          const VerticalDivider(width: 1),
          // <<< جدید: پنل چت >>>
          _buildChatPanel(context),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return SizedBox(
      width: 350, // عرض ثابت برای پنل کنترل
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('۱. تعریف حوزه تمرکز',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'به هوش مصنوعی بگویید روی کدام بخش تمرکز کند. می‌توانید از پنل چت هم استفاده کنید.',
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
              onPressed: controller.findFilesFromPanel,
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
      flex: 5, // فضای بیشتر برای درخت فایل
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
        child: Obx(() {
          return FileTreeView(
            nodes: controller.treeNodes,
            controller: controller,
          );
        }),
      ),
    );
  }

  // <<< جدید: متد برای ساخت پنل چت >>>
  Widget _buildChatPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: 6, // فضای بیشتر برای چت
      child: Container(
        color: theme.colorScheme.surface.withOpacity(0.5),
        child: Column(
          children: [
            // تاریخچه چت
            Expanded(
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true, // برای نمایش پیام‌های جدید در پایین
                    itemCount: controller.chatHistory.length,
                    itemBuilder: (context, index) {
                      // نمایش از آخر به اول
                      final message = controller.chatHistory[
                          controller.chatHistory.length - 1 - index];
                      return ChatBubble(message: message);
                    },
                  )),
            ),
            // کادر ورودی چت
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.chatInputController,
                      onSubmitted: (_) => controller.sendChatMessage(),
                      decoration: InputDecoration(
                        hintText: 'درخواست جدیدی دارید؟',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => controller.isAiFindingFiles.value
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SpinKitFadingCircle(
                                color: Colors.teal, size: 24),
                          )
                        : IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              fixedSize: const Size(48, 48),
                            ),
                            onPressed: controller.sendChatMessage,
                            icon:
                                const Icon(Iconsax.send_1, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
