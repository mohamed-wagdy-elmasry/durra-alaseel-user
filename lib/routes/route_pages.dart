part of '../routes/routes.dart';

class RoutePageList {
  static var list = [
    GetPage(
      name: Routes.settingScreen,
      page: () => const SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.notificationScreen,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.register_otp_verificationScreen,
      page: () => const RegisterOtpVerificationScreen(),
      binding: RegisterOtpVerificationBinding(),
    ),
    GetPage(
      name: Routes.change_passwordScreen,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.previewScreen,
      page: () => const PreviewScreen(),
      binding: PreviewBinding(),
    ),
    GetPage(
      name: Routes.update_profileScreen,
      page: () => const UpdateProfileScreen(),
      binding: UpdateProfileBinding(),
    ),
    GetPage(
      name: Routes.bookingScreen,
      page: () => BookingScreen(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.paymentManualField,
      page: () => PaymentManualField(),
    ),
    GetPage(
      name: Routes.RePaymentManualField,
      page: () => RePaymentManualField(),
    ),
    GetPage(
      name: Routes.new_passwordScreen,
      page: () => const NewPasswordScreen(),
      binding: NewPasswordBinding(),
    ),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otp_verificationScreen,
      page: () => const OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: Routes.reset_passwordScreen,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.registerScreen,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.product_detailsScreen,
      page: () => const ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: Routes.dashboardScreen,
      page: () => const CarsListScreen(),
      binding: CarsBinding(),
    ),
    GetPage(
      name: Routes.splashScreen,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboardScreen,
      page: () => OnboardScreen(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: Routes.historyScreen,
      page: () => HistoryScreen(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.pusherChannelsScreen,
      page: () => const PusherChannelsExampleView(),
    ),
    GetPage(
      name: Routes.kycScreen,
      page: () => const KycScreen(),
      binding: KycBinding(),
    ),
    GetPage(
      name: Routes.bookingDetailsScreen,
      page: () => const BookingDetailsScreen(),
      binding: BookingDetailsBinding(),
    ),
    GetPage(
      name: Routes.extensionHistoryScreen,
      page: () => const ExtensionHistoryScreen(),
      binding: ExtensionHistoryBinding(),
    ),
    GetPage(
      name: Routes.mapLocationPickerScreen,
      page: () => const MapLocationPickerScreen(),
    ),
    GetPage(
      name: Routes.walletScreen,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletPaymentWebview,
      page: () => const WalletPaymentWebviewScreen(),
    ),
  ];
}
