import 'package:get/get.dart';
import 'package:pusher_beams/pusher_beams.dart';

import 'push_notification_controller.dart';

/// Example usage of PushNotificationController
/// 
/// This file demonstrates common patterns for using push notifications
/// in your application.

/// Example 1: Managing user interests (e.g., car preferences)
void exampleUserInterests() {
  final controller = Get.find<PushNotificationController>();

  // Add single interest
  controller.addInterest('luxury_vehicles');

  // Add multiple interests
  controller.updateInterests(['sedan', 'luxury_vehicles', 'premium_member']);

  // Remove specific interest
  controller.removeInterest('sedan');

  // Clear all interests
  controller.clearAllInterests();

  // Get current interests (this is a reactive observable)
  // Interests update automatically in the UI
  // Use Obx(() => Text('Interests: ${controller.deviceInterests}'))
}

/// Example 2: Handling user authentication flow
void exampleAuthenticationFlow() {
  final controller = Get.find<PushNotificationController>();

  // On user login - set user ID for personalized notifications
  Future<void> onUserLogin(String userId, String? authToken) async {
    // Basic user ID without authentication
    await controller.setUserId(userId);

    // OR with authentication for secure notification delivery
    final provider = BeamsAuthProvider()
      ..authUrl = 'https://your-api.com/authenticate'
      ..headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      }
      ..queryParams = {'platform': 'flutter'};

    await controller.setUserId(userId, provider: provider);

    // Update interests based on user profile
    await controller.updateInterests(['member', 'active_user']);
  }

  // On user logout - clear all state
  Future<void> onUserLogout() async {
    await controller.clearAllState();
  }
}

/// Example 3: Syncing device interests with user preferences
void examplePreferenceSyncing() async {
  final controller = Get.find<PushNotificationController>();

  // Scenario: User preferences changed
  final userPreferences = [
    'sedan_cars',
    'premium_offers',
    'weekly_deals',
  ];

  // Update device interests to match user preferences
  await controller.updateInterests(userPreferences);
}

/// Example 4: Displaying notifications in UI
void exampleUIIntegration() {
  // In your widget:
  // Obx(() {
  //   return Column(
  //     children: [
  //       Text('Your Interests:'),
  //       ...controller.deviceInterests.map((interest) => 
  //         Chip(label: Text(interest))
  //       ).toList(),
  //       if (controller.isLoading.value)
  //         CircularProgressIndicator(),
  //     ],
  //   );
  // });
}

/// Example 5: Handling different notification types
void exampleNotificationHandling() {
  final controller = Get.find<PushNotificationController>();

  // Watch for UI changes when messages arrive
  final _ = controller.lastMessage;  // Reference for watching changes
  
  // To extend notification handling, override _handleNotification 
  // in PushNotificationController based on your app's specific needs
}

/// Example 6: Reactive property usage in GetX
void exampleReactiveProperties() {
  final controller = Get.find<PushNotificationController>();

  // Watch initialization status
  ever(controller.isInitialized, (isInit) {
    print('Push notifications ${isInit ? 'ready' : 'not ready'}');
  });

  // Watch loading state
  ever(controller.isLoading, (isLoading) {
    if (isLoading) {
      print('Push notification operation in progress');
    }
  });

  // Watch interests changes
  ever(controller.deviceInterests, (interests) {
    print('Interests updated: $interests');
  });

  // Watch current user ID
  ever(controller.currentUserId, (userId) {
    print('User ID: $userId');
  });
}

/// Example 7: Error handling
void exampleErrorHandling() async {
  final controller = Get.find<PushNotificationController>();

  try {
    await controller.addInterest('new_feature');
  } catch (e) {
    print('Failed to add interest: $e');
    // Show error to user or retry
  }

  try {
    await controller.setUserId('user@example.com');
  } catch (e) {
    print('Failed to set user ID: $e');
    // Show error message like "Authentication failed"
  }
}

/// Example 8: Service lifecycle
void exampleLifecycle() {
  final controller = Get.find<PushNotificationController>();

  // Start service
  Future<void> startNotifications() async {
    await controller.initializePushNotifications('YOUR_INSTANCE_ID');
  }

  // Stop service
  Future<void> stopNotifications() async {
    await controller.stopService();
  }

  // Clear but keep running
  Future<void> resetNotifications() async {
    await controller.clearAllState();
  }
}
