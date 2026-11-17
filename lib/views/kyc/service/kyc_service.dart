import 'package:carbo/base/api/endpoint/api_endpoint.dart';
import 'package:carbo/base/api/method/request_process.dart';
import 'package:carbo/views/kyc/model/identification_model.dart';
import 'package:get/get.dart';

/// Service class for handling KYC (Know Your Customer) identification API calls
/// 
/// This service follows SOLID principles:
/// - Single Responsibility: Only handles identification API operations
/// - Open/Closed: Easily extensible for new endpoints
/// - Dependency Injection: Accepts dependencies through constructor
/// 
/// Features:
/// - Get identification information
/// - Upload national ID image
/// - Upload driving license image
/// - Delete national ID image
/// - Delete driving license image
class KycService {
  /// Get user's current identification information
  /// 
  /// Returns: IdentificationModel with current ID and license images
  /// Throws: Exception with error message on failure
  static Future<IdentificationModel?> getIdentificationInfo({
    required RxBool isLoading,
  }) async {
    return RequestProcess().request<IdentificationModel>(
      fromJson: (json) => IdentificationModel.fromJson(json),
      apiEndpoint: ApiEndpoint.identificationInfo,
      isLoading: isLoading,
      method: HttpMethod.GET,
      onSuccess: (value) {
        // Success handled by controller
      },
    );
  }

  /// Get all identification information including completion status
  /// 
  /// Returns: IdentificationModel with all identification data
  /// Throws: Exception with error message on failure
  static Future<IdentificationModel?> getAllIdentifications({
    required RxBool isLoading,
  }) async {
    final result = await RequestProcess().request<IdentificationModel>(
      fromJson: (json) {
        final model = IdentificationModel.fromJson(json);
        return model;
      },
      apiEndpoint: ApiEndpoint.identificationAll,
      isLoading: isLoading,
      method: HttpMethod.GET,
      onSuccess: (value) {
        // Success handled by controller
      },
    );
    
    return result;
  }

  /// Upload national ID image to the backend
  /// 
  /// Parameters:
  ///   - imagePath: Full file path to the image
  ///   - isLoading: RxBool to track loading state
  /// 
  /// Returns: Path to uploaded image on success
  /// Throws: Exception with validation or upload error message
  static Future<String?> uploadNationalIdImage({
    required String imagePath,
    required RxBool isLoading,
  }) async {
    try {
      final result = await RequestProcess().request<String>(
        fromJson: (json) {
          try {
            // Handle upload response which has {data: {national_id: "filename"}}
            if (json['data'] == null) {
              return '';
            }
            
            final uploadedPath = json['data']['national_id'] ?? '';
            return uploadedPath;
          } catch (e) {
            return '';
          }
        },
        apiEndpoint: ApiEndpoint.uploadNationalId,
        isLoading: isLoading,
        method: HttpMethod.POST,
        fieldList: ['national_id'],
        pathList: [imagePath],
        onSuccess: (value) {
          // Success handled by controller
        },
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload driving license image to the backend
  /// 
  /// Parameters:
  ///   - imagePath: Full file path to the image
  ///   - isLoading: RxBool to track loading state
  /// 
  /// Returns: Path to uploaded image on success
  /// Throws: Exception with validation or upload error message
  static Future<String?> uploadDrivingLicenseImage({
    required String imagePath,
    required RxBool isLoading,
  }) async {
    try {
      final result = await RequestProcess().request<String>(
        fromJson: (json) {
          try {
            // Handle upload response which has {data: {driving_license: "filename"}}
            if (json['data'] == null) {
              return '';
            }
            
            final uploadedPath = json['data']['driving_license'] ?? '';
            return uploadedPath;
          } catch (e) {
            return '';
          }
        },
        apiEndpoint: ApiEndpoint.uploadDrivingLicense,
        isLoading: isLoading,
        method: HttpMethod.POST,
        fieldList: ['driving_license'],
        pathList: [imagePath],
        onSuccess: (value) {
          // Success handled by controller
        },
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete national ID image from backend
  /// 
  /// Returns: true if deletion was successful
  /// Throws: Exception if no image found or server error
  static Future<bool> deleteNationalIdImage({
    required RxBool isLoading,
  }) async {
    final result = await RequestProcess().request<Map<String, dynamic>>(
      fromJson: (json) => json,
      apiEndpoint: ApiEndpoint.deleteNationalId,
      isLoading: isLoading,
      method: HttpMethod.DELETE,
      onSuccess: (value) {
        // Success handled by controller
      },
    );
    return result != null;
  }

  /// Delete driving license image from backend
  /// 
  /// Returns: true if deletion was successful
  /// Throws: Exception if no image found or server error
  static Future<bool> deleteDrivingLicenseImage({
    required RxBool isLoading,
  }) async {
    final result = await RequestProcess().request<Map<String, dynamic>>(
      fromJson: (json) => json,
      apiEndpoint: ApiEndpoint.deleteDrivingLicense,
      isLoading: isLoading,
      method: HttpMethod.DELETE,
      onSuccess: (value) {
        // Success handled by controller
      },
    );
    return result != null;
  }
}

