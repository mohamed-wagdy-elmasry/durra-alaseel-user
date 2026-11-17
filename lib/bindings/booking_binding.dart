import 'package:get/get.dart';
import '../views/booking/controller/booking_controller.dart';
import '../services/delivery_api_service.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryApiService>(() => DeliveryApiService());
    Get.lazyPut(() => BookingController());
  }
}
