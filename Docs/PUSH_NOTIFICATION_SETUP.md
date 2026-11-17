# Push Notifications Configuration Guide

## Prerequisites

Before setting up push notifications, ensure you have:
- A Pusher Beams account (https://pusher.com/beams)
- Your Pusher Beams Instance ID
- Firebase project linked with Pusher Beams (for Android)
- APNs certificate setup (for iOS)

## Installation

The package `pusher_beams: ^1.2.0` has been added to `pubspec.yaml`.

Run:
```bash
flutter pub get
```

## Configuration

### Dart Code

The instance ID needs to be set in `lib/initializer.dart`:

```dart
const instanceId = 'YOUR_INSTANCE_ID';  // Replace with your actual Pusher Beams Instance ID
```

### Android Setup

**Status**: ✅ Already configured

The following are already in place:
- `android/build.gradle`: Google Services Gradle plugin (4.3.8)
- `android/app/build.gradle`: Firebase messaging and Pusher push notifications dependencies
- `android/app/google-services.json`: Firebase configuration file

**What you need to do**:
1. Ensure `android/app/google-services.json` is in place (it's already there)
2. Ensure `minSdkVersion` is at least 19 (currently using Flutter's default)

**Troubleshooting**:
- If google-services.json is missing, download it from Firebase Console:
  - Go to Firebase Project Settings
  - Download the `google-services.json` file
  - Place it in `android/app/`

### iOS Setup

**Status**: ⚠️ Manual configuration required

**Required Steps**:

1. **Enable Push Notifications Capability**:
   - Open iOS project: `open ios/Runner.xcworkspace`
   - Select "Runner" target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Push Notifications"

2. **Configure APNs Certificate**:
   - Go to Apple Developer Portal (https://developer.apple.com/account/)
   - Navigate to Certificates, Identifiers & Profiles
   - Create or select your App ID
   - Enable Push Notifications
   - Create a new APNs certificate (Development or Production)
   - Download the certificate and upload it to Pusher Beams dashboard

3. **Additional Capabilities** (if needed):
   - Background Modes: Enable "Remote notifications" if you want to handle notifications in background

4. **Minimum iOS Version**:
   - Ensure minimum deployment target is iOS 10.0 or higher
   - Check in Xcode: Build Settings → Minimum Deployments → iOS Deployment Target

**Update Podfile if needed**:
File: `ios/Podfile`
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### Web Setup

**Status**: ⚠️ Manual configuration required (if using web)

1. **Create service-worker.js**:
   Create file `web/service-worker.js`:
   ```javascript
   importScripts("https://js.pusher.com/beams/service-worker.js");
   ```

2. **Update web/index.html**:
   Add this script tag at the beginning of the body (before Flutter app loads):
   ```html
   <script src="https://js.pusher.com/beams/1.0/push-notifications-cdn.js"></script>
   ```

## Usage

### Basic Initialization

Push notifications are automatically initialized in the app. The instance is set up in `lib/initializer.dart`.

### Add Device Interests

```dart
final controller = Get.find<PushNotificationController>();
await controller.addInterest('premium_member');
await controller.addInterest('sedan_cars');
```

### Set User ID (After Login)

```dart
await controller.setUserId('user@example.com');
```

Or with authentication:

```dart
final provider = BeamsAuthProvider()
  ..authUrl = 'https://your-server.com/authenticate'
  ..headers = {'Authorization': 'Bearer $token'};

await controller.setUserId('user-id', provider: provider);
```

### Clear State (On Logout)

```dart
await controller.clearAllState();
```

### Handle Notifications in UI

```dart
class MyWidget extends GetView<PushNotificationController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Text('Interests: ${controller.deviceInterests.join(", ")}'),
    );
  }
}
```

## Architecture

The implementation follows SOLID principles:

- **Single Responsibility**: 
  - `PushNotificationService`: Handles all Pusher Beams operations
  - `PushNotificationController`: Manages state and UI interactions

- **Open/Closed**: Easy to extend or swap notification providers

- **Liskov Substitution**: Service methods are predictable and extensible

- **Interface Segregation**: Methods are focused on specific tasks

- **Dependency Inversion**: Uses abstraction through GetX's dependency injection

## Files Created

1. `lib/backend/services/push_notification_service.dart`: Core service
2. `lib/backend/services/push_notification_controller.dart`: GetX controller
3. `lib/initializer.dart`: Updated with push notification initialization

## Testing

Test notifications using Pusher Beams Dashboard:
1. Go to your Pusher Beams dashboard
2. Create a new notification/campaign
3. Set interests to match device interests
4. Send a test notification

## Environment Variables (Optional)

For security, you can store the instance ID in environment:

```dart
// In your config file
abstract class Config {
  static const String pusherBeamsInstanceId = String.fromEnvironment(
    'PUSHER_INSTANCE_ID',
    defaultValue: 'YOUR_INSTANCE_ID',
  );
}
```

Then use:
```dart
await controller.initializePushNotifications(Config.pusherBeamsInstanceId);
```

## Debugging

Enable debug logging to see push notification events:

```dart
// In push_notification_service.dart, the Logger provides debug info
// Watch the console output starting with "PushNotificationController" or "PushNotificationService"
```

## Common Issues

### Android
- **Multidex error**: Ensure minSdkVersion >= 21 or [enable multidex](https://firebase.flutter.dev/docs/manual-installation/android#enabling-multidex)
- **google-services.json not found**: Download from Firebase Console

### iOS
- **Push notification permission not requested**: Device needs to grant notification permission first
- **Certificate mismatch**: Ensure APNs certificate matches your bundle ID

### General
- **Instance ID invalid**: Double-check your Pusher Beams instance ID
- **Notifications not received**: Check device interests match the sent notification

## Next Steps

1. Replace `'YOUR_INSTANCE_ID'` in `lib/initializer.dart`
2. Follow platform-specific setup (Android/iOS/Web)
3. Test with Pusher Beams dashboard
4. Implement custom notification handling in `_handleNotification()` method if needed
