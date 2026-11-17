import 'package:flutter/material.dart';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/views/kyc/controller/kyc_controller.dart';
import 'package:carbo/views/kyc/widget/document_card.dart';
import 'package:carbo/views/kyc/widget/image_picker_bottom_sheet.dart';

part 'kyc_mobile_screen.dart';
part 'kyc_tablet_screen.dart';

/// Main KYC (Know Your Customer) Screen
/// 
/// Provides responsive layout for mobile and tablet devices
/// Handles national ID and driving license image uploads
class KycScreen extends GetView<KycController> {
  const KycScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: KycMobileScreen(),
      tablet: KycTabletScreen(),
    );
  }
}
