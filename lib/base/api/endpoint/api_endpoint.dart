class ApiConfig {
  static const String mainDomain = "https://dora-rent.com";
  // static const String mainDomain = "https://192.168.1.211";
  static const String baseUrl = "$mainDomain/api/v1";
  static const String languageUrl = "$baseUrl/settings/languages";

  static String extensionHistoryUrl(int bookingId) =>
      '$baseUrl/user/car-booking/$bookingId/extensions';
}

enum ApiEndpoint {
  basicSettings('/settings/basic-settings'),
  getAllCountry('/settings/countries'),
  // Auth
  login('/login'),
  forgotPassword('/password/forgot/find/user'),
  forgotPasswordVerifyCode('/password/forgot/verify/code'),
  resendForgotOtpCode('/password/forgot/resend/code'),
  resetPassword('/password/forgot/reset'),
  register('/register'), 
  emailOtpVerify('/authorize/mail/verify/code'),
  resendEmailOtp('/authorize/mail/resend/code'),
  kycInfo('/user/kyc-input-fields'),
  kycSubmit('/user/kyc-submit'),

  // 2FA
  twoFaInfo('/user/google-2fa'),
  twoFaStatusUpdate('/user/google-2fa/status/update'),
  twoFaOtpVerify('/user/google-2fa/verify/code'),
  logOut('/user/logout'),

  // Cars (Public)
  carsList('/cars'),
  carTypes('/cars/types'),
  carModels('/cars/models'),
  carDetails('/cars'),
  carBranches('/cars/branches'),

  // Dashboard
  dashboardInfo('/user/dashboard'),
  history('/user/car-booking/booking/history'),
  getArea('/user/car-booking/area'),
  postAreaHasType('/user/car-booking/area/types'),
  searchCar('/user/car-booking/search/car'),
  notification('/user/notifications'),

  // Profile
  profileInfo('/user/profile/info'),
  updateProfile('/user/profile/info/update'),
  updatePassword('/user/profile/password/update'),
  deleteAccount('/user/profile/delete-account'),

  // Identification (KYC)
  identificationInfo('/user/identification/info'),
  identificationAll('/user/identification/all'),
  uploadNationalId('/user/identification/national-id/upload'),
  deleteNationalId('/user/identification/national-id/delete'),
  uploadDrivingLicense('/user/identification/driving-license/upload'),
  deleteDrivingLicense('/user/identification/driving-license/delete'),

  // Booking confirm
  bookingConfirm('/user/car-booking/confirm'),
  getBookingPreview('/user/car-booking/preview'),

  // Payment
  manualRePayment('/user/car-booking/repayment/submit'),
  getManualPaymentField('/user/car-booking/manual/input-fields'),
  rePayment('/user/car-booking/re-manual/input-fields'),

  // Authorize
  authorizeSubmit("/user/car-booking/authorize-payment-submit"),

  // Booking Extension
  extendPreview('/user/car-booking/extend/preview'),
  extendBooking('/user/car-booking/extend'),

  // Delivery
  checkDeliveryArea('/user/check-delivery-area'),
  validateDateTime('/user/car-booking/validate-datetime'),

  // Wallet
  walletBalance('/user/wallet'),
  walletTransactions('/user/wallet/transactions'),
  walletRecharge('/user/wallet/recharge'),
  cancelBooking('/user/car-booking/cancel');

  final String path;

  const ApiEndpoint(this.path);

  /// Returns the full URL with optional query parameters
  String url({Map<String, String>? params}) {
    final base = "${ApiConfig.baseUrl}$path";

    // Always build URLs via Uri to ensure proper percent-encoding
    // (e.g. spaces, ':' in times, and bracketed keys like pickup_location[latitude]).
    if (params == null || params.isEmpty) return base;
    return Uri.parse(base).replace(queryParameters: params).toString();
  }

  /// Convenience method to append query parameters
  String withParams(Map<String, String> params) => url(params: params);
}
