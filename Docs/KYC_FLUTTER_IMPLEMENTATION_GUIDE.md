# Flutter KYC (Know Your Customer) Implementation Guide

## Overview

This guide explains how to integrate KYC (Know Your Customer) functionality into your Flutter application for handling National ID and Driving License document uploads. The implementation follows SOLID principles, DRY (Don't Repeat Yourself), and KISS (Keep It Simple, Stupid) practices.

---

## API Base URL

```
https://your-domain/api/v1/user/identification
```

## Authentication

All endpoints require a Bearer token. Add the authentication header to all requests:

```
Authorization: Bearer {token}
Content-Type: application/json
```

---

## Endpoints

### 1. Get User Identification Information

**Endpoint:** `GET /api/v1/user/identification/info`

**Method:** `GET`

**Purpose:** Retrieve the current user's national ID and driving license image URLs.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** Empty (No body required)

**Response Example (Success - 200):**
```json
{
    "message": ["Identification info fetched successfully!"],
    "status": true,
    "data": {
        "instructions": {
            "national_id": "Image URL path for national ID document",
            "driving_license": "Image URL path for driving license document"
        },
        "identification": {
            "national_id": "frontend/user-national-id/national_id_user_123_6584956.jpg",
            "driving_license": "frontend/user-driving-license/driving_lic_user_123_8945123.jpg"
        },
        "image_paths": {
            "base_url": "https://your-domain",
            "national_id_path_location": "frontend/user-national-id",
            "driving_license_path_location": "frontend/user-driving-license"
        }
    },
    "code": 200
}
```

**Response Example (No images uploaded - 200):**
```json
{
    "message": ["Identification info fetched successfully!"],
    "status": true,
    "data": {
        "instructions": {
            "national_id": "Image URL path for national ID document",
            "driving_license": "Image URL path for driving license document"
        },
        "identification": {
            "national_id": null,
            "driving_license": null
        },
        "image_paths": {
            "base_url": "https://your-domain",
            "national_id_path_location": "frontend/user-national-id",
            "driving_license_path_location": "frontend/user-driving-license"
        }
    },
    "code": 200
}
```

---

### 2. Get All Identification Information

**Endpoint:** `GET /api/v1/user/identification/all`

**Method:** `GET`

**Purpose:** Retrieve both national ID and driving license image URLs with completion status.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** Empty (No body required)

**Response Example (Success - 200):**
```json
{
    "message": ["All identification images fetched successfully!"],
    "status": true,
    "data": {
        "user_id": 123,
        "national_id": "frontend/user-national-id/national_id_user_123_6584956.jpg",
        "driving_license": "frontend/user-driving-license/driving_lic_user_123_8945123.jpg",
        "identification_complete": true,
        "image_paths": {
            "base_url": "https://your-domain",
            "national_id_path_location": "frontend/user-national-id",
            "driving_license_path_location": "frontend/user-driving-license"
        }
    },
    "code": 200
}
```

**Response Example (Incomplete - 200):**
```json
{
    "message": ["All identification images fetched successfully!"],
    "status": true,
    "data": {
        "user_id": 123,
        "national_id": "frontend/user-national-id/national_id_user_123_6584956.jpg",
        "driving_license": null,
        "identification_complete": false,
        "image_paths": {
            "base_url": "https://your-domain",
            "national_id_path_location": "frontend/user-national-id",
            "driving_license_path_location": "frontend/user-driving-license"
        }
    },
    "code": 200
}
```

---

### 3. Upload National ID Image

**Endpoint:** `POST /api/v1/user/identification/national-id/upload`

**Method:** `POST`

**Purpose:** Upload an image of the user's national ID document.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
| Field | Type | Required | Max Size | Allowed Formats |
|-------|------|----------|----------|-----------------|
| national_id | File/Image | Yes | 10 MB | jpg, png, jpeg, gif, webp |

**Example using cURL:**
```bash
curl -X POST \
  https://your-domain/api/v1/user/identification/national-id/upload \
  -H "Authorization: Bearer {token}" \
  -F "national_id=@/path/to/national_id.jpg"
```

**Valid Response (Success - 200):**
```json
{
    "message": ["National ID image successfully uploaded!"],
    "status": true,
    "data": {
        "national_id": "frontend/user-national-id/national_id_user_123_6584956.jpg"
    },
    "code": 200
}
```

**Error Response - Invalid File Format (422):**
```json
{
    "message": [
        "The national_id field must be a file of type: jpg, png, jpeg, gif, webp."
    ],
    "status": false,
    "data": [],
    "code": 422
}
```

**Error Response - File Too Large (422):**
```json
{
    "message": [
        "The national_id field must not be greater than 10240 kilobytes."
    ],
    "status": false,
    "data": [],
    "code": 422
}
```

**Error Response - No File Provided (422):**
```json
{
    "message": ["The national_id field is required."],
    "status": false,
    "data": [],
    "code": 422
}
```

---

### 4. Upload Driving License Image

**Endpoint:** `POST /api/v1/user/identification/driving-license/upload`

**Method:** `POST`

**Purpose:** Upload an image of the user's driving license document.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
| Field | Type | Required | Max Size | Allowed Formats |
|-------|------|----------|----------|-----------------|
| driving_license | File/Image | Yes | 10 MB | jpg, png, jpeg, gif, webp |

**Example using cURL:**
```bash
curl -X POST \
  https://your-domain/api/v1/user/identification/driving-license/upload \
  -H "Authorization: Bearer {token}" \
  -F "driving_license=@/path/to/driving_license.jpg"
```

**Valid Response (Success - 200):**
```json
{
    "message": ["Driving license image successfully uploaded!"],
    "status": true,
    "data": {
        "driving_license": "frontend/user-driving-license/driving_lic_user_123_8945123.jpg"
    },
    "code": 200
}
```

**Error Response - Invalid File Format (422):**
```json
{
    "message": [
        "The driving_license field must be a file of type: jpg, png, jpeg, gif, webp."
    ],
    "status": false,
    "data": [],
    "code": 422
}
```

**Error Response - File Too Large (422):**
```json
{
    "message": [
        "The driving_license field must not be greater than 10240 kilobytes."
    ],
    "status": false,
    "data": [],
    "code": 422
}
```

**Error Response - No File Provided (422):**
```json
{
    "message": ["The driving_license field is required."],
    "status": false,
    "data": [],
    "code": 422
}
```

---

### 5. Delete National ID Image

**Endpoint:** `DELETE /api/v1/user/identification/national-id/delete`

**Method:** `DELETE`

**Purpose:** Remove the user's national ID image.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** Empty (No body required)

**Valid Response (Success - 200):**
```json
{
    "message": ["National ID image successfully deleted!"],
    "status": true,
    "data": [],
    "code": 200
}
```

**Error Response - No Image Found (400):**
```json
{
    "message": ["No national ID image found to delete"],
    "status": false,
    "data": [],
    "code": 400
}
```

**Error Response - Server Error (500):**
```json
{
    "message": ["Something went wrong! Please try again"],
    "status": false,
    "data": [],
    "code": 500
}
```

---

### 6. Delete Driving License Image

**Endpoint:** `DELETE /api/v1/user/identification/driving-license/delete`

**Method:** `DELETE`

**Purpose:** Remove the user's driving license image.

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** Empty (No body required)

**Valid Response (Success - 200):**
```json
{
    "message": ["Driving license image successfully deleted!"],
    "status": true,
    "data": [],
    "code": 200
}
```

**Error Response - No Image Found (400):**
```json
{
    "message": ["No driving license image found to delete"],
    "status": false,
    "data": [],
    "code": 400
}
```

**Error Response - Server Error (500):**
```json
{
    "message": ["Something went wrong! Please try again"],
    "status": false,
    "data": [],
    "code": 500
}
```

---

## Image Upload Requirements

| Property            | Value                              |
| ------------------- | ---------------------------------- |
| **Max File Size**   | 10 MB                              |
| **Allowed Formats** | JPG, PNG, JPEG, GIF, WebP          |
| **Content Type**    | multipart/form-data                |
| **Field Name**      | `national_id` or `driving_license` |

---

## HTTP Status Codes

| Code | Name                  | Meaning                                        |
| ---- | --------------------- | ---------------------------------------------- |
| 200  | OK                    | Request was successful                         |
| 400  | Bad Request           | Image doesn't exist or other validation errors |
| 422  | Unprocessable Entity  | Validation failed (invalid file type/size)     |
| 500  | Internal Server Error | Server-side error                              |

---

## Flutter Implementation Architecture

### Project Structure

```
lib/
├── views/kyc/
│   ├── model/
│   │   └── identification_model.dart
│   ├── service/
│   │   └── kyc_service.dart
│   ├── controller/
│   │   └── kyc_controller.dart
│   ├── screen/
│   │   ├── kyc_screen.dart
│   │   ├── kyc_mobile_screen.dart
│   │   └── kyc_tablet_screen.dart
│   └── widget/
│       ├── document_card.dart
│       ├── image_picker_bottom_sheet.dart
│       └── verification_status_card.dart
├── bindings/
│   └── kyc_binding.dart
└── routes/
    └── routes.dart (updated)
```

### Design Principles Applied

#### SOLID Principles

1. **Single Responsibility Principle**
   - `KycService`: Only handles API calls
   - `KycController`: Only manages state
   - `DocumentCard`: Only displays document information
   - Each widget has a single, well-defined purpose

2. **Open/Closed Principle**
   - Service is open for extension (new endpoints can be added easily)
   - Controller is closed for modification (no need to change existing logic)

3. **Liskov Substitution Principle**
   - All screens extend `StatelessWidget` or `GetView`
   - Controllers extend `GetxController`
   - Follows standard Flutter/GetX patterns

4. **Interface Segregation Principle**
   - Clean public APIs in service and controller
   - No unused methods exposed
   - Focused method signatures

5. **Dependency Inversion Principle**
   - `KycController` depends on `KycService`
   - Both depend on abstractions (HTTP client abstractions)
   - Uses GetX for dependency injection

#### DRY (Don't Repeat Yourself) Principle

- **Reusable Components:**
  - `ImagePickerBottomSheet` used by both mobile and tablet screens
  - `DocumentCard` used for both national ID and driving license
  - `VerificationStatusCard` displays status across all layouts

- **Shared Business Logic:**
  - Image picker methods in controller (used by multiple widgets)
  - Error/success message handling centralized in controller
  - API calls delegated to service

#### KISS (Keep It Simple, Stupid) Principle

- **Simple State Management:**
  - RxBool, Rx<T> for reactive updates
  - No complex state transitions
  - Clear, straightforward getter methods

- **Simple UI Components:**
  - Each widget is self-contained and easy to understand
  - No complex logic in build methods
  - Clear separation between UI and business logic

---

## Usage Examples

### 1. Navigate to KYC Screen

```dart
Get.toNamed(Routes.kycScreen);
```

### 2. Upload National ID Image

```dart
final controller = Get.find<KycController>();

// User picks image from gallery
await controller.pickImageFromGallery(forNationalId: true);

// Upload the selected image
await controller.uploadNationalIdImage();
```

### 3. Download and Display Images

```dart
Obx(
  () => Image.network(
    controller.identification?.getNationalIdFullUrl() ?? '',
    fit: BoxFit.cover,
  ),
)
```

### 4. Check Verification Status

```dart
Obx(
  () {
    if (controller.isVerificationComplete) {
      // Show verified status
    } else {
      // Show incomplete status
      // Progress: ${controller.completionPercentage}%
    }
  },
)
```

### 5. Handle Errors

```dart
Obx(
  () {
    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
)
```

---

## State Management with GetX

### Controller State Variables

```dart
// Identification data
final _identification = Rx<IdentificationModel?>(null);

// Loading state
final _isLoading = false.obs;

// Selected images
final _selectedNationalIdImage = Rx<File?>(null);
final _selectedDrivingLicenseImage = Rx<File?>(null);

// Messages
final _errorMessage = Rx<String?>(null);
final _successMessage = Rx<String?>(null);
```

### Reactive Updates

All state changes automatically trigger UI rebuilds via `Obx()`:

```dart
Obx(() {
  if (controller.isLoading) {
    return CircularProgressIndicator();
  }
  return YourWidget();
})
```

---

## Localization Support

The KYC screen supports both English and Arabic:

### Accessing Translations

```dart
// In Dart code
Text(Strings.kycVerification)
Text(Strings.nationalId)
Text(Strings.drivingLicense)

// In JSON (automatically loaded)
"appLKycVerification": "KYC Verification"
"appLNationalId": "National ID"
"appLDrivingLicense": "Driving License"
```

### Arabic Translations

All strings have corresponding Arabic translations in `lib/languages/ar.json`:

```json
{
  "appLKycVerification": "التحقق من الهوية",
  "appLNationalId": "بطاقة الهوية",
  "appLDrivingLicense": "رخصة القيادة"
}
```

---

## Error Handling Best Practices

### Server Response Validation

```dart
if (result != null && response['status'] == true) {
  // Handle success
  print('Success: ${response['message']}');
} else {
  // Handle error
  final errorMessage = response['message']?[0] ?? 'Unknown error';
  print('Error: $errorMessage');
}
```

### User-Friendly Messages

```dart
String _extractErrorMessage(dynamic error) {
  if (error is Exception) {
    final message = error.toString();
    if (message.contains('Exception: ')) {
      return message.replaceAll('Exception: ', '');
    }
  }
  return Strings.somethingWentWrong;
}
```

### Confirmation Dialogs

```dart
Get.dialog(
  AlertDialog(
    title: Text(Strings.confirmUpload),
    content: Text(Strings.uploadNationalIdQuestion),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: Text(Strings.cancel),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
          controller.uploadNationalIdImage();
        },
        child: Text(Strings.upload),
      ),
    ],
  ),
);
```

---

## Folder Structure in Server

Images are stored in the following server directories:

```
public/frontend/
├── user-national-id/         (National ID images)
└── user-driving-license/     (Driving license images)
```

Full URL format:

```
https://your-domain/frontend/user-national-id/{filename}
https://your-domain/frontend/user-driving-license/{filename}
```

---

## Testing with Postman

### Setup

1. Import the collection from your API documentation
2. Set environment variable: `token` = your_auth_token
3. Set environment variable: `base_url` = your_api_base_url

### Test Get Identification Info

```
GET {{base_url}}/api/v1/user/identification/info
Authorization: Bearer {{token}}
```

### Test Upload National ID

```
POST {{base_url}}/api/v1/user/identification/national-id/upload
Authorization: Bearer {{token}}

Form Data:
Key: national_id
Type: File
Value: <select image file>
```

### Test Delete National ID

```
DELETE {{base_url}}/api/v1/user/identification/national-id/delete
Authorization: Bearer {{token}}
```

---

## Troubleshooting

### Issue: "The national_id field must be a file of type: jpg, png, jpeg, gif, webp"

**Solution:** Ensure the uploaded file is an image in one of the supported formats. Check the file extension and MIME type.

### Issue: "The national_id field must not be greater than 10240 kilobytes"

**Solution:** Compress your image or select a smaller file. Maximum size is 10 MB. The app automatically limits quality to 80% during image picking.

### Issue: "The national_id field is required"

**Solution:** Ensure an image is selected before attempting upload. Check `selectedNationalIdImage` is not null.

### Issue: "No national ID image found to delete"

**Solution:** The user hasn't uploaded a national ID image yet. Call the upload endpoint first.

### Issue: 401 Unauthorized

**Solution:** Check that the Bearer token is valid and hasn't expired. Verify token is properly formatted in headers.

### Issue: 500 Internal Server Error

**Solution:** This is a server error. Try again later or contact support if the problem persists.

---

## Dependencies

The KYC implementation uses:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.0              # State management and routing
  http: ^1.1.0             # HTTP client
  image_picker: ^1.1.2     # Image selection
```

---

## Performance Optimization

### Image Compression

Images are compressed to 80% quality during selection:

```dart
final XFile? pickedFile = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,  // Reduces file size
);
```

### Lazy Loading

The KYC controller is lazy-loaded via GetX binding:

```dart
Get.lazyPut(() => KycController());
```

### Reactive Updates

Only affected widgets rebuild when state changes via `Obx()`.

---

## Support and Maintenance

For issues or questions related to this implementation:

- **Email:** support@your-domain.com
- **Documentation:** https://your-domain.com/api-docs
- **Code Repository:** Check the `/Docs` folder for additional guides

---

**Last Updated:** February 14, 2026
**API Version:** v1
**Implementation Version:** 1.0.0

---

## Quick Reference

### Common Methods

```dart
// Refresh data
controller.refreshIdentification()

// Get completion percentage
controller.completionPercentage  // 0-100

// Check if verification is complete
controller.isVerificationComplete  // true/false

// Get full image URLs
controller.identification?.getNationalIdFullUrl()
controller.identification?.getDrivingLicenseFullUrl()

// Upload images
controller.uploadNationalIdImage()
controller.uploadDrivingLicenseImage()

// Delete images
controller.deleteNationalIdImage()
controller.deleteDrivingLicenseImage()

// Clear selected image
controller.clearSelectedImage(forNationalId: true)
```

### State Checking

```dart
// Check loading status
controller.isLoading

// Check if documents are uploaded
controller.identification?.nationalId != null
controller.identification?.drivingLicense != null

// Get error/success messages
controller.errorMessage
controller.successMessage
```
