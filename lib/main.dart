import 'package:context_extractor_ai/core/bindings/initial_binding.dart';
import 'package:context_extractor_ai/presentation/routes/app_pages.dart';
import 'package:context_extractor_ai/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/history_service.dart';
import 'core/services/settings_service.dart';

Future<void> main() async {
  // اطمینان از راه‌اندازی کامل فلاتر
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  debugPrint("Initializing critical services...");

  // ۱. راه‌اندازی و ثبت سرویس تنظیمات
  final settingsService = SettingsService();
  await settingsService.init();
  Get.put<SettingsService>(settingsService, permanent: true);

  // ۲. راه‌اندازی و ثبت سرویس تاریخچه
  final historyService = HistoryService();
  await historyService.init();
  Get.put<HistoryService>(historyService, permanent: true);

  debugPrint("✅ All critical services initialized and ready.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Context Extractor AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      themeMode: ThemeMode.dark, // قفل کردن برنامه روی تم تاریک
      initialBinding: InitialBinding(),
      initialRoute: AppPages.home,
      getPages: AppPages.routes,
    );
  }
}
