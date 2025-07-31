import 'package:get/get.dart';
import '../../presentation/controllers/theme_controller.dart'; // <<< جدید: ایمپورت کنترلر تم
import '../services/file_service.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../../presentation/controllers/home_controller.dart';

/// این کلاس مسئولیت تزریق وابستگی‌های اولیه و سراسری برنامه را دارد.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // سرویس‌های حیاتی که باید در ابتدای برنامه راه‌اندازی شوند
    // این سرویس‌ها از طریق `main.dart` به صورت `permanent: true` ثبت شده‌اند.
    // Get.putAsync<SettingsService>(() async { ... });
    // Get.putAsync<HistoryService>(() async { ... });

    // <<< جدید: تزریق کنترلر تم به صورت دائمی و سراسری >>>
    // این کنترلر مسئول مدیریت حالت روشن/تاریک برنامه است.
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // سرویس‌ها به صورت lazy (تنها در صورت نیاز) و دائمی (fenix: true)
    // در حافظه قرار می‌گیرند تا در کل چرخه حیات برنامه در دسترس باشند.
    Get.lazyPut<FileService>(() => FileService(), fenix: true);
    Get.lazyPut<GeminiService>(() => GeminiService(), fenix: true);

    // کنترلر اصلی برنامه نیز به همین شکل تزریق می‌شود.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
