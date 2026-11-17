import 'package:get/get.dart';
import '../views/booking_details/controller/booking_details_controller.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingDetailsController());
  }
}
