# OpenWolf

@.wolf/OPENWOLF.md

This project uses OpenWolf for context management. Read and follow .wolf/OPENWOLF.md every session. Check .wolf/cerebrum.md before generating code. Check .wolf/anatomy.md before reading files.


# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Carbo** is a Flutter car rental booking app (user-facing) with GetX state management, Pusher Beams push notifications, Awesome Notifications for rich in-app alerts, KYC verification, and wallet payments. Supports English and Arabic (RTL).

## Build Commands

```bash
flutter clean && flutter pub get        # Fresh dependency install
flutter run                             # Debug run on device
flutter build apk --release             # Production APK
cd android && ./gradlew clean --no-daemon  # Clear Android build cache
```

## Architecture

### State Management: GetX
All controllers extend `GetxController` and use reactive variables (`Rx<T>`, `.obs`, `.value`). UI subscribes via `Obx()`. Never use `setState`.

### Dependency Injection
Each screen has a `*Binding` class in `lib/bindings/` that registers controllers using `Get.lazyPut()` (lazy) or `Get.put()` (immediate). Bindings must be registered in `lib/routes/route_pages.dart` before navigation.

### Navigation
Named routes defined in `lib/routes/routes.dart`. Use `Get.toNamed(Routes.xyz, arguments: {...})` and `Navigator.of(context).pop()` (never `Get.back()`). Pass data between screens via `Get.arguments`.

### API Layer
All API calls go through `RequestProcess` in `lib/base/api/method/request_process.dart`:

```dart
await RequestProcess().request<MyModel>(
  fromJson: (json) => MyModel.fromJson(json),
  apiEndpoint: ApiEndpoint.someEndpoint,
  isLoading: isLoading,        // RxBool — auto manages loading state
  method: HttpMethod.POST,
  body: {'key': 'value'},
  onSuccess: (model) { ... },  // Errors auto-handled via CustomSnackBar
);
```

For file uploads (KYC, images), add `fieldList` and `pathList` parameters. Endpoints are defined as static getters in `lib/base/api/endpoint/api_endpoint.dart`. API responses are wrapped in `{"data": {...}, "message": "...", "type": "..."}` — `ApiServices` automatically extracts `json['data']` before calling `fromJson`.

### Feature Structure
Features live in `lib/views/{feature}/` with subdirectories: `controller/`, `screen/`, `widget/`, `model/` as needed. Follow this same structure for new features.

### Design System
**Always use Carbo DS tokens. Never hardcode colors, spacing, radius, shadows, typography, gradients, or icons inline.**

```dart
import 'package:carbo/base/design_system/carbo_ds.dart';

CarboColors.primary       // brand red #E93A3A
CarboColors.background    // scaffold bg #F7F8F8
CarboColors.credit        // #21C77B (money in)
CarboColors.debit         // #E93A3A (money out)

CarboRadius.lgAll         // 16 — cards
CarboRadius.mdAll         // 12 — inputs, chips
CarboRadius.fullAll       // pill shape

CarboSpacing.x4           // 16 — standard padding
CarboSpacing.x5           // 20 — horizontal screen margin
CarboSpacing.x6           // 24 — section gaps

CarboShadow.card          // standard card shadow
CarboShadow.primaryGlow   // red glow on primary buttons

CarboTypography.titleLarge   // screen titles (use inside build() only)
CarboTypography.bodyMedium
CarboTypography.buttonLabel  // white button text

CarboGradients.primary    // red → dark red (horizontal)
CarboDuration.normal      // 200ms standard animation
```

### Models
All models use `fromJson` factory + `toJson` method. Use `?? defaultValue` for all JSON fields — never assume fields are non-null.

### Internationalization
App supports English and Arabic. Use `'key'.tr` for translated strings. Access current locale via `LocaleService.to.currentLanguageCode` and text direction via `LocaleService.to.textDirection`. Strings are defined in `lib/languages/app_translations.dart`.

### Notifications
Two-system architecture:
- **Pusher Beams** — remote FCM push from backend (Android only; iOS/APNs pending)
- **Awesome Notifications** — rich in-app UI with buttons and deep linking

Flow: Backend → Pusher FCM → `PushNotificationController` → `AwesomeNotificationService` → display. Deep-link navigation uses `MyApp.navigatorKey` (static context).

5 channels by priority: `booking_channel` (max) > `payment_channel` (high) > `chat_channel` (default) > `promo_channel` (low) > `scheduled_channel` (high, reminders).

### Logging
Use `developer.log()` for complex flow tracing and `log.i()` / `log.e()` from `basic_import.dart`. Never use `print()`.

## Known Issues & Fixes

- **NEVER use `Get.back()`**: Always use `Navigator.of(context).pop()` instead. `Get.back()` internally calls `closeCurrentSnackbar`, which accesses a `late AnimationController` that may not be initialized yet, causing `LateInitializationError` on `SnackbarController._controller`. This applies to ALL screens, not just specific ones.
- **`RefreshIndicator` not animating**: Do NOT use `BouncingScrollPhysics` inside a `CustomScrollView` wrapped with `RefreshIndicator`. Use `AlwaysScrollableScrollPhysics()` instead.
- **NDK conflicts**: Clear with `Remove-Item -Recurse $env:LOCALAPPDATA\Android\sdk\ndk\*`
- **API 401 errors**: Verify Bearer token is present in request headers.

## Screen-Specific Notes

### Congratulations Screen (`lib/views/congratulations/`)
- `CongratulationsButton` widget has two buttons stacked vertically:
  1. **"My Booking"** (top) — red primary button → navigates with `Get.offAllNamed(Routes.dashboardScreen)` then `Get.toNamed(Routes.historyScreen)` so back from history lands on dashboard
  2. **"Home"** (bottom) — white outlined button with red border → `Get.offAllNamed(controller.route.value)`
- `Strings.myBooking` (`appLMyBooking`) added to `strings.dart` and both EN/AR translations in `app_translations.dart`

### Booking Screen (`lib/views/booking/widget/booking_all_fields.dart`)
- `_deliveryAvailabilityBadge()` method and its call/condition have been removed from `_deliveryToggleCard`
- `_deliveryStatusBanner()` and `_statusBannerRow()` methods have been removed; the `Obx` block that called `_deliveryStatusBanner` inside `_deliveryLocationCard` is also removed

### Shared Car Summary Card (`lib/views/booking/widget/car_summary_card.dart`)
- `CarSummaryCard` is a shared public widget (takes a `CarItem`) used in both the booking and preview hero headers
- The old private `_CarSummaryCard` in `booking_mobile_screen.dart` and `_PreviewCarSummaryCard` in `preview_mobile_screen.dart` have been removed
- Preview screen imports it from `package:carbo/views/booking/widget/car_summary_card.dart` and calls `CarSummaryCard(car: Get.find<BookingController>().selectedCar)` directly — no `Builder` needed since `BookingController` is always registered before navigation to preview

### Booking Details Screen (`lib/views/booking_details/screen/booking_details_screen.dart`)
- **Completely redesigned** from flat layout to modern card-based UI using Carbo Design System tokens exclusively
- **Hero animation**: Car image wrapped in `Hero(tag: 'car_hero_${booking.id}')` — matches the Hero in `HistoryCard` for smooth transition from history list to details
- **Red gradient header** (`CarboGradients.primary`) — compact bar with back button and "Booking Details" title only (no car info)
- **4 separated cards**:
  1. **Car Info Card** (`_CarInfoCard`) — Hero car image (160px, BoxFit.contain) on top, divider, then row with car icon, title, year, and `_StatusBadge` pill. Moved out of header into SliverList as first card
  2. **Booking Info Card** (`_BookingInfoCard`) — pickup date/time, round trip (with length guard on `roundPickupDate.toString()` to prevent `RangeError`), delivery type with chip badge, location, payment type, transaction ID
  3. **Price Breakdown Card** (`_PriceBreakdownCard`) — rental fees, charges, delivery fee, subtotal, tax, gradient total bar (same pattern as preview screen `_PricingCard`)
  4. **Vehicle Info Card** (`_VehicleInfoCard`) — car model, year, seats, daily rate, car number (uses `vendorId`-related car data since API only returns vendor ID, not name)
- **Note card** (`_NoteCard`) — info-style card shown only when `booking.message` is not empty
- **Cancel booking dialog** — redesigned from `Get.defaultDialog` to a modern `showModalBottomSheet` with `_CancelConfirmSheet`: errorBg header with circular close icon, headline in error red, centered confirmation text, side-by-side "Keep Booking" (outlined) and "Yes, Cancel" (solid error red) buttons
- **Reusable private widgets**: `_SectionCard`, `_DetailRow`, `_PricingRow`, `_DeliveryDetailRow` — same patterns as preview screen
- **Status badge colors** match `HistoryCard`: pending=warning, ongoing=info, completed=success, default=error
- No AppBar — uses CustomScrollView with SliverToBoxAdapter for the hero header
- Back button uses `Navigator.of(context).pop()` (not `Get.back()`) to avoid snackbar race condition

### History Card (`lib/views/history/widget/history_card.dart`)
- Car image wrapped in `Hero(tag: 'car_hero_${info.id}')` to enable hero transition to booking details screen

### String Keys Added
- `vehicleInfo`, `dailyRate`, `transactionId`, `priceBreakdown`, `charges`, `subtotal`, `bookingInfo` — added to `strings.dart` and EN/AR translations in `app_translations.dart`
- `confirmExtension`, `extendingByDays`, `additionalDays`, `newEndDate`, `ofDays`, `yesExtend`, `amountToCharge` — added for extend booking sheet in `strings.dart` and EN/AR translations in `app_translations.dart`
- `pickupTimeOutsideWorkingHours`, `branchWorkingHours` — added for validate-datetime warning banner in `strings.dart` and EN/AR translations
- `myWallet`, `availableBalance`, `topUpWallet`, `transactionHistory`, `noTransactionsYet`, `transactionHistoryEmpty`, `amountSar`, `minimumSar` — added for wallet screen i18n in `strings.dart` and EN/AR translations

### Wallet Screen (`lib/views/wallet/screen/wallet_screen.dart`)
- Transaction card title: `maxLines: 2`, `fontSize: 11.sp`, `fontWeight: FontWeight.w600`
- All strings fully translated using `Strings.xxx.tr`: `myWallet`, `availableBalance`, `topUpWallet`, `transactionHistory`, `amountSar`, `minimumSar`, `cancel`, `continuee`, `noTransactionsYet`, `transactionHistoryEmpty`

### Booking Validate-DateTime (`lib/views/booking/controller/booking_controller.dart`)
- Auto-validates pickup datetime on `POST /api/v1/user/car-booking/validate-datetime` when both date AND time are selected (300ms debounce)
- Uses direct `http.post` (not `ApiServices`) to parse non-200 responses (e.g., branch closed returns error status)
- `forcePickupFromBranch` getter updated: returns `true` when `dateTimeValidation.value?.isValid == false`
- `developer.log` logging for URL, body, status code, response, parsed result
- Model: `DateTimeValidationResult` at `lib/models/datetime_validation_result.dart`
- Endpoint: `ApiEndpoint.validateDateTime` in `lib/base/api/endpoint/api_endpoint.dart`

### Booking Delivery Toggle (`lib/views/booking/widget/booking_all_fields.dart`)
- Three states: (1) validating → `CircularProgressIndicator`, (2) invalid → red pill badge "Delivery Not Available", (3) valid → normal `Switch`
- Warning banner below toggle row when invalid: shows day name + hours (or just day name if branch has no hours)

### Extend Booking Bottom Sheet (`lib/views/booking_details/widget/extend_booking_bottom_sheet.dart`)
- **Fully redesigned** with hero counter widget, animated preview card, skeleton loader, and confirm sheet — all Carbo DS tokens exclusively
- **Counter**: `RxInt days` (1–365), `increment()`/`decrement()` with 800ms debounce before API preview fetch. `isPending` flag shows spinner while waiting.
- **Animated counter number**: `_AnimatedCounterNumber` — `AnimatedSwitcher` + `SlideTransition` direction-aware (slide up for increment, slide down for decrement)
- **Progress bar**: `LayoutBuilder` + `AnimatedContainer` for proportional fill (days/365)
- **Skeleton loader**: `_SkeletonLoader` with `AnimationController.repeat(reverse:true)` pulsing opacity while `isPreviewLoading` is true
- **Preview card**: gradient bg `#FFF5F5→#FFECEC`, red left-border strip, rows for additional days / new end date / daily rate / amount; gradient total pill at bottom
- **Confirm sheet**: `_ExtendConfirmSheet` via `showModalBottomSheet` — `CarboColors.primaryLight` header, summary, Cancel + "Yes, Extend" buttons
- **`VoidCallback onClose`**: sheet passes `() => Navigator.of(context).pop()` to `controller.confirmExtension(onClose)` — controller never stores `BuildContext`, no `Get.back()`

### 16 KB Memory Page Size (Google Play requirement)
- Root cause of Play rejection was `libmlkit_google_ocr_pipeline.so` (4KB ELF-aligned) bundled by ML Kit text-recognition `16.0.0`
- Fixed by bumping all four `com.google.mlkit:text-recognition-*` deps to `16.0.1` in `android/app/build.gradle` — do NOT downgrade them
- Toolchain already compliant: AGP 8.9.1 (≥8.5.1), Gradle 8.11.1, Flutter 3.38 engine (64KB-aligned libflutter.so/libapp.so); 32-bit armeabi-v7a libs are not checked by Play
- Verify after build: check ELF `p_align >= 0x4000` for all arm64-v8a/x86_64 `.so` entries in the AAB (Play Console → App Bundle Explorer shows "Supports 16 KB")
- Local release bundle `build/app/outputs/bundle/release/app-release.aab` verified on 2026-10-14: all arm64-v8a and x86_64 ELF LOAD segments are aligned at 16 KB or greater. This confirms that bundle only; publish/upload it and confirm the Play Console status to update production compliance.

## Execution Rules

- Modify only the requested code — no cleanup, refactoring, or improvements beyond scope
- Do not add comments unless explicitly asked
- Do not add extra logic, error handling, or features beyond what was requested
- always update CLAUDE.md after finish session