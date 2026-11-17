# Quick Start Guide: Awesome Notifications

## 🎯 What You Now Have

Your app has Awesome Notifications fully integrated with Pusher Beams. You can now:
- ✅ Send rich push notifications with action buttons
- ✅ Schedule local notifications for specific times
- ✅ Customize notification channels and priorities
- ✅ Handle notification actions and deep linking

---

## 🏃 Quick Start: 5 Minutes

### 1. Test a Push Notification (2 minutes)

Go to [Pusher Beams Dashboard](https://dashboard.pusher.com/beams/instances/f80f6f50-1302-4c1f-b7ba-b64a57fcbd29)

Click **"Publish a notification"** and send to interest `debug-hello`:

```json
{
  "data": {
    "title": "Test Booking",
    "body": "See this notification appear!",
    "type": "booking",
    "booking_id": "123"
  }
}
```

**You should see:**
- Notification in system tray
- "Booking Notifications" channel
- "View Details" and "Dismiss" buttons

### 2. Test a Scheduled Notification (3 minutes)

Create a test file or add to your code:

```dart
import 'package:carbo/backend/services/scheduled_notifications.dart';

// In any function in your app:
await ScheduledNotifications.scheduleBookingReminder(
  bookingId: 999,
  bookingDateTime: DateTime.now().add(Duration(minutes: 1)), // 1 minute from now
  carName: 'Test Car',
  pickupLocation: 'Test Location',
);

// You should get a notification reminder 1 minute later
```

---

## 📱 Common Tasks

### Schedule Booking Reminder

```dart
import 'package:carbo/backend/services/scheduled_notifications.dart';

await ScheduledNotifications.scheduleBookingReminder(
  bookingId: bookingId,
  bookingDateTime: DateTime(2026, 2, 15, 10, 0), // Your booking time
  carName: 'Tesla Model S',
  pickupLocation: 'Dubai Mall',
);
```

Shows notification 1 hour before the booking.

### Schedule Payment Reminder

```dart
await ScheduledNotifications.schedulePaymentReminder(
  paymentId: paymentId,
  amount: 'AED 500',
  dueDate: DateTime(2026, 2, 15), // Payment due date
);
```

Shows notification 1 day before payment is due at 9 AM.

### Cancel a Scheduled Notification

```dart
await ScheduledNotifications.cancelBookingReminder(bookingId);
```

### View All Scheduled Notifications

```dart
final scheduled = await ScheduledNotifications.listScheduledNotifications();
for (var notification in scheduled) {
  print('${notification.id}: ${notification.title}');
}
```

### Create a Custom Notification

```dart
import 'package:awesome_notifications/awesome_notifications.dart';

await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    channelKey: 'booking_channel',
    title: 'Custom Title',
    body: 'Custom body text',
  ),
);
```

---

## 🎯 Notification Types

Your backend should send notifications with a `type` field to trigger the right channel:

| Type | Channel | Priority | Sound | Buttons |
|------|---------|----------|-------|---------|
| `booking`, `trip`, `driver` | booking_channel | Max | ✓ | View Details, Dismiss |
| `payment`, `refund` | payment_channel | High | ✓ | View Payment |
| `chat`, `message` | chat_channel | Default | ✓ | Reply, Mark as Read |
| `promo`, `offer`, `discount` | promo_channel | Low | ✗ | (None) |

**Example Payload for Backend:**

```json
{
  "data": {
    "title": "Booking Confirmed",
    "body": "Your car is ready tomorrow",
    "type": "booking",
    "booking_id": "12345",
    "car_name": "Tesla Model S"
  }
}
```

---

## 🔧 Configuration

### Android Permissions (Already Done)

✅ `VIBRATE`
✅ `RECEIVE_BOOT_COMPLETED`
✅ `SCHEDULE_EXACT_ALARM`
✅ `USE_FULL_SCREEN_INTENT`

### Notification Channels (Already Created)

Users can customize in Settings:

**Settings → Notifications → App Notifications**

- Booking Notifications (Max priority)
- Payment Notifications (High priority)
- Chat Notifications (Default priority)
- Promotions & Offers (Low priority)
- Reminders (High priority)

---

## 🧪 Testing Checklist

- [ ] Test booking notification with View Details button
- [ ] Test payment notification
- [ ] Test chat notification with Reply button
- [ ] Test promotional notification
- [ ] Test scheduled booking reminder
- [ ] Test scheduled payment reminder
- [ ] Tap notification and verify deep link works
- [ ] Tap action button and verify action works
- [ ] Check notification appears on lock screen
- [ ] Verify waking screen (for booking/payment types)

---

## 🚨 Important for Backend Team

### ✅ Use This Format (Data-Only)

```json
{
  "data": {
    "title": "...",
    "body": "...",
    "type": "booking",
    "booking_id": "123"
  }
}
```

### ❌ Don't Use This Format (With notification field)

```json
{
  "notification": {
    "title": "...",
    "body": "..."
  }
}
```

The second format uses FCM's default notification display, bypassing our Awesome Notifications.

---

## 📚 Full Documentation

- **[AWESOME_NOTIFICATIONS_SETUP.md](AWESOME_NOTIFICATIONS_SETUP.md)** - Complete setup guide
- **[BACKEND_PAYLOAD_REFERENCE.md](BACKEND_PAYLOAD_REFERENCE.md)** - Payload format examples
- **[IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)** - Implementation details

---

## 🔗 Quick Links

- **[Pusher Beams Dashboard](https://dashboard.pusher.com/beams/instances/f80f6f50-1302-4c1f-b7ba-b64a57fcbd29)** - Send test notifications
- **[Awesome Notifications Docs](https://pub.dev/packages/awesome_notifications)** - API reference
- **[Your Instance](https://dashboard.pusher.com/beams/instances/f80f6f50-1302-4c1f-b7ba-b64a57fcbd29)** - Your Pusher Instance

---

## ❓ Common Questions

### Can I customize the notification sound?

Yes, in notification channels. Users can change per channel in Settings.

### Can I add custom fields to notifications?

Yes, use the `payload` field:

```dart
content: NotificationContent(
  ...
  payload: {
    'custom_field': 'custom_value',
    'order_id': '12345',
  },
)
```

### How do I handle notification taps?

Edit these methods in `awesome_notification_service.dart`:
- `_navigateToBooking()`
- `_navigateToPayment()`
- `_handleDefaultTap()`

### Can I send notifications to specific users?

Yes, use Pusher Beams user ID:

```dart
// In app:
await controller.setUserId('user@example.com');

// Backend:
Send to user: 'user@example.com'
```

### What about iOS?

iOS is prepared but disabled waiting for APNs certificate. Uncomment code in `lib/initializer.dart` when ready.

### How do I debug notifications?

Check logs:
```
flutter logs | grep -i notification
```

Or test in Settings → Developer options → Enable notification logging.

---

## 🐛 Troubleshooting

### Notification doesn't appear

1. ✓ Check app permissions: Settings → Apps → Durrat Alaseel → Notifications
2. ✓ Verify `type` field is included
3. ✓ Verify `title` and `body` are not empty
4. ✓ Check device battery optimization (may delay notifications)
5. ✓ Look for error in app logs: `flutter logs`

### Action buttons don't work

1. ✓ Verify route exists in `lib/routes/routes.dart`
2. ✓ Check navigation code in `awesome_notification_service.dart`
3. ✓ Look for errors in logs when tapping button

### Scheduled notifications don't trigger

1. ✓ Check device time is correct
2. ✓ Verify app is not force-closed
3. ✓ Check battery optimization settings
4. ✓ Verify `SCHEDULE_EXACT_ALARM` permission granted (Android 12+)

---

## 📞 Next Steps

1. **Test with Pusher Dashboard** - Send a test notification
2. **Work with backend** - Update notification API to send proper payloads
3. **Customize routes** - Update deep link navigation
4. **Add more features** - Reply functionality, custom layouts, etc.
5. **Monitor in production** - Track notification engagement and issues

---

## 🎉 You're All Set!

Your app now has enterprise-grade notification support. Start using it! Questions? Check the full documentation files.
