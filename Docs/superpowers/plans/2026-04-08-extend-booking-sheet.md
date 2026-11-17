# Extend Booking Sheet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the extend-booking bottom sheet with a hero counter widget (1–365 days), animated preview card, and confirmation alert sheet — all using Carbo DS tokens exclusively.

**Architecture:** The existing `ExtendBookingController` is refactored to replace `TextEditingController` with an `RxInt days` counter and expose `increment()`/`decrement()` methods. The bottom sheet widget is fully rewritten using Carbo DS tokens; a private `_ExtendConfirmSheet` is shown via `showModalBottomSheet` before the final API call. The `Get.back()` violation in the controller is fixed by passing a `VoidCallback onClose` from the sheet.

**Tech Stack:** Flutter, GetX (Rx), Carbo Design System tokens (`carbo_ds.dart`), `BasicServices.baseCurCode` for currency.

---

## File Map

| File | Action |
|---|---|
| `lib/languages/strings.dart` | Add 7 new string constant keys |
| `lib/languages/app_translations.dart` | Add EN + AR translations for those 7 keys |
| `lib/views/booking_details/controller/extend_booking_controller.dart` | Replace text input with `RxInt days`; add `increment`/`decrement`; fix `Get.back()` |
| `lib/views/booking_details/widget/extend_booking_bottom_sheet.dart` | Full redesign: hero counter, animated preview card, confirm sheet |

---

## Task 1: Add String Keys

**Files:**
- Modify: `lib/languages/strings.dart`
- Modify: `lib/languages/app_translations.dart`

- [ ] **Step 1: Add 7 constants to `strings.dart`**

Open `lib/languages/strings.dart`. At the end of the class body (after `branchName`, before the closing `}`), add:

```dart
  static const String confirmExtension  = "appLConfirmExtension";
  static const String extendingByDays   = "appLExtendingByDays";
  static const String additionalDays    = "appLAdditionalDays";
  static const String newEndDate        = "appLNewEndDate";
  static const String ofDays            = "appLOfDays";
  static const String yesExtend         = "appLYesExtend";
  static const String amountToCharge    = "appLAmountToCharge";
```

- [ ] **Step 2: Add EN translations to `app_translations.dart`**

In `_enTranslations`, after `'appLBranchName': 'Branch',` (line 262), add:

```dart
    // Extend booking sheet
    'appLConfirmExtension':  'Confirm Extension',
    'appLExtendingByDays':   'Extending by {days} days',
    'appLAdditionalDays':    'Additional Days',
    'appLNewEndDate':        'New End Date',
    'appLOfDays':            'of 365 days',
    'appLYesExtend':         'Yes, Extend',
    'appLAmountToCharge':    'Amount to Charge',
```

- [ ] **Step 3: Add AR translations to `app_translations.dart`**

In `_arTranslations`, after `'appLBranchName': 'الفرع',` (line 516), add:

```dart
    // Extend booking sheet
    'appLConfirmExtension':  'تأكيد التمديد',
    'appLExtendingByDays':   'تمديد بـ {days} أيام',
    'appLAdditionalDays':    'أيام إضافية',
    'appLNewEndDate':        'تاريخ الانتهاء الجديد',
    'appLOfDays':            'من 365 يوم',
    'appLYesExtend':         'نعم، مدّد',
    'appLAmountToCharge':    'المبلغ المطلوب',
```

- [ ] **Step 4: Commit**

```bash
git add lib/languages/strings.dart lib/languages/app_translations.dart
git commit -m "feat(i18n): add extend booking sheet string keys (EN + AR)"
```

---

## Task 2: Refactor ExtendBookingController

**Files:**
- Modify: `lib/views/booking_details/controller/extend_booking_controller.dart`

Replace the entire file content with:

- [ ] **Step 1: Rewrite the controller**

```dart
import 'dart:async';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/custom_snackbar.dart';
import '../../../backend/model/extend_confirm_model.dart';
import '../../../backend/model/extend_preview_model.dart';
import 'booking_details_controller.dart';

class ExtendBookingController extends GetxController {
  final int bookingId;

  ExtendBookingController(this.bookingId);

  // ── Counter state ────────────────────────────────────────────────────────────
  final RxInt days = 1.obs;
  final RxBool isPending = false.obs;   // true while debounce timer is running

  // ── Preview state ─────────────────────────────────────────────────────────────
  final RxBool isPreviewLoading = false.obs;
  final RxBool isPreviewLoaded  = false.obs;
  final Rx<ExtendPreviewModel?> previewResult = Rx<ExtendPreviewModel?>(null);
  final RxString validationError = ''.obs;

  // ── Confirm state ─────────────────────────────────────────────────────────────
  final RxBool isConfirming = false.obs;

  Timer? _debounce;

  // ── Public counter methods ────────────────────────────────────────────────────

  void increment() {
    if (days.value >= 365) return;
    days.value++;
    _onCounterChanged();
  }

  void decrement() {
    if (days.value <= 1) return;
    days.value--;
    _onCounterChanged();
  }

  // ── Internal ──────────────────────────────────────────────────────────────────

  void _onCounterChanged() {
    isPending.value = true;
    previewResult.value = null;
    isPreviewLoaded.value = false;
    validationError.value = '';
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      isPending.value = false;
      _fetchPreview(days.value);
    });
  }

  Future<void> _fetchPreview(int numDays) async {
    await RequestProcess().request<ExtendPreviewModel>(
      fromJson: ExtendPreviewModel.fromJson,
      apiEndpoint: ApiEndpoint.extendPreview,
      isLoading: isPreviewLoading,
      method: HttpMethod.GET,
      queryParams: {
        'booking_id':     bookingId.toString(),
        'extension_days': numDays.toString(),
      },
      showErrorMessage: true,
      onSuccess: (value) {
        if (value != null) {
          previewResult.value = value;
          isPreviewLoaded.value = true;
        } else {
          isPreviewLoaded.value = false;
          previewResult.value = null;
        }
      },
      onError: (_) {
        isPreviewLoaded.value = false;
        previewResult.value = null;
      },
    );
  }

  /// [onClose] is called after a successful extension to dismiss the sheet.
  /// The sheet passes `() => Navigator.of(context).pop()`.
  Future<void> confirmExtension(VoidCallback onClose) async {
    if (isConfirming.value || !isPreviewLoaded.value) return;

    await RequestProcess().request<ExtendConfirmModel>(
      fromJson: ExtendConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.extendBooking,
      isLoading: isConfirming,
      method: HttpMethod.POST,
      body: {
        'booking_id':     bookingId,
        'extension_days': days.value,
      },
      showSuccessMessage: false,
      showErrorMessage: true,
      onSuccess: (value) {
        onClose();
        CustomSnackBar.success(
          title: Strings.success,
          message: (value?.message.isNotEmpty == true)
              ? value!.message
              : 'Booking extended successfully',
        );
        if (Get.isRegistered<BookingDetailsController>()) {
          Get.find<BookingDetailsController>().refreshBooking();
        }
      },
      onError: (_) {
        isConfirming.value = false;
      },
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/views/booking_details/controller/extend_booking_controller.dart
git commit -m "refactor(extend): replace TextEditingController with RxInt counter, fix Get.back()"
```

---

## Task 3: Redesign ExtendBookingBottomSheet

**Files:**
- Modify: `lib/views/booking_details/widget/extend_booking_bottom_sheet.dart`

Replace the entire file content with the code below.

**Widget tree summary:**
```
ExtendBookingBottomSheet
  └─ Container (CarboRadius.xxlTop, white bg)
       └─ SingleChildScrollView
            └─ Column
                 ├─ _DragHandle
                 ├─ _SheetHeader            (title, subtitle, circular close ✕)
                 ├─ _CurrentEndDateRow      (calendar icon, date)
                 ├─ _CounterSection         (hero counter + progress bar)
                 ├─ _PreviewArea            (AnimatedSize + AnimatedSwitcher)
                 │    ├─ SizedBox.shrink    (idle)
                 │    ├─ _SkeletonLoader    (isPending || isPreviewLoading)
                 │    └─ _PreviewCard       (isPreviewLoaded)
                 └─ _ConfirmButton          (gradient, opens _ExtendConfirmSheet)

_ExtendConfirmSheet  (private, shown via showModalBottomSheet)
  └─ Container (CarboRadius.xxlAll, floating shadow, all-margin)
       ├─ Header section  (primaryLight bg, calendar icon, title, subtitle)
       └─ Body section
            ├─ Summary card  (new end date + amount)
            └─ Button row    (Cancel | Yes, Extend)
```

- [ ] **Step 1: Write the bottom sheet file**

```dart
import 'package:flutter/material.dart';
import '../../../base/api/services/basic_services.dart';
import '../../../base/design_system/carbo_ds.dart';
import '../../../base/utils/basic_import.dart';
import '../../../backend/model/extend_preview_model.dart';
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
        const SizedBox(height: CarboSpacing.x4),
        _ProgressBar(controller: controller),
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
  late int _prev;
  bool _isIncrement = true;

  @override
  void initState() {
    super.initState();
    _prev = widget.value;
  }

  @override
  void didUpdateWidget(_AnimatedCounterNumber old) {
    super.didUpdateWidget(old);
    _isIncrement = widget.value > old.value;
    _prev = old.value;
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

class _ProgressBar extends StatelessWidget {
  final ExtendBookingController controller;
  const _ProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth * 0.75;
        return Column(
          children: [
            Container(
              width: trackWidth,
              height: 5,
              decoration: BoxDecoration(
                color: CarboColors.divider,
                borderRadius: CarboRadius.fullAll,
              ),
              child: Obx(() {
                final fraction = (controller.days.value / 365).clamp(0.0, 1.0);
                return Row(
                  children: [
                    AnimatedContainer(
                      duration: CarboDuration.slow,
                      curve: Curves.easeInOut,
                      width: trackWidth * fraction,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: CarboGradients.primary,
                        borderRadius: CarboRadius.fullAll,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: CarboSpacing.x1),
            Obx(() => Text(
              '${controller.days.value} ${Strings.ofDays.tr}',
              style: CarboTypography.labelSmall.copyWith(
                color: CarboColors.textDisabled,
              ),
            )),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW AREA  (AnimatedSize + AnimatedSwitcher)
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewArea extends StatelessWidget {
  final ExtendBookingController controller;
  const _PreviewArea({required this.controller});

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
        child = const SizedBox.shrink(key: ValueKey('empty'));
      }

      return AnimatedSize(
        duration: CarboDuration.slow,
        curve: Curves.easeInOut,
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
                  value: preview.newEndDate,
                ),
                _divider(),
                _PreviewRow(
                  label: Strings.dailyRate.tr,
                  value: '${_fmt(preview.dailyRate)} $cur',
                ),
                _divider(),
                _PreviewRow(
                  label: Strings.subtotal.tr,
                  value: '${_fmt(preview.subtotal)} $cur',
                ),
                _divider(),
                _PreviewRow(
                  label: 'Tax',
                  value: '${_fmt(preview.tax)} $cur',
                ),
                const SizedBox(height: CarboSpacing.x3),
                // Total row with pill badge
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
                        '${_fmt(preview.total)} $cur',
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
// CONFIRM BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final ExtendBookingController controller;
  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canConfirm = controller.isPreviewLoaded.value &&
          !controller.isConfirming.value;
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
        newEndDate: preview.newEndDate,
        total:      preview.total,
        currency:   cur,
        onConfirm: () {
          Navigator.of(sheetContext).pop();
          controller.confirmExtension(() => Navigator.of(sheetContext).pop());
        },
      ),
    );
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/views/booking_details/widget/extend_booking_bottom_sheet.dart
git commit -m "feat(ui): redesign extend booking sheet with hero counter and animated preview"
```

---

## Task 4: Verify End-to-End

- [ ] **Step 1: Run the app**

```bash
flutter run
```

Expected: app launches without errors.

- [ ] **Step 2: Navigate to an Ongoing booking**

Go to History tab → tap a booking with status = "Ongoing" (blue badge).

Expected: booking details screen loads, "Extend Rental" red gradient button visible at the bottom.

- [ ] **Step 3: Open the extend sheet**

Tap "Extend Rental".

Expected:
- Sheet slides up with `xxlTop` rounded corners
- Drag handle at top, title "Extend Rental", circular ✕ close button
- Current End Date row with calendar icon (if round trip)
- "ADDITIONAL DAYS" overline
- Counter showing **1** in large red text, circular − and + buttons
- Progress bar at ~0.27% filled (1 of 365)

- [ ] **Step 4: Increment the counter**

Tap + several times (e.g. to 7).

Expected:
- Number animates with slide-up transition
- Progress bar grows smoothly
- "7 of 365 days" caption updates
- After 800ms: skeleton loader appears, then preview card slides in with pricing breakdown

- [ ] **Step 5: Decrement to 1**

Tap − until 1.

Expected:
- Number animates with slide-down transition  
- Tapping − at 1 has no effect (no-op)
- Preview card refreshes after debounce

- [ ] **Step 6: Test Confirm flow**

With preview loaded, tap "Confirm Extension" (red gradient button, enabled).

Expected: confirmation sheet slides up with calendar icon, "Confirm Extension?" title, days count in red, summary card with new end date and total, Cancel + "Yes, Extend" buttons.

- [ ] **Step 7: Cancel the confirmation**

Tap "Cancel" on the confirmation sheet.

Expected: confirmation sheet closes, extend sheet remains open unchanged.

- [ ] **Step 8: Confirm the extension**

Tap "Confirm Extension" again → tap "Yes, Extend".

Expected:
- Both sheets close
- Success snackbar appears
- Booking status refreshed in history list

- [ ] **Step 9: Verify no LateInitializationError**

Repeat the flow once more. Check logs for any `LateInitializationError` or `Get.back()` errors.

Expected: clean log, no errors.
