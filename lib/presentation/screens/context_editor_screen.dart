import 'package:context_extractor_ai/core/models/chat_message.dart';
import 'package:context_extractor_ai/core/models/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/context_editor_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

// <<< اصلاح: حذف const از سازنده >>>
class ContextEditorScreen extends GetView<ContextEditorController> {
  const ContextEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ویرایشگر هوشمند زمینه'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Get.back(),
        ),
        actions: [
          _buildGenerateButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ستون سمت راست: پنل کنترل
          SizedBox(
            width: 350,
            child: _buildControlPanel(context),
          ),
          const VerticalDivider(width: 1),
          // ستون وسط: درخت فایل‌ها
          Expanded(
            flex: 5,
            child: _buildTreeViewPanel(context),
          ),
          const VerticalDivider(width: 1),
          // ستون سمت چپ: پنل چت
          Expanded(
            flex: 6,
            child: _buildChatPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() => GradientButton(
          onPressed: controller.isGeneratingFinalCode.value
              ? null
              : controller.generateFinalCode,
          icon: controller.isGeneratingFinalCode.value
              ? const SizedBox.shrink()
              : const Icon(Iconsax.document_code, color: AppColors.onPrimary),
          label: Text(
            controller.isGeneratingFinalCode.value
                ? 'در حال تولید...'
                : 'تولید سند نهایی',
            style: const TextStyle(color: AppColors.onPrimary),
          ),
        ));
  }

  Widget _buildControlPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('۱. تعریف حوزه تمرکز', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'به هوش مصنوعی بگویید روی کدام بخش تمرکز کند. می‌توانید از پنل چت هم استفاده کنید.',
            style: context.textTheme.bodyMedium
                ?.copyWith(color: context.theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 16),
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
          Text('۲. تعریف هدف نهایی', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'دستورالعمل نهایی خود برای هوش مصنوعی را اینجا بنویسید.',
            style: context.textTheme.bodyMedium
                ?.copyWith(color: context.theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildTreeViewPanel(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surfaceVariant, // sidebar color
      child: Obx(() {
        if (controller.treeNodes.isEmpty) {
          return const Center(
              child: Text("ساختار درختی برای نمایش وجود ندارد."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.treeNodes.length,
          itemBuilder: (context, index) {
            return _TreeNodeWidget(
              node: controller.treeNodes[index],
              controller: controller,
              depth: 0,
            );
          },
        );
      }),
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: controller.chatHistory.length,
                itemBuilder: (context, index) {
                  final message =
                      controller.chatHistory.reversed.toList()[index];
                  return ChatBubble(message: message);
                },
              )),
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.chatInputController,
                  onSubmitted: (_) => controller.sendChatMessage(),
                  decoration: const InputDecoration(
                    hintText: 'درخواست جدیدی دارید؟',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => controller.isAiFindingFiles.value
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SpinKitFadingCircle(
                            color: AppColors.primaryStart, size: 24),
                      )
                    : InkWell(
                        onTap: controller.sendChatMessage,
                        borderRadius: BorderRadius.circular(50),
                        child: Ink(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.send_2,
                              color: AppColors.onPrimary),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusArea(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isAiFindingFiles.value ||
          controller.isGeneratingFinalCode.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SpinKitFadingCircle(color: AppColors.primaryStart, size: 24)
            else
              Icon(Iconsax.info_circle,
                  color: context.theme.colorScheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.statusMessage.value,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final ContextEditorController controller;
  final int depth;

  const _TreeNodeWidget({
    required this.node,
    required this.controller,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.userFinalSelection.contains(node.path);
      final isExpanded = node.isExpanded.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.onNodeToggled(node),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: EdgeInsets.only(
                  left: (16.0 * depth) + 8, right: 8, top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryStart.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (node.isFile)
                    Icon(
                      isSelected
                          ? Iconsax.document_15
                          : Iconsax.document_text_1,
                      size: 20,
                      color: isSelected
                          ? AppColors.primaryStart
                          : context.theme.colorScheme.tertiary,
                    )
                  else
                    Icon(
                      isExpanded ? Iconsax.arrow_down_2 : Iconsax.arrow_right_3,
                      size: 16,
                      color: context.theme.colorScheme.tertiary,
                    ),
                  const SizedBox(width: 10),
                  if (!node.isFile)
                    Icon(
                      isExpanded ? Iconsax.folder_open : Iconsax.folder,
                      size: 20,
                      color: Colors.orange.shade400,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? context.theme.colorScheme.onSurface
                            : context.theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: node.children
                    .map((childNode) => _TreeNodeWidget(
                        node: childNode,
                        controller: controller,
                        depth: depth + 1))
                    .toList(),
              ),
            ),
        ],
      );
    });
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: AppColors.primaryStart,
              child: Icon(Iconsax.cpu, color: AppColors.onPrimary, size: 20),
            ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(message.text,
                  style: TextStyle(
                      color: isUser
                          ? AppColors.onPrimary
                          : context.theme.colorScheme.onSurface,
                      height: 1.5)),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            CircleAvatar(
              backgroundColor: context.theme.colorScheme.surface,
              child: Icon(Iconsax.user,
                  color: context.theme.colorScheme.tertiary, size: 20),
            ),
        ],
      ),
    );
  }
}
