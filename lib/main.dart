import 'package:context_extractor_ai/core/bindings/initial_binding.dart';
import 'package:context_extractor_ai/presentation/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // اطمینان از مقداردهی اولیه ویجت‌ها
  WidgetsFlutterBinding.ensureInitialized();

  // بارگذاری متغیرهای محیطی (برای کلید API جمنای)
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
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
