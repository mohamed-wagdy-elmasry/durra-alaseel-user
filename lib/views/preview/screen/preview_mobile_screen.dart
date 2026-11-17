part of 'preview_screen.dart';

class PreviewMobileScreen extends GetView<PreviewController> {
  const PreviewMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarboColors.background,
      body: Obx(
        () => controller.isLoading
            ? Container(
                color: CarboColors.background,
                child: const Center(child: Loader()),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _PreviewHeroHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      CarboSpacing.x4,
                      CarboSpacing.x4,
                      CarboSpacing.x4,
                      CarboSpacing.x6,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        PreviewSectionCard(),
                        const SizedBox(height: CarboSpacing.x4),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Obx(
        () => controller.isLoading
            ? const SizedBox.shrink()
            : _BottomBar(),
      ),
    );
  }
}

class _PreviewHeroHeader extends GetView<PreviewController> {
  const _PreviewHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: CarboGradients.primary,
        boxShadow: CarboShadow.primaryGlow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CarboSpacing.x4,
            CarboSpacing.x3,
            CarboSpacing.x4,
            CarboSpacing.x6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: CarboRadius.mdAll,
                      ),
                      child: const Icon(
                        CarboIcons.back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: CarboSpacing.x3),
                  Expanded(
                    child: Text(
                      Strings.bookingPreview.tr,
                      style: CarboTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CarboSpacing.x5),
              Text(
                Strings.bookingPreview.tr,
                style: CarboTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: CarboSpacing.x3),
              CarSummaryCard(car: Get.find<BookingController>().selectedCar),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends GetView<PreviewController> {
  _BottomBar();

  final WalletController _walletController = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        CarboSpacing.x4,
        CarboSpacing.x3,
        CarboSpacing.x4,
        bottomPadding + CarboSpacing.x3,
      ),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        boxShadow: CarboShadow.floating,
      ),
      child: Obx(() {
        final wallet = _walletController.walletModel.value;
        final isInsufficient = wallet != null &&
            wallet.balance < controller.totalPayable.value;
        return PrimaryButton(
          isLoading: controller.isBookingLoading,
          title: Strings.ConfirmBooking,
          disable: isInsufficient,
          onPressed: isInsufficient ? () {} : () => controller.handlePaymentProcess(),
        );
      }),
    );
  }
}
