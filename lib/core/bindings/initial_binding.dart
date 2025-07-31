import 'package:get/get.dart';
import '../services/file_service.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart'; // <<< جدید: ایمپورت سرویس تنظیمات
import '../../presentation/controllers/home_controller.dart';

/// این کلاس مسئولیت تزریق وابستگی‌های اولیه و سراسری برنامه را دارد.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // <<< جدید: تزریق سرویس تنظیمات به صورت دائمی >>>
    // این سرویس باید قبل از سرویس‌های دیگر که به آن وابسته‌اند، تزریق شود.
    Get.putAsync<SettingsService>(() async {
      final service = SettingsService();
      await service.init();
      return service;
    }, permanent: true);

    // سرویس‌ها به صورت lazy (تنها در صورت نیاز) و دائمی (fenix: true)
    // در حافظه قرار می‌گیرند تا در کل چرخه حیات برنامه در دسترس باشند.
    Get.lazyPut<FileService>(() => FileService(), fenix: true);
    Get.lazyPut<GeminiService>(() => GeminiService(), fenix: true);

    // این سرویس به صورت همزمان (non-lazy) و دائمی تزریق می‌شود
    // و متد init آن برای بارگذاری اولیه تاریخچه فراخوانی می‌شود.
    Get.putAsync<HistoryService>(() async {
      final service = HistoryService();
      await service.init();
      return service;
    }, permanent: true);

    // کنترلر اصلی برنامه نیز به همین شکل تزریق می‌شود.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
