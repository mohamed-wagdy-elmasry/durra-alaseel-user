import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/cars/model/cars_list_model.dart';
import 'package:carbo/backend/model/car_booking/pickup_location_model.dart';
import 'package:carbo/models/delivery_check_result.dart';
import 'package:carbo/models/datetime_validation_result.dart';
import 'package:carbo/services/delivery_api_service.dart';
import 'package:carbo/base/api/endpoint/api_endpoint.dart';
import 'package:carbo/base/api/method/api_method.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingController extends GetxController {
  BookingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final emailController = TextEditingController();
  final noteController = TextEditingController();
  final mobileController = TextEditingController();
  final rentalDaysController = TextEditingController();

  RxBool isFormValid = false.obs;
  RxString selectedRoundDate = ''.obs;
  RxString selectedRoundTime = ''.obs;
  RxString selectedPickupDate = ''.obs;
  RxString selectedPickupTime = ''.obs;
  var isChecked = false.obs;

  // Delivery option state
  final deliveryCheckResult = Rxn<DeliveryCheckResult>();
  final selectedDeliveryLocation = Rxn<LatLng>();
  final isCheckingDelivery = false.obs;
  final selectedLocationAddress = ''.obs;

  // DateTime validation state
  final dateTimeValidation = Rxn<DateTimeValidationResult>();
  final isValidatingDateTime = false.obs;
  Timer? _validateDateTimeDebounce;

  // Pickup location management
  Rx<PickupLocation?> pickupLocation = Rx<PickupLocation?>(null);
  RxBool isPickupFromBranch = true.obs;

  // Car data from route arguments
  late CarItem selectedCar;
  RxString carFee = '0'.obs;
  RxInt rentalDaysCount = 0.obs;
  RxString selectedInsuranceType = 'daily'.obs;

  // ── Server-side pricing state ────────────────────────────────────────────
  final serverPricing = Rxn<Map<String, dynamic>>();
  final serverInsurance = Rxn<Map<String, dynamic>>();
  final pricingLoading = false.obs;
  final pricingError = ''.obs;
  Timer? _pricingDebounce;
    Timer? _validateDebounce;  

  int _pricingRequestId = 0;  
  void setInsuranceType(String type) {
    selectedInsuranceType.value = type;
  }

  bool? get deliveryAvailable {
    return selectedCar.branch?.isDeliveryAvailable;
  }

  bool get isDeliveryEnabled {
    return !isPickupFromBranch.value && deliveryCheckResult.value?.allowed == true;
  }

  double get deliveryPriceValue => selectedCar.deliveryPriceValue;

  bool get forcePickupFromBranch =>
      deliveryAvailable == false;

  bool get canConfirmBooking {
    if (!isFormValid.value) return false;
    if (isPickupFromBranch.value) return true;
    return deliveryCheckResult.value?.allowed == true;
  }

  BranchInfo? get deliveryBranchInfo => selectedCar.branch;

  Set<Marker> get mapMarkers {
    final markers = <Marker>{};
    final branch = selectedCar.branch;
    if (branch != null && (branch.latitude != 0.0 || branch.longitude != 0.0)) {
      markers.add(Marker(
        markerId: const MarkerId('branch'),
        position: LatLng(branch.latitude, branch.longitude),
        infoWindow: InfoWindow(title: branch.name),
      ));
    }
    if (selectedDeliveryLocation.value != null) {
      markers.add(Marker(
        markerId: const MarkerId('delivery'),
        position: selectedDeliveryLocation.value!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ));
    }
    return markers;
  }

  Set<Circle> get mapCircles {
    final branch = selectedCar.branch;
    if (branch == null || !branch.isDeliveryAvailable) return {};
    return {
      Circle(
        circleId: const CircleId('delivery_radius'),
        center: LatLng(branch.latitude, branch.longitude),
        radius: branch.deliveryRadiusKm! * 1000,
        strokeColor: const Color(0xFFFF8C00),
        strokeWidth: 2,
        fillColor: const Color(0x26FF8C00),
      ),
    };
  }

  /// Get car slug for API requests (from car type if available)
  String getCarSlug() {
    return selectedCar.carType?.slug ?? '';
  }

  @override
  void onInit() {
    // Get car data from route arguments
    if (Get.arguments != null && Get.arguments is Map) {
      selectedCar = Get.arguments['car'] ?? CarItem(
        id: 0, vendorId: 0, carTitle: {}, carModel: '', carNumber: '',
        seat: 0, year: 0, fees: '0', price: '0', image: '', imageUrl: '',
        status: 0, createdAt: '',
      );
      carFee.value = selectedCar.fees;
    }

    // Reset delivery state for the newly loaded car
    deliveryCheckResult.value = null;
    selectedDeliveryLocation.value = null;
    serverPricing.value = null;
    serverInsurance.value = null;

    // Auto-populate email and phone from LocalStorage (hidden fields)
    emailController.text = LocalStorage.email;
    mobileController.text = LocalStorage.number;

    // Listen to pickup location changes for form validation
    ever(pickupLocation, (_) => _updateFormValidity());
    ever(isPickupFromBranch, (_) {
      if (forcePickupFromBranch && !isPickupFromBranch.value) {
        isPickupFromBranch.value = true;
        return;
      }

      if (isPickupFromBranch.value) {
        deliveryCheckResult.value = null;
        selectedDeliveryLocation.value = null;
        selectedLocationAddress.value = '';
        _setPickupToBranchLocation();
      } else {
        pickupLocation.value = null;
        deliveryCheckResult.value = null;
        selectedDeliveryLocation.value = null;
        selectedLocationAddress.value = '';
      }
      _updateFormValidity();
      _onPricingInputsChanged();
    });
 // Rental days / date / time → validate first, then pricing
    ever(selectedPickupDate, (_) {
      _updateFormValidity();
      _onFieldChanged();
    });
    ever(selectedPickupTime, (_) {
      _updateFormValidity();
      _onFieldChanged();
    });
    // Insurance type → no validation needed, go straight to pricing
    ever(selectedInsuranceType, (_) => _onPricingInputsChanged());
    rentalDaysController.addListener(() {
      _updateFormValidity();
      _onFieldChanged();
    });

    // Default to branch pickup; set branch location
    _setPickupToBranchLocation();
    if (forcePickupFromBranch) {
      isPickupFromBranch.value = true;
    }

    super.onInit();
  }

  void _updateFormValidity() {
    bool hasValidPickupLocation = isPickupFromBranch.value ||
        (pickupLocation.value != null && pickupLocation.value!.isValid);

    rentalDaysCount.value = int.tryParse(rentalDaysController.text) ?? 0;
    bool hasValidRentalDays = rentalDaysCount.value > 0;

    bool hasPickupDate = selectedPickupDate.value.isNotEmpty;
    bool hasPickupTime = selectedPickupTime.value.isNotEmpty;

    isFormValid.value = hasValidPickupLocation &&
                        hasValidRentalDays &&
                        hasPickupDate &&
                        hasPickupTime;
  }

  /// Set pickup location to branch location from car data
  void _setPickupToBranchLocation() {
    final branchName = selectedCar.branch?.name;
    final branchAddress = branchName != null && branchName.isNotEmpty
        ? '$branchName Branch'
        : 'Branch Location';
    final branch = selectedCar.branch;
    pickupLocation.value = PickupLocation(
      latitude: branch?.latitude ?? 24.7136,
      longitude: branch?.longitude ?? 46.6753,
      address: branchAddress,
    );
  }

  /// Get branch location as LatLng for map centering
  LatLng? getBranchLocation() {
    final branch = selectedCar.branch;
    if (branch != null && (branch.latitude != 0.0 || branch.longitude != 0.0)) {
      return LatLng(branch.latitude, branch.longitude);
    }
    return const LatLng(24.7136, 46.6753);
  }

  /// Set pickup location from map picker
  void setPickupLocation(PickupLocation location) {
    if (forcePickupFromBranch) {
      isPickupFromBranch.value = true;
      _setPickupToBranchLocation();
      return;
    }

    pickupLocation.value = location;
    isPickupFromBranch.value = false;
  }

  Future<void> onDeliveryLocationSelected(LatLng location) async {
    selectedDeliveryLocation.value = location;
    selectedLocationAddress.value = '';
    isCheckingDelivery.value = true;
    deliveryCheckResult.value = null;

    pickupLocation.value = PickupLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      address: '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
    );

    await Future.wait([
      _resolveAddress(location),
      _validateDeliveryLocation(location),
    ]);

    isCheckingDelivery.value = false;
  }

  Future<void> _resolveAddress(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty &&
          selectedDeliveryLocation.value?.latitude == location.latitude &&
          selectedDeliveryLocation.value?.longitude == location.longitude) {
        final p = placemarks.first;
        final parts = [
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.subLocality?.isNotEmpty == true) p.subLocality!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        final addr = parts.join(', ');
        if (addr.isNotEmpty) {
          selectedLocationAddress.value = addr;
          pickupLocation.value = PickupLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            address: addr,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _validateDeliveryLocation(LatLng location) async {
    final branch = selectedCar.branch;
    if (branch == null) return;

    final service = Get.find<DeliveryApiService>();
    final result = await service.checkDeliveryArea(
      branchId: branch.id,
      lat: location.latitude,
      lng: location.longitude,
    );

    deliveryCheckResult.value = result;

    if (result == null) {
      Get.snackbar('Error', 'Could not validate delivery location. Please try again.');
    }
  }

  // void _debounceValidateDateTime() {
  //   _validateDateTimeDebounce?.cancel();
  //   _validateDateTimeDebounce = Timer(const Duration(milliseconds: 300), () {
  //     _validateDateTime();
  //   });
  // }

  Future<void> _validateDateTime() async {
    if (selectedPickupDate.value.isEmpty || selectedPickupTime.value.isEmpty) {
      dateTimeValidation.value = null;
      return;
    }

    isValidatingDateTime.value = true;
    dateTimeValidation.value = null;

    try {
      final headers = await bearerHeaderInfo();
      final url = ApiEndpoint.validateDateTime.url();
      final requestBody = {
        'car_id': selectedCar.id,
        'pickup_date': selectedPickupDate.value,
        'pickup_time': selectedPickupTime.value,
      };
      developer.log('POST $url', name: 'validate_datetime');
      developer.log('Body: $requestBody', name: 'validate_datetime');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      developer.log('Status: ${response.statusCode}', name: 'validate_datetime');
      developer.log('Response: ${response.body}', name: 'validate_datetime');

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = DateTimeValidationResult.fromJson(json);
      developer.log('Parsed: isValid=${result.isValid}, dayName=${result.dayName}, open=${result.openTime}, close=${result.closeTime}', name: 'validate_datetime');
      dateTimeValidation.value = result;
    } catch (e) {
      developer.log('DateTime validation error: $e', name: 'booking_controller');
    } finally {
      isValidatingDateTime.value = false;
    }
  }

  // ── Server-side pricing ──────────────────────────────────────────────────

   void _onFieldChanged() {
    _validateDebounce?.cancel();
    _pricingDebounce?.cancel();

    final hasDate = selectedPickupDate.value.isNotEmpty;
    final hasTime = selectedPickupTime.value.isNotEmpty;

    if (hasDate && hasTime) {
      // Date and time are both present — validate then fetch pricing
      _validateDebounce = Timer(const Duration(milliseconds: 300), () {
        _validateDateTimeThenPricing();
      });
    } else {
      // Missing date or time — clear pricing, no shimmer
      serverPricing.value = null;
      serverInsurance.value = null;
      pricingLoading.value = false;
      pricingError.value = '';
    }
  }


     /// Validate datetime, then ALWAYS proceed to pricing.
  /// The validation result is used for delivery toggle UI only.
  /// The pricing endpoint re-validates on the server side.
  Future<void> _validateDateTimeThenPricing() async {
    if (selectedPickupDate.value.isEmpty || selectedPickupTime.value.isEmpty) {
      serverPricing.value = null;
      serverInsurance.value = null;
      pricingLoading.value = false;
      return;
    }

    isValidatingDateTime.value = true;
    dateTimeValidation.value = null;

    try {
      final headers = await bearerHeaderInfo();
      final url = ApiEndpoint.validateDateTime.url();
      final requestBody = {
        'car_id': selectedCar.id,
        'pickup_date': selectedPickupDate.value,
        'pickup_time': selectedPickupTime.value,
      };

      developer.log('Validating datetime: $requestBody', name: 'pricing_flow');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = DateTimeValidationResult.fromJson(json);
      dateTimeValidation.value = result;

      developer.log(
        'Validation done: isValid=${result.isValid}, '
        'day=${result.dayName}, open=${result.openTime}',
        name: 'pricing_flow',
      );

      // ALWAYS proceed to pricing — server re-validates anyway.
      // isValid only controls the delivery toggle UI.
      _onPricingInputsChanged();
    } catch (e) {
      developer.log('Validation error: $e', name: 'pricing_flow');
      // Even on error, still try pricing as fallback
      _onPricingInputsChanged();
    } finally {
      isValidatingDateTime.value = false;
    }
  }

  /// Called ONLY after validation passes, or when a non-datetime
  /// field changes (insurance type, delivery toggle).
  /// Sets loading immediately and debounces the actual API call.
  void _onPricingInputsChanged() {
    _pricingDebounce?.cancel();
    pricingLoading.value = true;
    pricingError.value = '';
    _pricingDebounce = Timer(const Duration(milliseconds: 600), () {
      _fetchPricingPreview();
    });
  }

  /// Call the backend preview endpoint to get authoritative pricing.
  /// Only fires when all required fields are present.
    Future<void> _fetchPricingPreview() async {
    final requestId = ++_pricingRequestId;
    final days = rentalDaysCount.value;
    final pickupDate = selectedPickupDate.value;
    final pickupTime = selectedPickupTime.value;

    // Don't call API if required fields are missing
    if (days <= 0 || pickupDate.isEmpty || pickupTime.isEmpty) {
      if (requestId == _pricingRequestId) {
        serverPricing.value = null;
        serverInsurance.value = null;
        pricingLoading.value = false;
      }
      return;
    }

    // Already true from _onPricingInputsChanged, but keep for direct calls
    pricingLoading.value = true;
    pricingError.value = '';

    try {
      final headers = await bearerHeaderInfo();
      final url = '${ApiEndpoint.getBookingPreview.url()}?pricing_only=1';
      final body = <String, dynamic>{
        'car_id': selectedCar.id,
        'rental_days': days,
        'insurance_type': selectedInsuranceType.value,
        'pickup_date': pickupDate,
        'pickup_time': pickupTime,
        'include_delivery': !isPickupFromBranch.value,
      };

      if (!isPickupFromBranch.value && pickupLocation.value != null) {
        body['pickup_location'] = {
          'latitude': pickupLocation.value!.latitude,
          'longitude': pickupLocation.value!.longitude,
          'address': pickupLocation.value!.address,
        };
      }

      developer.log('POST $url', name: 'pricing_preview');
      developer.log('Body: $body', name: 'pricing_preview');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      developer.log('Raw response keys: ${json.keys.toList()}', name: 'pricing_preview');

      // If a newer request was dispatched while this one was in-flight,
      // discard this stale response entirely.
      if (requestId != _pricingRequestId) return;

      Map<String, dynamic>? data;
      if (json['data'] != null && json['data'] is Map) {
        data = Map<String, dynamic>.from(json['data'] as Map);
      } else if (json['pricing_breakdown'] != null) {
        data = json;
      }

      if (data != null && data['pricing_breakdown'] != null) {
        serverPricing.value = data['pricing_breakdown'] is Map
            ? Map<String, dynamic>.from(data['pricing_breakdown'] as Map)
            : null;
        serverInsurance.value = data['insurance_breakdown'] is Map
            ? Map<String, dynamic>.from(data['insurance_breakdown'] as Map)
            : null;
        pricingError.value = '';
        developer.log(
          'Pricing OK: rental_fees=${serverPricing.value?['rental_fees']}, '
          'base_price=${serverPricing.value?['base_price']}, '
          'total=${serverPricing.value?['total']}',
          name: 'pricing_preview',
        );
      } else {
        developer.log('Pricing parse failed. Raw: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}', name: 'pricing_preview');
        pricingError.value = 'Unexpected server response';
      }
    } catch (e) {
      if (requestId != _pricingRequestId) return;
      pricingError.value = e.toString();
      developer.log('Pricing exception: $e', name: 'pricing_preview');
    } finally {
      if (requestId == _pricingRequestId) {
        pricingLoading.value = false;
      }
    }
  }
    /// Public retry method for error state UI
  void retryPricing() {
    _fetchPricingPreview();
  }

  @override
  void onClose() {
        _validateDebounce?.cancel();  
    _validateDateTimeDebounce?.cancel();
    _pricingDebounce?.cancel();
    dateController.dispose();
    timeController.dispose();
    emailController.dispose();
    noteController.dispose();
    mobileController.dispose();
    rentalDaysController.dispose();
    super.onClose();
  }
}