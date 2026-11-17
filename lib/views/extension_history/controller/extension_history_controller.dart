import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/services/api_services.dart';
import '../../../base/utils/basic_import.dart';
import '../../../backend/model/extension_history_model.dart';

class ExtensionHistoryController extends GetxController {
  late final int bookingId;

  final RxBool isLoading = false.obs;
  final Rx<ExtensionHistoryModel?> data = Rx<ExtensionHistoryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    bookingId = Get.arguments['bookingId'] as int;
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final url = ApiConfig.extensionHistoryUrl(bookingId);
      final result = await ApiServices.apiService<ExtensionHistoryModel>(
        ExtensionHistoryModel.fromJson,
        url,
        showErrorMessage: true,
      );
      if (result != null) {
        data.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
