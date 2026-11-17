import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../assets/assets.dart';
import '../../../base/api/services/basic_services.dart';
import '../../../base/design_system/carbo_ds.dart';
import '../../../base/utils/basic_import.dart';
import '../../../backend/model/extend_preview_model.dart';
import '../../../routes/routes.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../controller/booking_details_controller.dart';
import '../controller/extend_booking_controller.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ROOT SHEET
// ═════════════════════════════════════════════════════════════════════════════

class ExtendBookingBottomSheet extends GetView<ExtendBookingController> {
  const ExtendBookingBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final endDate = _endDate();

    return Container(
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.xxlTop,
      ),
      padding: EdgeInsets.only(
        left:   CarboSpacing.x5,
        right:  CarboSpacing.x5,
        top:    CarboSpacing.x3,
        bottom: bottomInset + CarboSpacing.x6,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DragHandle(),
            const SizedBox(height: CarboSpacing.x2),
            _SheetHeader(),
            const SizedBox(height: CarboSpacing.x4),
            if (endDate != null) ...[
              _CurrentEndDateRow(endDate: endDate),
              const SizedBox(height: CarboSpacing.x5),
            ],
            _CounterSection(controller: controller),
            const SizedBox(height: CarboSpacing.x4),
            _PreviewArea(controller: controller),
            const SizedBox(height: CarboSpacing.x4),
            _WalletBalanceCard(controller: controller),
            const SizedBox(height: CarboSpacing.x4),
            _ConfirmButton(controller: controller),
          ],
        ),
      ),
    );
  }

  String? _endDate() {
    if (!Get.isRegistered<BookingDetailsController>()) return null;
    final raw = Get.find<BookingDetailsController>().booking.value?.roundPickupDate;
    if (raw == null) return null;
    final s = raw.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAG HANDLE
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: const BoxDecoration(
          color: CarboColors.divider,
          borderRadius: CarboRadius.fullAll,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.extendRental.tr,
                style: CarboTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Add days to your ongoing booking',
                style: CarboTypography.bodySmall,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: CarboColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: CarboColors.textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURRENT END DATE ROW
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentEndDateRow extends StatelessWidget {
  final String endDate;
  const _CurrentEndDateRow({required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x4,
        vertical: CarboSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: CarboColors.background,
        borderRadius: CarboRadius.mdAll,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: CarboColors.textSecondary,
          ),
          const SizedBox(width: CarboSpacing.x2),
          Text(
            'Current End Date',
            style: CarboTypography.bodySmall,
          ),
          const Spacer(),
          Text(
            endDate,
            style: CarboTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: CarboColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNTER SECTION  (hero widget)
// ─────────────────────────────────────────────────────────────────────────────

class _CounterSection extends StatelessWidget {
  final ExtendBookingController controller;
  const _CounterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Strings.additionalDays.tr.toUpperCase(),
          style: CarboTypography.overline,
        ),
        const SizedBox(height: CarboSpacing.x3),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.remove_rounded,
              onTap: controller.decrement,
              filled: false,
              disabled: controller.days.value <= 1,
            ),
            const SizedBox(width: CarboSpacing.x6),
            _AnimatedCounterNumber(value: controller.days.value),
            const SizedBox(width: CarboSpacing.x6),
            _CircleButton(
              icon: Icons.add_rounded,
              onTap: controller.increment,
              filled: true,
              disabled: controller.days.value >= 365,
            ),
          ],
        )),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool disabled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.filled,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFilled = filled && !disabled;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: effectiveFilled ? CarboGradients.primary : null,
          color: effectiveFilled ? null : CarboColors.background,
          border: effectiveFilled
              ? null
              : Border.all(color: CarboColors.divider),
          boxShadow: effectiveFilled ? CarboShadow.primaryGlow : null,
        ),
        child: Icon(
          icon,
          size: 24,
          color: disabled
              ? CarboColors.textDisabled
              : (filled ? CarboColors.textOnPrimary : CarboColors.primary),
        ),
      ),
    );
  }
}

class _AnimatedCounterNumber extends StatefulWidget {
  final int value;
  const _AnimatedCounterNumber({required this.value});

  @override
  State<_AnimatedCounterNumber> createState() => _AnimatedCounterNumberState();
}

class _AnimatedCounterNumberState extends State<_AnimatedCounterNumber> {
  bool _isIncrement = true;

  @override
  void didUpdateWidget(_AnimatedCounterNumber old) {
    super.didUpdateWidget(old);
    _isIncrement = widget.value > old.value;
  }

  @override
  Widget build(BuildContext context) {
    final slideBegin = _isIncrement
        ? const Offset(0, 0.4)
        : const Offset(0, -0.4);

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: CarboDuration.normal,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: slideBegin,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ));
              return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              '${widget.value}',
              key: ValueKey(widget.value),
              textAlign: TextAlign.center,
              style: CarboTypography.displayLarge.copyWith(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: CarboColors.primary,
                letterSpacing: -2,
              ),
            ),
          ),
          Text(
            'days',
            style: CarboTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW AREA  (AnimatedSize + AnimatedSwitcher)
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewArea extends StatelessWidget {
  final ExtendBookingController controller;
  const _PreviewArea({required this.controller});

  static const double _fixedHeight = 270;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading  = controller.isPending.value || controller.isPreviewLoading.value;
      final isLoaded   = controller.isPreviewLoaded.value;
      final preview    = controller.previewResult.value;

      Widget child;
      if (isLoaded && preview != null) {
        child = _PreviewCard(preview: preview, key: const ValueKey('card'));
      } else if (isLoading) {
        child = const _SkeletonLoader(key: ValueKey('skeleton'));
      } else {
        child = const _SkeletonLoader(key: ValueKey('skeleton'));
      }

      return SizedBox(
        height: _fixedHeight,
        child: AnimatedSwitcher(
          duration: CarboDuration.normal,
          child: child,
        ),
      );
    });
  }
}

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader({Key? key}) : super(key: key);

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(CarboSpacing.x4),
          decoration: BoxDecoration(
            color: CarboColors.background,
            borderRadius: CarboRadius.lgAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (i) => Padding(
              padding: EdgeInsets.only(
                bottom: i < 3 ? CarboSpacing.x3 : 0,
              ),
              child: Container(
                height: 14,
                width: i.isEven ? double.infinity : 120,
                decoration: BoxDecoration(
                  color: CarboColors.divider,
                  borderRadius: CarboRadius.smAll,
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final ExtendPreviewModel preview;
  const _PreviewCard({required this.preview, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cur = BasicServices.baseCurCode.value;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFECEC)],
        ),
        borderRadius: CarboRadius.lgAll,
        border: Border.all(
          color: CarboColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarboSpacing.x4,
              vertical: CarboSpacing.x3,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: CarboColors.primary,
                    borderRadius: CarboRadius.fullAll,
                  ),
                ),
                const SizedBox(width: CarboSpacing.x2),
                Text(
                  'PRICE PREVIEW',
                  style: CarboTypography.overline.copyWith(
                    color: CarboColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: CarboColors.primary.withValues(alpha: 0.1),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.all(CarboSpacing.x4),
            child: Column(
              children: [
                _PreviewRow(
                  label: Strings.newEndDate.tr,
                  value: preview.newReturnDate,
                ),
                _divider(),
                _PreviewRow(
                  label: Strings.dailyRate.tr,
                  value: '${_fmt(preview.basePrice)} $cur',
                ),
                _divider(),
                _PreviewRow(
                  label: Strings.subtotal.tr,
                  value: '${_fmt(preview.rentalFees)} $cur',
                ),
                _divider(),
                _PreviewRow(
                  label: 'Tax (${_fmt(preview.taxPercentage)}%)',
                  value: '${_fmt(preview.taxAmount)} $cur',
                ),
                const SizedBox(height: CarboSpacing.x3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: CarboTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CarboColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CarboSpacing.x3,
                        vertical: CarboSpacing.x1,
                      ),
                      decoration: BoxDecoration(
                        color: CarboColors.primary,
                        borderRadius: CarboRadius.fullAll,
                      ),
                      child: Text(
                        '${_fmt(preview.totalCost)} $cur',
                        style: CarboTypography.labelLarge.copyWith(
                          color: CarboColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: CarboSpacing.x4,
    thickness: 0.5,
    color: Color(0x1AE93A3A),
  );

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CarboTypography.bodySmall),
        Text(
          value,
          style: CarboTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: CarboColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WALLET BALANCE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _WalletBalanceCard extends StatelessWidget {
  final ExtendBookingController controller;
  const _WalletBalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    return Obx(() {
      final wallet = walletCtrl.walletModel.value;
      final isWalletLoading = walletCtrl.isLoading.value;
      final balance = wallet?.balance ?? 0.0;
      final currency = wallet?.currency ?? 'SAR';
      final preview = controller.previewResult.value;
      final isInsufficient = !isWalletLoading &&
          wallet != null &&
          preview != null &&
          balance < preview.totalCost;

      return Container(
        decoration: BoxDecoration(
          color: CarboColors.surface,
          borderRadius: CarboRadius.lgAll,
          border: Border.all(
            color: isInsufficient
                ? CarboColors.debit.withValues(alpha: 0.4)
                : CarboColors.divider,
          ),
        ),
        child: Column(
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
                          ? CarboColors.debit.withValues(alpha: 0.1)
                          : CarboColors.credit.withValues(alpha: 0.12),
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
                  if (isWalletLoading && wallet == null)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
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

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final ExtendBookingController controller;
  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    return Obx(() {
      final preview = controller.previewResult.value;
      final wallet = walletCtrl.walletModel.value;
      final isInsufficient = controller.isPreviewLoaded.value &&
          wallet != null &&
          preview != null &&
          wallet.balance < preview.totalCost;
      final canConfirm = controller.isPreviewLoaded.value &&
          !controller.isConfirming.value &&
          !isInsufficient;
      final isLoading = controller.isConfirming.value;

      return GestureDetector(
        onTap: canConfirm ? () => _showConfirmSheet(context) : null,
        child: AnimatedContainer(
          duration: CarboDuration.normal,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x4),
          decoration: BoxDecoration(
            gradient: canConfirm ? CarboGradients.primary : null,
            color: canConfirm ? null : CarboColors.textDisabled,
            borderRadius: CarboRadius.mdAll,
            boxShadow: canConfirm ? CarboShadow.primaryGlow : null,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CarboColors.textOnPrimary,
                    ),
                  ),
                )
              : Text(
                  Strings.confirmExtension.tr,
                  textAlign: TextAlign.center,
                  style: CarboTypography.buttonLabel,
                ),
        ),
      );
    });
  }

  void _showConfirmSheet(BuildContext sheetContext) {
    final preview = controller.previewResult.value!;
    final cur     = BasicServices.baseCurCode.value;

    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExtendConfirmSheet(
        days:       controller.days.value,
        newEndDate: preview.newReturnDate,
        total:      preview.totalCost,
        currency:   cur,
        onConfirm: () {
          Navigator.of(sheetContext).pop();
          controller.confirmExtension(() {
            _showExtendSuccessOverlay(sheetContext, () => Navigator.of(sheetContext).pop());
          });
        },
      ),
    );
  }

  void _showExtendSuccessOverlay(BuildContext context, VoidCallback onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const _ExtendSuccessOverlay(),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
      onDone();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMATION SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ExtendConfirmSheet extends StatelessWidget {
  final int days;
  final String newEndDate;
  final double total;
  final String currency;
  final VoidCallback onConfirm;

  const _ExtendConfirmSheet({
    required this.days,
    required this.newEndDate,
    required this.total,
    required this.currency,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(CarboSpacing.x4),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.xxlAll,
        boxShadow: CarboShadow.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        CarboSpacing.x5,
        CarboSpacing.x6,
        CarboSpacing.x5,
        CarboSpacing.x5,
      ),
      decoration: const BoxDecoration(
        color: CarboColors.primaryLight,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(CarboRadius.xxl),
          topRight: Radius.circular(CarboRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CarboColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: CarboColors.primary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: CarboColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: CarboSpacing.x4),
          Text(
            Strings.confirmExtension.tr,
            style: CarboTypography.headlineMedium.copyWith(
              color: CarboColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CarboSpacing.x2),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: CarboTypography.bodyMedium.copyWith(
                color: CarboColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'Extending by '),
                TextSpan(
                  text: '$days days',
                  style: CarboTypography.bodyMedium.copyWith(
                    color: CarboColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final totalStr = total == total.truncateToDouble()
        ? total.toInt().toString()
        : total.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CarboSpacing.x5,
        CarboSpacing.x4,
        CarboSpacing.x5,
        CarboSpacing.x6,
      ),
      child: Column(
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CarboSpacing.x4),
            decoration: BoxDecoration(
              color: CarboColors.background,
              borderRadius: CarboRadius.mdAll,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.newEndDate.tr,
                      style: CarboTypography.bodySmall,
                    ),
                    Text(
                      newEndDate,
                      style: CarboTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CarboColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CarboSpacing.x3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.amountToCharge.tr,
                      style: CarboTypography.bodySmall,
                    ),
                    Text(
                      '$totalStr $currency',
                      style: CarboTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CarboColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: CarboSpacing.x4),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CarboColors.textSecondary,
                    side: const BorderSide(color: CarboColors.divider),
                    padding: const EdgeInsets.symmetric(
                      vertical: CarboSpacing.x3,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: CarboRadius.mdAll,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: CarboTypography.titleSmall.copyWith(
                      color: CarboColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: CarboSpacing.x3,
                    ),
                    decoration: BoxDecoration(
                      gradient: CarboGradients.primary,
                      borderRadius: CarboRadius.mdAll,
                      boxShadow: CarboShadow.primaryGlow,
                    ),
                    child: Text(
                      Strings.yesExtend.tr,
                      textAlign: TextAlign.center,
                      style: CarboTypography.buttonLabel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTEND SUCCESS OVERLAY
// ─────────────────────────────────────────────────────────────────────────────

class _ExtendSuccessOverlay extends StatelessWidget {
  const _ExtendSuccessOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(CarboSpacing.x6),
        padding: const EdgeInsets.symmetric(
          horizontal: CarboSpacing.x6,
          vertical: CarboSpacing.x6,
        ),
        decoration: const BoxDecoration(
          color: CarboColors.surface,
          borderRadius: CarboRadius.xxlAll,
          boxShadow: CarboShadow.floating,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.icons.success,
              height: 96,
            ),
            const SizedBox(height: CarboSpacing.x4),
            Text(
              Strings.extendRental.tr,
              style: CarboTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: CarboColors.primary,
              ),
            ),
            const SizedBox(height: CarboSpacing.x2),
            Text(
              'Your booking has been extended successfully',
              textAlign: TextAlign.center,
              style: CarboTypography.bodySmall.copyWith(
                color: CarboColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
