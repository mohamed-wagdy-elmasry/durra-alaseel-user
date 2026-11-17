import 'package:get/get.dart';
import '../views/cars/controller/cars_controller.dart';

class CarsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CarsController(), fenix: true);
  }
}
