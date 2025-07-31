import 'package:get/get.dart';
import '../../core/bindings/result_binding.dart';
import '../../core/bindings/context_editor_binding.dart';
import '../../core/bindings/settings_binding.dart';
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/context_editor_screen.dart';
import '../screens/settings_screen.dart';

class AppPages {
  static const String home = '/';
  static const String contextEditor = '/context-editor';
  static const String result = '/result';
  static const String settings = '/settings';

  static final List<GetPage> routes = [
    GetPage(
      name: home,
      // <<< اصلاح: حذف const برای فعال کردن بازسازی ویجت >>>
      page: () => HomeScreen(),
    ),
    GetPage(
      name: contextEditor,
      // <<< اصلاح: حذف const >>>
      page: () => ContextEditorScreen(),
      binding: ContextEditorBinding(),
    ),
    GetPage(
      name: result,
      // <<< اصلاح: حذف const >>>
      page: () => ResultScreen(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: settings,
      // <<< اصلاح: حذف const >>>
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
