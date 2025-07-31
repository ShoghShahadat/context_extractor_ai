import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('کلیدهای API جمنای',
                    'لیست کلیدهای API خود را برای استفاده در برنامه مدیریت کنید.'),
                _buildListEditor(
                  controller.apiKeys,
                  controller.apiKeyController,
                  'یک کلید API جدید وارد کنید...',
                  controller.addApiKey,
                  controller.removeApiKey,
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                _buildSectionHeader('پوشه‌های مستثنی',
                    'پوشه‌هایی که باید در هنگام تحلیل پروژه نادیده گرفته شوند.'),
                _buildListEditor(
                  controller.excludedDirs,
                  controller.excludedDirController,
                  'نام یک پوشه جدید وارد کنید...',
                  controller.addExcludedDir,
                  controller.removeExcludedDir,
                ),
                const SizedBox(height: 40),
                GradientButton(
                  onPressed: controller.saveSettings,
                  label: const Text('ذخیره تغییرات'),
                  icon: const Icon(Iconsax.save_2, color: AppColors.onPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Get.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Get.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildListEditor(
    RxList<String> items,
    TextEditingController textController,
    String hintText,
    VoidCallback onAdd,
    void Function(String) onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.add_square,
                    color: AppColors.primaryStart),
                onPressed: onAdd,
              ),
            ],
          ),
          const Divider(),
          Obx(
            () => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'هیچ آیتمی وجود ندارد.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Iconsax.key,
                            color: AppColors.textSecondary),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.red),
                          onPressed: () => onRemove(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
