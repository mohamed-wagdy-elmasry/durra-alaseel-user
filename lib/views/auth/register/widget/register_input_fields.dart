part of '../screen/register_screen.dart';

class RegisterInputFields extends GetView<RegisterController> {
  const RegisterInputFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                // ---> WRAPPED IN Obx <---
                child: Obx(() => PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.firstName,
                  controller: controller.firstNameController,
                  hintText: Strings.firstName,
                  validatorFunction: controller.validateRequired,
                  apiErrorText: controller.firstNameError.value.isEmpty ? null : controller.firstNameError.value,
                )),
              ),
              Sizes.width.v10,
              Expanded(
                // ---> WRAPPED IN Obx <---
                child: Obx(() => PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.lastName,
                  controller: controller.lastNameController,
                  hintText: Strings.lastName,
                  validatorFunction: controller.validateRequired,
                  apiErrorText: controller.lastNameError.value.isEmpty ? null : controller.lastNameError.value,
                )),
              ),
            ],
          ),
          Sizes.height.v10,
          
          // ---> WRAPPED IN Obx <---
          Obx(() => PrimaryInputWidget(
            label: Strings.Phone,
            controller: controller.phoneController,
            hintText: Strings.Phone,
            textInputType: TextInputType.phone,
            validatorFunction: controller.validatePhone,
            apiErrorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
          )),
          Sizes.height.v10,
          
          // ---> WRAPPED IN Obx <---
          Obx(() => PrimaryInputWidget(
            label: Strings.emailAddress,
            controller: controller.emailAddressController,
            hintText: Strings.emailAddress,
            validatorFunction: controller.validateEmail,
            apiErrorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
          )),
          Sizes.height.v10,
          
          // ---> WRAPPED IN Obx <---
          Obx(() => PrimaryInputWidget(
            isPasswordField: true,
            label: Strings.password,
            controller: controller.passwordController,
            hintText: Strings.password,
            validatorFunction: controller.validatePassword,
            apiErrorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
          )),
        ],
      ),
    );
  }
}