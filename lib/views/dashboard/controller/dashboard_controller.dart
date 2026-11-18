import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/dashboard/model/area_has_type_model.dart';
import 'package:carbo/views/dashboard/model/car_area_model.dart';
import 'package:carbo/views/dashboard/model/branch_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../backend/services/push_notification_controller.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../model/car_info_model.dart';
import '../model/dashboard_info_model.dart';

class DashboardController extends GetxController {
  final List<String> carType = [];
  PushNotificationController get pushController =>
      Get.isRegistered<PushNotificationController>()
          ? Get.find<PushNotificationController>()
          : Get.put(PushNotificationController(), permanent: true);

  RxInt currentIndex = 0.obs;
  RxString selectedDate = ''.obs;
  RxString selectedTime = ''.obs;
  RxString userFullName = ''.obs;
  RxString userEmail = ''.obs;
  RxString userName = ''.obs;
  RxString userDefaultImageUrl = ''.obs;
  RxString userProfileImage = ''.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;
  var selectedCarIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardInfo();
  }

  void clearData() {
    cars.clear();
    selectedTime.value = '';
    selectedDate.value = '';
  }

  // Get Dashboard Info
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  late DashboardInfoModel _dashboardInfoModel;

  DashboardInfoModel get dashboardInfoModel => _dashboardInfoModel;

  Future<DashboardInfoModel?> getDashboardInfo() async {
    return RequestProcess().request<DashboardInfoModel>(
      fromJson: DashboardInfoModel.fromJson,
      apiEndpoint: ApiEndpoint.dashboardInfo,
      isLoading: _isLoading,
      showErrorMessage: false,
      onSuccess: (value) {
        _dashboardInfoModel = value!;
        _getDashboardInfo();
        
        // Subscribe to push notifications for auto-authenticated users
        // This ensures users receive notifications after app restart
        final userId = _dashboardInfoModel.data.userInfo.id;
        pushController.subscribeUser(userId);
        
        areaList.clear();
        typeList.clear();
        branchList.clear();
        getArea();
        getBranches();
      },
    );
  }

  void _getDashboardInfo() {
    var baseUrl = _dashboardInfoModel.data.profileImagePaths.baseUrl;
    var path = _dashboardInfoModel.data.profileImagePaths.pathLocation;
    var img = _dashboardInfoModel.data.userInfo.image;
    var defaultImg = _dashboardInfoModel.data.profileImagePaths.defaultImage;
    
    // Check if user has a profile image
    // Handle null, empty string, and the string "null"
    if (img != null && 
        img.toString().isNotEmpty && 
        img.toString() != 'null') {
      userProfileImage.value = '${baseUrl}/$path/$img';
      print('✅ User has profile image: $img');
    } else {
      userProfileImage.value = '${baseUrl}/$defaultImg';
      print('⚠️ No user image, using default (image value was: $img)');
    }
    
    userDefaultImageUrl.value = '${baseUrl}/$defaultImg';
    print('🖼️ User Profile Image URL: ${userProfileImage.value}');
    print('🖼️ User Default Image URL: ${userDefaultImageUrl.value}');
    userFullName.value = _dashboardInfoModel.data.userInfo.fullname;
    userEmail.value = _dashboardInfoModel.data.userInfo.email;

    // Save email and mobile to LocalStorage for auto-fill in booking
    LocalStorage.save(
      email: _dashboardInfoModel.data.userInfo.email,
      number: _dashboardInfoModel.data.userInfo.mobile?.toString() ?? '',
    );
  }

  // Clear cached profile images
  void _clearImageCache() {
    try {
      // Clear the cache for old profile images
      if (userProfileImage.value.isNotEmpty) {
        CachedNetworkImage.evictFromCache(userProfileImage.value);
      }
      print('🗑️ Cleared image cache');
    } catch (e) {
      print('⚠️ Failed to clear image cache: $e');
    }
  }

  //// GET ARE - - - - - - - - - - - - - - - - -
  Rxn<Datum> selectedArea = Rxn<Datum>();
  final List<Datum> areaList = [];

  RxInt areaId = 0.obs;
  RxString selectArea = ''.obs;

  late CarAreaModel _carAreaModel;

  CarAreaModel get carAreaModel => _carAreaModel;

  Future<CarAreaModel?> getArea() async {
    return RequestProcess().request<CarAreaModel>(
      fromJson: CarAreaModel.fromJson,
      apiEndpoint: ApiEndpoint.getArea,
      isLoading: _isLoading,
      showErrorMessage: false,
      onSuccess: (value) {
        _carAreaModel = value!;
        selectArea.value = _carAreaModel.data.first.name;
        _carAreaModel.data.forEach((v) {
          areaList.add(
            Datum(
              name: v.name,
              status: v.status,
              createdAt: v.createdAt,
              id: v.id,
              lastEditBy: v.lastEditBy,
              slug: v.slug,
              updatedAt: v.updatedAt,
            ),
          );
        });
      },
    );
  }

  // AREA HAS TYPE POST - - - - - - - - - - - - - - - - -
  RxInt carTypeId = 0.obs;
  RxString alis = ''.obs;

  Rxn<TypesAll> selectType = Rxn<TypesAll>();
  final List<TypesAll> typeList = [];

  // BRANCH - - - - - - - - - - - - - - - - -
  Rxn<Branch> selectedBranch = Rxn<Branch>();
  final List<Branch> branchList = [];

  RxInt branchId = 0.obs;
  RxString selectBranchName = ''.obs;

  final _isLoad = false.obs;

  bool get isLoad => _isLoad.value;

  late AreaHasTypeModel _areaHasTypeModel;

  AreaHasTypeModel get areaHasTypeModel => _areaHasTypeModel;

  Future<AreaHasTypeModel?> areaHasType() async {
    Map<String, dynamic> inputBody = {'area': areaId.value.toString()};
    return RequestProcess().request<AreaHasTypeModel>(
      fromJson: AreaHasTypeModel.fromJson,
      apiEndpoint: ApiEndpoint.postAreaHasType,
      isLoading: _isLoad,
      method: HttpMethod.POST,
      showResult: true,
      body: inputBody,
      onSuccess: (value) {
        _areaHasTypeModel = value!;
        _areaHasTypeModel.data.area.typesAll?.forEach((v) {
          typeList.add(
            TypesAll(
              name: v.type?.name,
              id: v.id,
              updatedAt: v.updatedAt,
              createdAt: v.createdAt,
              type: v.type,
              carTypeId: v.carTypeId,
              carAreaId: v.carAreaId,
            ),
          );
        });
      },
    );
  }

  // GET BRANCHES - - - - - - - - - - - - - - - - -
  late BranchModel _branchModel;

  BranchModel get branchModel => _branchModel;

  Future<BranchModel?> getBranches() async {
    return RequestProcess().request<BranchModel>(
      fromJson: BranchModel.fromJson,
      apiEndpoint: ApiEndpoint.carBranches,
      isLoading: _isLoading,
      showErrorMessage: true,
      onSuccess: (value) {
        _branchModel = value!;
        print('✅ Branches loaded: ${_branchModel.data.branches.length}');
        _branchModel.data.branches.forEach((v) {
          branchList.add(
            Branch(
              id: v.id,
              name: v.name,
              slug: v.slug,
              address: v.address,
              status: v.status,
              createdAt: v.createdAt,
              updatedAt: v.updatedAt,
              lastEditBy: v.lastEditBy,
            ),
          );
        });
        print('📍 Total branches in list: ${branchList.length}');
      },
    );
  }

  // =  SEARCH CAR API

  var cars = <Car>[].obs;
  RxString carImgUrl = ''.obs;
  final _isSearchingCar = false.obs;

  bool get isSearchingCar => _isSearchingCar.value;

  late CarInfoModel _carInfoModel;

  CarInfoModel get carInfoModel => _carInfoModel;

  Future<CarInfoModel?> searchAllCar() async {
    cars.clear();
    Map<String, dynamic> inputBody = {
      'car_area': areaId.value,
      'car_type': carTypeId.value,
      'pickup_time': selectedTime.value,
      'pickup_date': selectedDate.value,
    };
    // Add branch_id if selected
    if (branchId.value > 0) {
      inputBody['branch_id'] = branchId.value;
    }
    return RequestProcess().request<CarInfoModel>(
      fromJson: CarInfoModel.fromJson,
      apiEndpoint: ApiEndpoint.searchCar,
      isLoading: _isSearchingCar,
      method: HttpMethod.POST,
      body: inputBody,
      showResult: true,
      onSuccess: (value) {
        _carInfoModel = value!;
        carToken.value = _carInfoModel.data.token;
        print('🔑 Car Token: ${carToken.value}');

        carImgUrl.value =
            '${_carInfoModel.data.dataPath.baseUrl}/${_carInfoModel.data.dataPath.imagePath}/';
        _carInfoModel.data.cars.forEach((element) {
          cars.add(
            Car(
              carAreaId: element.carAreaId,
              id: element.id,
              carTypeId: element.carTypeId,
              carNumber: element.carNumber,
              slug: element.slug,
              status: element.status,
              fees: element.fees,
              image: element.image,
              approval: element.approval,
              carModel: element.carModel,
              createdAt: element.createdAt,
              experience: element.experience,
              seat: element.seat,
              updatedAt: element.updatedAt,
              vendorId: element.vendorId,
              carTitle: element.carTitle,
            ),
          );
        });
        if (cars.isEmpty) {
          CustomSnackBar.error(Strings.noCarFindMessage.tr);
        }
      },
    );
  }
}
