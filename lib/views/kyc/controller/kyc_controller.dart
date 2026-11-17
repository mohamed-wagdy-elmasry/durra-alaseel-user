import 'dart:io';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:image_picker/image_picker.dart';
import '../model/identification_model.dart';
import '../service/kyc_service.dart';

/// KYC (Know Your Customer) Controller
/// 
/// Manages identification document upload and retrieval using GetX state management.
/// 
/// SOLID Principles Applied:
/// - Single Responsibility: Only manages KYC-related state
/// - Open/Closed: Easily extendable for additional features
/// - Liskov Substitution: Follows standard GetxController pattern
/// - Interface Segregation: Clean public API
/// - Dependency Inversion: Depends on KycService abstraction
/// 
/// DRY Principle: Shared business logic in helper methods
/// KISS Principle: Simple, straightforward state management
class KycController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  final _identification = Rx<IdentificationModel?>(null);
  final _isFetching = false.obs;
  final _isUploadingNationalId = false.obs;
  final _isUploadingDrivingLicense = false.obs;
  final _selectedNationalIdImage = Rx<File?>(null);
  final _selectedDrivingLicenseImage = Rx<File?>(null);
  final _errorMessage = Rx<String?>(null);
  final _successMessage = Rx<String?>(null);

  // Getters
  IdentificationModel? get identification => _identification.value;
  bool get isFetching => _isFetching.value;
  bool get isUploadingNationalId => _isUploadingNationalId.value;
  bool get isUploadingDrivingLicense => _isUploadingDrivingLicense.value;
  bool get isLoading => _isFetching.value || _isUploadingNationalId.value || _isUploadingDrivingLicense.value;
  File? get selectedNationalIdImage => _selectedNationalIdImage.value;
  File? get selectedDrivingLicenseImage => _selectedDrivingLicenseImage.value;
  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;

  /// Check if both documents are uploaded
  bool get isVerificationComplete => identification?.identificationComplete ?? false;

  @override
  void onInit() {
    super.onInit();
    _fetchAllIdentifications();
  }

  // ============================================================
  //                    FETCH OPERATIONS (GET)
  // ============================================================

  /// Fetch all identification information from backend
  Future<void> _fetchAllIdentifications() async {
    try {
      _clearMessages();
      final result = await KycService.getAllIdentifications(
        isLoading: _isFetching,
      );
      
      if (result != null) {
        _identification.value = result;
      }
    } catch (e) {
      _setError(_extractErrorMessage(e));
    }
  }

  /// Refresh identification data from backend
  Future<void> refreshIdentification() async {
    await _fetchAllIdentifications();
  }

  // ============================================================
  //                    IMAGE PICKER OPERATIONS
  // ============================================================

  /// Pick image from gallery (shows in placeholder, does not upload)
  /// 
  /// Parameters:
  ///   - forNationalId: true for national ID, false for driving license
  Future<void> pickImageFromGallery({required bool forNationalId}) async {
    try {
      _clearMessages();
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (forNationalId) {
          _selectedNationalIdImage.value = file;
        } else {
          _selectedDrivingLicenseImage.value = file;
        }
      }
    } catch (e) {
      _setError(Strings.errorPickingImage);
    }
  }

  /// Pick image from camera (shows in placeholder, does not upload)
  /// 
  /// Parameters:
  ///   - forNationalId: true for national ID, false for driving license
  Future<void> pickImageFromCamera({required bool forNationalId}) async {
    try {
      _clearMessages();
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (forNationalId) {
          _selectedNationalIdImage.value = file;
        } else {
          _selectedDrivingLicenseImage.value = file;
        }
      }
    } catch (e) {
      _setError(Strings.errorCapturingImage);
    }
  }

  /// Clear selected image
  void clearSelectedImage({required bool forNationalId}) {
    _clearMessages();
    if (forNationalId) {
      _selectedNationalIdImage.value = null;
    } else {
      _selectedDrivingLicenseImage.value = null;
    }
  }

  // ============================================================
  //                    UPLOAD OPERATIONS (POST)
  // ============================================================

  /// Upload national ID image
  Future<void> uploadNationalIdImage() async {
    final imageFile = _selectedNationalIdImage.value;
    if (imageFile == null) {
      _setError(Strings.pleaseSelectImage);
      return;
    }

    try {
      _clearMessages();
      
      if (!await imageFile.exists()) {
        _setError('Image file not found. Please try again.');
        _selectedNationalIdImage.value = null;
        return;
      }

      await KycService.uploadNationalIdImage(
        imagePath: imageFile.path,
        isLoading: _isUploadingNationalId,
      );
      
      _selectedNationalIdImage.value = null;
      _setSuccess(Strings.nationalIdUploadedSuccessfully);
      
      await _fetchAllIdentifications();
    } catch (e) {
      _selectedNationalIdImage.value = null;
      _setError(_extractErrorMessage(e));
    }
  }

  /// Upload driving license image
  Future<void> uploadDrivingLicenseImage() async {
    final imageFile = _selectedDrivingLicenseImage.value;
    if (imageFile == null) {
      _setError(Strings.pleaseSelectImage);
      return;
    }

    try {
      _clearMessages();
      
      if (!await imageFile.exists()) {
        _setError('Image file not found. Please try again.');
        _selectedDrivingLicenseImage.value = null;
        return;
      }

      await KycService.uploadDrivingLicenseImage(
        imagePath: imageFile.path,
        isLoading: _isUploadingDrivingLicense,
      );
      
      _selectedDrivingLicenseImage.value = null;
      _setSuccess(Strings.drivingLicenseUploadedSuccessfully);
      
      await _fetchAllIdentifications();
    } catch (e) {
      _selectedDrivingLicenseImage.value = null;
      _setError(_extractErrorMessage(e));
    }
  }

  // ============================================================
  //                    DELETE OPERATIONS (DELETE)
  // ============================================================

  /// Delete national ID image from backend
  Future<void> deleteNationalIdImage() async {
    try {
      _clearMessages();
      final success = await KycService.deleteNationalIdImage(
        isLoading: _isUploadingNationalId,
      );

      if (success) {
        _setSuccess(Strings.nationalIdDeletedSuccessfully);
        await _fetchAllIdentifications();
      }
    } catch (e) {
      _setError(_extractErrorMessage(e));
    }
  }

  /// Delete driving license image from backend
  Future<void> deleteDrivingLicenseImage() async {
    try {
      _clearMessages();
      final success = await KycService.deleteDrivingLicenseImage(
        isLoading: _isUploadingDrivingLicense,
      );

      if (success) {
        _setSuccess(Strings.drivingLicenseDeletedSuccessfully);
        await _fetchAllIdentifications();
      }
    } catch (e) {
      _setError(_extractErrorMessage(e));
    }
  }

  // ============================================================
  //                    HELPER METHODS
  // ============================================================

  /// Set error message
  void _setError(String message) {
    _errorMessage.value = message;
    _successMessage.value = null;
  }

  /// Set success message
  void _setSuccess(String message) {
    _successMessage.value = message;
    _errorMessage.value = null;
  }

  /// Clear all messages
  void _clearMessages() {
    _errorMessage.value = null;
    _successMessage.value = null;
  }

  /// Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      
      // Handle common error patterns
      if (message.contains('SocketException') || message.contains('NetworkException')) {
        return 'Network error. Please check your internet connection.';
      }
      
      if (message.contains('TimeoutException')) {
        return 'Upload timeout. Please try again.';
      }
      
      if (message.contains('FormatException')) {
        return 'Invalid image format. Please select a valid image.';
      }
      
      if (message.contains('FileSystemException')) {
        return 'Error accessing image file. Please try again.';
      }
      
      // Extract custom error message
      if (message.contains('Exception: ')) {
        return message.replaceAll('Exception: ', '');
      }
    }
    return Strings.somethingWentWrong;
  }

  /// Check if either image is selected
  bool get hasSelectedImage =>
      _selectedNationalIdImage.value != null ||
      _selectedDrivingLicenseImage.value != null;

  /// Get completion percentage (0-100)
  int get completionPercentage {
    int count = 0;
    if (identification?.hasNationalId ?? false) count++;
    if (identification?.hasDrivingLicense ?? false) count++;
    return (count / 2 * 100).toInt();
  }

  @override
  void onClose() {
    _imagePicker as dynamic;
    super.onClose();
  }
}
