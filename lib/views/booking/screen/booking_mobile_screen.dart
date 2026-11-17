part of 'booking_screen.dart';

class BookingMobileScreen extends GetView<BookingController> {
  const BookingMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarboColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _BookingHeroHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  CarboSpacing.x4, CarboSpacing.x5, CarboSpacing.x4, CarboSpacing.x4,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    BookingAllFields(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCTA(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        CarboSpacing.x4,
        CarboSpacing.x3,
        CarboSpacing.x4,
        bottomInset + CarboSpacing.x3,
      ),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        boxShadow: CarboShadow.floating,
      ),
      child: Obx(() {
        final canConfirm = controller.canConfirmBooking;
        return GestureDetector(
          onTap: canConfirm ? () => Get.toNamed(Routes.previewScreen) : null,
          child: AnimatedOpacity(
            duration: CarboDuration.normal,
            opacity: canConfirm ? 1.0 : 0.45,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: canConfirm ? CarboGradients.primary : null,
                color: canConfirm ? null : CarboColors.textDisabled,
                borderRadius: CarboRadius.lgAll,
                boxShadow: canConfirm ? CarboShadow.primaryGlow : null,
              ),
              alignment: Alignment.center,
              child: Text(
                Strings.continuee.tr,
                style: CarboTypography.buttonLabel,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BookingHeroHeader extends GetView<BookingController> {
  const _BookingHeroHeader();

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
                        color: Colors.white.withValues(alpha: 0.2),
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
                      Strings.bookYorCar.tr,
                      style: CarboTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CarboSpacing.x5),
              Text(
                Strings.rentalDetails.tr,
                style: CarboTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: CarboSpacing.x3),
              CarSummaryCard(car: controller.selectedCar),
            ],
          ),
        ),
      ),
    );
  }
}
