import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/api_error_handler.dart';
import '../../../../languages/strings.dart'; // Make sure this is imported

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool isFormValid = false.obs;
  
  RxString emailError = ''.obs;
  RxString passwordError = ''.obs;

  get onLogInProcess => logInProcess();

  @override
  void onInit() {
    emailAddressController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    super.onInit();
  }

  void _updateFormValidity() {
    isFormValid.value = emailAddressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
        
    if (emailError.value.isNotEmpty) emailError.value = '';
    if (passwordError.value.isNotEmpty) passwordError.value = '';
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  String? validateEmail(String? value) {
    // ---> USE STRINGS CLASS <---
    if (value == null || value.trim().isEmpty) return Strings.pleaseFillOutTheField.tr;
    if (!GetUtils.isEmail(value.trim())) return Strings.invalidEmail.tr;
    return null;
  }

  logInProcess() async {
    ApiErrorHandler.clearError();
    emailError.value = '';
    passwordError.value = '';

    if (!formKey.currentState!.validate()) return;

    return AuthServices.logInService(
      credentials: emailAddressController.text,
      password: passwordController.text,
      isLoading: _isLoading,
      onError: (error) {
        // ---> USE STRINGS CLASS FOR SECURITY MESSAGE <---
        passwordError.value = Strings.invalidCredentials.tr; 
      },
    );
  }

  logOutProcess() async {
    return AuthServices.logOutService(isLoading: _isLoading);
  }

  deleteAccountProcess() async {
    return AuthServices.deleteAccountServices(isLoading: _isLoading);
  }

  void clearError() {
    emailError.value = '';
    passwordError.value = '';
  }
}