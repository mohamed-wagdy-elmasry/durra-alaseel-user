import 'dart:developer' as developer;
import '../base/api/endpoint/api_endpoint.dart';
import '../base/api/services/api_services.dart';
import '../models/delivery_check_result.dart';

class DeliveryApiService {
  /// Returns null on network/server error — callers must handle gracefully.
  Future<DeliveryCheckResult?> checkDeliveryArea({
    required int branchId,
    required double lat,
    required double lng,
  }) async {
    try {
      return await ApiServices.apiService<DeliveryCheckResult>(
        (json) => DeliveryCheckResult.fromJson(json),
        ApiEndpoint.checkDeliveryArea.url(),
        method: 'POST',
        body: {
          'branch_id': branchId,
          'lat': lat,
          'lng': lng,
        },
        showErrorMessage: false,
      );
    } catch (e) {
      developer.log('DeliveryApiService error: $e', name: 'delivery_service');
      return null;
    }
  }
}
