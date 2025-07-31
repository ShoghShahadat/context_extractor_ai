import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';
import '../theme/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          // ستون سمت راست: نوار کناری
          Sidebar(),
          // ستون سمت چپ: محتوای اصلی
          Expanded(
            child: MainContent(),
          ),
        ],
      ),
    );
  }
}

// ویجت نوار کناری (Sidebar)
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Container(
      width: 280,
      color: AppColors.sidebar,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // هدر نوار کناری
          Row(
            children: [
              Icon(Iconsax.cpu_charge, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Context AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'شروع تحلیل جدید',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // دکمه‌های اقدام
          SidebarButton(
            text: 'انتخاب پوشه پروژه',
            icon: Iconsax.folder_open,
            onTap: controller.pickAndProcessProjectDirectory,
          ),
          const SizedBox(height: 12),
          SidebarButton(
            text: 'انتخاب فایل تکی',
            icon: Iconsax.document_text_1,
            onTap: controller.pickAndProcessProjectFile,
          ),
        ],
      ),
    );
  }
}

// ویجت دکمه‌های نوار کناری
class SidebarButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const SidebarButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.surface.withOpacity(0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _isHovered
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                widget.text,
                style: TextStyle(
                  color: _isHovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ویجت محتوای اصلی (لیست تاریخچه)
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'پروژه‌های اخیر',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'یکی از پروژه‌هایی که اخیراً تحلیل کرده‌اید را برای ادامه انتخاب کنید.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.recentPaths.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.clock,
                          size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'تاریخچه‌ای وجود ندارد',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: controller.recentPaths.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final path = controller.recentPaths[index];
                  return HistoryListItem(
                    path: path,
                    onTap: () => controller.processPathFromHistory(path),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ویجت هر آیتم در لیست تاریخچه
class HistoryListItem extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const HistoryListItem({super.key, required this.path, required this.onTap});

  @override
  State<HistoryListItem> createState() => _HistoryListItemState();
}

class _HistoryListItemState extends State<HistoryListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _isHovered ? AppColors.surface : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.path.split(RegExp(r'[/\\]')).last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.path,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Iconsax.arrow_left_2,
                color: _isHovered
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
