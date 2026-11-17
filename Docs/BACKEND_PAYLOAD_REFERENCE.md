# Backend Integration: Push Notifications Payload Format

## Quick Reference for Backend Team

### ✅ Correct Payload Format (Data-Only)

Send to your app via **Firebase Cloud Messaging (FCM)** through **Pusher Beams**:

```json
{
  "data": {
    "title": "Booking Confirmed",
    "body": "Your Tesla Model S is ready",
    "type": "booking",
    "booking_id": "12345",
    "booking_time": "2026-02-15T10:00:00Z"
  }
}
```

⚠️ **IMPORTANT**: 
- ✅ Use **data payload only**
- ❌ Do NOT include `notification` field
- ❌ Do NOT use `notification.title` or `notification.body`

This prevents Pusher SDK from auto-displaying, allowing Awesome Notifications to handle display.

---

## Notification Types & Channels

The app automatically selects channels based on the `type` field:

### Booking Related
```json
{
  "data": {
    "title": "Your booking is confirmed",
    "body": "Pickup tomorrow at 10:00 AM",
    "type": "booking",
    "booking_id": "12345"
  }
}
```
**Channel**: `booking_channel` (Max Priority, Sound + Vibration)
**Auto Actions**: View Details, Dismiss
**Wake Screen**: Yes

### Trip Updates
```json
{
  "data": {
    "title": "Driver on the way",
    "body": "Your driver is 5 minutes away",
    "type": "trip",
    "booking_id": "12345"
  }
}
```
**Channel**: `booking_channel`
**Note**: Same as booking

### Driver Communication
```json
{
  "data": {
    "title": "Driver message",
    "body": "I'll be there in 10 minutes",
    "type": "driver",
    "booking_id": "12345"
  }
}
```
**Channel**: `booking_channel`

---

### Payment Related

```json
{
  "data": {
    "title": "Payment successful",
    "body": "AED 350 charged to your card",
    "type": "payment",
    "payment_id": "67890",
    "amount": "350 AED"
  }
}
```
**Channel**: `payment_channel` (High Priority, Sound + Vibration)
**Auto Actions**: View Payment
**Wake Screen**: Yes

### Payment Refund
```json
{
  "data": {
    "title": "Refund processed",
    "body": "AED 100 refunded to your card",
    "type": "refund",
    "payment_id": "67890",
    "amount": "100 AED"
  }
}
```
**Channel**: `payment_channel`

---

### Chat Messages

```json
{
  "data": {
    "title": "New message from support",
    "body": "Thank you for your booking",
    "type": "chat",
    "message_id": "msg_001",
    "sender_id": "support"
  }
}
```
**Channel**: `chat_channel` (Default Priority, Sound + Vibration)
**Auto Actions**: Reply (inline input), Mark as Read
**Wake Screen**: No

### Driver Chat
```json
{
  "data": {
    "title": "Driver's message",
    "body": "Can you send me your location?",
    "type": "message",
    "booking_id": "12345"
  }
}
```
**Channel**: `chat_channel`

---

### Promotions & Offers

```json
{
  "data": {
    "title": "Special offer!",
    "body": "Get 20% off on luxury cars today",
    "type": "promo",
    "campaign_id": "promo_feb_2026"
  }
}
```
**Channel**: `promo_channel` (Low Priority, No Sound/Vibration)
**Auto Actions**: None
**Wake Screen**: No

### Discounts
```json
{
  "data": {
    "title": "Exclusive discount",
    "body": "15% off for next 3 bookings",
    "type": "discount",
    "campaign_id": "exclusive_feb"
  }
}
```
**Channel**: `promo_channel`

### Offers
```json
{
  "data": {
    "title": "Limited time offer",
    "body": "First ride free",
    "type": "offer",
    "campaign_id": "first_ride_free"
  }
}
```
**Channel**: `promo_channel`

---

## Required Fields

| Field | Example | Purpose |
|-------|---------|---------|
| `title` | "Booking Confirmed" | Notification title (required) |
| `body` | "Your car is ready" | Notification body text (required) |
| `type` | "booking", "payment", "chat", "promo" | Determines channel & actions (required) |
| `*_id` | "booking_id", "payment_id", "message_id" | For deep linking (recommended) |

---

## Optional Fields

These can be included for additional context:

```json
{
  "data": {
    "title": "...",
    "body": "...",
    "type": "booking",
    "booking_id": "12345",
    "car_name": "Tesla Model S",
    "pickup_location": "Dubai Mall",
    "pickup_time": "2026-02-15T10:00:00Z",
    "driver_name": "Ahmed",
    "driver_phone": "+971501234567",
    "amount": "350 AED",
    "custom_field": "any_value"
  }
}
```

All optional fields are included in the notification payload and available in the app.

---

## Testing Your Payload

### Using cURL (Firebase Cloud Messaging)

```bash
curl -X POST "https://fcm.googleapis.com/fcm/send" \
  -H "Authorization: key=YOUR_FCM_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_TOKEN",
    "data": {
      "title": "Test Booking",
      "body": "Test notification",
      "type": "booking",
      "booking_id": "999"
    }
  }'
```

### Using Pusher Beams Dashboard

1. Go to [Pusher Beams Dashboard](https://dashboard.pusher.com/beams)
2. Select instance: `f80f6f50-1302-4c1f-b7ba-b64a57fcbd29`
3. Click "Publish to device/interest"
4. Publish to interest: `debug-hello`
5. Paste this JSON:

```json
{
  "title": "Test Message",
  "body": "This is a test notification",
  "type": "booking",
  "booking_id": "123"
}
```

---

## Common Mistakes to Avoid

### ❌ Wrong: Using notification field

```json
{
  "notification": {
    "title": "...",
    "body": "..."
  }
}
```

This uses FCM's default notification display, bypassing Awesome Notifications.

### ❌ Wrong: Missing type field

```json
{
  "data": {
    "title": "...",
    "body": "..."
  }
}
```

Without `type`, the app defaults to `booking_channel`. Specify type for correct behavior.

### ❌ Wrong: Non-string values in payload

```json
{
  "data": {
    "amount": 350
  }
}
```

All values must be strings. Use `"amount": "350"` instead.

---

## App Notification Channels

These are automatically created in the app. Users can customize in Settings:

**Settings → Notifications → App Settings → App Notifications**

Each channel appears in Android Settings with:
- Name
- Description
- Sound settings
- Vibration settings
- Light settings
- Badge options

Users can:
- Enable/Disable each channel
- Change sound
- Enable/Disable vibration
- Change importance level

---

## Success Indicators

After sending a notification, you should see:

1. ✅ Notification appears in system tray
2. ✅ Notification is grouped by channel
3. ✅ Notification has action buttons (if applicable)
4. ✅ Tapping notification navigates to correct screen
5. ✅ Tapping action button performs correct action

---

## Support & Troubleshooting

### Notification doesn't appear

1. ✓ Verify payload has `data` field (not `notification`)
2. ✓ Check type field is correct
3. ✓ Ensure title and body are non-empty
4. ✓ Verify app has notification permissions (Android 13+)
5. ✓ Check app is running or backgrounded (not force-closed)

### Wrong action buttons appear

1. ✓ Verify `type` field is exactly one of: booking, payment, chat, promo
2. ✓ Use lowercase type

### Notification doesn't wake screen

1. ✓ Only booking and payment types wake screen
2. ✓ Device must not be in critical low battery mode
3. ✓ WAKE_LOCK permission must be granted

### Deep linking not working

1. ✓ Verify booking_id, payment_id, etc. are included
2. ✓ Check route exists in app (ask frontend team)
3. ✓ Verify IDs match what app expects

---

## Next Deployment Steps

1. **Update API documentation** - Document new payload format
2. **Update notification service** - If applicable
3. **Test with integration environment** - Send test notifications
4. **Monitor error logs** - Check for payload issues
5. **Prepare deployment** - Plan notification migration if applicable

---

## Resources

- Backend notification service source: [Your backend repository]
- App source code: `carbo-app/durra-alaseel-user`
- Pusher Instance ID: `f80f6f50-1302-4c1f-b7ba-b64a57fcbd29`
- Documentation: [AWESOME_NOTIFICATIONS_SETUP.md](AWESOME_NOTIFICATIONS_SETUP.md)

---

## Questions?

Contact frontend team for:
- Payload format clarification
- Testing assistance
- New notification type requirements
- Custom field support requests
