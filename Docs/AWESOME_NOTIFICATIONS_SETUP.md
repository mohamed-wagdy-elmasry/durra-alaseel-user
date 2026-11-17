# Awesome Notifications Integration Guide

## Overview

Your app now has **Awesome Notifications** integrated alongside **Pusher Beams** for enhanced push notification capabilities. This provides:

- ✅ Rich notification layouts with action buttons
- ✅ Custom notification channels with different priorities
- ✅ Scheduled local notifications
- ✅ Notification grouping and management
- ✅ Better control over notification display and behavior

## Architecture

```
┌─────────────────┐
│ Backend Server  │ ──► Push messages via Firebase Cloud Messaging
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Pusher Beams   │ ──► Receives push messages
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Push Controller │ ──► Forwards to Awesome Notifications
└─────────────────┘
         │
         ▼
┌──────────────────────┐
│ Awesome Notifications │ ──► Displays rich notifications with actions
└──────────────────────┘
```

## Notification Channels

The app has 5 notification channels configured:

| Channel | Purpose | Priority | Sound | Vibration |
|---------|---------|----------|-------|-----------|
| `booking_channel` | Booking confirmations, driver updates | Max | ✅ | ✅ |
| `payment_channel` | Payment confirmations, refunds | High | ✅ | ✅ |
| `chat_channel` | Messages from drivers/support | Default | ✅ | ✅ |
| `promo_channel` | Offers, discounts, marketing | Low | ❌ | ❌ |
| `scheduled_channel` | Scheduled reminders | High | ✅ | ✅ |

Users can customize each channel's behavior in Android Settings.

## How It Works

### 1. **Push Notifications from Backend**

When your backend sends a push notification via Pusher Beams, it should use this payload format:

```json
{
  "title": "Booking Confirmed",
  "body": "Your Tesla Model S has been booked for tomorrow",
  "type": "booking",
  "booking_id": "12345",
  "booking_time": "2026-02-13T10:00:00Z",
  "data": {
    "car_name": "Tesla Model S",
    "pickup_location": "Dubai Mall"
  }
}
```

**Important**: Use **data-only messages** (no `notification` field in FCM payload) to prevent Pusher from automatically displaying notifications. This allows Awesome Notifications to handle all display.

### 2. **Automatic Channel Selection**

The system automatically selects the appropriate channel based on the `type` field:

- `type: "booking"` → `booking_channel` (urgent, max priority)
- `type: "payment"` → `payment_channel` (high priority)
- `type: "chat"` → `chat_channel` (default priority)
- `type: "promo"` → `promo_channel` (low priority, no sound)

### 3. **Action Buttons**

Notifications automatically get action buttons based on type:

**Booking notifications:**
- "View Details" button → navigates to booking details
- "Dismiss" button → dismisses notification

**Payment notifications:**
- "View Payment" button → navigates to payment screen

**Chat notifications:**
- "Reply" button → opens inline reply input
- "Mark as Read" button → marks message as read (silent action)

## Usage Examples

### Schedule a Booking Reminder

```dart
import 'package:carbo/backend/services/scheduled_notifications.dart';

// Schedule reminder 1 hour before booking
await ScheduledNotifications.scheduleBookingReminder(
  bookingId: 12345,
  bookingDateTime: DateTime(2026, 2, 13, 10, 0),
  carName: 'Tesla Model S',
  pickupLocation: 'Dubai Mall',
);
```

### Schedule a Payment Reminder

```dart
await ScheduledNotifications.schedulePaymentReminder(
  paymentId: 67890,
  amount: 'AED 500',
  dueDate: DateTime(2026, 2, 15),
);
```

### Schedule a Daily Promotional Notification

```dart
await ScheduledNotifications.scheduleDailyPromo(
  title: 'Special Offer!',
  message: '20% off on all luxury cars today',
  hour: 10, // 10 AM
  minute: 0,
);
```

### Create a Custom Notification Manually

```dart
import 'package:awesome_notifications/awesome_notifications.dart';

await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    channelKey: 'booking_channel',
    title: 'Custom Notification',
    body: 'This is a custom notification',
    payload: {'custom_data': 'value'},
    wakeUpScreen: true,
  ),
  actionButtons: [
    NotificationActionButton(
      key: 'CUSTOM_ACTION',
      label: 'Take Action',
      actionType: ActionType.Default,
    ),
  ],
);
```

### Cancel Scheduled Notifications

```dart
// Cancel specific booking reminder
await ScheduledNotifications.cancelBookingReminder(12345);

// Cancel all scheduled notifications
await ScheduledNotifications.cancelAllScheduled();

// Cancel specific notification by ID
await AwesomeNotificationService.cancelNotification(notificationId);
```

### List Active Scheduled Notifications

```dart
final scheduled = await ScheduledNotifications.listScheduledNotifications();
print('Active scheduled notifications: ${scheduled.length}');
for (var notification in scheduled) {
  print('ID: ${notification.id}, Title: ${notification.title}');
}
```

## Handling Notification Actions

Notification actions are automatically handled by `AwesomeNotificationService.onActionReceivedMethod()`.

To customize navigation for your app, edit the handler methods in `lib/backend/services/awesome_notification_service.dart`:

```dart
/// Navigate to booking details
static Future<void> _navigateToBooking(Map<String, String?> payload) async {
  final bookingId = payload['booking_id'];
  if (bookingId != null) {
    // Update this route to match your app's routing
    Get.toNamed('/booking-details', arguments: {'id': bookingId});
  }
}
```

## Permissions

Awesome Notifications automatically requests permissions on Android 13+. For earlier Android versions, permissions are granted by default.

To manually request permissions:

```dart
final isAllowed = await AwesomeNotifications().isNotificationAllowed();
if (!isAllowed) {
  await AwesomeNotifications().requestPermissionToSendNotifications();
}
```

## Backend Integration Checklist

For your backend team to properly send notifications:

### ✅ **Data-Only Messages**

Send FCM messages with **data payload only**, no `notification` field:

```json
{
  "data": {
    "title": "Booking Confirmed",
    "body": "Your car is ready",
    "type": "booking",
    "booking_id": "12345"
  }
}
```

❌ **Don't send:**

```json
{
  "notification": {
    "title": "...",
    "body": "..."
  }
}
```

This prevents Pusher SDK from auto-displaying notifications.

### ✅ **Include Type Field**

Always include a `type` field to enable automatic channel selection:

- `booking` | `trip` | `driver` → booking_channel
- `payment` | `refund` → payment_channel
- `chat` | `message` → chat_channel
- `promo` | `offer` | `discount` → promo_channel

### ✅ **Include Relevant IDs**

Include identifiers for deep linking:

- `booking_id` for booking notifications
- `payment_id` for payment notifications
- `message_id` for chat notifications

## Testing

### Test Push Notification from Pusher Dashboard

1. Go to [Pusher Beams Dashboard](https://dashboard.pusher.com/beams)
2. Select your instance: `f80f6f50-1302-4c1f-b7ba-b64a57fcbd29`
3. Send test notification to interest `debug-hello`
4. Use this payload:

```json
{
  "title": "Test Booking",
  "body": "This is a test notification",
  "type": "booking",
  "booking_id": "999"
}
```

### Test Scheduled Notification

```dart
// Add this to any button in your app for testing
await ScheduledNotifications.scheduleBookingReminder(
  bookingId: 999,
  bookingDateTime: DateTime.now().add(Duration(minutes: 2)),
  carName: 'Test Car',
);
```

## iOS Support (Coming Soon)

iOS initialization is currently disabled in `lib/initializer.dart`. To enable:

1. Configure APNs certificate in Pusher Beams dashboard
2. Add Push Notifications capability in Xcode
3. Uncomment iOS initialization code in `lib/initializer.dart` (lines with TODO: iOS Setup)
4. Test on iOS device

## Troubleshooting

### Notifications Not Showing

1. Check notification permissions: Settings → Apps → Durrat Alaseel → Notifications
2. Verify channel is not disabled by user
3. Check Android version (requires API 23+)
4. Look for error logs with `flutter logs | grep -i notification`

### Scheduled Notifications Not Triggering

1. Check device battery optimization settings
2. Ensure app is not in battery saver mode
3. Verify `SCHEDULE_EXACT_ALARM` permission is granted (Android 12+)
4. Check if time has passed before scheduling

### Actions Not Working

1. Verify routes exist in `lib/routes/routes.dart`
2. Check `navigatorKey` is properly set in `main.dart`
3. Look for navigation errors in logs

## Files Modified/Created

### Created Files:
- `lib/backend/services/notification_channels.dart` - Channel configurations
- `lib/backend/services/awesome_notification_service.dart` - Main service
- `lib/backend/services/scheduled_notifications.dart` - Scheduling helpers
- `AWESOME_NOTIFICATIONS_SETUP.md` - This documentation

### Modified Files:
- `pubspec.yaml` - Added awesome_notifications dependency
- `android/app/src/main/AndroidManifest.xml` - Added permissions and receivers
- `lib/initializer.dart` - Added Awesome Notifications initialization
- `lib/main.dart` - Added navigator key and initial action handling
- `lib/backend/services/push_notification_controller.dart` - Integrated with Awesome Notifications

## Next Steps

1. **Test notification flow** with real push messages from backend
2. **Customize navigation routes** in `awesome_notification_service.dart`
3. **Add notification icons** to `android/app/src/main/res/drawable/`
4. **Implement reply functionality** for chat notifications
5. **Configure iOS** when APNs certificate is ready
6. **Add analytics** to track notification engagement

## Resources

- [Awesome Notifications Documentation](https://pub.dev/packages/awesome_notifications)
- [Pusher Beams Documentation](https://pusher.com/docs/beams)
- [Your Pusher Beams Instance](https://dashboard.pusher.com/beams/instances/f80f6f50-1302-4c1f-b7ba-b64a57fcbd29)
