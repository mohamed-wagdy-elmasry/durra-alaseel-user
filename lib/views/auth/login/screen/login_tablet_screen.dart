part of 'login_screen.dart';

class LoginTabletScreen extends GetView<LoginController> {
  const LoginTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Login Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                // ---> ADD LANGUAGE TOGGLE HERE <---
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildLanguageToggle(),
                ),
                Sizes.height.v10,

                BrandLogo(),
                const HeadingWidget(),
                InputWidget(),
                const LogInButtonWidget(),
                if (BasicServices.userIsRegister.value == 1)
                  const DoNotHaveAnAccount(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Obx(() {
      final isEnglish = LocaleService.to.currentLanguageCode == 'en';
      return InkWell(
        onTap: () {
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