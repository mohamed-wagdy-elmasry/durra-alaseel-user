import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carbo/base/utils/basic_import.dart';

/// Document upload card widget
/// 
/// Displays document image with upload/delete buttons
/// Supports both English and Arabic languages
class DocumentCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final File? localImage;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;
  final VoidCallback? onClearSelection;
  final bool isLoading;

  const DocumentCard({
    Key? key,
    required this.title,
    this.imageUrl,
    this.localImage,
    required this.onUpload,
    this.onDelete,
    this.onClearSelection,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title.tr,
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.defaultHorizontalSize * 0.75),

            // Image Preview Section
            _buildImagePreview(),
            SizedBox(height: Dimensions.defaultHorizontalSize * 0.75),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // Check if imageUrl is valid (not null and not empty)
    final hasValidImageUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300] ?? Colors.grey,
          width: 1.5,
        ),
        color: Get.isDarkMode ? Colors.grey[850] : Colors.grey[50],
      ),
      child: localImage != null
          ? _buildLocalImage()
          : hasValidImageUrl
              ? _buildLoadedImage()
              : _buildEmptyPlaceholder(),
    );
  }

  Widget _buildLocalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        localImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  Strings.failedToLoadImage.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  Strings.failedToLoadImage.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: Dimensions.defaultHorizontalSize * 0.5),
          Text(
            Strings.noImageUploaded.tr,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasLocalImage = localImage != null;
    final hasBackendImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    
    return Row(
      children: [
        Expanded(
          child: _buildUploadButton(),
        ),
        // Show clear button only if local image is selected (not uploaded yet)
        if (hasLocalImage && onClearSelection != null) ...[
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: _buildClearButton(),
          ),
        ],
        // Show delete button only if image is uploaded to backend
        if (hasBackendImage && !hasLocalImage && onDelete != null) ...[
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: _buildDeleteButton(),
          ),
        ]
      ],
    );
  }

  Widget _buildUploadButton() {
    final hasLocalImage = localImage != null;
    final buttonText = hasLocalImage ? Strings.uploadToServer : Strings.uploadImage;
    final buttonIcon = hasLocalImage ? Icons.cloud_upload : Icons.add_photo_alternate;
    
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onUpload,
      icon: Icon(buttonIcon, color: Colors.white),
      label: Text(buttonText.tr, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.primary,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onDelete,
      icon: Icon(Icons.delete, color: Colors.white),
      label: Text(Strings.delete.tr, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onClearSelection,
      icon: Icon(Icons.close, color: Colors.white),
      label: Text(Strings.clear.tr, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
