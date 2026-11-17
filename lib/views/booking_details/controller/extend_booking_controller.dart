import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/utils/basic_import.dart';
import '../../../backend/model/extend_confirm_model.dart';
import '../../../backend/model/extend_preview_model.dart';
import 'booking_details_controller.dart';

class ExtendBookingController extends GetxController {
  final int bookingId;

  ExtendBookingController(this.bookingId);

  // ── Counter state ────────────────────────────────────────────────────────────
  final RxInt days = 1.obs;
  final RxBool isPending = false.obs;   // true while debounce timer is running

  // ── Preview state ─────────────────────────────────────────────────────────────
  final RxBool isPreviewLoading = false.obs;
  final RxBool isPreviewLoaded  = false.obs;
  final Rx<ExtendPreviewModel?> previewResult = Rx<ExtendPreviewModel?>(null);
  final RxString validationError = ''.obs;

  // ── Confirm state ─────────────────────────────────────────────────────────────
  final RxBool isConfirming = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _fetchPreview(days.value);
  }

  // ── Public counter methods ────────────────────────────────────────────────────

  void increment() {
    if (days.value >= 365) return;
    days.value++;
    _onCounterChanged();
  }

  void decrement() {
    if (days.value <= 1) return;
    days.value--;
    _onCounterChanged();
  }

  // ── Internal ──────────────────────────────────────────────────────────────────

  void _onCounterChanged() {
    isPending.value = true;
    previewResult.value = null;
    isPreviewLoaded.value = false;
    validationError.value = '';
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      isPending.value = false;
      _fetchPreview(days.value);
    });
  }

  Future<void> _fetchPreview(int numDays) async {
    await RequestProcess().request<ExtendPreviewModel>(
      fromJson: ExtendPreviewModel.fromJson,
      apiEndpoint: ApiEndpoint.extendPreview,
      isLoading: isPreviewLoading,
      method: HttpMethod.GET,
      queryParams: {
        'booking_id':     bookingId.toString(),
        'extension_days': numDays.toString(),
      },
      showErrorMessage: true,
      onSuccess: (value) {
        if (value != null) {
          previewResult.value = value;
          isPreviewLoaded.value = true;
        } else {
          isPreviewLoaded.value = false;
          previewResult.value = null;
        }
      },
      onError: (_) {
        isPreviewLoaded.value = false;
        previewResult.value = null;
      },
    );
  }

  /// [onClose] is called after a successful extension to dismiss the sheet.
  /// The sheet passes `() => Navigator.of(context).pop()`.
  Future<void> confirmExtension(VoidCallback onClose) async {
    if (isConfirming.value || !isPreviewLoaded.value) return;

    await RequestProcess().request<ExtendConfirmModel>(
      fromJson: ExtendConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.extendBooking,
      isLoading: isConfirming,
      method: HttpMethod.POST,
      body: {
        'booking_id':     bookingId,
        'extension_days': days.value,
        'payment_type':   'balance',
      },
      showSuccessMessage: false,
      showErrorMessage: true,
      onSuccess: (value) {
        onClose();
        CustomSnackBar.success(
          title: Strings.success,
          message: (value?.message.isNotEmpty == true)
              ? value!.message
              : 'Booking extended successfully',
        );
        if (Get.isRegistered<BookingDetailsController>()) {
          Get.find<BookingDetailsController>().refreshBooking();
        }
      },
      onError: (_) {
        isConfirming.value = false;
      },
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
