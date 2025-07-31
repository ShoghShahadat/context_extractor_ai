import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';
import '../theme/app_theme.dart';

// ویجت جدید: کارت اقدام در مرکز صفحه
class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassmorphism(
                opacity: 0.2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .shimmer(
            delay: 3000.ms,
            duration: 2000.ms,
            color: AppColors.primary.withOpacity(0.1),
          )
          .animate() // این انیمیشن برای هاور است
          .scale(
            duration: 200.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
          ),
    );
  }
}

// ویجت بازطراحی شده برای کارت‌های تاریخچه
class HistoryCard extends StatelessWidget {
  final String path;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassmorphism(
          opacity: 0.15,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.folder_2, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.split(RegExp(r'[/\\]')).last,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    path,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: Colors.white.withOpacity(0.7)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms, curve: Curves.easeOut)
        .slideY(begin: 0.5, duration: 500.ms, curve: Curves.easeOut);
  }
}

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildActionHub(),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.cpu_charge, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          const Text(
            'Context Extractor AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5);
  }

  Widget _buildActionHub() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: AspectRatio(
        aspectRatio: 3 / 1,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassmorphism(
            opacity: 0.1,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'شروع تحلیل جدید',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    ActionCard(
                      title: 'انتخاب پوشه',
                      description: 'کل پروژه را برای تحلیل انتخاب کنید.',
                      icon: Iconsax.folder_open,
                      onTap: controller.pickAndProcessProjectDirectory,
                    ),
                    const SizedBox(width: 20),
                    ActionCard(
                      title: 'انتخاب فایل تکی',
                      description: 'یک فایل .txt از پیش آماده شده را باز کنید.',
                      icon: Iconsax.document_text_1,
                      onTap: controller.pickAndProcessProjectFile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(
          begin: const Offset(0.9, 0.9),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildHistorySection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'پروژه‌های اخیر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.recentPaths.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.hierarchy_square,
                            size: 48, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'تاریخچه‌ای برای نمایش وجود ندارد.',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                  );
                }
                return ListView.builder(
                  itemCount: controller.recentPaths.length,
                  itemBuilder: (context, index) {
                    final path = controller.recentPaths[index];
                    return HistoryCard(
                      path: path,
                      onTap: () => controller.processPathFromHistory(path),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
