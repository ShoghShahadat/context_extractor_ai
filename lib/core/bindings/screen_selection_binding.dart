import 'package:get/get.dart';
import '../../presentation/controllers/screen_selection_controller.dart';

class ScreenSelectionBinding extends Bindings {
  @override
  void dependencies() {
    // این کنترلر فقط برای صفحه خودش لازم است، پس fenix: true نیاز نیست.
    Get.lazyPut<ScreenSelectionController>(() => ScreenSelectionController());
  }
}
