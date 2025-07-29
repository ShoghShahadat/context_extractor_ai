import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استخراج کننده هوشمند زمینه کد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 24),
            const Divider(),
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(Iconsax.code,
            size: 60, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        const Text(
          'به ابزار هوشمند استخراج کد خوش آمدید!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'یک پوشه پروژه را انتخاب کنید یا از تاریخچه برای شروع تحلیل استفاده نمایید.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: controller.pickAndProcessProjectDirectory,
          icon: const Icon(Iconsax.folder_open),
          label: const Text('انتخاب پوشه پروژه'),
        ),
        const SizedBox(height: 12),
        // <<< اصلاح: استایل دکمه برای هماهنگی با تم >>>
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.pickAndProcessProjectFile,
          icon: const Icon(Iconsax.document_text),
          label: const Text('انتخاب فایل تکی (.txt)'),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'پروژه‌های اخیر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.recentPaths.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.hierarchy1,
                          size: 40, color: Colors.grey.shade700),
                      const SizedBox(height: 8),
                      const Text('تاریخچه‌ای وجود ندارد.'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.recentPaths.length,
                itemBuilder: (context, index) {
                  final path = controller.recentPaths[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      // <<< اصلاح: استفاده از رنگ تم برای آیکون >>>
                      leading: Icon(Iconsax.folder_2,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(
                        path.split(RegExp(r'[/\\]')).last,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        path,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                      onTap: () => controller.processPathFromHistory(path),
                    ),
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
