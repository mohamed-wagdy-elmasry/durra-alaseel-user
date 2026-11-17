import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pusher_beams/pusher_beams.dart';

import 'push_notification_service.dart';
import 'awesome_notification_service.dart';

/// Controller for managing push notification state and interactions.
/// 
/// Extends GetxController for lifecycle management and reactive updates.
/// Provides reactive observable properties for UI state updates.
class PushNotificationController extends GetxController {
  final PushNotificationService _service = PushNotificationService();
  final Logger _logger = Logger();

  // Reactive properties
  RxBool isInitialized = false.obs;
  RxBool isLoading = false.obs;
  RxList<String> deviceInterests = <String>[].obs;
  Rx<String?> currentUserId = Rx<String?>(null);
  RxString? lastMessage = RxString('');

  /// Initializes push notifications using the provided Pusher Beams instance ID.
  /// 
  /// Should be called once during app startup.
  /// The [instanceId] is obtained from your Pusher Beams dashboard.
  Future<void> initializePushNotifications(String instanceId) async {
    try {
      isLoading.value = true;

      await _service.initialize(instanceId);

      // Load current interests
      await _refreshInterests();

      // Setup message callbacks
      _setupCallbacks();

      isInitialized.value = true;
      _logger.i('Push notifications ready for use');
    } catch (e) {
      _logger.e('Failed to initialize push notifications: $e');
      isInitialized.value = false;
      // Don't rethrow - allow app to continue without push notifications
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds an interest for receiving targeted notifications.
  /// 
  /// Examples: 'premium_member', 'sedan_cars', 'city_offers'
  Future<void> addInterest(String interest) async {
    try {
      isLoading.value = true;
      await _service.addInterest(interest);
      await _refreshInterests();
    } catch (e) {
      _logger.e('Error adding interest: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Removes a specific interest.
  Future<void> removeInterest(String interest) async {
    try {
      isLoading.value = true;
      await _service.removeInterest(interest);
      await _refreshInterests();
    } catch (e) {
      _logger.e('Error removing interest: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Replaces all interests with the provided list.
  /// 
  /// Useful for syncing interests based on user preferences or profile.
  Future<void> updateInterests(List<String> interests) async {
    try {
      isLoading.value = true;
      if (interests.isEmpty) {
        await _service.clearInterests();
      } else {
        await _service.setInterests(interests);
      }
      await _refreshInterests();
    } catch (e) {
      _logger.e('Error updating interests: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears all device interests.
  Future<void> clearAllInterests() async {
    try {
      isLoading.value = true;
      await _service.clearInterests();
      await _refreshInterests();
    } catch (e) {
      _logger.e('Error clearing interests: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sets user ID for personalized notifications.
  /// 
  /// Call this after user login. Supports optional authentication provider
  /// for secure user identification on backend.
  /// 
  /// Example with authentication:
  /// ```dart
  /// final provider = BeamsAuthProvider()
  ///   ..authUrl = 'https://your-server.com/authenticate'
  ///   ..headers = {'Authorization': 'Bearer $token'};
  /// await controller.setUserId(userId, provider: provider);
  /// ```
  Future<void> setUserId(
    String userId, {
    BeamsAuthProvider? provider,
  }) async {
    try {
      isLoading.value = true;
      await _service.setUserId(userId, provider: provider);
      currentUserId.value = userId;
    } catch (e) {
      _logger.e('Error setting user ID: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears all notification state including user ID and interests.
  /// 
  /// Call this on user logout. The device will no longer receive notifications.
  Future<void> clearAllState() async {
    try {
      isLoading.value = true;
      await _service.clearAllState();
      currentUserId.value = null;
      deviceInterests.clear();
    } catch (e) {
      _logger.e('Error clearing state: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Stops the push notification service.
  /// 
  /// Reinitialize with [initializePushNotifications] to resume.
  Future<void> stopService() async {
    try {
      await _service.stop();
      isInitialized.value = false;
    } catch (e) {
      _logger.e('Error stopping service: $e');
      rethrow;
    }
  }

  /// Subscribe user to push notifications using user ID.
  /// Should be called after user login.
  /// 
  /// The service will automatically create a publishable ID in the format:
  /// user-{userId}
  Future<void> subscribeUser(int userId) async {
    try {
      isLoading.value = true;
      _logger.i('🚀 Controller: Starting subscription for user $userId');
      await _service.subscribeUser(userId);
      currentUserId.value = userId.toString();
      _logger.i('✅ Controller: Subscription completed for user $userId');
    } catch (e, stackTrace) {
      _logger.e('❌ Controller: Error subscribing user: $e');
      _logger.e('Stack trace: $stackTrace');
      // Don't rethrow - allow app to continue without push notifications
    } finally {
      isLoading.value = false;
    }
  }

  /// Unsubscribe user from push notifications.
  /// Should be called on user logout.
  Future<void> unsubscribeUser() async {
    try {
      isLoading.value = true;
      _logger.i('Unsubscribing user from push notifications');
      await _service.unsubscribeUser();
      currentUserId.value = null;
      deviceInterests.clear();
    } catch (e) {
      _logger.e('Error unsubscribing user: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Request notification permissions (iOS).
  /// Returns true if permissions are granted.
  Future<bool> requestPermissions() async {
    try {
      return await _service.requestPermissions();
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  /// Refreshes the device interests list from service.
  Future<void> _refreshInterests() async {
    try {
      final interests = await _service.getInterests();
      deviceInterests.assignAll(interests);
    } catch (e) {
      _logger.e('Error refreshing interests: $e');
    }
  }

  void _setupCallbacks() {
    // Setup foreground message handler
    _service.onForegroundMessage((notification) {
      _logger.i('Notification received in foreground: $notification');
      lastMessage?.value = notification.toString();
      _handleNotification(notification);
    });

    // Setup interest changes listener
    _service.onInterestChanged((interests) {
      _logger.d('Device interests updated: $interests');
      deviceInterests.assignAll(interests);
    });
  }

  /// Handle notification data - override or extend as needed
  void _handleNotification(Map<String, dynamic> notification) {
    // Extract common fields
    final title = notification['title'] as String?;
    final body = notification['body'] as String?;
    final data = notification['data'] as Map?;

    _logger.i('Processing notification: title=$title, body=$body, data=$data');
    
    // Create Awesome Notification instead of snackbar
    // This provides rich notification display with actions and better UX
    AwesomeNotificationService.createNotificationFromPusher(
      pusherData: notification,
    );
    
    // Optional: Still show in-app snackbar for immediate visibility
    // Uncomment if you want both notification tray AND in-app alert
    /*
    if (Get.context != null && title != null) {
      Get.snackbar(
        title,
        body ?? 'New notification',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.notifications, color: Colors.white),
        shouldIconPulse: true,
        onTap: (_) {
          _logger.i('User tapped notification snackbar');
          // Navigate based on notification type
          AwesomeNotificationService.onActionReceivedMethod(
            ReceivedAction(
              payload: notification.map((k, v) => MapEntry(k.toString(), v?.toString())),
            ),
          );
        },
      );
    }
    */
    
    // Custom notification handling logic here
    // Examples:
    // - Update UI state based on notification type
    // - Play sound or vibration
    // - Log analytics event
  }

  @override
  void onClose() {
    _logger.d('PushNotificationController disposed');
    super.onClose();
  }
}
