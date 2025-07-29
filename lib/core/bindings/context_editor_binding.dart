import 'package:get/get.dart';
import '../../presentation/controllers/context_editor_controller.dart';

class ContextEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContextEditorController>(() => ContextEditorController());
  }
}
