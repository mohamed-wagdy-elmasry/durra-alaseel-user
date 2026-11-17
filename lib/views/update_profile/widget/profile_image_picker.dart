import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/base/design_system/carbo_ds.dart';
import 'package:carbo/views/update_profile/controller/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../base/utils/basic_import.dart';
import '../../../../languages/locale_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class ProfileImagePicker extends GetView<UpdateProfileController> {
  final double radius;
  ProfileImagePicker({super.key, this.radius = 52.0});

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _imagePickerBottomSheetWidget(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openImagePicker(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // outer ring — white border that separates avatar from the red hero
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CarboColors.surface,
              boxShadow: CarboShadow.floating,
            ),
            padding: const EdgeInsets.all(4),
            child: Obx(() {
              return CircleAvatar(
                radius: radius,
                backgroundColor: CarboColors.background,
                backgroundImage: controller.imageFile.value != null
                    ? FileImage(controller.imageFile.value!) as ImageProvider
                    : null,
                child: controller.imageFile.value == null
                    ? ClipOval(
                        child: Builder(builder: (context) {
                          var profileUrl = '';
                          if (Get.isRegistered<DashboardController>()) {
                            profileUrl = Get.find<DashboardController>()
                                .userProfileImage
                                .value;
                          }
                          if (profileUrl.isEmpty) {
                            profileUrl = controller.userImage.value;
                          }

                          if (profileUrl.isEmpty) {
                            return Icon(Icons.person_rounded,
                                size: radius * 0.9,
                                color: CarboColors.textSecondary);
                          }
                          return CachedNetworkImage(
                            imageUrl: profileUrl,
                            width: radius * 2,
                            height: radius * 2,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              var defaultUrl = '';
                              if (Get.isRegistered<DashboardController>()) {
                                defaultUrl = Get.find<DashboardController>()
                                    .userDefaultImageUrl
                                    .value;
                              }
                              if (defaultUrl.isEmpty) {
                                return Icon(Icons.person_rounded,
                                    size: radius * 0.9,
                                    color: CarboColors.textSecondary);
                              }
                              return Image.network(defaultUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.person_rounded,
                                      size: radius * 0.9,
                                      color: CarboColors.textSecondary));
                            },
                          );
                        }),
                      )
                    : null,
              );
            }),
          ),
          // camera badge
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openImagePicker(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: CarboGradients.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: CarboColors.surface, width: 2.5),
                  boxShadow: CarboShadow.primaryGlow,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePickerBottomSheetWidget(BuildContext context) {
    final isArabic = LocaleService.to.currentLocale.languageCode.startsWith('ar');
    return Container(
      margin: const EdgeInsets.fromLTRB(
          CarboSpacing.x4, 0, CarboSpacing.x4, CarboSpacing.x5),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.xxlTop,
      ),
      padding: const EdgeInsets.all(CarboSpacing.x5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: CarboSpacing.x5),
            decoration: BoxDecoration(
              color: CarboColors.border,
              borderRadius: CarboRadius.fullAll,
            ),
          ),
          Text(
            isArabic ? 'تعديل الصورة الشخصية' : 'Update Photo',
            style: CarboTypography.titleMedium
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: CarboSpacing.x5),
          Row(
            children: [
              Expanded(
                child: _pickerOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: Strings.fromGallery.tr,
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ),
              const SizedBox(width: CarboSpacing.x4),
              Expanded(
                child: _pickerOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: Strings.fromCamera.tr,
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: CarboSpacing.x3),
        ],
      ),
    );
  }

  Widget _pickerOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x5),
        decoration: BoxDecoration(
          color: CarboColors.primaryLight,
          borderRadius: CarboRadius.lgAll,
        ),
        child: Column(
          children: [
            Icon(icon, color: CarboColors.primary, size: 32),
            const SizedBox(height: CarboSpacing.x2),
            Text(label,
                style: CarboTypography.labelMedium
                    .copyWith(color: CarboColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
