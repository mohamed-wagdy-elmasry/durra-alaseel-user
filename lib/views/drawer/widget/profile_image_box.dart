part of '../screen/drawer_screen.dart';

class ProfileHeaderWidget extends GetView<DashboardController> {
  const ProfileHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If profile info hasn't loaded yet, trigger fetch
    if (controller.userFullName.value.isEmpty ||
        controller.userProfileImage.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getDashboardInfo();
      });
    }

    final double avatarRadius = Dimensions.radius * 4.5;

    return GestureDetector(
      onTap: () {
        Get.back(); // Close drawer
        Get.toNamed(Routes.update_profileScreen);
      },
      child: Obx(() {
        final profileImageUrl = controller.userProfileImage.value;
        final defaultImageUrl = controller.userDefaultImageUrl.value;
        final fullName = controller.userFullName.value;
        final email = controller.userEmail.value;

        bool isValidUrl(String url) {
          return url.isNotEmpty &&
              (url.startsWith('http://') || url.startsWith('https://'));
        }

        return Column(
          children: [
            Sizes.height.v30,
            Hero(
              tag: 'profile_avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2.5, color: CustomColor.primary),
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: CustomColor.primary.withOpacity(0.08),
                  child: ClipOval(
                    child: Builder(
                      builder: (context) {
                        if (isValidUrl(profileImageUrl)) {
                          return CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            width: avatarRadius * 2,
                            height: avatarRadius * 2,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CustomColor.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                isValidUrl(defaultImageUrl)
                                    ? Image.network(
                                        defaultImageUrl,
                                        width: avatarRadius * 2,
                                        height: avatarRadius * 2,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          size: avatarRadius * 1.2,
                                          color: CustomColor.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: avatarRadius * 1.2,
                                        color: CustomColor.primary,
                                      ),
                          );
                        } else if (isValidUrl(defaultImageUrl)) {
                          return Image.network(
                            defaultImageUrl,
                            width: avatarRadius * 2,
                            height: avatarRadius * 2,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              size: avatarRadius * 1.2,
                              color: CustomColor.primary,
                            ),
                          );
                        } else {
                          return Icon(
                            Icons.person,
                            size: avatarRadius * 1.2,
                            color: CustomColor.primary,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Sizes.height.v10,
            Column(
              crossAxisAlignment: crossStart,
              children: [
                TextWidget(
                  fullName.isNotEmpty
                      ? fullName
                      : (LocalStorage.email.isNotEmpty
                          ? LocalStorage.email.split('@').first
                          : 'User'),
                  fontSize: Dimensions.titleLarge,
                  fontWeight: FontWeight.w600,
                  color: CustomColor.typography,
                  translate: false,
                ),
                TextWidget(
                  email.isNotEmpty ? email : LocalStorage.email,
                  fontSize: Dimensions.titleSmall,
                  color: CustomColor.secondary,
                  translate: false,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
