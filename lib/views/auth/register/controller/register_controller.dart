import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/api_error_handler.dart';
import '../../../../languages/strings.dart'; // ---> ENSURE THIS IMPORT IS HERE <---

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  
  RxBool agree = false.obs;
  RxBool isFormValid = false.obs;

  // ---> Field-specific API errors <---
  RxString firstNameError = ''.obs;
  RxString lastNameError = ''.obs;
  RxString phoneError = ''.obs;
  RxString emailError = ''.obs;
  RxString passwordError = ''.obs;

  @override
  void onInit() {
    // add initial values for testing purposes
    // emailAddressController.text = 'test@gmail.com';
    // passwordController.text = '123456';
    // firstNameController.text = 'John';
    // lastNameController.text = 'Doe';
    // phoneController.text = '1234567890';

    emailAddressController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    firstNameController.addListener(_updateFormValidity);
    lastNameController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    super.onInit();
  }

  void _updateFormValidity() {
    isFormValid.value =
        emailAddressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
        
    // Clear API error messages when user starts typing
    if (firstNameError.value.isNotEmpty) firstNameError.value = '';
    if (lastNameError.value.isNotEmpty) lastNameError.value = '';
    if (phoneError.value.isNotEmpty) phoneError.value = '';
    if (emailError.value.isNotEmpty) emailError.value = '';
    if (passwordError.value.isNotEmpty) passwordError.value = '';
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return Strings.pleaseFillOutTheField.tr;
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return Strings.pleaseFillOutTheField.tr;
    if (!GetUtils.isEmail(value.trim())) return Strings.invalidEmail.tr;
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return Strings.pleaseFillOutTheField.tr;
    if (!GetUtils.isNumericOnly(value.trim())) return Strings.invalidPhone.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return Strings.pleaseFillOutTheField.tr;
    if (value.length < 6) return Strings.shortPassword.tr;
    return null;
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // ---> Updated to clear field errors <---
  void clearAllErrors() {
    firstNameError.value = '';
    lastNameError.value = '';
    phoneError.value = '';
    emailError.value = '';
    passwordError.value = '';
  }

  get onPrivacyPolicy => '';
  get onRegistration => registrationProcess();

  registrationProcess() async {
    ApiErrorHandler.clearError();
    clearAllErrors(); // Clear previous field errors

    // Trigger local validation (red borders) if formats are wrong
    if (!formKey.currentState!.validate()) return;

    return AuthServices.registrationProcess(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailAddressController.text,
      password: passwordController.text,
      phone: phoneController.text,
      isLoading: _isLoading,
      onError: (error) {
        // Map API errors to specific fields
        String errorText = ApiErrorHandler.lastError.isNotEmpty 
            ? ApiErrorHandler.lastError 
            : 'Registration failed. Please try again.'; // Fallback

        if (errorText.toLowerCase().contains('first name')) {
          firstNameError.value = errorText;
        } else if (errorText.toLowerCase().contains('last name')) {
          lastNameError.value = errorText;
        } else if (errorText.toLowerCase().contains('phone')) {
          phoneError.value = errorText;
        } else if (errorText.toLowerCase().contains('email') || errorText.toLowerCase().contains('exist')) {
          emailError.value = errorText;
        } else {
          // If the API error doesn't match specific fields, show it under email as a general error
          emailError.value = errorText; 
        }
      },
    );
  }
}