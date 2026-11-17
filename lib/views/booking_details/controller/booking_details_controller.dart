import 'package:carbo/base/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../routes/routes.dart';
import '../../../views/history/controller/history_controller.dart';
import '../../../views/history/model/history_model.dart';
import '../../../views/wallet/controller/wallet_controller.dart';
import '../model/cancel_booking_model.dart';
import 'extend_booking_controller.dart';

class BookingDetailsController extends GetxController {
  final Rx<History?> booking = Rx<History?>(null);
  final RxBool isCancelLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    booking.value = Get.arguments['booking'] as History?;
  }

  bool get canExtend => booking.value?.status == 2;

  bool get canCancel {
    final status = booking.value?.status;
    return status == 0 || status == 1;
  }

  /// Registers [ExtendBookingController] before the screen opens the sheet.
  /// Calling multiple times is safe — registers only once.
  void prepareExtendSheet() {
    final id = booking.value?.id;
    if (id == null) return;
    if (!Get.isRegistered<ExtendBookingController>()) {
      Get.put(ExtendBookingController(id));
    }
  }

  /// Cleans up [ExtendBookingController] after the bottom sheet is closed.
  void disposeExtendSheet() {
    if (Get.isRegistered<ExtendBookingController>()) {
      Get.delete<ExtendBookingController>();
    }
  }

  Future<void> refreshBooking() async {
    if (!Get.isRegistered<HistoryController>()) return;

    final historyController = Get.find<HistoryController>();
    await historyController.getHistoryInfo();

    final updated = historyController.historyList
        .firstWhereOrNull((h) => h.id == booking.value?.id);
    if (updated != null) {
      booking.value = updated;
    }
  }

  Future<void> cancelBooking() async {
    final id = booking.value?.id;
    if (id == null) return;

    await RequestProcess().request<CancelBookingModel>(
      fromJson: CancelBookingModel.fromJson,
      apiEndpoint: ApiEndpoint.cancelBooking,
      isLoading: isCancelLoading,
      method: HttpMethod.POST,
      body: {'booking_id': id},
      onSuccess: (value) {
        booking.value!.status = 5;
        booking.refresh();

        final refunded = double.tryParse(value?.refunded ?? '0') ?? 0.0;
        final message = refunded > 0
            ? 'Booking cancelled. ${value!.refunded} SAR returned to your wallet.'
            : 'Booking cancelled successfully.';
        CustomSnackBar.success(title: 'Cancelled', message: message);

        if (Get.isRegistered<WalletController>()) {
          final walletController = Get.find<WalletController>();
          walletController.fetchWallet();
          walletController.fetchTransactions(refresh: true);
        }
      },
    );
  }

  void navigateToExtensionHistory() {
    final id = booking.value?.id;
    if (id == null) return;
    Get.toNamed(
      Routes.extensionHistoryScreen,
      arguments: {'bookingId': id},
    );
  }
}
