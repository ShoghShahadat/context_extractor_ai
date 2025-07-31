import 'dart:ui';
import 'package:context_extractor_ai/core/models/chat_message.dart';
import 'package:context_extractor_ai/core/models/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/context_editor_controller.dart';
import '../theme/app_theme.dart';

// ویجت کانتینر شیشه‌ای برای پنل‌ها
class GlassPanel extends StatelessWidget {
  final Widget child;
  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: AppTheme.glassmorphism(opacity: 0.15),
          child: child,
        ),
      ),
    );
  }
}

// ویجت بازطراحی شده حباب چت
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
              backgroundColor: AppColors.accent,
              child: Icon(Iconsax.cpu, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isUser ? AppGradients.primaryButton : null,
                color: isUser ? null : AppColors.glassFill.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Text(message.text,
                  style: const TextStyle(color: Colors.white, height: 1.5)),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Iconsax.user, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}

// ویجت بازطراحی شده گره درخت
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
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: EdgeInsets.only(
                  left: (20.0 * depth) + 8, right: 8, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (!node.isFile)
                    Icon(
                      isExpanded ? Iconsax.arrow_down_2 : Iconsax.arrow_right_3,
                      size: 16,
                      color: Colors.white70,
                    )
                  else
                    Icon(
                      isSelected
                          ? Iconsax.document_15
                          : Iconsax.document_text_1,
                      size: 20,
                      color: isSelected ? AppColors.primary : AppColors.accent,
                    ),
                  const SizedBox(width: 12),
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
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
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

class ContextEditorScreen extends GetView<ContextEditorController> {
  const ContextEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: _buildControlPanel(context)),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: _buildTreeViewPanel(context)),
                const SizedBox(width: 16),
                Expanded(flex: 6, child: _buildChatPanel(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('۱. تعریف حوزه تمرکز',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'به AI بگویید روی کدام بخش تمرکز کند. می‌توانید از پنل چت هم استفاده کنید.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
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
              label: const Text('یافتن فایل‌های مرتبط'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('۲. تعریف هدف نهایی',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'دستورالعمل نهایی خود برای AI را اینجا بنویسید.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.goalController,
              decoration: const InputDecoration(
                hintText: 'مثال: قابلیت ورود با گوگل را اضافه کن.',
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
    return GlassPanel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Iconsax.hierarchy_square_2,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text("ساختار پروژه",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.treeNodes.isEmpty) {
                return const Center(
                    child: Text("ساختار درختی برای نمایش وجود ندارد."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    return GlassPanel(
      child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true, // پیام‌ها از پایین به بالا نمایش داده می‌شوند
                  itemCount: controller.chatHistory.length,
                  itemBuilder: (context, index) {
                    final reversedList =
                        controller.chatHistory.reversed.toList();
                    final message = reversedList[index];
                    return ChatBubble(message: message);
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.chatInputController,
                    onSubmitted: (_) => controller.sendChatMessage(),
                    decoration: const InputDecoration(
                      hintText: 'درخواست جدیدی دارید؟',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => controller.isAiFindingFiles.value
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SpinKitFadingCircle(
                              color: AppColors.primary, size: 24),
                        )
                      : IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            fixedSize: const Size(52, 52),
                          ),
                          onPressed: controller.sendChatMessage,
                          icon: const Icon(Iconsax.send_2, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isAiFindingFiles.value ||
          controller.isGeneratingFinalCode.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SpinKitFadingCircle(color: AppColors.primary, size: 24)
            else
              const Icon(Iconsax.info_circle, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.statusMessage.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGenerateButton() {
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.primaryButton,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: controller.isGeneratingFinalCode.value
                ? null
                : controller.generateFinalCode,
            icon: controller.isGeneratingFinalCode.value
                ? const SizedBox.shrink()
                : const Icon(Iconsax.document_code, color: Colors.white),
            label: Text(
              controller.isGeneratingFinalCode.value
                  ? 'در حال تولید...'
                  : 'تولید سند نهایی',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
