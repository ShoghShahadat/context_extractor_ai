import 'package:context_extractor_ai/core/bindings/initial_binding.dart';
import 'package:context_extractor_ai/core/services/history_service.dart'; // <<< جدید
import 'package:context_extractor_ai/presentation/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // اطمینان از مقداردهی اولیه ویجت‌ها قبل از هر کاری
  WidgetsFlutterBinding.ensureInitialized();

  // بارگذاری متغیرهای محیطی (برای کلید API جمنای)
  await dotenv.load(fileName: ".env");

  // <<< اصلاح کلیدی: مقداردهی اولیه سرویس‌های ناهمزمان قبل از اجرای برنامه >>>
  await initServices();

  runApp(const MyApp());
}

/// تابع کمکی برای مقداردهی اولیه سرویس‌های ضروری
Future<void> initServices() async {
  // سرویس تاریخچه را مقداردهی اولیه کرده و سپس آن را در GetX ثبت می‌کنیم.
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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: GoogleFonts.vazirmatn().fontFamily,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.vazirmatn().fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      // اتصال بایندینگ اولیه و تعریف مسیرها
      initialBinding: InitialBinding(),
      initialRoute: AppPages.home,
      getPages: AppPages.routes,
    );
  }
}
