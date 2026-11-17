part of 'register_screen.dart';

class RegisterMobileScreen extends GetView<RegisterController> {
  const RegisterMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _bodyWidget(context));
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: Dimensions.defaultHorizontalSize),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              BrandLogo(),
              HeadingTextHeader(),
              RegisterInputFields(),
              Sizes.height.v10,
            
              Sizes.height.v10,
                CustomCheckboxWidget(),
              RegisterButton(),
              AlreadyAccountWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
