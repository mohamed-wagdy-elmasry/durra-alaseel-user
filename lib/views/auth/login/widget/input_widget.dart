part of '../screen/login_screen.dart';

class InputWidget extends GetView<LoginController> {
  const InputWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form( // ---> WRAPPED IN FORM <---
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => PrimaryInputWidget(
            controller: controller.emailAddressController,
            label: Strings.emailAddress,
            hintText: Strings.emailAddress,
            textInputType: TextInputType.emailAddress,
            showBorderSide: true,
            apiErrorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
            validatorFunction: controller.validateEmail, // ---> ADDED VALIDATOR <---
          )),
          Sizes.height.betweenInputBox,
          Obx(() => PrimaryInputWidget(
            controller: controller.passwordController,
            label: Strings.password,
            hintText: Strings.password,
            isPasswordField: true,
            textInputType: TextInputType.text,
            apiErrorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
          )),
          _isRememberMeWidget(context),
          Sizes.height.v30,
        ],
      ),
    );
  }

  _isRememberMeWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Dimensions.heightSize * 0.66),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => Get.toNamed(Routes.reset_passwordScreen),
            child: TextWidget(
              Strings.forgotPassword,
              fontWeight: FontWeight.w400,
              color: CustomColor.primary,
              typographyStyle: TypographyStyle.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}