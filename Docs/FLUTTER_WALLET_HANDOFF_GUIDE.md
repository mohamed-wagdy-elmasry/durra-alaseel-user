# Flutter Wallet System — Complete Integration Handoff Guide

> Stack: Flutter (GetX) · Laravel REST API · Moyasar payments · Pusher Beams + Awesome Notifications
> Date: 2026-03-08
> Status: Production-ready

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [API Overview](#2-api-overview)
3. [Get Wallet Balance](#3-get-wallet-balance)
4. [Wallet Transactions](#4-wallet-transactions)
5. [Wallet Topup](#5-wallet-topup)
6. [Payment Webhook (Backend Only)](#6-payment-webhook-backend-only)
7. [Booking Wallet Deduction](#7-booking-wallet-deduction)
8. [Booking Refund to Wallet](#8-booking-refund-to-wallet)
9. [Payment Refund to Card (Moyasar)](#9-payment-refund-to-card-moyasar)
10. [Wallet Notifications](#10-wallet-notifications)
11. [Error Responses](#11-error-responses)
12. [Flutter Integration Flow](#12-flutter-integration-flow)
13. [Mobile Integration Checklist](#13-mobile-integration-checklist)
14. [Backend Safety Rules](#14-backend-safety-rules)

---

## 1. System Overview

The wallet is created automatically when a user registers.
All financial operations go through the `balance_transactions` ledger on the backend.

The wallet supports:

| Feature | Trigger |
|---|---|
| View balance | On wallet screen open |
| Topup | User action → Moyasar invoice |
| Booking deduction | Auto on booking confirmation (payment method: `balance`) |
| Refund to wallet | Auto on booking cancel or vendor rejection |
| Refund to card | User or admin action via Moyasar |

**Response envelope used by all APIs in this app:**

```json
{
  "message": { "success": ["..."] },
  "data": {},
  "type": "success"
}
```

Error envelope:

```json
{
  "message": { "error": ["..."] },
  "data": [],
  "type": "error"
}
```

> The `ApiServices._handleResponse()` helper already extracts `json['data']` before passing it to `fromJson()`. All models in this guide are written accordingly.

---

## 2. API Overview

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/api/v1/user/wallet` | GET | Bearer | Get wallet balance + recent transactions |
| `/api/v1/user/wallet/transactions` | GET | Bearer | Paginated transaction history |
| `/api/v1/user/wallet/recharge` | POST | Bearer | Create Moyasar invoice for topup |
| `/api/webhooks/moyasar` | POST | Secret | Moyasar webhook (Flutter does NOT call) |
| `/api/v1/user/car-booking/confirm` | POST | Bearer | Confirms booking; deducts if payment=`balance` |
| `/api/v1/user/car-booking/cancel` | POST | Bearer | Cancel booking + auto refund to wallet |
| `/api/v1/user/payments/{paymentId}/refund` | POST | Bearer | Refund a card payment via Moyasar |

**Common headers for all authenticated requests:**

```http
Authorization: Bearer <token>
Accept: application/json
Content-Type: application/json
```

---

## 3. Get Wallet Balance

### Endpoint

```
GET /api/v1/user/wallet
```

### Success Response

```json
{
  "message": { "success": ["Wallet data fetched successfully"] },
  "data": {
    "wallet_id": 1,
    "balance": "250.00",
    "currency": "SAR",
    "updated_at": "2026-03-01T10:00:00Z",
    "recent_transactions": [
      {
        "id": 15,
        "trx_id": "BAL-8K3P1XQZ0M",
        "type": "recharge",
        "amount": "100.00000000",
        "balance_before": "150.00000000",
        "balance_after": "250.00000000",
        "reference_type": "App\\Models\\PaymentTransaction",
        "reference_id": 22,
        "description": "Wallet recharge via Moyasar",
        "created_at": "2026-03-01T10:00:00.000000Z"
      }
    ]
  },
  "type": "success"
}
```

### Error Cases

| Code | Cause |
|---|---|
| 401 | Unauthenticated (missing or expired token) |
| 500 | Unexpected backend failure |

### Dart Model — `WalletModel`

File: `lib/views/wallet/model/wallet_model.dart`

```dart
class WalletModel {
  final int walletId;
  final double balance;
  final String currency;
  final String updatedAt;
  final List<WalletTransaction> recentTransactions;

  WalletModel({
    required this.walletId,
    required this.balance,
    required this.currency,
    required this.updatedAt,
    required this.recentTransactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final rawTransactions = data['recent_transactions'] as List?;
    return WalletModel(
      walletId: _asInt(data['wallet_id'], fallback: 0),
      balance: _asDouble(data['balance'], fallback: 0.0),
      currency: _asString(data['currency'], fallback: 'SAR'),
      updatedAt: _asString(data['updated_at']),
      recentTransactions: rawTransactions
              ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
```

### Controller Call — `WalletController.fetchWallet()`

File: `lib/views/wallet/controller/wallet_controller.dart`

```dart
Future<void> fetchWallet() async {
  await RequestProcess().request<WalletModel>(
    fromJson: WalletModel.fromJson,
    apiEndpoint: ApiEndpoint.walletBalance,   // path: /user/wallet
    isLoading: isLoading,
    onSuccess: (value) {
      walletModel.value = value;
    },
  );
}
```

### UI Display

```dart
// Reactive balance card
Obx(() {
  final wallet = controller.walletModel.value;
  if (controller.isLoading.value && wallet == null) {
    return const CircularProgressIndicator();
  }
  return Column(
    children: [
      Text(
        '${wallet?.balance.toStringAsFixed(2) ?? '0.00'} ${wallet?.currency ?? 'SAR'}',
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      Text('Last updated: ${wallet?.updatedAt.substring(0, 10) ?? ''}'),
    ],
  );
})
```

**Refresh triggers:**
- Screen `onInit`
- Pull-to-refresh (`RefreshIndicator`)
- After payment webview closes
- On `wallet_charged` / `wallet_deducted` / `wallet_refund` notification arrival

---

## 4. Wallet Transactions

### Endpoint

```
GET /api/v1/user/wallet/transactions?per_page=15&page=1
```

### Success Response

```json
{
  "message": { "success": ["Transactions fetched successfully"] },
  "data": {
    "transactions": [
      {
        "id": 15,
        "trx_id": "BAL-8K3P1XQZ0M",
        "type": "recharge",
        "amount": "100.00000000",
        "balance_before": "150.00000000",
        "balance_after": "250.00000000",
        "reference_type": "App\\Models\\PaymentTransaction",
        "reference_id": 22,
        "description": "Wallet topup via Moyasar",
        "created_at": "2026-03-01T10:00:00.000000Z"
      },
      {
        "id": 16,
        "trx_id": "BAL-9XQ0MK3P1Z",
        "type": "booking_deduction",
        "amount": "200.00000000",
        "balance_before": "250.00000000",
        "balance_after": "50.00000000",
        "reference_type": "App\\Models\\CarBooking",
        "reference_id": 91,
        "description": "Booking payment - TRX123456",
        "created_at": "2026-03-01T11:00:00.000000Z"
      },
      {
        "id": 17,
        "trx_id": "BAL-3P1XQZ0M9K",
        "type": "refund",
        "amount": "200.00000000",
        "balance_before": "50.00000000",
        "balance_after": "250.00000000",
        "reference_type": "App\\Models\\CarBooking",
        "reference_id": 91,
        "description": "Refund for cancelled booking - TRX123456",
        "created_at": "2026-03-02T09:15:00.000000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total": 42,
      "per_page": 15,
      "last_page": 3
    }
  },
  "type": "success"
}
```

### Transaction Types

| `type` value | Direction | Color |
|---|---|---|
| `recharge` | Credit (+) | Green |
| `refund` | Credit (+) | Green |
| `booking_deduction` | Debit (−) | Red |

### Dart Models

```dart
class WalletTransaction {
  final int id;
  final String trxId;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String referenceType;
  final int referenceId;
  final String description;
  final String createdAt;

  // true for recharge and refund; false for booking_deduction
  bool get isCredit => type == 'recharge' || type == 'refund';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _asInt(json['id']),
      trxId: _asString(json['trx_id']),
      type: _asString(json['type']),
      amount: _asDouble(json['amount']),
      balanceBefore: _asDouble(json['balance_before']),
      balanceAfter: _asDouble(json['balance_after']),
      referenceType: _asString(json['reference_type']),
      referenceId: _asInt(json['reference_id']),
      description: _asString(json['description']),
      createdAt: _asString(json['created_at']),
    );
  }
}

class WalletTransactionsModel {
  final List<WalletTransaction> transactions;
  final WalletPagination pagination;

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final rawList = data['transactions'] as List?;
    return WalletTransactionsModel(
      transactions: rawList
              ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      pagination: WalletPagination.fromJson(
          (data['pagination'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class WalletPagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  bool get hasMorePages => currentPage < lastPage;

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
      currentPage: _asInt(json['current_page'], fallback: 1),
      total: _asInt(json['total']),
      perPage: _asInt(json['per_page'], fallback: 15),
      lastPage: _asInt(json['last_page'], fallback: 1),
    );
  }
}
```

### Controller Call

```dart
Future<void> fetchTransactions({bool refresh = false}) async {
  if (refresh) {
    currentPage.value = 1;
    transactions.clear();
  }

  await RequestProcess().request<WalletTransactionsModel>(
    fromJson: WalletTransactionsModel.fromJson,
    apiEndpoint: ApiEndpoint.walletTransactions,  // path: /user/wallet/transactions
    isLoading: isTransactionsLoading,
    queryParams: {
      'per_page': '15',
      'page': currentPage.value.toString(),
    },
    onSuccess: (value) {
      transactions.addAll(value!.transactions);
      hasMorePages.value = value.pagination.hasMorePages;
      currentPage.value = value.pagination.currentPage + 1;
    },
  );
}

void loadMoreTransactions() {
  if (!isTransactionsLoading.value && hasMorePages.value) {
    fetchTransactions();
  }
}
```

### UI — Transaction List

```dart
Obx(() {
  final list = controller.transactions;

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        if (index == list.length) {
          // Load more on reaching end
          controller.loadMoreTransactions();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final tx = list[index];
        final isCredit = tx.isCredit;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isCredit
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          title: Text(tx.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(tx.createdAt.substring(0, 10)),
          trailing: Text(
            '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} SAR',
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      childCount: list.length + (controller.hasMorePages.value ? 1 : 0),
    ),
  );
})
```

**UI Guidelines:**
- Group rows by date: `Today`, `Yesterday`, `Earlier`
- Show `trx_id` in the detail sheet for customer support
- Show `balance_after` in the detail sheet as "Balance after this transaction"

---

## 5. Wallet Topup

### Flow

```
User taps "Top Up"
  └─► Flutter shows amount input dialog
        └─► POST /api/v1/user/wallet/recharge  { "amount": 150 }
              └─► Backend creates Moyasar invoice
                    └─► Flutter receives payment_url
                          └─► InAppWebView opens payment page
                                └─► User completes payment on Moyasar
                                      └─► Moyasar triggers webhook → backend credits wallet
                                            └─► Flutter polls GET /wallet every 3s (max 10 retries)
                                                  └─► Balance increased → refresh transactions
```

### Endpoint

```
POST /api/v1/user/wallet/recharge
```

### Request

```json
{
  "amount": 150
}
```

Backend validation:
- `amount` must be a positive integer
- Minimum: `10` SAR

### Success Response

```json
{
  "message": { "success": ["Invoice created successfully. Please complete payment."] },
  "data": {
    "invoice_id": "inv_93822",
    "payment_url": "https://pay.moyasar.com/invoices/xxxx",
    "expires_at": "2026-03-01T10:20:00Z",
    "amount": "150.00",
    "currency": "SAR"
  },
  "type": "success"
}
```

> `expires_at` may be absent on some backend versions. Treat as optional.

### Dart Model — `WalletRechargeModel`

```dart
class WalletRechargeModel {
  final String invoiceId;
  final String paymentUrl;
  final String expiresAt;
  final double amount;
  final String currency;

  factory WalletRechargeModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return WalletRechargeModel(
      invoiceId: _asString(data['invoice_id']),
      paymentUrl: _asString(data['payment_url']),
      expiresAt: _asString(data['expires_at']),
      amount: _asDouble(data['amount']),
      currency: _asString(data['currency'], fallback: 'SAR'),
    );
  }
}
```

### Controller Call

```dart
Future<WalletRechargeModel?> recharge(int amount) async {
  WalletRechargeModel? result;
  await RequestProcess().request<WalletRechargeModel>(
    fromJson: WalletRechargeModel.fromJson,
    apiEndpoint: ApiEndpoint.walletRecharge,   // path: /user/wallet/recharge
    isLoading: isRechargeLoading,
    method: HttpMethod.POST,
    body: {'amount': amount},
    onSuccess: (value) {
      result = value;
    },
  );
  return result;
}
```

### Opening the Payment Page — InAppWebView

Add a route for the payment WebView. Register in `route_pages.dart`:

```dart
GetPage(
  name: '/walletPaymentWebview',
  page: () => const WalletPaymentWebviewScreen(),
),
```

WebView screen:

```dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WalletPaymentWebviewScreen extends StatelessWidget {
  const WalletPaymentWebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final url = Get.arguments['url'] as String;
    final walletController = Get.find<WalletController>();

    void _onClose() {
      walletController.startPollingAfterPayment();
      Get.back();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: BackButton(onPressed: _onClose),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onLoadStop: (webviewController, loadedUrl) {
          // Detect success redirect URL from Moyasar callback
          if (loadedUrl != null &&
              loadedUrl.toString().contains('payment_success')) {
            _onClose();
          }
        },
      ),
    );
  }
}
```

Triggering the flow from `WalletController`:

```dart
Future<void> initiateTopup(int amount) async {
  final invoice = await recharge(amount);
  if (invoice != null && invoice.paymentUrl.isNotEmpty) {
    Get.toNamed('/walletPaymentWebview', arguments: {'url': invoice.paymentUrl});
  }
}
```

### Balance Polling After Payment

```dart
// WalletController
static const int _maxPollRetries = 10;
Timer? _pollingTimer;
int _pollCount = 0;

void startPollingAfterPayment() {
  _pollCount = 0;
  _stopPolling();
  _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
    _pollCount++;
    final previousBalance = walletModel.value?.balance ?? 0.0;
    await fetchWallet();
    final newBalance = walletModel.value?.balance ?? 0.0;
    if (newBalance > previousBalance || _pollCount >= _maxPollRetries) {
      _stopPolling();
      if (newBalance > previousBalance) {
        fetchTransactions(refresh: true);
      }
    }
  });
}

void _stopPolling() {
  _pollingTimer?.cancel();
  _pollingTimer = null;
}

@override
void onClose() {
  _stopPolling();
  super.onClose();
}
```

**Important:** Show a "Payment Processing…" state while polling is active.  
If 10 retries pass without a balance increase, show: `"Your payment is being processed. Please check back shortly."`

---

## 6. Payment Webhook (Backend Only)

> Flutter does **NOT** call this endpoint. This section is for developer awareness only.

```
POST /api/webhooks/moyasar
```

This endpoint is called exclusively by Moyasar servers.

### Backend Behavior

1. Reads `X-Moyasar-Signature` header.
2. Verifies HMAC-SHA256 signature using the Moyasar webhook secret stored in `.env`.
3. Parses payload: `invoice_id`, `status`, `payment_id`, `amount`.
4. Looks up the matching `payment_transactions` row by `invoice_id`.
5. **Idempotency check:** if the row is already `paid`, exits immediately without re-crediting.
6. If `status == 'paid'`:
   - Updates `payment_transactions.status = 'paid'`
   - Adds `amount / 100` (SAR) to `wallets.balance` inside a DB transaction
   - Inserts a `balance_transactions` record: `type = 'recharge'`
   - Triggers push notification: `type = 'wallet_charged'`

### Example Webhook Payload (Moyasar → Backend)

```json
{
  "type": "payment.updated",
  "data": {
    "id": "pay_abc123xyz",
    "invoice_id": "inv_93822",
    "status": "paid",
    "amount": 15000,
    "currency": "SAR",
    "metadata": {
      "user_id": "42",
      "wallet_topup": "true"
    }
  }
}
```

> `amount` is in **halalas** (1 SAR = 100 halalas). The backend divides by 100.

---

## 7. Booking Wallet Deduction

### How It Works

When the user selects `balance` as the payment method, the backend:
1. Checks `wallet.balance >= booking.total_amount`
2. If insufficient → returns `422 insufficient_balance`
3. If sufficient → deducts inside a DB transaction and creates a `balance_transactions` record

### Flutter — Selecting Wallet Payment

The booking preview response includes the user's balance:

```json
{
  "data": {
    "user_balance": {
      "balance": "250.00",
      "has_sufficient_balance": true
    },
    "payment_gateways": {
      "balance": "balance",
      "online-payment": "online-payment",
      "cash": "cash"
    }
  }
}
```

Disable the wallet option if `has_sufficient_balance == false`:

```dart
// In PreviewScreen payment method selector
Obx(() {
  final hasFunds = controller.previewData?.userBalance.hasSufficientBalance ?? false;
  return RadioListTile(
    title: Text('Wallet (${controller.previewData?.userBalance.balance ?? '0.00'} SAR)'),
    value: 'balance',
    groupValue: controller.selectedMethodText,
    onChanged: hasFunds ? (v) => controller.setPaymentMethod(v!) : null,
    subtitle: hasFunds
        ? null
        : const Text('Insufficient balance — Top up to use wallet',
            style: TextStyle(color: Colors.red, fontSize: 12)),
  );
})
```

Booking confirmation call with wallet:

```dart
Map<String, dynamic> inputBody = {
  'car_id': carId,
  'car_slug': carSlugValue,
  'location': locationDisplay,
  'rental_days': rentalDays,
  'pickup_location': pickupLocationJson,
  'pickup_date': bookingController.selectedPickupDate.value,
  'pickup_time': bookingController.selectedPickupTime.value,
  'credentials': LocalStorage.email,
  'mobile': LocalStorage.number,
  'message': bookingController.noteController.text,
  'payment': 'balance',          // ← wallet deduction
  'include_delivery': includeDelivery,
  'delivery_price': deliveryPrice,
};

await RequestProcess().request<BookingConfirmModel>(
  fromJson: BookingConfirmModel.fromJson,
  apiEndpoint: ApiEndpoint.bookingConfirm,
  isLoading: _isBookingLoading,
  method: HttpMethod.POST,
  body: inputBody,
  onSuccess: (value) {
    _bookingConfirmModel = value!;
    _confirmation(_bookingConfirmModel);
  },
);
```

### Booking Confirm Success Response (Wallet Payment)

```json
{
  "message": { "success": ["Booking Successful! Amount deducted from your balance."] },
  "data": {
    "booking_id": 91,
    "trx_id": "TRX123456",
    "amount_paid": 200,
    "payment_method": "wallet",
    "amount_deducted": 200,
    "wallet_balance_after": 50,
    "new_balance": 50
  },
  "type": "success"
}
```

### Flutter UI After Booking Confirmation

Show the CongratulationsScreen with a deduction summary:

```
✓ Booking Confirmed
  Booking: #91
  Amount paid: 200.00 SAR (from wallet)
  Wallet balance: 50.00 SAR
```

Then refresh the wallet:

```dart
// On booking success
if (Get.isRegistered<WalletController>()) {
  Get.find<WalletController>().fetchWallet();
  Get.find<WalletController>().fetchTransactions(refresh: true);
}
```

---

## 8. Booking Refund to Wallet

### Refund Scenarios

| Scenario | How Triggered | Flutter Action |
|---|---|---|
| User cancels pending booking | `POST /api/v1/user/car-booking/cancel` | Active; user initiates |
| Vendor rejects booking | Backend-triggered auto refund | Passive; Flutter reacts to push notification |

### Cancellation Endpoint

```
POST /api/v1/user/car-booking/cancel
```

### Request

```json
{
  "booking_id": 91
}
```

### Success Response

```json
{
  "message": { "success": ["Booking cancelled successfully."] },
  "data": {
    "refund_id": 22,
    "booking_id": 91,
    "amount": 200,
    "method": "wallet",
    "refunded": "200.00",
    "wallet_balance_after": 250
  },
  "type": "success"
}
```

### Controller Call

```dart
Future<void> cancelBooking(int bookingId) async {
  await RequestProcess().request<CommonSuccessModel>(
    fromJson: CommonSuccessModel.fromJson,
    apiEndpoint: ApiEndpoint.cancelBooking,   // path: /user/car-booking/cancel
    isLoading: isLoading,
    method: HttpMethod.POST,
    body: {'booking_id': bookingId},
    onSuccess: (_) {
      // Refresh wallet on success
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().fetchWallet();
        Get.find<WalletController>().fetchTransactions(refresh: true);
      }
    },
  );
}
```

### Flutter UI Flow

```
1. User taps "Cancel Booking" on BookingDetailsScreen

2. Show confirmation dialog:
   "Cancel this booking?"
   "200.00 SAR will be refunded to your wallet."
   [Cancel]  [Confirm]

3. On confirm → POST /api/v1/user/car-booking/cancel

4. On success:
   → Show snackbar: "Refund of 200.00 SAR sent to your wallet"
   → Navigate back to history list
   → Refresh WalletController (balance + transactions)

5. Push notification arrives (type: wallet_refund)
   → AwesomeNotifications shows banner: "Refund Received"
   → Tap → navigate to WalletScreen
   → WalletController.fetchWallet() called
```

### Vendor Rejection (Passive Refund)

Flutter does not initiate this. The backend credits the wallet automatically.

```dart
// In PushNotificationController, on push receipt:
if (type == 'wallet_refund') {
  if (Get.isRegistered<WalletController>()) {
    Get.find<WalletController>().fetchWallet();
  }
}
```

---

## 9. Payment Refund to Card (Moyasar)

### Endpoint

```
POST /api/v1/user/payments/{paymentId}/refund
```

Replace `{paymentId}` with the backend `payment_transactions.id`.

### Request

No body required. The backend fetches the original Moyasar charge by `paymentId`.

### Success Response

```json
{
  "message": { "success": ["Payment refunded successfully."] },
  "data": {
    "refund_status": "success",
    "payment_id": 22,
    "amount": "100.00",
    "currency": "SAR",
    "provider": "moyasar",
    "status": "refunded"
  },
  "type": "success"
}
```

### Important Notes for Flutter

- This refund **reverses the wallet credit** from the original top-up.
- After a successful card refund, `wallet.balance` will decrease.
- Show a warning before confirming: `"100.00 SAR will be removed from your wallet and returned to your card."`
- This operation may take 3–5 business days to appear on the card statement.

### Calling with Dynamic Path Parameter

Since `RequestProcess` uses `ApiEndpoint` enum paths, build the URL via `ApiConfig` for path-param endpoints (following the same pattern as `ApiConfig.extensionHistoryUrl`):

```dart
// In api_endpoint.dart or api_config.dart
class ApiConfig {
  // ... existing fields ...
  static String paymentRefundUrl(int paymentId) =>
      '$baseUrl/user/payments/$paymentId/refund';
}
```

Then call `ApiServices` directly:

```dart
// Example — call via direct URL
final response = await ApiServices().postRequest(
  url: ApiConfig.paymentRefundUrl(paymentId),
  token: LocalStorage.token,
);
```

After success, refresh wallet:

```dart
Get.find<WalletController>().fetchWallet();
Get.find<WalletController>().fetchTransactions(refresh: true);
```

---

## 10. Wallet Notifications

### Notification Events

| `type` | Event | Priority | Channel |
|---|---|---|---|
| `wallet_charged` | Moyasar payment confirmed, wallet credited | High | `payment_channel` |
| `wallet_deducted` | Booking confirmed using wallet balance | High | `payment_channel` |
| `wallet_refund` | Booking cancelled/rejected, wallet refunded | High | `payment_channel` |

### Example Pusher Payloads

Wallet topped up:
```json
{
  "title": "Wallet Recharged",
  "body": "150.00 SAR has been added to your wallet",
  "type": "wallet_charged",
  "amount": "150.00",
  "currency": "SAR",
  "wallet_balance": "400.00"
}
```

Booking deduction:
```json
{
  "title": "Booking Payment",
  "body": "200.00 SAR has been deducted for your booking",
  "type": "wallet_deducted",
  "amount": "200.00",
  "booking_id": "91"
}
```

Booking refund:
```json
{
  "title": "Refund Received",
  "body": "200.00 SAR has been refunded to your wallet",
  "type": "wallet_refund",
  "amount": "200.00",
  "booking_id": "91"
}
```

### Routing Already Implemented

`AwesomeNotificationService` already handles all three wallet types (added in this integration):

```dart
// Channel routing → payment_channel (High priority, green)
case 'wallet_charged':
case 'wallet_deducted':
case 'wallet_refund':
  return 'payment_channel';

// Action button → "View Wallet"
case 'wallet_charged':
case 'wallet_deducted':
case 'wallet_refund':
  return [
    NotificationActionButton(
      key: 'VIEW_WALLET',
      label: 'View Wallet',
      actionType: ActionType.Default,
      autoDismissible: true,
    ),
  ];

// Tap navigation → /walletScreen
case 'VIEW_WALLET':
  Get.toNamed('/walletScreen');
```

### Triggering Wallet Refresh on Push

Add to `PushNotificationController` after `createNotificationFromPusher` is called:

```dart
final type = pusherData['type'] as String?;
const walletTypes = {'wallet_charged', 'wallet_deducted', 'wallet_refund'};
if (walletTypes.contains(type)) {
  if (Get.isRegistered<WalletController>()) {
    Get.find<WalletController>().fetchWallet();
  }
}
```

### Foreground vs Background Behavior

| App State | Behavior |
|---|---|
| **Foreground** | Awesome Notifications shows in-app banner; `fetchWallet()` triggered immediately |
| **Background** (notification tapped) | Navigate to `WalletScreen` via `Get.toNamed('/walletScreen')` |
| **Killed** (notification tapped) | `onActionReceivedMethod` fires on next launch; navigate to wallet |

---

## 11. Error Responses

All error responses use the standard envelope:

```json
{
  "message": { "error": ["Human-readable message"] },
  "data": [],
  "type": "error"
}
```

### Error Reference

| HTTP | Error Key | Message | Flutter Action |
|---|---|---|---|
| `401` | `unauthenticated` | Unauthenticated. | Force re-login, clear local token |
| `400` | `validation_error` | The amount must be at least 10. | Show inline field error |
| `422` | `insufficient_balance` | Your wallet balance is not enough. | Show dialog with "Top Up Wallet" CTA |
| `422` | `booking_not_cancellable` | This booking cannot be cancelled. | Show error snackbar |
| `422` | `payment_already_refunded` | This payment has already been refunded. | Show info dialog |
| `500` | `payment_failed` | Payment was not completed. | Show retry dialog |
| `500` | `server_error` | Something went wrong. | Show generic error snackbar |

### Specific Error JSON

**Insufficient balance (422):**
```json
{
  "message": { "error": ["Your wallet balance is not enough"] },
  "data": { "error": "insufficient_balance" },
  "type": "error"
}
```

**Validation error (400):**
```json
{
  "message": { "error": ["The amount must be at least 10."] },
  "data": [],
  "type": "error"
}
```

**Payment failed (500):**
```json
{
  "message": { "error": ["Payment was not completed"] },
  "data": { "error": "payment_failed" },
  "type": "error"
}
```

**Already refunded (422):**
```json
{
  "message": { "error": ["This payment has already been refunded."] },
  "data": { "error": "payment_already_refunded" },
  "type": "error"
}
```

### Flutter Handling

`RequestProcess` auto-shows errors via `CustomSnackBar.error()`. No try/catch is required.

For business-logic errors that need custom UI (e.g. showing a topup dialog on `insufficient_balance`), pass `showErrorMessage: false` and handle the response manually.

---

## 12. Flutter Integration Flow

### 12.1 Wallet Topup Flow

```
1.  User navigates to WalletScreen (/walletScreen)
    └─► WalletBinding injects WalletController
    └─► WalletController.onInit() → fetchWallet() + fetchTransactions()

2.  User sees balance card + transaction list

3.  User taps "Top Up Wallet"
    └─► Amount input dialog

4.  User enters 150 → taps "Continue"
    └─► WalletController.recharge(150)
        POST /api/v1/user/wallet/recharge  { "amount": 150 }
        Response ← { "invoice_id": "inv_...", "payment_url": "https://pay.moyasar.com/..." }

5.  Flutter opens /walletPaymentWebview
    └─► InAppWebView loads payment_url

6.  User completes Moyasar payment

7.  Moyasar POSTs to /api/webhooks/moyasar (backend only)
    └─► Backend credits wallet + sends push notification

8.  User closes/returns from WebView
    └─► WalletController.startPollingAfterPayment()
        └─► Every 3s: GET /api/v1/user/wallet
        └─► Balance > previous → stop polling, fetchTransactions(refresh: true)
        └─► After 10 retries → stop, show "Payment is processing" message

9.  Push notification: type = wallet_charged
    └─► Banner: "150.00 SAR added to your wallet"
    └─► WalletController.fetchWallet()
```

### 12.2 Booking Flow (Wallet Deduction)

```
1.  User selects car → BookingScreen → PreviewScreen

2.  GET /api/v1/user/car-booking/preview
    Response includes: user_balance.balance + user_balance.has_sufficient_balance

3.  If has_sufficient_balance == true → show "Wallet" payment option
    If has_sufficient_balance == false → disable option + show "Top Up" CTA

4.  User selects "Wallet" → taps "Confirm Booking"
    POST /api/v1/user/car-booking/confirm  { "payment": "balance", ... }
    Response ← { "amount_deducted": 200, "wallet_balance_after": 50 }

5.  CongratulationsScreen:
    "200.00 SAR deducted from wallet — New balance: 50.00 SAR"

6.  Refresh: WalletController.fetchWallet() + fetchTransactions(refresh: true)

7.  Push notification: type = wallet_deducted
    └─► WalletController.fetchWallet() (if controller is active)
```

### 12.3 Refund Flow

```
USER-INITIATED CANCELLATION:

1.  User opens BookingDetailsScreen → taps "Cancel Booking"

2.  Confirmation dialog:
    "200.00 SAR will be refunded to your wallet."

3.  User confirms
    POST /api/v1/user/car-booking/cancel  { "booking_id": 91 }
    Response ← { "refunded": "200.00", "wallet_balance_after": 250 }

4.  Snackbar: "Refund of 200.00 SAR sent to your wallet"
    Refresh: WalletController.fetchWallet() + fetchTransactions(refresh: true)

5.  Push notification: type = wallet_refund
    └─► Banner: "200.00 SAR refunded to your wallet"
    └─► Tap → navigate to WalletScreen

───────────────────────────────────────────────────────

VENDOR REJECTION (passive):

1.  Vendor rejects booking (server-side)
    └─► Backend auto-refunds wallet
    └─► Push notification: type = wallet_refund

2.  Flutter (in PushNotificationController):
    └─► Creates Awesome Notification banner
    └─► WalletController.fetchWallet()

3.  User taps notification → WalletScreen
    └─► Sees updated balance + new refund transaction
```

---

## 13. Mobile Integration Checklist

- [ ] `ApiEndpoint.walletBalance`, `walletTransactions`, `walletRecharge`, `cancelBooking` cases added to `api_endpoint.dart`
- [ ] `Routes.walletScreen = '/walletScreen'` added to `routes.dart`
- [ ] `WalletBinding` + `WalletScreen` registered in `route_pages.dart`
- [ ] `WalletModel`, `WalletTransaction`, `WalletTransactionsModel`, `WalletRechargeModel` created in `lib/views/wallet/model/`
- [ ] `WalletController` with `fetchWallet()`, `fetchTransactions()`, `recharge()`, `startPollingAfterPayment()` created
- [ ] Polling timer cancelled in `WalletController.onClose()` (prevents memory leaks)
- [ ] `WalletPaymentWebviewScreen` calls `startPollingAfterPayment()` on every close path
- [ ] "Payment Processing…" state shown during polling (up to 30 seconds)
- [ ] `has_sufficient_balance == false` disables wallet option in PreviewScreen
- [ ] Wallet refreshed after booking confirmation when `payment_method == 'wallet'`
- [ ] Cancellation dialog shows refund amount before confirming
- [ ] Wallet refreshed after successful cancel API call
- [ ] Push notification types `wallet_charged`, `wallet_deducted`, `wallet_refund` routed to `payment_channel`
- [ ] `VIEW_WALLET` action button navigates to `Routes.walletScreen`
- [ ] `PushNotificationController` calls `fetchWallet()` on any wallet notification receipt
- [ ] Transaction amounts always displayed with 2 decimal places
- [ ] `trx_id` visible in transaction detail view for support reference
- [ ] 401 response forces re-login and clears token

---

## 14. Backend Safety Rules (for Mobile Awareness)

These rules are enforced server-side. They drive the mobile UX decisions listed above.

| Rule | Mobile Implication |
|---|---|
| Wallet balance cannot become negative | Disable wallet payment if `has_sufficient_balance == false` |
| Every balance change creates a transaction record | Refresh is always safe and reflects the real ledger state |
| Refunds reference the original booking or payment | `reference_id` in a refund transaction equals the `booking_id` — safe to link |
| Webhooks are idempotent | Polling for balance change will never cause double-credit |
| All balance updates run inside DB transactions | If balance has not changed after 10 polls (30 seconds), show "payment is being processed" — do not show failure |
