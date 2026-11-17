# Copilot Instructions for Carbo App

## Project Overview
**Carbo** is a Flutter car rental booking application with real-time notifications, KYC verification, and wallet payments. Built with **GetX** for state management, **Pusher Beams** for push notifications, and **Awesome Notifications** for rich in-app alerts.

---

## Architecture & Core Patterns

### State Management: GetX
The entire app uses **GetX** reactivity. Controllers inherit `GetxController`:
```dart
class DashboardController extends GetxController {
  RxString selectedDate = ''.obs;        // Observable string
  RxBool isLoading = false.obs;          // Observable boolean
  RxList<CarItem> cars = <CarItem>[].obs; // Observable list
  
  void updateDate(String newDate) {
    selectedDate.value = newDate;
  }
}
```

**UI subscribes with Obx:**
```dart
Obx(() => Text(controller.selectedDate.value))
```

### Dependency Injection via Bindings
Each screen has a **Binding** that registers controllers. Located in `lib/bindings/`:
```dart
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.put(PushNotificationController());  // Immediate injection
  }
}
```

### Navigation with Named Routes
Routes defined in `lib/routes/routes.dart`. Use Get navigation:
```dart
Get.toNamed(Routes.bookingScreen, arguments: {'car': selectedCar});
Navigator.of(context).pop();  // Never use Get.back()
```

---

## API & Data Flow

### Request Pattern: `RequestProcess` → `ApiServices`
All API calls use this pattern in `lib/base/api/method/request_process.dart`:

```dart
final result = await RequestProcess().request<BookingModel>(
  fromJson: (json) => BookingModel.fromJson(json),
  apiEndpoint: ApiEndpoint.bookingPreview,
  isLoading: isLoading,
  method: HttpMethod.POST,
  body: {'car_id': '123', 'days': 5},
  onSuccess: (booking) {
    // Handle success
  },
);
```

**Key points:**
- Generic `<T>` typing for automatic deserialization
- Always pass `isLoading` RxBool to manage UI loading state
- `onSuccess` callback for business logic
- Errors auto-handled via `CustomSnackBar.error()`

### Multipart File Uploads (KYC, Images)
For file uploads use `multipartApiService`:
```dart
final result = await RequestProcess().request<IdentificationModel>(
  fromJson: (json) => IdentificationModel.fromJson(json),
  apiEndpoint: ApiEndpoint.nationalIdUpload,
  isLoading: isLoading,
  method: HttpMethod.POST,
  body: {'user_id': '123'},
  fieldList: ['national_id'],        // Form field name
  pathList: ['/path/to/image.jpg'],  // File path
  onSuccess: (model) {
    // Update UI
  },
);
```

### API Endpoints
Located in `lib/base/api/endpoint/api_endpoint.dart`. Add new endpoints as:
```dart
class ApiEndpoint {
  static String get bookingPreview => '${baseUrl}car/booking/preview';
  static String get nationalIdUpload => '${baseUrl}user/identification/national-id/upload';
}
```

---

## Notifications System

### Dual Notification Architecture
The app uses **two** notification systems:

1. **Pusher Beams** - Remote push from backend
2. **Awesome Notifications** - Rich UI with buttons, deep linking

**Flow:** Backend → Pusher FCM → `PushNotificationController` → `AwesomeNotificationService` → Display

### Pusher Setup
- Configured in `lib/initializer.dart` (Android only, iOS skipped pending APNs)
- Controller in `lib/backend/services/push_notification_controller.dart`

### Awesome Notifications
Rich notification service in `lib/backend/services/awesome_notification_service.dart`:

```dart
// Create from Pusher message
await AwesomeNotificationService.createNotificationFromPusher(
  title: 'Booking Confirmed',
  body: 'Your booking is ready',
  type: 'booking',
  bookingId: '123',
  channelKey: NotificationChannels.bookingChannel,
);

// Handle taps via deep linking
onActionReceivedMethod() -> Navigate using MyApp.navigatorKey
```

**5 Notification Channels** (by priority):
- `booking_channel` - Max (urgent updates)
- `payment_channel` - High
- `chat_channel` - Default
- `promo_channel` - Low (promotions)
- `scheduled_channel` - High (reminders)

### Scheduled Notifications
Use `ScheduledNotifications` helper for recurring alerts:
```dart
await ScheduledNotifications.scheduleBookingReminder(
  bookingId: '123',
  bookingDateTime: DateTime(2026, 2, 15, 10, 0),
  carName: 'Tesla Model S',
  pickupLocation: 'Dubai Mall',
);  // Fires 1 hour before
```

---

## Key File Structure

```
lib/
├── main.dart                    # App entry, MyApp widget with navigator key
├── initializer.dart             # App startup, notification init
├── backend/
│   ├── model/                   # Data models (car_booking/)
│   └── services/                # API services, notifications, Pusher integration
├── base/
│   ├── api/
│   │   ├── endpoint/            # ApiEndpoint class definitions
│   │   ├── method/              # RequestProcess, ApiMethod
│   │   └── services/            # ApiServices (generic HTTP)
│   └── utils/                   # Helpers, logging
├── bindings/                    # GetX dependency injection per screen
├── languages/                   # i18n: English & Arabic
├── res/                         # Themes, strings, colors
├── routes/                      # Named route definitions, route pages
└── views/
    ├── auth/                    # Login, Register, OTP, Password reset
    ├── booking/                 # Booking form & controller
    ├── cars/                    # Car list display
    ├── kyc/                     # KYC verification (national ID upload)
    │   ├── controller/
    │   ├── model/
    │   ├── service/             # KycService for ID uploads
    │   └── screen/
    ├── preview/                 # Booking preview (pricing calc)
    ├── product_details/         # Car detail view
    ├── notification/            # Notification UI
    ├── history/                 # Booking history
    └── dashboard/               # Home screen with car list
```

---

## Key Workflows

### Booking Flow (Dashboard → Booking → Preview → Confirm)
1. **Dashboard**: Lists cars, user selects car + date/time
2. **Booking Screen**: User inputs rental days, pickup location, notes
3. **Preview Screen**: Calls `/car/booking/preview` API, shows pricing breakdown
4. **Confirm**: Calls `/car/booking/confirm`, proceeds to payment

**Data passing via Get.arguments:**
```dart
Get.toNamed(Routes.bookingScreen, arguments: {
  'car': selectedCarItem,
  'date': selectedDate,
  'time': selectedTime,
});
```

### KYC Verification Workflow
- **KyC Screen** collects national ID + driving license images
- **KycService** uploads to backend via multipart
- **IdentificationModel** tracks upload status
- **KycController** manages reactive state

---

## Model Pattern & JSON

All models use `fromJson`/`toJson` factory pattern:

```dart
class BookingModel {
  final String id;
  final String carId;
  final int rentalDays;

  BookingModel({
    required this.id,
    required this.carId,
    required this.rentalDays,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] ?? '',
    carId: json['car_id'] ?? '',
    rentalDays: json['rental_days'] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'car_id': carId,
    'rental_days': rentalDays,
  };
}
```

**Important:** Response from API is wrapped in `data` field:
```json
{
  "data": { ... model json ... },
  "message": "Success",
  "type": "success"
}
```

The `ApiServices._handleResponse()` automatically extracts `json['data']` before passing to `fromJson()`.

---

## Internationalization (i18n)

App supports **English & Arabic** with RTL support:

```dart
// Access translated strings
Text(Strings.appName)        // From AppTranslations
Text('key_name'.tr)          // GetX inline translation

// Get current language
LocaleService.to.currentLanguageCode    // 'en' or 'ar'
LocaleService.to.textDirection          // TextDirection.ltr or rtl
```

Strings defined in `lib/languages/app_translations.dart`.

---

## Build, Debug & Common Issues

### Build Commands
```bash
flutter clean; flutter pub get           # Fresh start
cd android; ./gradlew clean --no-daemon  # Android cache
flutter run                              # Debug on device
flutter build apk --release              # Production APK
```

### Firebase & Notifications
- **Google Services**: `android/app/google-services.json` (committed)
- **Pusher Beams**: Configured in `initializer.dart`, iOS disabled (no APNs)
- **Awesome Notifications**: Requires AndroidManifest.xml permissions (vibrate, boot_completed, schedule_exact_alarm)

### Common Fixes
- **NDK conflicts**: Cleared via `Remove-Item -Recurse $env:LOCALAPPDATA\Android\sdk\ndk\*`
- **Manifest package errors**: Fixed pusher_beams_android manifest via post-processing
- **API 401 Unauthorized**: Verify Bearer token in headers
- **NEVER use `Get.back()`**: Always use `Navigator.of(context).pop()` instead. GetX's `Get.back()` internally calls `closeCurrentSnackbar`, which accesses a `late AnimationController` that may not be initialized yet (race condition when a snackbar is mid-queue), causing `LateInitializationError`. This rule applies globally to ALL screens and widgets — not just specific ones.
- **RefreshIndicator not animating (pull-to-refresh stuck)**: Do NOT use `BouncingScrollPhysics` (or `BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())`) inside a `CustomScrollView` wrapped with `RefreshIndicator`. Bouncing physics suppresses the overscroll that `RefreshIndicator` needs. Use `AlwaysScrollableScrollPhysics()` instead:
  ```dart
  // WRONG - refresh indicator will not animate
  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),

  // CORRECT
  physics: const AlwaysScrollableScrollPhysics(),
  ```

---

## Logging Best Practices

Use injected logger for debugging — `developer.log` for complex flow tracing:

```dart
import 'dart:developer' as developer;

developer.log('KYC upload started', name: 'kyc_service');
log.i('Info message with value: $value');   // From basic_import
log.e('🐞 Error detail: $error');           // Emojis for visibility
```

**Never** use `print()` in production code. Use `log.d()` for debug.

---

## Important Notes for AI Agents

1. **Always use GetX reactive variables** (`Rx<T>`, `.obs`, `.value`) rather than setState for state management
2. **Controllers are long-lived** — logic goes in controllers, not widgets
3. **Bindings must be registered** for each screen before navigation
4. **API errors are auto-handled** — no need for explicit try-catch in business logic
5. **Image uploads require multipart** — use `fieldList`/`pathList` parameters in RequestProcess
6. **Deep linking for notifications** — use `MyApp.navigatorKey` from static context
7. **Models must have fromJson factory** — automatic deserialization requires this
8. **All API endpoints follow pattern** — `/api/v1/{resource}/{action}`
9. **RTL support is automatic** — use `LocaleService.to.textDirection` in Directionality widget
10. **Permissions are runtime on Android 13+** — `AwesomeNotifications.requestPermissionToSendNotifications()`
11. **Always use the Carbo Design System** — import and use `carbo_ds.dart` for ALL UI work. Never hardcode colors, spacing, radius, shadows, typography, durations, gradients, or icons inline. Use the tokens below:

```dart
import 'package:carbo/base/design_system/carbo_ds.dart';

// Colors
CarboColors.primary          // #E93A3A brand red
CarboColors.surface          // white card background
CarboColors.background       // #F7F8F8 scaffold bg
CarboColors.textPrimary      // #1D1D1D
CarboColors.textSecondary    // #8F9396
CarboColors.credit           // #21C77B money in
CarboColors.debit            // #E93A3A money out

// Radius
CarboRadius.mdAll            // 12 — inputs, chips
CarboRadius.lgAll            // 16 — cards
CarboRadius.xxlAll           // 32 — hero sections
CarboRadius.fullAll          // pill shape

// Spacing (plain doubles, NOT .w/.h)
CarboSpacing.x4              // 16 — standard padding
CarboSpacing.x5              // 20 — horizontal screen margin
CarboSpacing.x6              // 24 — section gaps

// Shadows
CarboShadow.soft             // subtle lift
CarboShadow.card             // standard card shadow
CarboShadow.floating         // FAB / bottom sheet
CarboShadow.primaryGlow      // red glow on primary buttons

// Typography (runtime getters — use inside build() only)
CarboTypography.titleLarge   // screen titles
CarboTypography.bodyMedium   // body text
CarboTypography.labelSmall   // timestamps, captions
CarboTypography.buttonLabel  // white button text

// Gradients
CarboGradients.primary       // red → dark red (horizontal)
CarboGradients.primaryVertical

// Durations
CarboDuration.normal         // 200ms standard animation
CarboDuration.fast           // 150ms micro interaction

// Icons
CarboIcons.wallet
CarboIcons.topUp
CarboIcons.transaction
CarboIcons.back
CarboIcons.car
```

---

## Screen-Specific Notes

### Booking Details Screen (`lib/views/booking_details/screen/booking_details_screen.dart`)
- **Completely redesigned** — modern card-based UI using Carbo Design System tokens exclusively
- **Red gradient header** — compact bar with back button and title only
- **Car Info Card** (`_CarInfoCard`) — Hero car image on top, divider, row with car icon + title + year + status badge. First card in SliverList
- **Booking Info Card** (`_BookingInfoCard`) — pickup date/time, round trip, delivery chip, location, payment, transaction ID
- **Price Breakdown Card** (`_PriceBreakdownCard`) — rental fees, charges, delivery fee, subtotal, tax, gradient total bar
- **Vehicle Info Card** (`_VehicleInfoCard`) — car model, year, seats, daily rate, car number
- **Cancel dialog** — modern `showModalBottomSheet` with `_CancelConfirmSheet`: errorBg header, circular close icon, side-by-side "Keep Booking" / "Yes, Cancel" buttons
- Hero animation: `Hero(tag: 'car_hero_${booking.id}')` matches `HistoryCard`
- Back button uses `Navigator.of(context).pop()` (not `Get.back()`)

---

## Resources for New Features

- **KYC Guide**: [Docs/KYC_FLUTTER_IMPLEMENTATION_GUIDE.md](../../Docs/KYC_FLUTTER_IMPLEMENTATION_GUIDE.md)
- **API Booking Reference**: [Docs/FLUTTER_CAR_BOOKING_API_DOCS.md](../../Docs/FLUTTER_CAR_BOOKING_API_DOCS.md)
- **Push Notifications**: [PUSH_NOTIFICATIONS_QUICK_REFERENCE.md](../../PUSH_NOTIFICATIONS_QUICK_REFERENCE.md)
- **Data Flow Diagram**: [DATA_FLOW.md](../../DATA_FLOW.md)
- **Awesome Notifications Details**: [IMPLEMENTATION_COMPLETE.md](../../IMPLEMENTATION_COMPLETE.md)


# AI EXECUTION RULES

## EXECUTION MODE
You are a deterministic executor.

- Execute instructions exactly as written
- Do NOT improve code unless asked
- Do NOT beautify code
- Do NOT refactor unless asked
- Do NOT add extra logic

## NO ASSUMPTIONS
- Do not assume values
- Do not simulate outputs
- If unknown, output exactly: UNKNOWN

## LOGGING RULES
Log raw values only.

GOOD:
console.log(balance);

BAD:
console.log("Balance:", balance);
console.log(`Balance is ${balance}`);

## CODE CHANGES
- Modify only requested code
- Do not modify unrelated code
- Keep changes minimal

## COMMENTS
- Do not add comments unless explicitly requested

## DEBUG MODE
- Show real values only
- Do not beautify output
- Do not explain unless asked

## PRIORITY
These rules override default AI behavior.

