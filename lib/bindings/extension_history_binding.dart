import 'package:get/get.dart';
import '../views/extension_history/controller/extension_history_controller.dart';

class ExtensionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExtensionHistoryController());
  }
}
