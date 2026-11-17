part of 'login_screen.dart';

class LoginMobileScreen extends GetView<LoginController> {
  const LoginMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              // ---> ADD LANGUAGE TOGGLE HERE <---
              Align(
                alignment: Alignment.centerRight,
                child: _buildLanguageToggle(),
              ),
              Sizes.height.v10, // Add a little spacing
              
              BrandLogo(),
              const HeadingWidget(),
              InputWidget(),
              const LogInButtonWidget(),
              if (BasicServices.userIsRegister.value == 1)
                const DoNotHaveAnAccount(),
            ],
          ),
        ),
      ),
    );
  }

  // ---> ADD THIS WIDGET METHOD <---
  Widget _buildLanguageToggle() {
    return Obx(() {
      final isEnglish = LocaleService.to.currentLanguageCode == 'en';
      return InkWell(
        onTap: () {
          // Toggle between 'en' and 'ar'
          LocaleService.to.changeLanguage(isEnglish ? 'ar' : 'en');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                isEnglish ? 'العربية' : 'English',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}