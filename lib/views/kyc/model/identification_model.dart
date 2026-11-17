/// Model class for user identification data
/// Represents national ID and driving license information
class IdentificationModel {
  final String? nationalId;
  final String? drivingLicense;
  final bool identificationComplete;
  final String? baseUrl;
  final String? nationalIdPath;
  final String? drivingLicensePath;

  IdentificationModel({
    this.nationalId,
    this.drivingLicense,
    this.identificationComplete = false,
    this.baseUrl,
    this.nationalIdPath,
    this.drivingLicensePath,
  });

  /// Factory constructor to parse from JSON response
  factory IdentificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final imagePaths = data['image_paths'] ?? {};
    
    final nationalId = data['national_id'];
    final drivingLicense = data['driving_license'];
    final baseUrl = imagePaths['base_url'];
    final nationalIdPath = imagePaths['national_id_path_location'];
    final drivingLicensePath = imagePaths['driving_license_path_location'];
    
    return IdentificationModel(
      nationalId: nationalId,
      drivingLicense: drivingLicense,
      identificationComplete: data['identification_complete'] ?? false,
      baseUrl: baseUrl,
      nationalIdPath: nationalIdPath,
      drivingLicensePath: drivingLicensePath,
    );
  }

  /// Get full URL for national ID image
  String? getNationalIdFullUrl() {
    if (nationalId != null && 
        nationalId!.trim().isNotEmpty && 
        baseUrl != null && 
        baseUrl!.trim().isNotEmpty) {
      
      // Use nationalIdPath if available, otherwise use default path
      final pathPrefix = nationalIdPath ?? 'public/frontend/user-national-id';
      return '$baseUrl/$pathPrefix/$nationalId';
    }
    return null;
  }

  /// Get full URL for driving license image
  String? getDrivingLicenseFullUrl() {
    if (drivingLicense != null && 
        drivingLicense!.trim().isNotEmpty && 
        baseUrl != null && 
        baseUrl!.trim().isNotEmpty) {
      
      // Use drivingLicensePath if available, otherwise use default path
      final pathPrefix = drivingLicensePath ?? 'public/frontend/user-driving-license';
      return '$baseUrl/$pathPrefix/$drivingLicense';
    }
    return null;
  }

  /// Check if national ID image exists (uploaded)
  bool get hasNationalId {
    return nationalId != null && nationalId!.trim().isNotEmpty;
  }

  /// Check if driving license image exists (uploaded)
  bool get hasDrivingLicense {
    return drivingLicense != null && drivingLicense!.trim().isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'national_id': nationalId,
    'driving_license': drivingLicense,
    'identification_complete': identificationComplete,
  };

  /// Copy with method for immutability
  IdentificationModel copyWith({
    String? nationalId,
    String? drivingLicense,
    bool? identificationComplete,
    String? baseUrl,
    String? nationalIdPath,
    String? drivingLicensePath,
  }) {
    return IdentificationModel(
      nationalId: nationalId ?? this.nationalId,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      identificationComplete: identificationComplete ?? this.identificationComplete,
      baseUrl: baseUrl ?? this.baseUrl,
      nationalIdPath: nationalIdPath ?? this.nationalIdPath,
      drivingLicensePath: drivingLicensePath ?? this.drivingLicensePath,
    );
  }
}
