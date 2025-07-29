import 'package:get/get.dart';
import '../../core/bindings/result_binding.dart';
import '../../core/bindings/context_editor_binding.dart'; // <<< جدید
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/context_editor_screen.dart'; // <<< جدید

class AppPages {
  // <<< مسیر جدید جایگزین screenSelection شد >>>
  static const String home = '/';
  static const String contextEditor = '/context-editor';
  static const String result = '/result';

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
  ];
}
