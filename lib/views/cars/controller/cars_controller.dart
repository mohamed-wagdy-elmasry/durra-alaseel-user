import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/services/location_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../model/cars_list_model.dart';

class CarsController extends GetxController {
  // Sort state
  RxString sortOrder = 'price_desc'.obs; // 'price_asc' or 'price_desc'

  // Location state
  Rxn<double> userLat = Rxn<double>();
  Rxn<double> userLng = Rxn<double>();
  RxBool isLocationSorting = false.obs;

  // Filter state
  Rxn<int> selectedCarTypeId = Rxn<int>();
  Rxn<int> selectedCarModelId = Rxn<int>();
  Rxn<int> selectedBranchId = Rxn<int>();

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt perPage = 15.obs;

  // Data
  RxList<CarItem> cars = <CarItem>[].obs;
  RxList<CarTypeFilter> carTypes = <CarTypeFilter>[].obs;
  RxList<CarModelFilter> carModels = <CarModelFilter>[].obs;
  RxList<BranchFilter> branches = <BranchFilter>[].obs;

  // Data path for images
  RxString baseUrl = ''.obs;
  RxString imagePath = ''.obs;

  // Loading states
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  @override
  void onInit() {
    super.onInit();
    _fetchLocationAndLoad();
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getDashboardInfo();
    }
  }

  /// Request location permission once, obtain coordinates, then load cars.
  /// Falls back to price-based sort if location is unavailable for any reason.
  Future<void> _fetchLocationAndLoad() async {
    try {
      developer.log('Starting location fetch', name: 'CarsController');

      final locationService = LocationService();
      final serviceEnabled = await locationService.isLocationServiceEnabled();
      developer.log('Location service enabled: $serviceEnabled', name: 'CarsController');

      if (!serviceEnabled) {
        developer.log('Location services disabled, opening settings', name: 'CarsController');
        await locationService.openLocationSettings();
        loadCars();
        return;
      }

      final permission = await locationService.checkAndRequestPermission();
      developer.log('Permission status: $permission', name: 'CarsController');

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        developer.log('Location permission not granted, proceeding without location', name: 'CarsController');
        loadCars();
        return;
      }

      developer.log('Getting current position', name: 'CarsController');
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        userLat.value = position.latitude;
        userLng.value = position.longitude;
        isLocationSorting.value = true;
        developer.log(
          'Location obtained: lat=${position.latitude}, lng=${position.longitude}',
          name: 'CarsController',
        );
      } else {
        developer.log('Failed to get position', name: 'CarsController');
      }
    } catch (e) {
      developer.log('Location error (proceeding without location): $e', name: 'CarsController');
    }
    developer.log('Loading cars', name: 'CarsController');
    loadCars();
  }

  /// Toggle sort order between price_asc and price_desc.
  /// Clears location sort so the user's manual choice takes priority.
  void toggleSort() {
    _clearLocationSort();
    sortOrder.value =
        sortOrder.value == 'price_desc' ? 'price_asc' : 'price_desc';
    refreshCars();
  }

  /// Set sort order explicitly.
  /// Clears location sort so the user's manual choice takes priority.
  void setSortOrder(String order) {
    if (sortOrder.value != order) {
      _clearLocationSort();
      sortOrder.value = order;
      refreshCars();
    }
  }

  void _clearLocationSort() {
    userLat.value = null;
    userLng.value = null;
    isLocationSorting.value = false;
  }

  /// Set car type filter
  void setCarTypeFilter(int? typeId) {
    selectedCarTypeId.value = typeId;
    // Reset car model filter when type changes
    selectedCarModelId.value = null;
    refreshCars();
  }

  /// Set car model filter
  void setCarModelFilter(int? modelId) {
    selectedCarModelId.value = modelId;
    refreshCars();
  }

  /// Set branch filter
  void setBranchFilter(int? branchId) {
    selectedBranchId.value = branchId;
    refreshCars();
  }

  /// Clear all filters (type, model, branch). Preserves location sort if active.
  void clearFilters() {
    selectedCarTypeId.value = null;
    selectedCarModelId.value = null;
    selectedBranchId.value = null;
    if (!isLocationSorting.value) {
      sortOrder.value = 'price_desc';
    }
    refreshCars();
  }

  /// Refresh cars (reset to page 1)
  void refreshCars() {
    currentPage.value = 1;
    cars.clear();
    loadCars();
  }

  /// Load more cars (next page)
  void loadMoreCars() {
    if (currentPage.value < totalPages.value && !isLoadingMore) {
      currentPage.value++;
      loadCars(isLoadMore: true);
    }
  }

  /// Build query parameters for API
  Map<String, String> _buildQueryParams() {
    final params = <String, String>{
      'per_page': perPage.value.toString(),
      'page': currentPage.value.toString(),
    };

    if (isLocationSorting.value &&
        userLat.value != null &&
        userLng.value != null) {
      params['sort'] = 'distance_asc';
      params['user_lat'] = userLat.value.toString();
      params['user_lng'] = userLng.value.toString();
    } else {
      params['sort'] = sortOrder.value;
    }

    if (selectedCarTypeId.value != null) {
      params['car_type_id'] = selectedCarTypeId.value.toString();
    }

    if (selectedCarModelId.value != null) {
      params['car_model_id'] = selectedCarModelId.value.toString();
    }

    if (selectedBranchId.value != null) {
      params['branch_id'] = selectedBranchId.value.toString();
    }

    return params;
  }

  /// Load cars from API
  Future<CarsListModel?> loadCars({bool isLoadMore = false}) async {
    final loadingState = isLoadMore ? _isLoadingMore : _isLoading;

    return RequestProcess().request<CarsListModel>(
      fromJson: CarsListModel.fromJson,
      apiEndpoint: ApiEndpoint.carsList,
      isLoading: loadingState,
      queryParams: _buildQueryParams(),
      isBasic: true,
      showErrorMessage: true,
      onSuccess: (value) {
        if (value != null) {
          final data = value.data;

          // Update data path
          baseUrl.value = data.dataPath.baseUrl;
          imagePath.value = data.dataPath.imagePath;

          // Update cars list
          if (isLoadMore) {
            cars.addAll(data.cars);
          } else {
            cars.value = data.cars;
          }

          // Update filters from available_filters
          carTypes.value = data.availableFilters.carTypes;
          carModels.value = data.availableFilters.carModels;
          branches.value = data.availableFilters.branches;

          // Update pagination
          totalPages.value = data.pagination.lastPage;
        }
      },
    );
  }

  /// Get full image URL for a car
  String getCarImageUrl(CarItem car) {
    if (car.imageUrl.isNotEmpty) {
      return car.imageUrl;
    }
    if (baseUrl.value.isNotEmpty && car.image.isNotEmpty) {
      return '${baseUrl.value}/${imagePath.value}/${car.image}';
    }
    return '';
  }

  /// Get filtered car models based on selected car type
  List<CarModelFilter> get filteredCarModels {
    if (selectedCarTypeId.value == null) {
      return carModels;
    }
    return carModels
        .where((model) => model.carTypeId == selectedCarTypeId.value)
        .toList();
  }
}
