part of '../screen/preview_screen.dart';

class PreviewSectionCard extends GetView<PreviewController> {
  PreviewSectionCard({super.key});

  final bookController = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    final model = controller.bookingPreviewModel;
    final pricingBreakdown = model?.data.pricingBreakdown;
    final currency = model?.data.bookingCurrency ?? 'SAR';
    final bookingDetails = model?.data.bookingDetails;
    final user = model?.data.user;
    final branch = model?.data.car?.branch;

    String pickupLocationDisplay;
    if (bookingDetails?.pickupLocation?.address != null &&
        bookingDetails!.pickupLocation!.address.isNotEmpty) {
      pickupLocationDisplay = bookingDetails.pickupLocation!.address;
    } else if (bookController.pickupLocation.value?.address != null &&
        bookController.pickupLocation.value!.address.isNotEmpty) {
      pickupLocationDisplay = bookController.pickupLocation.value!.address;
    } else if (bookController.isPickupFromBranch.value &&
        branch?.name != null &&
        branch!.name.isNotEmpty) {
      pickupLocationDisplay = '${branch.name} Branch';
    } else {
      pickupLocationDisplay = 'Not selected';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model?.data.car?.allowanceKm != null &&
            model?.data.car?.allowancePricePerKm != null)
          _AllowanceInfoCard(
            allowanceKm: model!.data.car!.allowanceKm!,
            allowancePricePerKm: model.data.car!.allowancePricePerKm!,
          ),

        _SectionCard(
          icon: CarboIcons.booking,
          title: Strings.preview.tr,
          children: [
            if (user?.email != null && user!.email.isNotEmpty)
              _DetailRow(
                icon: Icons.email_outlined,
                label: Strings.email.tr,
                value: user.email,
              ),
            if (user?.mobile != null && user!.mobile.isNotEmpty)
              _DetailRow(
                icon: Icons.phone_outlined,
                label: Strings.Phone.tr,
                value: user.mobile,
              ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: Strings.PickUpLocation.tr,
              value: pickupLocationDisplay,
            ),
            if (bookingDetails?.pickupDate != null &&
                bookingDetails!.pickupDate.isNotEmpty)
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: Strings.PickUpdate.tr,
                value: bookingDetails.pickupDate,
              ),
            if (bookingDetails?.pickupTime != null &&
                bookingDetails!.pickupTime.isNotEmpty)
              _DetailRow(
                icon: Icons.access_time_outlined,
                label: Strings.PickUpTime.tr,
                value: bookingDetails.pickupTime,
              ),
            if (bookingDetails?.roundPickupDate != null &&
                bookingDetails!.roundPickupDate!.isNotEmpty)
              _DetailRow(
                icon: Icons.calendar_month_outlined,
                label: Strings.roundTripDate.tr,
                value: bookingDetails.roundPickupDate!,
              ),
            if (bookingDetails?.roundPickupTime != null &&
                bookingDetails!.roundPickupTime!.isNotEmpty)
              _DetailRow(
                icon: Icons.access_time_rounded,
                label: Strings.roundTripTime.tr,
                value: bookingDetails.roundPickupTime!,
              ),
            _DetailRow(
              icon: CarboIcons.car,
              label: Strings.carModel.tr,
              value: controller.carModel.value,
            ),
          ],
        ),

        const SizedBox(height: CarboSpacing.x3),

        _WalletBalanceCard(),

        const SizedBox(height: CarboSpacing.x3),

        if (pricingBreakdown != null)
          _PricingCard(
            pricingBreakdown: pricingBreakdown,
            insuranceBreakdown: model?.data.insuranceBreakdown,
            currency: currency,
            controller: controller,
          ),
      ],
    );
  }
}

class _WalletBalanceCard extends GetView<PreviewController> {
  _WalletBalanceCard();

  final WalletController _walletController = Get.isRegistered<WalletController>()
      ? Get.find<WalletController>()
      : Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final wallet = _walletController.walletModel.value;
      final isLoading = _walletController.isLoading.value;
      final balance = wallet?.balance ?? 0.0;
      final currency = wallet?.currency ?? 'SAR';
      final totalPayable = controller.totalPayable.value;
      final isInsufficient = !isLoading && wallet != null && balance < totalPayable;

      return Container(
        decoration: BoxDecoration(
          color: CarboColors.surface,
          borderRadius: CarboRadius.lgAll,
          boxShadow: CarboShadow.card,
          border: isInsufficient
              ? Border.all(color: CarboColors.debit.withOpacity(0.4))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(CarboSpacing.x4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isInsufficient
                          ? CarboColors.debit.withOpacity(0.1)
                          : CarboColors.credit.withOpacity(0.12),
                      borderRadius: CarboRadius.mdAll,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: isInsufficient ? CarboColors.debit : CarboColors.credit,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: CarboSpacing.x3),
                  Expanded(
                    child: Text(
                      Strings.wallet.tr,
                      style: CarboTypography.bodyMedium.copyWith(
                        color: CarboColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isLoading && wallet == null)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CarboColors.credit,
                      ),
                    )
                  else
                    Text(
                      '${balance.toStringAsFixed(2)} $currency',
                      style: CarboTypography.titleMedium.copyWith(
                        color: isInsufficient ? CarboColors.debit : CarboColors.credit,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (isInsufficient) ...[
              const Divider(height: 1, color: CarboColors.divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CarboSpacing.x4,
                  CarboSpacing.x3,
                  CarboSpacing.x4,
                  CarboSpacing.x4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: CarboColors.debit,
                      size: 16,
                    ),
                    const SizedBox(width: CarboSpacing.x2),
                    Expanded(
                      child: Text(
                        Strings.insufficientBalance.tr,
                        style: CarboTypography.bodySmall.copyWith(
                          color: CarboColors.debit,
                        ),
                      ),
                    ),
                    const SizedBox(width: CarboSpacing.x3),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.walletScreen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CarboSpacing.x3,
                          vertical: CarboSpacing.x2,
                        ),
                        decoration: BoxDecoration(
                          gradient: CarboGradients.primary,
                          borderRadius: CarboRadius.mdAll,
                          boxShadow: CarboShadow.primaryGlow,
                        ),
                        child: Text(
                          Strings.rechargeWallet.tr,
                          style: CarboTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _AllowanceInfoCard extends StatelessWidget {
  final String allowanceKm;
  final String allowancePricePerKm;

  const _AllowanceInfoCard({
    required this.allowanceKm,
    required this.allowancePricePerKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CarboSpacing.x3),
      padding: const EdgeInsets.all(CarboSpacing.x3),
      decoration: BoxDecoration(
        color: CarboColors.infoBg,
        borderRadius: CarboRadius.lgAll,
        border: Border.all(color: CarboColors.info.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CarboIcons.info, color: CarboColors.info, size: 16),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Text(
              Strings.allowanceInfo.tr
                  .replaceAll('{allowanceKm}', allowanceKm)
                  .replaceAll('{allowancePricePerKm}', allowancePricePerKm),
              style: CarboTypography.bodySmall.copyWith(
                color: CarboColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CarboSpacing.x4,
              CarboSpacing.x4,
              CarboSpacing.x4,
              CarboSpacing.x3,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: CarboColors.primaryLight,
                    borderRadius: CarboRadius.smAll,
                  ),
                  child: Icon(icon, color: CarboColors.primary, size: 16),
                ),
                const SizedBox(width: CarboSpacing.x3),
                Text(title, style: CarboTypography.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1, color: CarboColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x2),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x4,
        vertical: CarboSpacing.x2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: CarboColors.textSecondary),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: CarboTypography.bodyMedium.copyWith(
                color: CarboColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: CarboSpacing.x3),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: CarboTypography.titleSmall,
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final PricingBreakdown pricingBreakdown;
  final InsuranceBreakdown? insuranceBreakdown;
  final String currency;
  final PreviewController controller;

  const _PricingCard({
    required this.pricingBreakdown,
    this.insuranceBreakdown,
    required this.currency,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CarboSpacing.x4,
              CarboSpacing.x4,
              CarboSpacing.x4,
              CarboSpacing.x3,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: CarboColors.primaryLight,
                    borderRadius: CarboRadius.smAll,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: CarboColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: CarboSpacing.x3),
                Text(Strings.rentalFees.tr, style: CarboTypography.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1, color: CarboColors.divider),
          Padding(
            padding: const EdgeInsets.only(
              top: CarboSpacing.x2,
              bottom: CarboSpacing.x3,
            ),
            child: Column(
              children: [
                _PricingRow(
                  label: Strings.rentalDays.tr,
                  value: '${pricingBreakdown.rentalDays}',
                  currency: '',
                ),
                _PricingRow(
                  label: Strings.rentalFees.tr,
                  value: pricingBreakdown.rentalFees,
                  currency: currency,
                ),
                if (double.tryParse(pricingBreakdown.insuranceTotal) != null &&
                    double.parse(pricingBreakdown.insuranceTotal) > 0)
                  _PricingRow(
                    label: Strings.dailyInsurance.tr,
                    value: pricingBreakdown.insuranceTotal,
                    currency: currency,
                  ),
                if (double.tryParse(pricingBreakdown.deliveryPrice) != null &&
                    double.parse(pricingBreakdown.deliveryPrice) > 0)
                  _PricingRow(
                    label: Strings.delivery.tr,
                    value: pricingBreakdown.deliveryPrice,
                    currency: currency,
                  ),
                if (double.tryParse(pricingBreakdown.charges) != null &&
                    double.parse(pricingBreakdown.charges) > 0)
                  _PricingRow(
                    label: 'Charges',
                    value: pricingBreakdown.charges,
                    currency: currency,
                  ),
                Obx(() => _PricingRow(
                  label: Strings.tax.tr,
                  value: controller.taxAmountDisplay.value,
                  currency: currency,
                )),
                if (insuranceBreakdown?.insuranceType == 'deductible' &&
                    (insuranceBreakdown?.deductibleInsurance ?? 0) > 0)
                  _DeductibleInfoRow(
                    amount: insuranceBreakdown!.deductibleInsurance,
                    currency: currency,
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    CarboSpacing.x4,
                    CarboSpacing.x1,
                    CarboSpacing.x4,
                    0,
                  ),
                  child: Divider(height: 1, color: CarboColors.divider),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(
              CarboSpacing.x4,
              0,
              CarboSpacing.x4,
              CarboSpacing.x4,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: CarboSpacing.x4,
              vertical: CarboSpacing.x4,
            ),
            decoration: BoxDecoration(
              gradient: CarboGradients.primary,
              borderRadius: CarboRadius.mdAll,
              boxShadow: CarboShadow.primaryGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.totalPayable.tr,
                  style: CarboTypography.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.totalPayable.value.toStringAsFixed(BasicServices.precision.value)} $currency',
                    style: CarboTypography.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final String label;
  final String value;
  final String currency;

  const _PricingRow({
    required this.label,
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x4,
        vertical: CarboSpacing.x2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CarboTypography.bodyMedium.copyWith(
              color: CarboColors.textSecondary,
            ),
          ),
          Text(
            currency.isEmpty ? value : '$value $currency',
            style: CarboTypography.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _DeductibleInfoRow extends StatelessWidget {
  final double amount;
  final String currency;

  const _DeductibleInfoRow({
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CarboSpacing.x4,
        CarboSpacing.x2,
        CarboSpacing.x4,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarboSpacing.x3,
          vertical: CarboSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: CarboColors.infoBg,
          borderRadius: CarboRadius.mdAll,
          border: Border.all(color: CarboColors.info.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(CarboIcons.info, size: 14, color: CarboColors.info),
            const SizedBox(width: CarboSpacing.x2),
            Expanded(
              child: Text(
                '${Strings.deductibleNote.tr}: ${amount.toStringAsFixed(0)} $currency',
                style: CarboTypography.bodySmall.copyWith(
                  color: CarboColors.info,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
