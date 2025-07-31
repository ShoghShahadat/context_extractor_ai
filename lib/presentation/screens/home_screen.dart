import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart'; // <<< جدید: ایمپورت کنترلر تم
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  // <<< جدید: دسترسی به کنترلر تم برای استفاده در کلید >>>
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    // <<< اصلاح کلیدی: استفاده از Obx و ValueKey برای بازسازی اجباری >>>
    // این ویجت به تغییرات تم گوش می‌دهد و با تغییر کلید، کل Scaffold را از نو می‌سازد.
    return Obx(() {
      return Scaffold(
        key: ValueKey(themeController.themeMode.value),
        body: Row(
          children: [
            Sidebar(),
            Expanded(
              child: MainContent(),
            ),
          ],
        ),
      );
    });
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
      color: Get.theme.colorScheme.surfaceVariant, // sidebar color
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.cpu_charge,
                  color: AppColors.primaryStart, size: 28),
              const SizedBox(width: 12),
              Text(
                'Context AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'شروع تحلیل جدید',
            style: TextStyle(
              color: Get.theme.colorScheme.tertiary, // textSecondary
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
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
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          SidebarButton(
            text: 'تنظیمات',
            icon: Iconsax.setting_2,
            onTap: () => Get.toNamed(AppPages.settings),
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
                ? Get.theme.colorScheme.surface.withOpacity(0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _isHovered
                    ? Get.theme.colorScheme.onSurface
                    : Get.theme.colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                widget.text,
                style: TextStyle(
                  color: _isHovered
                      ? Get.theme.colorScheme.onSurface
                      : Get.theme.colorScheme.tertiary,
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
          Text(
            'پروژه‌های اخیر',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'یکی از پروژه‌هایی که اخیراً تحلیل کرده‌اید را برای ادامه انتخاب کنید.',
            style:
                TextStyle(fontSize: 14, color: Get.theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 24),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.recentPaths.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.clock,
                          size: 48, color: Get.theme.colorScheme.tertiary),
                      const SizedBox(height: 16),
                      Text(
                        'تاریخچه‌ای وجود ندارد',
                        style: TextStyle(color: Get.theme.colorScheme.tertiary),
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
          color:
              _isHovered ? Get.theme.colorScheme.surface : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.path.split(RegExp(r'[/\\]')).last,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.path,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.theme.colorScheme.tertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Iconsax.arrow_left_2,
                color: _isHovered
                    ? Get.theme.colorScheme.onSurface
                    : Get.theme.colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
