import 'package:get/get.dart';
import '../../core/bindings/result_binding.dart';
import '../../core/bindings/screen_selection_binding.dart';
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/screen_selection_screen.dart';

class AppPages {
  static const String home = '/';
  static const String screenSelection = '/select-screens';
  static const String result = '/result';

  static final List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      // بایندینگ اولیه در main.dart اعمال شده است
    ),
    GetPage(
      name: screenSelection,
      page: () => const ScreenSelectionScreen(),
      binding: ScreenSelectionBinding(),
    ),
    GetPage(
      name: result,
      page: () => const ResultScreen(),
      binding: ResultBinding(),
    ),
  ];
}
