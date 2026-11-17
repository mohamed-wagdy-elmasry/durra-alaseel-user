import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/design_system/carbo_ds.dart';
import '../../../base/utils/dimensions.dart';
import '../../../base/widgets/primary_button.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../controller/congratulations_controller.dart';

class CongratulationsButton extends StatelessWidget {
  CongratulationsButton({super.key});
  final controller = Get.put(CongratulationsController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize * 1.4,
        vertical: Dimensions.verticalSize * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            title: Strings.myBooking.tr,
            onPressed: () {
              Get.offAllNamed(Routes.dashboardScreen);
              Get.toNamed(Routes.historyScreen);
            },
          ),
          SizedBox(height: CarboSpacing.x3),
          PrimaryButton(
            title: controller.buttonText.value,
            buttonColor: Colors.white,
            buttonTextColor: CarboColors.primary,
            borderColor: CarboColors.primary,
            borderWidth: 1.5,
            onPressed: () {
              Get.offAllNamed(controller.route.value);
            },
          ),
        ],
      ),
    );
  }
}
