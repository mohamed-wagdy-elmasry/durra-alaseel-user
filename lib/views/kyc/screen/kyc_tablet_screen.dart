part of 'kyc_screen.dart';

/// KYC Tablet Screen
/// 
/// Optimized layout for tablet devices
/// Side-by-side card layout for better use of screen space
class KycTabletScreen extends GetView<KycController> {
  const KycTabletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Strings.kycVerification,
      ),
      body: Obx(
        () => controller.isLoading && controller.identification == null
            ? _buildLoadingState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Cards Side by Side
          Row(
            children: [
              // National ID Card
              Expanded(
                child: Obx(
                  () => DocumentCard(
                    title: Strings.nationalId,
                    imageUrl:
                        controller.identification?.getNationalIdFullUrl(),
                    localImage: controller.selectedNationalIdImage,
                    isLoading: controller.isUploadingNationalId,
                    onUpload: () => _handleUpload(forNationalId: true),
                    onClearSelection: () => controller.clearSelectedImage(forNationalId: true),
                    onDelete: (controller.identification?.hasNationalId ?? false)
                        ? () => _showDeleteConfirmation(
                              forNationalId: true,
                              onConfirm:
                                  controller.deleteNationalIdImage,
                            )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.defaultHorizontalSize),

              // Driving License Card
              Expanded(
                child: Obx(
                  () => DocumentCard(
                    title: Strings.drivingLicense,
                    imageUrl: controller.identification
                        ?.getDrivingLicenseFullUrl(),
                    localImage: controller.selectedDrivingLicenseImage,
                    isLoading: controller.isUploadingDrivingLicense,
                    onUpload: () =>
                        _handleUpload(forNationalId: false),
                    onClearSelection: () => controller.clearSelectedImage(forNationalId: false),
                    onDelete: (controller.identification?.hasDrivingLicense ?? false)
                        ? () => _showDeleteConfirmation(
                              forNationalId: false,
                              onConfirm: controller
                                  .deleteDrivingLicenseImage,
                            )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.defaultHorizontalSize),

          // Messages
          _buildMessages(),
          SizedBox(height: Dimensions.defaultHorizontalSize),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Column(
      children: [
        Obx(
          () => controller.errorMessage != null
              ? _buildErrorMessage(controller.errorMessage ?? '')
              : SizedBox.shrink(),
        ),
        Obx(
          () => controller.successMessage != null
              ? _buildSuccessMessage(controller.successMessage ?? '')
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize * 0.75),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize * 0.75),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpload({required bool forNationalId}) {
    // Check if local image is already selected
    final hasLocalImage = forNationalId
        ? controller.selectedNationalIdImage != null
        : controller.selectedDrivingLicenseImage != null;

    if (hasLocalImage) {
      // Upload the selected image
      if (forNationalId) {
        controller.uploadNationalIdImage();
      } else {
        controller.uploadDrivingLicenseImage();
      }
    } else {
      // Show image picker to select image
      _showImagePickerSheet(forNationalId: forNationalId);
    }
  }

  void _showImagePickerSheet({required bool forNationalId}) {
    final context = Get.context;
    if (context == null) return;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius * 1.5),
        ),
      ),
      builder: (context) => ImagePickerBottomSheet(
        onGalleryTap: () => controller.pickImageFromGallery(
          forNationalId: forNationalId,
        ),
        onCameraTap: () => controller.pickImageFromCamera(
          forNationalId: forNationalId,
        ),
      ),
    );
  }

  void _showDeleteConfirmation({
    required bool forNationalId,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(Strings.confirmDelete),
        content: Text(
          forNationalId
              ? Strings.deleteNationalIdQuestion
              : Strings.deleteDrivingLicenseQuestion,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(Strings.cancel, style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(Strings.delete, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
