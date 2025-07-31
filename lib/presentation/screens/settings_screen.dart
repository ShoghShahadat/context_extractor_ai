import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // <<< جدید: ایمپورت پکیج
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

// <<< جدید: محتوای HTML برای راهنما >>>
const String apiKeyInstructionsHtml = """
<p>برای استفاده از قابلیت‌های هوش مصنوعی این برنامه، به یک کلید API از <b>Google AI Studio</b> نیاز دارید. دریافت این کلید کاملاً رایگان است.</p>
<ol>
    <li>بر روی دکمه <b>"دریافت کلید API"</b> در پایین کلیک کنید تا به صفحه Google AI Studio هدایت شوید.</li>
    <li>اگر وارد حساب گوگل خود نشده‌اید، وارد شوید.</li>
    <li>در صفحه باز شده، بر روی دکمه <b>"Create API key in new project"</b> کلیک کنید.</li>
    <li>کلید ساخته شده را کپی کرده و در کادر زیر وارد کنید.</li>
</ol>
<p><b>توجه:</b> کلید API شما به صورت محلی و امن بر روی دستگاه شما ذخیره می‌شود و به هیچ سروری ارسال نمی‌گردد.</p>
""";

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
                // <<< جدید: بخش راهنمای دریافت کلید >>>
                _buildSectionHeader('راهنمای دریافت کلید API',
                    'برای فعال‌سازی دستیار هوشمند، مراحل زیر را دنبال کنید.'),
                _buildInstructionsCard(),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                _buildSectionHeader('کلیدهای API جمنای',
                    'لیست کلیدهای API خود را برای استفاده در برنامه مدیریت کنید.'),
                _buildListEditor(
                  controller.apiKeys,
                  controller.apiKeyController,
                  'یک کلید API جدید وارد کنید...',
                  controller.addApiKey,
                  controller.removeApiKey,
                  Iconsax.key,
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
                  Iconsax.folder_minus,
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

  // <<< جدید: ویجت برای کارت راهنما >>>
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Html(
            data: apiKeyInstructionsHtml,
            style: {
              // <<< اصلاح کلیدی: افزودن جهت راست به چپ برای متن >>>
              "body": Style(
                color: AppColors.textSecondary,
                fontSize: FontSize.medium,
                lineHeight: LineHeight.number(1.6),
                direction: TextDirection.rtl, // این خط متن را راست‌چین می‌کند
              ),
              "b": Style(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              "ol": Style(padding: HtmlPaddings.only(right: 20)),
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.launchApiKeyUrl,
            icon: const Icon(Iconsax.export_1),
            label: const Text('دریافت کلید API از Google AI Studio'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface.withOpacity(0.8),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.border)),
          )
        ],
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
    IconData itemIcon,
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
                        leading: Icon(itemIcon, color: AppColors.textSecondary),
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
