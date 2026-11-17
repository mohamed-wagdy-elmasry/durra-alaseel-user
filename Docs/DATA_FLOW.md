# Data Flow: Dashboard → Booking → Preview → Confirm

## Architecture Overview

```
Dashboard Screen
       ↓
  [User selects car, date, time]
       ↓
Booking Screen
       ↓
  [User fills pickup location, rental days, notes]
       ↓
Preview Screen (Calls Booking Preview API)
       ↓
  [Display pricing breakdown, payment options]
       ↓
Booking Confirm (Calls Booking Confirm API)
       ↓
Payment Screen / Web Payment / Cash Booking
```

---

## 1. DASHBOARD → BOOKING

### Dashboard Controller (`dashboard_controller.dart`)
**Purpose**: Fetch user info, available areas, car types, branches, and car token

**Key Data Stored**:
```dart
RxString selectedDate = ''.obs;          // Selected pickup date
RxString selectedTime = ''.obs;          // Selected pickup time
RxString carToken = ''.obs;              // Auth token for booking API
RxString userFullName = ''.obs;          // User name
RxString userEmail = ''.obs;             // User email
List<CarItem> cars = [];                 // Available cars list
List<Datum> areaList = [];               // Available areas
List<String> typeList = [];              // Car types
List<BranchModel> branchList = [];       // Branches for pickup
```

### Navigation to Booking
```dart
// User taps a car from the list
// Passes car data via Get.arguments
Get.to(
  () => BookingScreen(),
  arguments: {
    'car': selectedCarItem,  // CarItem with id, model, price, etc.
  }
);
```

---

## 2. BOOKING SCREEN

### Booking Controller (`booking_controller.dart`)
**Purpose**: Collect booking details from user

**Data Received from Dashboard**:
```dart
late CarItem selectedCar;           // From Get.arguments
RxString carFee = '0'.obs;          // From selectedCar.fees
```

**Data Collected from User Input**:
```dart
dateController                      // Pickup date (from dashboard)
timeController                      // Pickup time (from dashboard)
rentalDaysController               // Number of rental days (USER INPUT)
noteController                      // Special notes (USER INPUT)
Rx<PickupLocation?> pickupLocation // Selected pickup location (USER INPUT)
RxString selectedRoundDate = ''     // Return date for round trip
RxString selectedRoundTime = ''     // Return time for round trip
```

**Validation**:
```dart
isFormValid = 
  - hasValidPickupLocation (from branch OR custom location)
  - hasValidRentalDays (> 0)
  - hasPickupDate (not empty)
  - hasPickupTime (not empty)
```

### Navigation to Preview
```dart
// User taps "Proceed to Booking"
// Booking controller data remains in memory
// Preview controller accesses it via Get.find<BookingController>()
Get.to(() => PreviewScreen());
```

---

## 3. BOOKING PREVIEW SCREEN

### Preview Controller (`preview_controller.dart`)

**Data Collected from Other Controllers**:
```dart
// From BookingController:
final bookingController = Get.find<BookingController>();
String carId = bookingController.selectedCar.id.toString();
String carSlug = bookingController.getCarSlug();
String rentalDays = bookingController.rentalDaysController.text;
String pickupDate = bookingController.selectedPickupDate.value;
String pickupTime = bookingController.selectedPickupTime.value;
PickupLocation pickupLocation = bookingController.pickupLocation.value;

// From DashboardController:
final dashboardController = Get.find<DashboardController>();
String token = dashboardController.carToken.value;
```

### API Call: GET /api/v1/user/car-booking/preview
```dart
// Query Parameters sent to backend:
Map<String, String> queryParams = {
  'token': token,                          // Auth token from dashboard
  'car_id': carId,                         // From selected car
  'rental_days': rentalDays,               // Days from booking form
  'pickup_date': pickupDate,               // Date from booking form
  'pickup_time': pickupTime,               // Time from booking form
  'pickup_location[latitude]': latitude,   // Location from booking form
  'pickup_location[longitude]': longitude,
  'pickup_location[address]': address,
};
```

### API Response: BookingPreviewModel
```dart
BookingPreviewModel {
  List<String> message,
  String type,
  Data {
    String token,                          // NEW: Session token for confirmation
    BookingDetails bookingDetails {        // Echo of booking params
      int carType,
      String pickupDate,
      String pickupTime,
      int rentalDays,
      PickupLocationData pickupLocation,
      String? roundPickupDate,
      String? roundPickupTime,
    },
    String bookingCurrency,                // e.g., "USD"
    
    Car car,                               // Full car details
    User user,                             // Current user info
    UserBalance userBalance,               // User's wallet balance
    DeliveryInfo deliveryInfo,             // Delivery availability & price
    
    PricingBreakdown pricingBreakdown {    // ⭐ KEY DATA FOR PREVIEW
      int rentalDays,
      String rentalFees,                   // e.g., "750.00"
      String deliveryPrice,                // e.g., "50.00"
      String charges,                      // Additional fees
      String subtotal,                     // Before tax
      double taxPercentage,                // e.g., 15.0
      String taxAmount,                    // e.g., "112.50"
      String total,                        // Final total
      String priceRuleApplied,             // "daily" | "weekly" | "monthly"
      double taxRate,                      // Tax rate percentage
    },
    
    PaymentType paymentType {              // Available payment methods
      String onlinePayment,                // "online-payment"
      String cash,                         // "cash"
      String balance,                      // "balance" (wallet)
    },
    
    List<PaymentGateway> paymentGateways { // Payment providers
      int id,
      String name,                         // "PayPal", "Stripe", etc.
      int status,
      List<Currency> currencies,
    },
  }
}
```

### Data Stored for Preview Display
```dart
RxDouble totalPayable = 0.0;              // From pricingBreakdown.total
RxString carModel = '';                   // From car.carModel
RxString carNumber = '';                  // From car.carNumber
RxString pickupTime = '';                 // Display user's selection
RxString slug = '';                       // From car.slug
RxString Id = '';                         // From car.id
List<PaymentGateway> paymentGatewayList;  // Available payment options
```

### Preview Screen Display
```
✅ Pickup Location: [From BookingController]
✅ Pickup Date: [From BookingController]
✅ Pickup Time: [From BookingController]
✅ Car Model: [From Preview API]
✅ Car Number: [From Preview API]
✅ Rental Days: [From PricingBreakdown]
✅ Rental Fees: [From PricingBreakdown]
✅ Delivery: [From PricingBreakdown]
✅ Tax (15%): [From PricingBreakdown]
✅ TOTAL: [From PricingBreakdown.total]

Payment Method Selection:
  - 💳 Online Payment (Gateway selection)
  - 💰 Cash
  - 💵 Wallet Balance
```

### Navigation to Confirm
```dart
// User selects payment method and taps "Confirm Booking"
// Calls controller.handlePaymentProcess()
Get.to(() => PaymentScreen()); // Or WebPaymentScreen / CashScreen
```

---

## 4. BOOKING CONFIRM SCREEN

### API Call: POST /api/v1/user/car-booking/confirm
```dart
// Body sent to backend:
Map<String, dynamic> inputBody = {
  // Booking Details (from BookingController)
  'pickup_location': pickupLocation.toJson(),
  'rental_days': rentalDaysController.text,
  'message': noteController.text,
  'pickup_time': selectedPickupTime.value,
  'pickup_date': selectedPickupDate.value,
  'round_pickup_time': selectedRoundTime.value,
  'round_pickup_date': selectedRoundDate.value,
  
  // User Info (from LocalStorage)
  'mobile': LocalStorage.number,
  'credentials': LocalStorage.email,
  
  // Car Info (from BookingController)
  'car_slug': carSlug,
  'car_id': carId,
  
  // Payment Info (from Preview selection)
  'gateway_type': paymentTypes.value,              // Gateway ID
  'gateway_currency': alias.value,                 // Currency alias
  'payment': selectedMethodText,                   // "cash" | "online-payment" | "balance"
  
  // Session (from Preview API response)
  'token': dashboardController.carToken.value,    // Auth token
};
```

### API Response: BookingConfirmModel
```dart
BookingConfirmModel {
  String message,
  String type,
  Data {
    String identifier,                    // For payment processing
    String bookingNumber,                 // Booking reference
    // ... other confirmation details
  }
}
```

### Next Steps
```dart
// Based on payment method:
if (alias.value.contains('authorize')) {
  // Authorize.net payment
  Get.to(AuthorizeGatewayScreen());
} else if (payment == 'online-payment') {
  // Stripe / PayPal
  Get.to(() => WebPaymentScreen());
} else if (payment == 'cash') {
  // Cash booking - show confirmation
  Get.to(CongratulationsScreen());
}
```

---

## Data Flow Summary Table

| Stage | Source | Key Data | Destination |
|-------|--------|----------|-------------|
| **Dashboard** | API `/dashboard-info` | token, userInfo, carList, areas, branches | Memory (DashboardController) |
| **Booking** | User Input | selectedCar, pickupDate, pickupTime, rentalDays, pickupLocation, notes | Memory (BookingController) |
| **Preview API** | GET `/preview` | Params from Booking + Dashboard token | BookingPreviewModel |
| **Preview** | Preview API Response | pricingBreakdown, paymentGateways, userBalance | Display + Memory (PreviewController) |
| **Confirm API** | POST `/confirm` | All booking + preview + payment info | BookingConfirmModel |
| **Payment** | Confirm API Response | identifier, bookingNumber | Payment Gateway / Confirmation |

---

## Key Objects Flow

```
CarItem (Dashboard)
  ├─ id, model, price, area, type, slug
  └─→ BookingController.selectedCar

BookingDetails (User Input in Booking)
  ├─ pickupDate, pickupTime
  ├─ rentalDays, pickupLocation
  ├─ roundDate, roundTime, notes
  └─→ Used in Preview & Confirm APIs

BookingPreviewModel (API Response)
  ├─ BookingDetails (echo)
  ├─ Car (full details)
  ├─ PricingBreakdown ⭐
  ├─ PaymentGateways
  └─→ Display in Preview Screen

BookingConfirmModel (API Response)
  ├─ identifier (payment use)
  ├─ bookingNumber
  └─→ Redirect to Payment Gateway
```

---

## Important Notes

✅ **Data Persistence**: 
- Dashboard data persists while user navigates to Booking → Preview
- BookingController data stays in memory until booking is confirmed
- PreviewController accesses both via `Get.find()`

✅ **API Tokens**:
- `carToken` from Dashboard is used in both Preview & Confirm APIs
- Ensures authenticated requests

✅ **Location Handling**:
- User can pick location from branch OR enter custom location
- Sent as latitude/longitude/address array to backend

✅ **Payment Info**:
- Selected in Preview screen
- Sent with Confirm API call
- Determines post-booking redirect (gateway URL, cash confirmation, etc.)

✅ **Pricing Calculation**:
- Calculated by BACKEND based on rentalDays & pricing rules
- Not calculated locally in app
- Includes daily/weekly/monthly tier adjustments
- Includes tax & delivery fees
