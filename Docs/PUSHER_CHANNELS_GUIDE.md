# Pusher Channels Implementation Guide

This guide shows you how to implement real-time messaging in your Flutter app using Pusher Channels.

## 📋 Table of Contents
- [Setup](#setup)
- [Basic Usage](#basic-usage)
- [Advanced Features](#advanced-features)
- [Server-Side Implementation](#server-side-implementation)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Setup

### 1. Get Pusher Credentials

1. Visit [Pusher Dashboard](https://dashboard.pusher.com/)
2. Create a new Channels app or select existing
3. Go to **App Keys** section
4. Copy:
   - `app_id`
   - `key` (API Key)
   - `secret`
   - `cluster` (e.g., 'us2', 'eu', 'ap1')

### 2. Configure Credentials

Update `lib/backend/services/pusher_config.dart`:

```dart
class PusherChannelsConfig {
  static const String apiKey = 'a1b2c3d4e5f6g7h8i9j0';  // Your app key
  static const String cluster = 'us2';                    // Your cluster
}
```

### 3. Install Dependencies

Already done! Run:
```bash
flutter pub get
```

---

## 📱 Basic Usage

### Initialize in Your App

In `lib/initializer.dart` or `lib/main.dart`:

```dart
import 'package:get/get.dart';
import 'backend/services/pusher_channels_controller.dart';
import 'backend/services/pusher_config.dart';

Future<void> initializeApp() async {
  // Initialize Pusher Channels
  final pusherController = Get.put(PusherChannelsController());
  
  await pusherController.initialize(
    apiKey: PusherChannelsConfig.apiKey,
    cluster: PusherChannelsConfig.cluster,
  );
  
  await pusherController.connect();
  
  print('Pusher Channels ready!');
}
```

### Subscribe to a Channel

```dart
final controller = Get.find<PusherChannelsController>();

// Subscribe to public channel
await controller.subscribeToChannel(
  'booking-updates',
  onEvent: (event) {
    print('Event: ${event.eventName}');
    print('Data: ${event.data}');
  },
);
```

### Listen to Specific Events

```dart
await controller.bindToEvent(
  channelName: 'booking-updates',
  eventName: 'booking-confirmed',
  callback: (event) {
    final data = event.data;
    print('Booking confirmed: $data');
    
    // Update UI, show notification, etc.
    Get.snackbar('Booking Confirmed', 'Your booking is ready!');
  },
);
```

---

## 🎯 Advanced Features

### Private Channels (Authentication Required)

Private channels require authentication on your backend.

**Flutter:**
```dart
await controller.subscribeToPrivateChannel(
  'private-user-123',
  onEvent: (event) {
    print('Private event: ${event.data}');
  },
);
```

**Backend Setup (Node.js/Express example):**
```javascript
const Pusher = require('pusher');

const pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID,
  key: process.env.PUSHER_KEY,
  secret: process.env.PUSHER_SECRET,
  cluster: process.env.PUSHER_CLUSTER,
});

app.post('/pusher/auth', (req, res) => {
  const socketId = req.body.socket_id;
  const channel = req.body.channel_name;
  
  // Verify user authentication here
  const userId = req.user.id;
  
  const auth = pusher.authenticate(socketId, channel);
  res.send(auth);
});
```

### Presence Channels (Member Tracking)

Track who's online in real-time:

```dart
await controller.subscribeToPresenceChannel(
  'presence-chat-room',
  onEvent: (event) {
    if (event.eventName == 'pusher:member_added') {
      print('User joined: ${event.userId}');
    } else if (event.eventName == 'pusher:member_removed') {
      print('User left: ${event.userId}');
    }
  },
);
```

### Client Events (Peer-to-Peer)

Send events directly between clients (must enable in dashboard):

```dart
// Send typing indicator
await controller.triggerClientEvent(
  channelName: 'private-chat',
  eventName: 'client-typing',
  data: {'userId': currentUser.id, 'isTyping': true},
);

// Listen for typing indicators
await controller.bindToEvent(
  channelName: 'private-chat',
  eventName: 'client-typing',
  callback: (event) {
    final data = event.data;
    print('${data['userId']} is typing...');
  },
);
```

---

## 🖥️ Server-Side Implementation

### Trigger Events from Backend

**Node.js:**
```javascript
const Pusher = require('pusher');

const pusher = new Pusher({
  appId: 'YOUR_APP_ID',
  key: 'YOUR_KEY',
  secret: 'YOUR_SECRET',
  cluster: 'YOUR_CLUSTER',
});

// Trigger event
pusher.trigger('booking-updates', 'booking-confirmed', {
  bookingId: '12345',
  status: 'confirmed',
  message: 'Your booking has been confirmed!',
});
```

**Python:**
```python
import pusher

pusher_client = pusher.Pusher(
  app_id='YOUR_APP_ID',
  key='YOUR_KEY',
  secret='YOUR_SECRET',
  cluster='YOUR_CLUSTER',
)

pusher_client.trigger('booking-updates', 'booking-confirmed', {
  'bookingId': '12345',
  'status': 'confirmed',
  'message': 'Your booking has been confirmed!'
})
```

**PHP:**
```php
require __DIR__ . '/vendor/autoload.php';

$pusher = new Pusher\Pusher(
  'YOUR_KEY',
  'YOUR_SECRET',
  'YOUR_APP_ID',
  array('cluster' => 'YOUR_CLUSTER')
);

$pusher->trigger('booking-updates', 'booking-confirmed', [
  'bookingId' => '12345',
  'status' => 'confirmed',
  'message' => 'Your booking has been confirmed!'
]);
```

---

## 💡 Examples

### Example 1: Real-Time Booking Updates

```dart
class BookingController extends GetxController {
  final PusherChannelsController _pusher = Get.find();
  
  @override
  void onInit() {
    super.onInit();
    _setupRealtimeBookings();
  }
  
  Future<void> _setupRealtimeBookings() async {
    await _pusher.subscribeToChannel('booking-updates');
    
    // Listen for new bookings
    await _pusher.bindToEvent(
      channelName: 'booking-updates',
      eventName: 'booking-created',
      callback: _handleNewBooking,
    );
    
    // Listen for cancellations
    await _pusher.bindToEvent(
      channelName: 'booking-updates',
      eventName: 'booking-cancelled',
      callback: _handleBookingCancelled,
    );
  }
  
  void _handleNewBooking(PusherEvent event) {
    final data = event.data;
    print('New booking: ${data['bookingId']}');
    
    Get.snackbar(
      'New Booking',
      'Booking #${data['bookingId']} created',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void _handleBookingCancelled(PusherEvent event) {
    final data = event.data;
    print('Booking cancelled: ${data['bookingId']}');
    
    Get.snackbar(
      'Booking Cancelled',
      'Booking #${data['bookingId']} was cancelled',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

### Example 2: Live Car Availability

```dart
class CarAvailabilityController extends GetxController {
  final PusherChannelsController _pusher = Get.find();
  RxList<Car> availableCars = <Car>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _listenToCarUpdates();
  }
  
  Future<void> _listenToCarUpdates() async {
    await _pusher.subscribeToChannel('car-availability');
    
    await _pusher.bindToEvent(
      channelName: 'car-availability',
      eventName: 'car-status-changed',
      callback: (event) {
        final carId = event.data['carId'];
        final status = event.data['status'];
        
        if (status == 'available') {
          _addCarToList(carId);
        } else {
          _removeCarFromList(carId);
        }
      },
    );
  }
  
  void _addCarToList(String carId) {
    // Fetch car details and add to list
    print('Car $carId is now available');
  }
  
  void _removeCarFromList(String carId) {
    availableCars.removeWhere((car) => car.id == carId);
  }
}
```

### Example 3: Chat with Typing Indicators

```dart
class ChatController extends GetxController {
  final PusherChannelsController _pusher = Get.find();
  RxBool isOtherUserTyping = false.obs;
  
  Future<void> joinChatRoom(String roomId) async {
    final channelName = 'private-chat-$roomId';
    
    await _pusher.subscribeToPrivateChannel(channelName);
    
    // Listen for typing indicators
    await _pusher.bindToEvent(
      channelName: channelName,
      eventName: 'client-typing',
      callback: (event) {
        isOtherUserTyping.value = event.data['isTyping'] ?? false;
      },
    );
    
    // Listen for messages
    await _pusher.bindToEvent(
      channelName: channelName,
      eventName: 'new-message',
      callback: _handleNewMessage,
    );
  }
  
  Future<void> sendTypingIndicator(bool isTyping) async {
    await _pusher.triggerClientEvent(
      channelName: 'private-chat-123',
      eventName: 'client-typing',
      data: {'isTyping': isTyping},
    );
  }
  
  void _handleNewMessage(PusherEvent event) {
    final message = event.data['message'];
    print('New message: $message');
    // Add to messages list
  }
}
```

---

## 🔧 Troubleshooting

### Connection Issues

**Problem:** Can't connect to Pusher
**Solutions:**
1. Verify API key and cluster are correct
2. Check internet connection
3. Enable debug logging:
   ```dart
   PusherChannelsFlutter.getInstance().init(
     apiKey: apiKey,
     cluster: cluster,
     logToConsole: true, // Enable debug logs
   );
   ```

### Authentication Errors (Private Channels)

**Problem:** 401 error when subscribing to private channel
**Solutions:**
1. Ensure backend authentication endpoint is set up
2. Configure auth endpoint in initialization:
   ```dart
   await pusher.init(
     apiKey: apiKey,
     cluster: cluster,
     authEndpoint: 'https://your-server.com/pusher/auth',
   );
   ```
3. Include auth headers if needed

### Events Not Received

**Problem:** Not receiving events
**Solutions:**
1. Verify you're subscribed to the channel
2. Check event name matches exactly (case-sensitive)
3. Use debug console in Pusher Dashboard to test events
4. Ensure app is in foreground (some platforms)

### Client Events Not Working

**Problem:** Client events fail to trigger
**Solutions:**
1. Enable client events in Pusher Dashboard settings
2. Verify event name starts with 'client-'
3. Ensure channel is private or presence (not public)

---

## 📚 Additional Resources

- [Pusher Channels Documentation](https://pusher.com/docs/channels)
- [pusher_channels_flutter GitHub](https://github.com/pusher/pusher-channels-flutter)
- [Pusher Dashboard](https://dashboard.pusher.com/)
- [API Reference](https://pusher.com/docs/channels/library_auth_reference/rest-api)

---

## 🆘 Need Help?

1. Check [Pusher Status](https://status.pusher.com/)
2. Review [Pusher Support](https://support.pusher.com/)
3. Check connection state: `controller.connectionState.value`
4. Review logs with Logger package

---

**Happy Real-Time Coding! 🚀**
