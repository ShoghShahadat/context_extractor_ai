import 'package:get/get.dart';
import '../services/file_service.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart'; // <<< جدید: ایمپورت سرویس تاریخچه
import '../../presentation/controllers/home_controller.dart';

/// این کلاس مسئولیت تزریق وابستگی‌های اولیه و سراسری برنامه را دارد.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // سرویس‌ها به صورت lazy (تنها در صورت نیاز) و دائمی (fenix: true)
    // در حافظه قرار می‌گیرند تا در کل چرخه حیات برنامه در دسترس باشند.
    Get.lazyPut<FileService>(() => FileService(), fenix: true);
    Get.lazyPut<GeminiService>(() => GeminiService(), fenix: true);

    // <<< جدید: تزریق سرویس تاریخچه >>>
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
