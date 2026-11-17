import 'package:get/get.dart';
import '../views/wallet/controller/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletController());
  }
}
