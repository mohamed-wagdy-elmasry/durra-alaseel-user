import 'dart:ui' as ui;
import 'package:carbo/base/api/services/basic_services.dart';
import 'package:carbo/base/design_system/carbo_ds.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../base/utils/basic_import.dart';
import '../../../views/history/model/history_model.dart';
import '../controller/booking_details_controller.dart';
import '../widget/extend_booking_bottom_sheet.dart';

class BookingDetailsScreen extends GetView<BookingDetailsController> {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarboColors.background,
      body: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _BookingDetailsBody(
          booking: booking,
          controller: controller,
        );
      }),
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  final History booking;
  final BookingDetailsController controller;

  const _BookingDetailsBody({
    required this.booking,
    required this.controller,
  });

  bool _shouldShowRejectionReason() {
    final isRejectedOrCancelled = booking.status == 4 || booking.status == 5;
    final hasReason = booking.rejectionReason != null &&
        booking.rejectionReason.toString().isNotEmpty;
    return isRejectedOrCancelled && hasReason;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeroHeader(booking: booking),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CarboSpacing.x4,
            CarboSpacing.x4,
            CarboSpacing.x4,
            CarboSpacing.x6,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _CarInfoCard(booking: booking),
              const SizedBox(height: CarboSpacing.x3),
              _BookingInfoCard(booking: booking),
              const SizedBox(height: CarboSpacing.x3),
              _PriceBreakdownCard(booking: booking),
              const SizedBox(height: CarboSpacing.x3),
              _VendorInfoCard(booking: booking),
              if (booking.message.isNotEmpty) ...[
                const SizedBox(height: CarboSpacing.x3),
                _NoteCard(message: booking.message),
              ],
              if (_shouldShowRejectionReason()) ...[
                const SizedBox(height: CarboSpacing.x3),
                _RejectionReasonCard(
                  reason: booking.rejectionReason?.toString() ?? '',
                  isCancelled: booking.status == 5,
                ),
              ],
              const SizedBox(height: CarboSpacing.x5),
              Obx(() => controller.canExtend
                  ? _ExtendRentalButton(controller: controller)
                  : const SizedBox.shrink()),
              Obx(() => controller.canCancel
                  ? Padding(
                      padding: const EdgeInsets.only(top: CarboSpacing.x3),
                      child: _CancelBookingButton(controller: controller),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: CarboSpacing.x6),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REJECTION / CANCEL REASON CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RejectionReasonCard extends StatelessWidget {
  final String reason;
  final bool isCancelled;

  const _RejectionReasonCard({
    required this.reason,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCancelled ? CarboColors.warning : CarboColors.error;
    final title = isCancelled
        ? Strings.cancelReason.tr
        : Strings.rejectionReason.tr;
    final icon = isCancelled
        ? Icons.cancel_outlined
        : Icons.block_outlined;

    return Container(
      padding: const EdgeInsets.all(CarboSpacing.x3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: CarboRadius.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CarboTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: CarboTypography.bodySmall.copyWith(
                    color: color,
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

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final History booking;
  const _HeroHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: CarboGradients.primary,
        boxShadow: CarboShadow.primaryGlow,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CarboSpacing.x4,
                CarboSpacing.x3,
                CarboSpacing.x4,
                0,
              ),
              child: Row(
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
                      Strings.bookingDetails.tr,
                      style: CarboTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CarboSpacing.x3),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAR INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CarInfoCard extends StatelessWidget {
  final History booking;
  const _CarInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final cars = booking.cars;
    final enValue = cars.carTitle['en'];
    final carTitle =
        (enValue is Map ? enValue['car_title'] : enValue)?.toString() ?? '';
    final year = cars.year != 0 ? cars.year.toString() : '';

    return Container(
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: Column(
        children: [
          const SizedBox(height: CarboSpacing.x4),
          Hero(
            tag: 'car_hero_${booking.id}',
            child: SizedBox(
              height: 160,
              child: cars.imageUrl.isNotEmpty
                  ? Image.network(
                      cars.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _carPlaceholder(),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _carPlaceholder();
                      },
                    )
                  : _carPlaceholder(),
            ),
          ),
          const SizedBox(height: CarboSpacing.x3),
          const Divider(height: 1, color: CarboColors.divider),
          Padding(
            padding: const EdgeInsets.all(CarboSpacing.x4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: CarboColors.primaryLight,
                    borderRadius: CarboRadius.mdAll,
                  ),
                  child: const Icon(CarboIcons.car,
                      color: CarboColors.primary, size: 20),
                ),
                const SizedBox(width: CarboSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carTitle,
                        style: CarboTypography.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (year.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          year,
                          style: CarboTypography.bodySmall.copyWith(
                            color: CarboColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carPlaceholder() {
    return Container(
      height: 160,
      width: 200,
      decoration: BoxDecoration(
        color: CarboColors.primaryLight,
        borderRadius: CarboRadius.lgAll,
      ),
      child: const Icon(CarboIcons.car, color: CarboColors.primary, size: 48),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final int status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    if (status == 1) {
      bg = CarboColors.warningBg;
      fg = CarboColors.warning;
      label = Strings.pending;
    } else if (status == 2) {
      bg = CarboColors.infoBg;
      fg = CarboColors.info;
      label = Strings.ongoing;
    } else if (status == 3) {
      bg = CarboColors.successBg;
      fg = CarboColors.success;
      label = Strings.complete;
    } else if (status == 5) {
      bg = CarboColors.warningBg;
      fg = CarboColors.warning;
      label = Strings.cancelled;
    } else {
      bg = CarboColors.errorBg;
      fg = CarboColors.error;
      label = Strings.reject;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: CarboRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: fg),
          const SizedBox(width: 6),
          Text(
            label.tr,
            style: CarboTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD (reusable card shell)
// ─────────────────────────────────────────────────────────────────────────────

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
      decoration: const BoxDecoration(
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

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ROW
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x4,
        vertical: CarboSpacing.x2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: onTap != null ? CarboColors.primary : CarboColors.textSecondary),
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
              style: CarboTypography.titleSmall.copyWith(
                color: onTap != null ? CarboColors.primary : null,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CarboRadius.md),
        child: content,
      );
    }
    return content;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICING ROW
// ─────────────────────────────────────────────────────────────────────────────

class _PricingRow extends StatelessWidget {
  final String label;
  final String value;
  final String currency;
  final ui.TextDirection? labelDirection;

  const _PricingRow({
    required this.label,
    required this.value,
    required this.currency,
    this.labelDirection,
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
            textDirection: labelDirection,
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

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final History booking;
  const _BookingInfoCard({required this.booking});

  String _formatTimeAmPm(String time) {
    if (time.isEmpty) return '';
    try {
      final parsed = DateFormat('HH:mm').parse(time);
      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return time;
    }
  }

  String _displayPaymentType(String type) {
    if (type.toLowerCase() == 'balance') return Strings.wallet.tr;
    return type;
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: CarboIcons.booking,
      title: Strings.bookingInfo.tr,
      children: [
        _DetailRow(
          icon: Icons.confirmation_number_outlined,
          label: Strings.bookingId.tr,
          value: '#${booking.bookingId != 0 ? booking.bookingId : booking.id}',
        ),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: Strings.PickUpdate.tr,
          value: DateFormat('d MMM yyyy').format(booking.pickupDate),
        ),
        _DetailRow(
          icon: Icons.access_time_outlined,
          label: Strings.PickUpTime.tr,
          value: _formatTimeAmPm(booking.pickupTime),
        ),
        if (booking.roundPickupDate != null &&
            booking.roundPickupDate.toString().length >= 10) ...[
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: Strings.roundTripDate.tr,
            value: booking.roundPickupDate.toString().substring(0, 10),
          ),
        ],
        if (booking.roundPickupTime != null &&
            booking.roundPickupTime.toString().isNotEmpty) ...[
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: Strings.roundTripTime.tr,
            value: _formatTimeAmPm(booking.roundPickupTime.toString()),
          ),
        ],
        _DeliveryDetailRow(
          isDelivery: booking.isDelivery,
          location: booking.location,
        ),
        _DetailRow(
          icon: Icons.credit_card_outlined,
          label: Strings.paymentType.tr,
          value: _displayPaymentType(booking.paymentType),
        ),
        if (booking.trxId.isNotEmpty) ...[
          _DetailRow(
            icon: Icons.tag_outlined,
            label: Strings.transactionId.tr,
            value: booking.trxId,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY DETAIL ROW
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryDetailRow extends StatelessWidget {
  final bool isDelivery;
  final String location;

  const _DeliveryDetailRow({
    required this.isDelivery,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isDelivery ? CarboColors.primary : CarboColors.info;
    final chipLabel = isDelivery
        ? Strings.deliveryToLocation.tr
        : Strings.branchPickup.tr;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x4,
        vertical: CarboSpacing.x2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                size: 15,
                color: CarboColors.textSecondary,
              ),
              const SizedBox(width: CarboSpacing.x2),
              Expanded(
                child: Text(
                  Strings.delivery.tr,
                  style: CarboTypography.bodyMedium.copyWith(
                    color: CarboColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarboSpacing.x2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.1),
                  borderRadius: CarboRadius.fullAll,
                  border: Border.all(
                    color: chipColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  chipLabel,
                  style: CarboTypography.caption.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: CarboColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: CarboTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: CarboSpacing.x2),
                  GestureDetector(
                    onTap: () => _openInMap(location),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CarboSpacing.x2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: CarboColors.primary.withValues(alpha: 0.1),
                        borderRadius: CarboRadius.fullAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined,
                              size: 12, color: CarboColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            Strings.openInMap.tr,
                            style: CarboTypography.caption.copyWith(
                              color: CarboColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  void _openInMap(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICE BREAKDOWN CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PriceBreakdownCard extends StatelessWidget {
  final History booking;
  const _PriceBreakdownCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final curCode = BasicServices.baseCurCode.value;
    final amount = _formatNum(booking.amount);
    final charges = _formatNum(booking.charges);
    final deliveryFee = _formatNum(booking.deliveryFee);
    final taxAmount = _formatNum(booking.taxAmount);
    final subtotal = _formatNum(booking.subtotal);
    final total = _formatNum(booking.totalAmount);
    final double dailyFee = _toDouble(booking.cars.fees);
    final int rentalDays = booking.rentalDays > 0
        ? booking.rentalDays
        : (dailyFee > 0
            ? (_toDouble(booking.amount) / dailyFee).round()
            : 0);
    final String dailyFeeFormatted = _formatNum(booking.cars.fees);
    final String rentalLabel = rentalDays > 0
        ? '$rentalDays ${Strings.days.tr} x $dailyFeeFormatted $curCode'
        : Strings.rentalFees.tr;
    final int extDays = booking.totalExtensionDays;
    final String extLabel =
        '${Strings.extend.tr} $extDays ${Strings.days.tr} x $dailyFeeFormatted $curCode';
    final String extAmount = _formatNum(extDays * dailyFee);

    return Container(
      decoration: const BoxDecoration(
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
                Text(Strings.priceBreakdown.tr,
                    style: CarboTypography.titleLarge),
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
                  label: rentalLabel,
                  value: amount,
                  currency: curCode,
                  labelDirection: ui.TextDirection.ltr,
                ),
                if (extDays > 0)
                  _PricingRow(
                    label: extLabel,
                    value: extAmount,
                    currency: curCode,
                    labelDirection: ui.TextDirection.ltr,
                  ),
                if (_toDouble(booking.charges) > 0)
                  _PricingRow(
                    label: Strings.charges.tr,
                    value: charges,
                    currency: curCode,
                  ),
                if (_toDouble(booking.deliveryFee) > 0)
                  _PricingRow(
                    label: Strings.delivery.tr,
                    value: deliveryFee,
                    currency: curCode,
                  ),
                if (_toDouble(booking.subtotal) > 0)
                  _PricingRow(
                    label: Strings.subtotal.tr,
                    value: subtotal,
                    currency: curCode,
                  ),
                _PricingRow(
                  label: Strings.tax.tr,
                  value: taxAmount,
                  currency: curCode,
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
              color: CarboColors.surface,
              borderRadius: CarboRadius.mdAll,
              border:
                  Border.all(color: CarboColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.totalPayable.tr,
                  style: CarboTypography.titleMedium.copyWith(
                    color: CarboColors.primary,
                  ),
                ),
                Text(
                  '$total $curCode',
                  style: CarboTypography.headlineMedium.copyWith(
                    color: CarboColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(dynamic val) {
    if (val == null) return '0';
    final d = double.tryParse(val.toString()) ?? 0;
    return d == d.roundToDouble()
        ? d.toInt().toString()
        : d.toStringAsFixed(2);
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0;
    return double.tryParse(val.toString()) ?? 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VENDOR INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _VendorInfoCard extends StatelessWidget {
  final History booking;
  const _VendorInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final vendor = booking.cars.vendor;
    final branch = booking.cars.branch;

    return _SectionCard(
      icon: Icons.store_outlined,
      title: Strings.vendorInfo.tr,
      children: [
        if (vendor != null && vendor.fullname.isNotEmpty)
          _DetailRow(
            icon: Icons.person_outline,
            label: Strings.vendorName.tr,
            value: vendor.fullname,
          ),
        if (branch != null && branch.email.isNotEmpty)
          _DetailRow(
            icon: Icons.email_outlined,
            label: Strings.email.tr,
            value: branch.email,
            onTap: () async {
              try {
                await launchUrl(Uri.parse('mailto:${branch.email}'),
                    mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
        if (branch != null && branch.phone.isNotEmpty)
          _DetailRow(
            icon: Icons.phone_outlined,
            label: Strings.Phone.tr,
            value: branch.phone,
            onTap: () async {
              try {
                await launchUrl(Uri.parse('tel:${branch.phone}'),
                    mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
        if (branch != null && (branch.address ?? '').isNotEmpty)
          _BranchLocationRow(
            address: branch.address!,
            latitude: branch.latitude,
            longitude: branch.longitude,
          ),
        if (branch != null && branch.name.isNotEmpty)
          _DetailRow(
            icon: Icons.location_city_outlined,
            label: Strings.branchName.tr,
            value: branch.name,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRANCH LOCATION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _BranchLocationRow extends StatelessWidget {
  final String address;
  final String latitude;
  final String longitude;

  const _BranchLocationRow({
    required this.address,
    required this.latitude,
    required this.longitude,
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
          const Icon(Icons.location_on_outlined,
              size: 15, color: CarboColors.textSecondary),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.branchLocation.tr,
                  style: CarboTypography.bodyMedium.copyWith(
                    color: CarboColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: CarboTypography.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: CarboSpacing.x2),
          GestureDetector(
            onTap: _openInMap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarboSpacing.x2,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: CarboColors.primary.withValues(alpha: 0.1),
                borderRadius: CarboRadius.fullAll,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined,
                      size: 12, color: CarboColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    Strings.openInMap.tr,
                    style: CarboTypography.caption.copyWith(
                      color: CarboColors.primary,
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

  void _openInMap() async {
    final geoUri =
        Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($address)');
    final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final String message;
  const _NoteCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CarboSpacing.x3),
      decoration: BoxDecoration(
        color: CarboColors.infoBg,
        borderRadius: CarboRadius.lgAll,
        border: Border.all(color: CarboColors.info.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CarboIcons.info, color: CarboColors.info, size: 16),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.note.tr,
                  style: CarboTypography.labelMedium.copyWith(
                    color: CarboColors.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: CarboTypography.bodySmall.copyWith(
                    color: CarboColors.info,
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

// ─────────────────────────────────────────────────────────────────────────────
// EXTEND RENTAL BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ExtendRentalButton extends StatelessWidget {
  final BookingDetailsController controller;
  const _ExtendRentalButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        title: Strings.extendRental.tr,
        onPressed: () => _openExtendSheet(context),
      ),
    );
  }

  void _openExtendSheet(BuildContext context) {
    controller.prepareExtendSheet();
    Get.bottomSheet(
      const ExtendBookingBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
      enableDrag: true,
    ).then((_) => controller.disposeExtendSheet());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CANCEL BOOKING BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _CancelBookingButton extends StatelessWidget {
  final BookingDetailsController controller;
  const _CancelBookingButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: controller.isCancelLoading.value
              ? null
              : () => _showConfirmDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: CarboColors.error,
            side: const BorderSide(color: CarboColors.error),
            padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x3),
            shape: const RoundedRectangleBorder(
              borderRadius: CarboRadius.mdAll,
            ),
          ),
          child: controller.isCancelLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CarboColors.error,
                  ),
                )
              : Text(
                  Strings.cancelBooking.tr,
                  style: CarboTypography.labelLarge.copyWith(
                    color: CarboColors.error,
                  ),
                ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CancelConfirmSheet(
        onConfirm: () {
          Navigator.of(context).pop();
          controller.cancelBooking();
        },
      ),
    );
  }
}

class _CancelConfirmSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CancelConfirmSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(CarboSpacing.x4),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.xlAll,
        boxShadow: CarboShadow.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              CarboSpacing.x5,
              CarboSpacing.x6,
              CarboSpacing.x5,
              CarboSpacing.x4,
            ),
            decoration: const BoxDecoration(
              color: CarboColors.errorBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CarboColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CarboColors.error.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: CarboColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: CarboSpacing.x4),
                Text(
                  Strings.cancelBooking.tr,
                  style: CarboTypography.headlineMedium.copyWith(
                    color: CarboColors.error,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CarboSpacing.x5,
              CarboSpacing.x5,
              CarboSpacing.x5,
              CarboSpacing.x3,
            ),
            child: Text(
              Strings.cancelBookingConfirm.tr,
              style: CarboTypography.bodyMedium.copyWith(
                color: CarboColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CarboSpacing.x5,
              CarboSpacing.x2,
              CarboSpacing.x5,
              CarboSpacing.x5,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CarboColors.textPrimary,
                        side: const BorderSide(color: CarboColors.divider),
                        shape: const RoundedRectangleBorder(
                          borderRadius: CarboRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        Strings.keepBooking.tr,
                        style: CarboTypography.labelLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CarboSpacing.x3),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CarboColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: CarboRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        Strings.yesCancel.tr,
                        style: CarboTypography.buttonLabel,
                      ),
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