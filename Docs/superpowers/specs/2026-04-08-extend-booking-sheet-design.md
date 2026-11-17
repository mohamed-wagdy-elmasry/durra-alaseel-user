# Extend Booking Sheet — Design Spec
**Date:** 2026-04-08  
**Status:** Approved

---

## Context

Users with an **ongoing booking** (status = 2) can extend their rental period. The API endpoints and controller logic for this already exist (`ExtendBookingController`, `ApiEndpoint.extendPreview`, `ApiEndpoint.extendBooking`), but the existing `ExtendBookingBottomSheet` uses old design tokens (`CustomColor`, `Dimensions`, `TextWidget`) and a plain text input field. This spec redesigns the sheet using Carbo DS tokens exclusively, replaces the text input with a hero counter widget (style C), adds an animated preview card, and adds a confirmation alert sheet before final submission. It also fixes all `Get.back()` violations inside the sheet per the project rule.

---

## Scope

Two files are fully redesigned. The controller gets a focused refactor (text input → counter). No other files touched beyond string additions.

---

## Files Changed

| File | Change |
|---|---|
| `lib/views/booking_details/widget/extend_booking_bottom_sheet.dart` | Full redesign — hero counter, animated preview, confirmation sheet |
| `lib/views/booking_details/controller/extend_booking_controller.dart` | Replace `TextEditingController` + `onDaysChanged(String)` with `RxInt days` + `increment()` / `decrement()` |
| `lib/languages/strings.dart` | Add new string keys |
| `lib/languages/app_translations.dart` | Add EN + AR translations for new keys |

---

## Controller Changes (`extend_booking_controller.dart`)

Replace the `TextEditingController extensionDaysController` with:

```dart
final RxInt days = 1.obs;          // current counter value, 1–365
final RxBool isPending = false.obs; // true while debounce timer is running
```

Add methods:
```dart
void increment() { if (days.value < 365) { days.value++; _onCounterChanged(); } }
void decrement() { if (days.value > 1)   { days.value--; _onCounterChanged(); } }

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
```

In `confirmExtension()` replace the text-parse with `days.value`.  
Add a `VoidCallback? onClose` parameter to `confirmExtension(VoidCallback onClose)`. The sheet passes `() => Navigator.of(context).pop()` when calling it. The controller calls `onClose()` instead of `Get.back()` on success. No `BuildContext` stored in the controller.

---

## Bottom Sheet UI (`extend_booking_bottom_sheet.dart`)

All tokens from `CarboDS`. No `CustomColor`, `Dimensions`, or `TextWidget`.

### Structure (top → bottom)

```
DragHandle
SheetHeader          ← title + subtitle + circular close button
CurrentEndDateRow    ← pill with calendar icon, date right-aligned
HeroCounter          ← circular − / big number / circular +, progress bar
PreviewArea          ← AnimatedSize wrapper containing:
                         • SkeletonShimmer  (while isPending || isPreviewLoading)
                         • PreviewCard      (when isPreviewLoaded)
                         • SizedBox.shrink  (idle, days not yet changed)
ConfirmButton        ← gradient, disabled until isPreviewLoaded
```

### HeroCounter widget

```
Column(
  "ADDITIONAL DAYS"  // overline, uppercase, letter-spacing
  Row(
    _CircleButton(icon: Icons.remove, onTap: decrement, filled: false)
    _CounterNumber(days)   // AnimatedSwitcher, slide up/down
    _CircleButton(icon: Icons.add,    onTap: increment, filled: true)  // red gradient + glow shadow
  )
  ProgressBar           // AnimatedContainer width = days/365 * maxWidth
  "X of 365 days"       // caption
)
```

**Counter animation:** `AnimatedSwitcher` with a `SlideTransition` — slides up when incrementing, slides down when decrementing. Track direction with a `bool _lastWasIncrement` field.

**Progress bar:** `AnimatedContainer` duration `CarboDuration.slow` (350ms). Width = `(days / 365) * trackWidth`. Gradient fill: `CarboGradients.primary`.

**Plus button glow:** `BoxDecoration` with `CarboShadow.primaryGlow` when `!isPending && !isPreviewLoading`, plain shadow otherwise.

### PreviewArea animation

`AnimatedSize` wrapping an `AnimatedSwitcher`:
- **Idle / 0 days:** `SizedBox.shrink()`
- **Loading (isPending || isPreviewLoading):** `_SkeletonShimmer` — three shimmer rows in a rounded card
- **Loaded:** `_PreviewCard` — gradient background `#FFF5F5→#FFECEC`, red left-border accent strip, rows for New End Date / Daily Rate / Subtotal / Tax, divider, Total pill badge (white text on `CarboColors.primary` rounded pill)

`AnimatedSize` duration: `CarboDuration.slow` (350ms), curve `Curves.easeInOut`.  
`AnimatedSwitcher` duration: `CarboDuration.normal` (200ms), `FadeTransition`.

### ConfirmButton

```dart
Obx(() => GradientButton(   // or standard ElevatedButton with gradient decoration
  enabled: controller.isPreviewLoaded.value && !controller.isConfirming.value,
  isLoading: controller.isConfirming.value,
  onPressed: () => _showConfirmSheet(context),
  label: Strings.confirmExtension.tr,
))
```

Button uses `CarboGradients.primary` + `CarboShadow.primaryGlow`. Disabled state uses `CarboColors.disabled` background.

### Close button

Circular `InkWell` with `CarboColors.background` fill, `Icons.close_rounded`. Calls `Navigator.of(context).pop()` — **never `Get.back()`**.

---

## Confirmation Alert Sheet (`_ExtendConfirmSheet`)

A private `StatelessWidget` shown via `showModalBottomSheet` (same pattern as `_CancelConfirmSheet`).

```
DragHandle
Center column:
  Circle icon container  ← CarboColors.primaryLight bg, calendar icon
  "Confirm Extension?"   ← CarboTypography.headlineSmall, bold
  "Extending by X days"  ← bodyMedium, secondary color
                           "X days" span in CarboColors.primary + bold
Summary card (CarboColors.background bg, CarboRadius.mdAll):
  Row: "New end date"  |  date value
  Row: "Amount"        |  total in CarboColors.primary bold
Two buttons row:
  "Cancel"   ← OutlinedButton, border CarboColors.border
  "Yes, Extend" ← ElevatedButton, CarboColors.primary bg, wider (flex 1.4)
```

`"Yes, Extend"` calls `Navigator.of(context).pop()` to dismiss the confirm sheet, then calls `controller.confirmExtension(() => Navigator.of(context).pop())` — passing a `VoidCallback` so the controller closes the main sheet after success without storing `BuildContext`.

---

## String Keys to Add

| Key constant | EN | AR |
|---|---|---|
| `Strings.confirmExtension` | `"Confirm Extension"` | `"تأكيد التمديد"` |
| `Strings.extendingByDays` | `"Extending by {days} days"` | `"تمديد بـ {days} أيام"` |
| `Strings.additionalDays` | `"Additional Days"` | `"أيام إضافية"` |
| `Strings.newEndDate` | `"New End Date"` | `"تاريخ الانتهاء الجديد"` |
| `Strings.ofDays` | `"of 365 days"` | `"من 365 يوم"` |
| `Strings.yesExtend` | `"Yes, Extend"` | `"نعم، مدّد"` |
| `Strings.amountToCharge` | `"Amount to Charge"` | `"المبلغ المطلوب"` |

> `Strings.dailyRate` and `Strings.subtotal` already exist — do **not** re-add them.

---

## Animations Summary

| Element | Technique | Duration |
|---|---|---|
| Counter number change | `AnimatedSwitcher` + `SlideTransition` (up/down) | 200ms |
| Progress bar width | `AnimatedContainer` | 350ms |
| Preview card appear/disappear | `AnimatedSize` + `AnimatedSwitcher` FadeTransition | 350ms / 200ms |
| Skeleton shimmer | Manual `AnimationController` with `AnimatedBuilder` gradient sweep (no extra package) | continuous |
| Confirm button enabled state | `AnimatedContainer` color | 200ms |

---

## Known Constraints

- **`Get.back()` is forbidden** — use `Navigator.of(context).pop()`. The controller must receive `BuildContext` or a `VoidCallback onClose` to dismiss the sheet after successful extension. Use the callback pattern to avoid storing context in the controller.
- **Carbo DS tokens only** — no `CustomColor`, `Dimensions`, `TextWidget`, or `PrimaryButton`.
- **Counter range: 1–365** — `decrement` no-ops at 1, `increment` no-ops at 365.
- **Debounce: 800ms** — unchanged from existing controller.
- **`_ExtendConfirmSheet` is a private widget** inside `extend_booking_bottom_sheet.dart` — same file, same pattern as `_CancelConfirmSheet` in the booking details screen.

---

## Verification

1. Run app, navigate to History → tap an **Ongoing** booking.
2. Confirm "Extend Rental" button is visible.
3. Tap it — bottom sheet opens with hero counter starting at 1.
4. Tap + several times — number animates up, progress bar grows, debounce fires after 800ms.
5. Preview card slides in with correct pricing.
6. Tap − past 1 — button no-ops at 1.
7. Tap "Confirm Extension" — confirmation sheet appears with correct summary.
8. Tap "Cancel" on confirmation sheet — returns to extend sheet (main sheet stays open).
9. Tap "Yes, Extend" — API call fires, both sheets close, success snackbar shown, booking refreshed.
10. Verify no `LateInitializationError` (no `Get.back()` anywhere in the flow).
