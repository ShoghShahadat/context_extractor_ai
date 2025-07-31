import 'package:context_extractor_ai/core/bindings/initial_binding.dart';
import 'package:context_extractor_ai/presentation/controllers/theme_controller.dart';
import 'package:context_extractor_ai/presentation/routes/app_pages.dart';
import 'package:context_extractor_ai/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/history_service.dart';
import 'core/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(MyApp());
}

Future<void> initServices() async {
  debugPrint("Initializing critical services...");
  final settingsService = SettingsService();
  await settingsService.init();
  Get.put<SettingsService>(settingsService, permanent: true);

  final historyService = HistoryService();
  await historyService.init();
  Get.put<HistoryService>(historyService, permanent: true);

  Get.put<ThemeController>(ThemeController(), permanent: true);

  debugPrint("✅ All critical services initialized and ready.");
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() {
      // <<< اصلاح کلیدی و نهایی: افزودن ValueKey به GetMaterialApp >>>
      // این کلید با تغییر تم، تغییر کرده و کل برنامه را مجبور به بازسازی کامل
      // با ThemeData جدید می‌کند و مشکل رنگ‌های درهم را به طور قطعی حل می‌کند.
      return GetMaterialApp(
        key: ValueKey(themeController.themeMode.value),
        title: 'Context Extractor AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: themeController.themeMode.value,
        initialBinding: InitialBinding(),
        initialRoute: AppPages.home,
        getPages: AppPages.routes,
      );
    });
  }
}
