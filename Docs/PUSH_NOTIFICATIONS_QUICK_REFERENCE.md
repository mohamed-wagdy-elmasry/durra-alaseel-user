# Push Notifications - Quick Reference

## Installation & Setup

✅ **Already Done:**
- Added `pusher_beams: ^1.2.0` to `pubspec.yaml`
- Created `PushNotificationService` (core service)
- Created `PushNotificationController` (GetX controller)
- Integrated into app initialization
- Android dependencies configured
- Web service worker setup

⚠️ **Manual Setup Required:**
- Replace `'YOUR_INSTANCE_ID'` in `lib/initializer.dart` with your Pusher Beams instance ID
- Complete iOS APNs configuration (see `PUSH_NOTIFICATION_SETUP.md`)
- Download `google-services.json` if not present (Android)

---

## Quick Start

### 1. Set Your Instance ID

**File:** `lib/initializer.dart`

```dart
const instanceId = 'abc123def456';  // Replace with your actual instance ID
```

### 2. Use in Your App

```dart
import 'package:get/get.dart';
import 'package:carbo/backend/services/push_notification_controller.dart';

class MyScreen extends GetView<PushNotificationController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Text('Status: ${controller.isInitialized.value ? "Ready" : "Loading"}'),
        Text('Your Interests: ${controller.deviceInterests.join(", ")}'),
      ],
    ));
  }
}
```

---

## Common Operations

### Add Interest
```dart
final controller = Get.find<PushNotificationController>();
await controller.addInterest('sedan_cars');
```

### Remove Interest
```dart
await controller.removeInterest('sedan_cars');
```

### Set Multiple Interests
```dart
await controller.updateInterests(['sedan', 'luxury', 'premium']);
```

### Get Current Interests
```dart
final interests = controller.deviceInterests;  // Reactive
```

### On User Login
```dart
await controller.setUserId('user@example.com');

// Or with authentication
final provider = BeamsAuthProvider()
  ..authUrl = 'https://api.example.com/auth'
  ..headers = {'Authorization': 'Bearer $token'};

await controller.setUserId('user@example.com', provider: provider);
```

### On User Logout
```dart
await controller.clearAllState();
```

### Clear All Interests
```dart
await controller.clearAllInterests();
```

---

## Reactive State Management

All properties are observable (reactive):

```dart
Obx(() {
  if (controller.isLoading.value) return CircularProgressIndicator();
  if (!controller.isInitialized.value) return Text('Initializing...');
  
  return Column(
    children: [
      Text('Interests: ${controller.deviceInterests.join(", ")}'),
      Text('User: ${controller.currentUserId.value ?? "Not logged in"}'),
    ],
  );
});
```

---

## Handle Foreground Messages

Messages received while app is open:

```dart
@override
void initState() {
  super.initState();
  final controller = Get.find<PushNotificationController>();
  
  // This is called automatically, but you can extend the handler
  // to perform custom actions (navigate, show dialog, etc.)
}
```

Customize in `lib/backend/services/push_notification_controller.dart` → `_handleNotification()` method.

---

## Error Handling

```dart
try {
  await controller.addInterest('new_interest');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed: $e')),
  );
}
```

---

## Architecture Overview

```
lib/
├── initializer.dart
│   └── Initializes PushNotificationController
├── main.dart
│   └── Calls AppInitializer.init()
└── backend/
    └── services/
        ├── push_notification_service.dart (Core logic)
        ├── push_notification_controller.dart (GetX controller)
        └── push_notification_examples.dart (Usage examples)
```

### Separation of Concerns

| Component | Responsibility |
|-----------|-----------------|
| **Service** | Only Pusher Beams operations |
| **Controller** | State management, error handling, UI updates |
| **UI Widgets** | Display state using Obx() |

---

## Testing Notifications

1. Go to **Pusher Beams Dashboard**
2. Create a notification/campaign
3. Set **Interests** to match device interests
4. Set **Target Devices** (all/specific)
5. Send test notification
6. Check device for notification

---

## Debugging

Enable debug logging to console:

```dart
// Logs are automatically printed using Logger package
// Watch console output for messages starting with:
// - "PushNotificationService:"
// - "PushNotificationController:"
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Instance ID not set | Replace 'YOUR_INSTANCE_ID' in initializer.dart |
| Notifications not received | Check device interests match notification target |
| iOS push not working | Complete APNs setup (see PUSH_NOTIFICATION_SETUP.md) |
| Multidex error (Android) | Enable multidex or increase minSdkVersion to 21+ |
| Initialization fails | Check Firebase Console for google-services.json |

---

## API Reference

### PushNotificationController Methods

```dart
// Lifecycle
Future<void> initializePushNotifications(String instanceId)
Future<void> stopService()

// Interest Management
Future<void> addInterest(String interest)
Future<void> removeInterest(String interest)
Future<void> updateInterests(List<String> interests)
Future<void> clearAllInterests()

// User Management
Future<void> setUserId(String userId, {BeamsAuthProvider? provider})
Future<void> clearAllState()

// Reactive Properties
RxBool isInitialized          // Service ready
RxBool isLoading              // Operation in progress
RxList<String> deviceInterests  // Current interests
Rx<String?> currentUserId     // Logged in user
RxString? lastMessage         // Last received message
```

---

## Integration Examples

### With Login/Register Flow
```dart
// After successful login
final userId = response.user.id;
await controller.setUserId(userId);

// Update interests based on user preferences
await controller.updateInterests(userPreferences);
```

### With Ride Booking
```dart
// User books a ride
await controller.addInterest('active_rider');

// Ride completed
await controller.removeInterest('active_rider');
```

### With Preference Changes
```dart
// User updates car preferences
final preferences = ['sedan', 'luxury', 'automatic'];
await controller.updateInterests(preferences);
```

---

## Performance Notes

- Service initializes during app startup (non-blocking)
- Operations are async - use `await` for proper sequencing
- State updates are reactive - no manual setState needed
- All errors are caught and logged - check console for issues

---

## Next Steps

1. ✅ Set your Pusher Beams Instance ID
2. ✅ Test basic interest management
3. ✅ Implement user login integration
4. ✅ Customize `_handleNotification()` for app-specific logic
5. ✅ Complete platform-specific setup (iOS/Android)
6. ✅ Test with Pusher Beams dashboard

---

**For detailed setup instructions, see:** `PUSH_NOTIFICATION_SETUP.md`
