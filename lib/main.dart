import 'package:context_extractor_ai/core/bindings/initial_binding.dart';
import 'package:context_extractor_ai/core/services/history_service.dart';
import 'package:context_extractor_ai/presentation/routes/app_pages.dart';
import 'package:context_extractor_ai/presentation/theme/app_theme.dart'; // <<< جدید: ایمپورت تم جدید
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  // این متد دیگر نیازی به تغییر ندارد
  final historyService = HistoryService();
  await historyService.init();
  Get.put<HistoryService>(historyService, permanent: true);
  debugPrint("History Service Initialized and Ready.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Context Extractor AI',
      debugShowCheckedModeBanner: false,

      // <<< اصلاح: استفاده از سیستم تم متمرکز جدید >>>
      theme: AppTheme.getTheme(),
      darkTheme: AppTheme.getTheme(), // استفاده از همان تم برای هر دو حالت
      themeMode: ThemeMode.dark, // قفل کردن برنامه روی تم تاریک

      initialBinding: InitialBinding(),
      initialRoute: AppPages.home,
      getPages: AppPages.routes,
    );
  }
}
