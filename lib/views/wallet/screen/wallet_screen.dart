import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed = Color(0xFFE93A3A);
const _kRedDark = Color(0xFFB72E2E);
const _kRedLight = Color(0xFFFFECEC);
const _kBg = Color(0xFFF7F8F8);
const _kSurface = Color(0xFFFFFFFF);
const _kText = Color(0xFF1D1D1D);
const _kTextSub = Color(0xFF8F9396);
const _kCredit = Color(0xFF21C77B);
const _kDebit = Color(0xFFE93A3A);

// ─── Screen ─────────────────────────────────────────────────────────────────
class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: RefreshIndicator(
          color: _kRed,
          onRefresh: () async {
            controller.fetchWallet();
            await controller.fetchTransactions(refresh: true);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header + Balance ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  final wallet = controller.walletModel.value;
                  return _HeroCard(
                    balance: wallet?.balance ?? 0.0,
                    currency: wallet?.currency ?? 'SAR',
                    isLoading: controller.isLoading.value && wallet == null,
                    controller: controller,
                  );
                }),
              ),

              // ── Section Title ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.transactionHistory.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Obx(() => controller.isTransactionsLoading.value
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kRed,
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),

              // ── Transaction List ─────────────────────────────────────────
              Obx(() {
                final list = controller.transactions;

                if (controller.isTransactionsLoading.value && list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180.h,
                      child: const Center(
                        child: CircularProgressIndicator(color: _kRed),
                      ),
                    ),
                  );
                }

                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == list.length) {
                        if (controller.hasMorePages.value) {
                          controller.loadMoreTransactions();
                          return Padding(
                            padding: EdgeInsets.all(16.h),
                            child: const Center(
                              child: CircularProgressIndicator(color: _kRed),
                            ),
                          );
                        }
                        return null;
                      }
                      return _TransactionCard(transaction: list[index]);
                    },
                    childCount:
                        list.length + (controller.hasMorePages.value ? 1 : 0),
                  ),
                );
              }),

              SliverToBoxAdapter(child: SizedBox(height: 32.h)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Card ───────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final double balance;
  final String currency;
  final bool isLoading;
  final WalletController controller;

  const _HeroCard({
    required this.balance,
    required this.currency,
    required this.isLoading,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(32.r),
        bottomRight: Radius.circular(32.r),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kRed, _kRedDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -40,
                top: -40,
                child: _Circle(size: 180.r, opacity: 0.08),
              ),
              Positioned(
                right: 60,
                top: 60,
                child: _Circle(size: 100.r, opacity: 0.06),
              ),
              Positioned(
                left: -30,
                bottom: -20,
                child: _Circle(size: 140.r, opacity: 0.07),
              ),
              // Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 38.w,
                              height: 38.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                          Text(
                            Strings.myWallet.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.fetchWallet();
                              controller.fetchTransactions(refresh: true);
                            },
                            child: Container(
                              width: 38.w,
                              height: 38.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      // Balance label
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_wallet_rounded,
                                    color: Colors.white70, size: 12.sp),
                                SizedBox(width: 5.w),
                                Text(
                                  Strings.availableBalance.tr,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Balance amount
                      isLoading
                          ? _ShimmerBlock(width: 180.w, height: 44.h)
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  balance.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5.h),
                                  child: Text(
                                    currency,
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                      SizedBox(height: 28.h),

                      // Top-up button
                      Obx(() => GestureDetector(
                            onTap: controller.isRechargeLoading.value
                                ? null
                                : () => _showTopupDialog(context, controller),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 52.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: controller.isRechargeLoading.value
                                  ? Center(
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                          color: _kRed,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 28.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            color: _kRedLight,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.add_rounded,
                                              color: _kRed, size: 16.sp),
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          Strings.topUpWallet.tr,
                                          style: TextStyle(
                                            color: _kRed,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          )),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  void _showTopupDialog(BuildContext context, WalletController ctrl) {
    final amountController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _kRedLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: _kRed, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    Strings.topUpWallet.tr,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _kText,
                ),
                decoration: InputDecoration(
                  labelText: Strings.amountSar.tr,
                  hintText: Strings.minimumSar.tr,
                  labelStyle: TextStyle(color: _kTextSub, fontSize: 13.sp),
                  hintStyle: TextStyle(color: _kTextSub, fontSize: 13.sp),
                  prefixIcon:
                      Icon(Icons.payments_rounded, color: _kRed, size: 20.sp),
                  filled: true,
                  fillColor: _kBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: _kRed, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            Strings.cancel.tr,
                            style: TextStyle(
                              color: _kTextSub,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final amount =
                            int.tryParse(amountController.text.trim());
                        if (amount == null || amount < 1 || amount > 5000) return;
                        Get.back();
                        final invoice = await ctrl.recharge(amount);
                        if (invoice != null &&
                            invoice.paymentUrl.isNotEmpty) {
                          Get.toNamed(Routes.walletPaymentWebview,
                              arguments: {'url': invoice.paymentUrl});
                        }
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kRed, _kRedDark],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            Strings.continuee.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionCard({required this.transaction});

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final date = DateFormat('dd/MM/yyyy').format(dt);
      final time = DateFormat('hh:mm a').format(dt);
      return '$date • $time';
    } catch (_) {
      return raw;
    }
  }

  IconData _iconFor(String refType, bool isCredit) {
    switch (refType.toLowerCase()) {
      case 'booking':
        return Icons.directions_car_rounded;
      case 'topup':
      case 'recharge':
        return Icons.account_balance_wallet_rounded;
      case 'refund':
        return Icons.undo_rounded;
      case 'payment':
        return Icons.payments_rounded;
      default:
        return isCredit
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? _kCredit : _kDebit;
    final bgColor =
        isCredit ? const Color(0xFFEBFAF3) : _kRedLight;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              _iconFor(transaction.referenceType, isCredit),
              color: color,
              size: 20.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _kText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: TextStyle(
                    color: _kTextSub,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'SAR',
                style: TextStyle(
                  color: _kTextSub,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: _kRedLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, color: _kRed, size: 32.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            Strings.noTransactionsYet.tr,
            style: TextStyle(
              color: _kText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            Strings.transactionHistoryEmpty.tr,
            style: TextStyle(color: _kTextSub, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBlock({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}


