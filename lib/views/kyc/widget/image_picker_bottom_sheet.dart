import 'package:flutter/material.dart';
import 'package:carbo/base/utils/basic_import.dart';

/// Image picker bottom sheet widget
/// 
/// Shows options to pick image from gallery or camera
/// Follows DRY principle by centralizing image picker UI
class ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const ImagePickerBottomSheet({
    Key? key,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            margin: EdgeInsets.only(bottom: Dimensions.defaultHorizontalSize),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Strings.selectImageSource,
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                )
              ],
            ),
          ),

          // Gallery Option
          ListTile(
            leading: Icon(Icons.photo_library, color: CustomColor.primary),
            title: Text(Strings.fromGallery),
            onTap: () {
              Get.back();
              onGalleryTap();
            },
          ),

          // Camera Option
          ListTile(
            leading: Icon(Icons.camera_alt, color: CustomColor.primary),
            title: Text(Strings.fromCamera),
            onTap: () {
              Get.back();
              onCameraTap();
            },
          ),

          SizedBox(height: Dimensions.defaultHorizontalSize),
        ],
      ),
    );
  }
}
