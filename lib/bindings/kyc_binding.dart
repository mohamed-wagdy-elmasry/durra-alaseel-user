import 'package:carbo/views/kyc/controller/kyc_controller.dart';
import 'package:get/get.dart';

/// KYC Binding
///
/// Lazy loads KYC controller for dependency injection with GetX
/// Follows the GetX binding pattern used throughout the application
class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KycController());
  }
}
