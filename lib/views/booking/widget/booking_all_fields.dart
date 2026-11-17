part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.selectedInsuranceType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rentalDetailsCard(context),
          const SizedBox(height: CarboSpacing.x4),
          _insuranceTypeCard(context),
          const SizedBox(height: CarboSpacing.x4),

          Obx(() => _deductibleNotice()),
          const SizedBox(height: CarboSpacing.x4),
          _deliveryToggleCard(context),
          const SizedBox(height: CarboSpacing.x4),
          AnimatedSwitcher(
            duration: CarboDuration.normal,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            ),
            child: !controller.isPickupFromBranch.value
                ? _deliveryLocationCard(context)
                : const SizedBox.shrink(key: ValueKey('no_delivery')),
          ),
          if (!controller.isPickupFromBranch.value)
            const SizedBox(height: CarboSpacing.x4),
          _rentalCalculationCard(context),
          const SizedBox(height: CarboSpacing.x4),
          _notesCard(context),
        ],
      );
    });
  }

  Widget _deductibleNotice() {
    if (controller.selectedInsuranceType.value != 'deductible') {
      return SizedBox.shrink();
    }

    final deductible = controller.selectedCar.deductibleInsurance;
    final curCode = BasicServices.baseCurCode.value.isNotEmpty
        ? BasicServices.baseCurCode.value
        : 'SAR';

    if (deductible <= 0) return SizedBox.shrink();

    final amountText = '${deductible.toStringAsFixed(0)} $curCode';
    final messageText = Strings.inCaseOfAccident.tr.replaceAll(
      '{amount}',
      amountText,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: CarboColors.infoBg,
        borderRadius: CarboRadius.mdAll,
        border: Border.all(color: CarboColors.info, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: CarboSpacing.x2),
            decoration: BoxDecoration(
              color: CarboColors.infoBg,
              borderRadius: CarboRadius.smAll,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: CarboColors.info,
            ),
          ),
          SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Text(
              messageText,
              style: CarboTypography.bodyMedium.copyWith(
                color: CarboColors.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared card container ──────────────────────────────────────────────────
  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CarboSpacing.x4),
      decoration: BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CarboSpacing.x3),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: CarboColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: CarboColors.primary),
          ),
          const SizedBox(width: CarboSpacing.x2),
          Text(
            label,
            style: CarboTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Delivery Toggle ─────────────────────────────────────────────
  Widget _deliveryToggleCard(BuildContext context) {
    final isDelivery = !controller.isPickupFromBranch.value;
    final disabled = controller.forcePickupFromBranch;
    final isValidating = controller.isValidatingDateTime.value;
    final validation = controller.dateTimeValidation.value;
    final showHours = validation != null && !validation.isValid;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: CarboColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: CarboColors.primary,
                ),
              ),
              const SizedBox(width: CarboSpacing.x2),
              Expanded(
                child: Text(
                  Strings.delivery.tr,
                  style: CarboTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isValidating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CarboColors.primary,
                  ),
                )
              else if (showHours)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarboSpacing.x3,
                    vertical: CarboSpacing.x1,
                  ),
                  decoration: BoxDecoration(
                    color: CarboColors.errorBg,
                    borderRadius: CarboRadius.fullAll,
                  ),
                  child: Text(
                    Strings.deliveryNotAvailable.tr,
                    style: CarboTypography.labelSmall.copyWith(
                      color: CarboColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Opacity(
                  opacity: disabled ? 0.45 : 1.0,
                  child: Switch(
                    value: isDelivery,
                    onChanged: disabled
                        ? null
                        : (val) => controller.isPickupFromBranch.value = !val,
                    activeColor: CarboColors.primary,
                    activeTrackColor: CarboColors.primaryLight,
                    inactiveThumbColor: CarboColors.textSecondary,
                    inactiveTrackColor: CarboColors.background,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (showHours) ...[
            const SizedBox(height: CarboSpacing.x2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: CarboSpacing.x3,
                vertical: CarboSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: CarboColors.infoBg,
                borderRadius: CarboRadius.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: CarboColors.info),
                  const SizedBox(width: CarboSpacing.x2),
                  Expanded(
                    child: Text(
                      validation.openTime.isNotEmpty
                          ? '${Strings.pickupTimeOutsideWorkingHours.tr}\n${validation.dayName}: ${validation.openTime} - ${validation.closeTime}'
                          : '${Strings.pickupTimeOutsideWorkingHours.tr}\n${validation.dayName}',
                      style: CarboTypography.labelMedium.copyWith(
                        color: CarboColors.info,
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
  }

  // ── Section 2: Delivery Location ──────────────────────────────────────────
  Widget _deliveryLocationCard(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('delivery_section'),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.map_outlined, Strings.deliveryLocation.tr),
            _mapPickerRow(context),
          ],
        ),
      ),
    );
  }

  Widget _mapPickerRow(BuildContext context) {
    final hasLocation = controller.selectedDeliveryLocation.value != null;
    final addressText = controller.selectedLocationAddress.value.isNotEmpty
        ? controller.selectedLocationAddress.value
        : (hasLocation
              ? '${controller.selectedDeliveryLocation.value!.latitude.toStringAsFixed(5)}, '
                    '${controller.selectedDeliveryLocation.value!.longitude.toStringAsFixed(5)}'
              : Strings.selectLocationOnMap.tr);
    final labelText = hasLocation
        ? Strings.changePickupLocation.tr
        : Strings.selectLocationOnMap.tr;

    return GestureDetector(
      onTap: controller.forcePickupFromBranch
          ? null
          : () => Get.to(() => const MapLocationPickerScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarboSpacing.x3,
          vertical: CarboSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: CarboColors.background,
          borderRadius: CarboRadius.mdAll,
          border: Border.all(
            color: hasLocation ? CarboColors.primary : CarboColors.border,
            width: hasLocation ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasLocation
                    ? CarboColors.primaryLight
                    : CarboColors.background,
                borderRadius: CarboRadius.smAll,
              ),
              child: const Icon(
                Icons.location_on,
                size: 20,
                color: CarboColors.primary,
              ),
            ),
            const SizedBox(width: CarboSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLocation ? Strings.selectedLocation.tr : labelText,
                    style: CarboTypography.labelMedium.copyWith(
                      color: CarboColors.textSecondary,
                    ),
                  ),
                  if (hasLocation) ...[
                    const SizedBox(height: 2),
                    Text(
                      addressText,
                      style: CarboTypography.bodyMedium.copyWith(
                        color: CarboColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Transform.scale(
              scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: CarboColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Rental Details ──────────────────────────────────────────────
    Widget _rentalDetailsCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.calendar_month_outlined,
            Strings.rentalDetails.tr,
          ),
          CounterInput(
            controller: controller.rentalDaysController,
            label: Strings.rentalDays.tr,
            hintText: Strings.enterRentalDays.tr,
            suffixBuilder: (count) {
              if (count == 1) return Strings.day.tr;
              if (count == 2) return Strings.twoDays.tr;
              if (count <= 10) return Strings.daysPlural.tr;
              return Strings.dayAccusative.tr;
            },
            min: 1,
            max: 90,
          ),
          const SizedBox(height: CarboSpacing.x3),
          Row(
            children: [
              Expanded(
                child: CustomDatePicker(
                  showBorder: true,
                  label: Strings.PickUpdate,
                  selectedDate: controller.selectedPickupDate,
                  firstDate: DateTime.now(),
                ),
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                child: CustomTimePicker(
                  showBorder: true,
                  label: Strings.PickUpTime,
                  selectedTime: controller.selectedPickupTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section 4: Rental Calculation (server-side only) ────────────────────
     Widget _rentalCalculationCard(BuildContext context) {
    return Obx(() {
      final pricing = controller.serverPricing.value;
      final isLoading = controller.pricingLoading.value;
      final error = controller.pricingError.value;
      final curCode = BasicServices.baseCurCode.value;

      // ── Error State (only when not loading) ─────────────────────────
      if (!isLoading && error.isNotEmpty && pricing == null) {
        return _sectionCard(
          child: Column(
            children: [
              _sectionHeader(
                Icons.receipt_long_outlined,
                Strings.totalAmount.tr,
              ),
              const SizedBox(height: CarboSpacing.x5),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: CarboColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 28,
                  color: CarboColors.error,
                ),
              ),
              const SizedBox(height: CarboSpacing.x3),
              Text(
                Strings.somethingWentWrong.tr,
                style: CarboTypography.titleSmall.copyWith(
                  color: CarboColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CarboSpacing.x2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarboSpacing.x6,
                ),
                child: Text(
                  error.length > 80 ? '${error.substring(0, 80)}...' : error,
                  style: CarboTypography.bodySmall.copyWith(
                    color: CarboColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: CarboSpacing.x4),
              GestureDetector(
                onTap: () => controller.retryPricing(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarboSpacing.x5,
                    vertical: CarboSpacing.x2 + 2,
                  ),
                  decoration: BoxDecoration(
                    color: CarboColors.errorBg,
                    borderRadius: CarboRadius.fullAll,
                    border: Border.all(
                      color: CarboColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: CarboColors.error,
                      ),
                      const SizedBox(width: CarboSpacing.x2),
                      Text(
                        Strings.resend.tr,
                        style: CarboTypography.labelMedium.copyWith(
                          color: CarboColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // ── Empty / Waiting State (only when not loading) ────────────────
      if (!isLoading && pricing == null) {
        return _sectionCard(
          child: Column(
            children: [
              _sectionHeader(
                Icons.receipt_long_outlined,
                Strings.totalAmount.tr,
              ),
              const SizedBox(height: CarboSpacing.x5),
              _emptyStateIllustration(),
              const SizedBox(height: CarboSpacing.x4),
              Text(
                Strings.enterRentalDetails.tr,
                style: CarboTypography.bodyMedium.copyWith(
                  color: CarboColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CarboSpacing.x4),
              _emptyHintPills(),
            ],
          ),
        );
      }

      // ── Data Card (always built if pricing exists) ───────────────────
      final taxLabel = BasicServices.taxName.value.isNotEmpty
          ? BasicServices.taxName.value
          : Strings.tax.tr;
      final insurance = controller.serverInsurance.value;

      final days =
          (pricing?['rental_days'] as num?)?.toInt() ??
          controller.rentalDaysCount.value;
      final basePrice = (pricing?['base_price'] as num?)?.toDouble() ?? 0.0;
      final rentalFees = (pricing?['rental_fees'] as num?)?.toDouble() ?? 0.0;
      final deliveryPrice =
          (pricing?['delivery_price'] as num?)?.toDouble() ?? 0.0;
      final insuranceTotal =
          (insurance?['insurance_total'] as num?)?.toDouble() ?? 0.0;
      final taxAmount = (pricing?['tax_amount'] as num?)?.toDouble() ?? 0.0;
      final total = (pricing?['total'] as num?)?.toDouble() ?? 0.0;
      final taxPct = (pricing?['tax_percentage'] as num?)?.toDouble() ?? 15.0;

      Widget dataCard = _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              Icons.receipt_long_outlined,
              Strings.totalAmount.tr,
            ),
            _calcRow(Strings.rentalDays.tr, '$days'),
            _calcDivider(),
            _calcRow(
              Strings.pricePerDay.tr,
              '${basePrice.toStringAsFixed(2)} $curCode',
            ),
            _calcDivider(),
            _calcRow(
              Strings.rentalFees.tr,
              '${rentalFees.toStringAsFixed(2)} $curCode',
              highlight: true,
            ),
            if (deliveryPrice > 0) ...[
              _calcDivider(),
              _calcRow(
                Strings.delivery.tr,
                '${deliveryPrice.toStringAsFixed(2)} $curCode',
              ),
            ],
            if (insuranceTotal > 0) ...[
              _calcDivider(),
              _calcRow(
                Strings.dailyInsurance.tr,
                '${insuranceTotal.toStringAsFixed(2)} $curCode',
              ),
            ],
            _calcDivider(),
            _calcRow(
              '$taxLabel (${taxPct.toStringAsFixed(0)}%)',
              '${taxAmount.toStringAsFixed(2)} $curCode',
            ),
            const SizedBox(height: CarboSpacing.x3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarboSpacing.x3,
                vertical: CarboSpacing.x3,
              ),
              decoration: BoxDecoration(
                color: CarboColors.primaryLight,
                borderRadius: CarboRadius.mdAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.totalAmount.tr,
                    style: CarboTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CarboColors.primary,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} $curCode',
                    style: CarboTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CarboColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // ── Shimmer skeleton (built to match the data card shape) ────────
      Widget shimmerCard = _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              Icons.receipt_long_outlined,
              Strings.totalAmount.tr,
            ),
            const SizedBox(height: CarboSpacing.x2),
            _shimmerRow(),
            _shimmerDivider(),
            _shimmerRow(widthFraction: 0.3),
            _shimmerDivider(),
            _shimmerRow(widthFraction: 0.45, highlight: true),
            _shimmerDivider(),
            _shimmerRow(widthFraction: 0.25),
            _shimmerDivider(),
            _shimmerRow(widthFraction: 0.2),
            const SizedBox(height: CarboSpacing.x3),
            _shimmerTotalBox(),
          ],
        ),
      );

      // ── Cross-fade: shimmer → data ──────────────────────────────────
      // When loading, show shimmer on top (fades in).
      // When done, show data on top (shimmer fades out).
      // If no data yet, only shimmer is visible (data is a transparent skeleton).
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isLoading
            ? KeyedSubtree(key: const ValueKey('shimmer'), child: shimmerCard)
            : KeyedSubtree(key: const ValueKey('data'), child: dataCard),
      );
    });
  }
  // ── Empty State Components ───────────────────────────────────────────────

  Widget _emptyStateIllustration() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: CarboColors.background,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Receipt body
            Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                color: CarboColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Receipt top notch
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: CarboColors.background,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Lines
            Positioned(
              top: 22,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: CarboColors.background,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: CarboColors.background,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 24,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: CarboColors.background,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dashed bottom
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: CarboColors.background,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHintPills() {
    return Wrap(
      spacing: CarboSpacing.x2,
      runSpacing: CarboSpacing.x2,
      alignment: WrapAlignment.center,
      children: [
        _hintPill(Icons.calendar_today_outlined, Strings.rentalDays.tr),
        _hintPill(Icons.schedule_outlined, Strings.PickUpTime.tr),
        _hintPill(Icons.event_outlined, Strings.PickUpdate.tr),
      ],
    );
  }

  Widget _hintPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x1 + 2,
      ),
      decoration: BoxDecoration(
        color: CarboColors.background,
        borderRadius: CarboRadius.fullAll,
        border: Border.all(color: CarboColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: CarboColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: CarboTypography.labelSmall.copyWith(
              color: CarboColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer Loading Components ───────────────────────────────────────────

  Widget _shimmerRow({double widthFraction = 0.55, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _shimmerBox(widthFraction: 0.4),
          _shimmerBox(widthFraction: widthFraction, highlight: highlight),
        ],
      ),
    );
  }

  Widget _shimmerDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: _ShimmerBox(height: 1),
      ),
    );
  }

  Widget _shimmerTotalBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: CarboColors.background,
        borderRadius: CarboRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(flex: 35, child: _ShimmerBox(height: 18)),
          const SizedBox(width: CarboSpacing.x4),
          Expanded(flex: 30, child: _ShimmerBox(height: 18)),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double widthFraction,
    double height = 14,
    bool highlight = false,
  }) {
    return Expanded(
      flex: (widthFraction * 100).round().clamp(1, 100),
      child: _ShimmerBox(height: height, highlight: highlight),
    );
  }

  Widget _calcRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x2),
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
            value,
            style: CarboTypography.bodyMedium.copyWith(
              color: highlight
                  ? CarboColors.textPrimary
                  : CarboColors.textSecondary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcDivider() =>
      const Divider(height: 1, thickness: 0.5, color: CarboColors.border);

  // ── Section: Insurance Type ───────────────────────────────────────────────
  Widget _insuranceTypeCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.shield_outlined, Strings.selectInsuranceType.tr),
          Obx(() {
            final selected = controller.selectedInsuranceType.value;
            return Column(
              children: [
                _insuranceTile(
                  icon: Icons.verified_user_outlined,
                  title: Strings.dailyInsurance.tr,
                  value: 'daily',
                  selected: selected,
                ),
                const SizedBox(height: CarboSpacing.x3),
                _insuranceTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: Strings.deductibleInsurance.tr,
                  value: 'deductible',
                  selected: selected,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _insuranceTile({
    required IconData icon,
    required String title,
    required String value,
    required String selected,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => controller.setInsuranceType(value),
      child: AnimatedContainer(
        duration: CarboDuration.normal,
        padding: const EdgeInsets.all(CarboSpacing.x3),
        decoration: BoxDecoration(
          color: isSelected ? CarboColors.primaryLight : CarboColors.background,
          borderRadius: CarboRadius.mdAll,
          border: Border.all(
            color: isSelected ? CarboColors.primary : CarboColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? CarboColors.primary : CarboColors.surface,
                borderRadius: CarboRadius.smAll,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : CarboColors.textSecondary,
              ),
            ),
            const SizedBox(width: CarboSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CarboTypography.titleSmall.copyWith(
                      color: isSelected
                          ? CarboColors.primary
                          : const Color.fromARGB(255, 19, 19, 19),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: CarboDuration.normal,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? CarboColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? CarboColors.primary : CarboColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 5: Notes ──────────────────────────────────────────────────────
  Widget _notesCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.notes_outlined, Strings.additionalNotes.tr),
          PrimaryInputWidget(
            skipEnterText: true,
            optionalText: Strings.Optional,
            label: Strings.note,
            maxLines: 4,
            controller: controller.noteController,
            hintText: Strings.writeHere,
            textInputType: TextInputType.name,
            showBorderSide: true,
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Animation Widget ──────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double height;
  final bool highlight;

  const _ShimmerBox({required this.height, this.highlight = false});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final pos = _animation.value;
            return Container(
              height: widget.height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: widget.highlight
                      ? [
                          CarboColors.primaryLight,
                          CarboColors.primary.withOpacity(0.15),
                          CarboColors.primaryLight,
                        ]
                      : [
                          CarboColors.border,
                          CarboColors.background,
                          CarboColors.border,
                        ],
                  stops: [
                    (pos).clamp(0.0, 1.0),
                    (pos + 0.4).clamp(0.0, 1.0),
                    (pos + 0.8).clamp(0.0, 1.0),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
