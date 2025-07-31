import 'package:get/get.dart';
import '../../core/bindings/result_binding.dart';
import '../../core/bindings/context_editor_binding.dart';
import '../../core/bindings/settings_binding.dart'; // <<< جدید: ایمپورت بایندینگ تنظیمات
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/context_editor_screen.dart';
import '../screens/settings_screen.dart'; // <<< جدید: ایمپورت صفحه تنظیمات

class AppPages {
  static const String home = '/';
  static const String contextEditor = '/context-editor';
  static const String result = '/result';
  static const String settings = '/settings'; // <<< جدید: مسیر صفحه تنظیمات

  static final List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: contextEditor,
      page: () => const ContextEditorScreen(),
      binding: ContextEditorBinding(),
    ),
    GetPage(
      name: result,
      page: () => const ResultScreen(),
      binding: ResultBinding(),
    ),
    // <<< جدید: تعریف صفحه و بایندینگ برای تنظیمات >>>
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
