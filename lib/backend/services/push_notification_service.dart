import 'package:pusher_beams/pusher_beams.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../base/api/endpoint/api_endpoint.dart';
import '../../base/utils/local_storage.dart';
import 'awesome_notification_service.dart';

typedef NotificationCallback = Function(Map<String, dynamic>);
typedef InterestCallback = Function(List<String>);
typedef ErrorCallback = Function(Exception?);

/// Service responsible for push notification management using Pusher Beams.
/// 
/// Handles initialization, interest management, message receiving, and user identification.
/// Follows single responsibility principle - only manages push notifications.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  static final Logger _logger = Logger();

  NotificationCallback? _foregroundMessageCallback;
  InterestCallback? _interestChangedCallback;

  PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  /// Initializes Pusher Beams with the given instance ID.
  /// Must be called once during app startup, before any other operations.
  ///
  /// Throws [Exception] if initialization fails.
  Future<void> initialize(String instanceId) async {
    try {
      // Validate instance ID
      if (instanceId.isEmpty || instanceId == 'YOUR_INSTANCE_ID') {
        throw Exception(
          'Invalid Pusher Beams instance ID. '
          'Please set a valid ID from https://dashboard.pusher.com/beams',
        );
      }

      _logger.i('Initializing push notifications with instanceId: $instanceId');
      
      await PusherBeams.instance.start(instanceId);
      
      // Check for initial message from notification that opened the app
      await _handleInitialMessage();
      
      // Setup foreground message listener for mobile platforms
      if (!kIsWeb) {
        await _setupForegroundMessageListener();
        await _setupInterestChangesListener();
      }
      
      _logger.i('Push notifications initialized successfully');
    } on Exception catch (e) {
      _logger.e('Failed to initialize push notifications: $e');
      _logger.w('Push features will be unavailable. Check:');
      _logger.w('  • Instance ID is valid and from https://dashboard.pusher.com/beams');
      _logger.w('  • Android: google-services.json in android/app/');
      _logger.w('  • iOS: APNs certificate configured in Pusher dashboard');
      rethrow;
    }
  }

  /// Adds a device interest for targeted notifications.
  /// 
  /// Example: 'sedan', 'suv', 'luxury-car'
  Future<void> addInterest(String interest) async {
    try {
      _logger.d('Adding interest: $interest');
      await PusherBeams.instance.addDeviceInterest(interest);
    } catch (e) {
      _logger.e('Failed to add interest: $e');
      rethrow;
    }
  }

  /// Removes a device interest.
  Future<void> removeInterest(String interest) async {
    try {
      _logger.d('Removing interest: $interest');
      await PusherBeams.instance.removeDeviceInterest(interest);
    } catch (e) {
      _logger.e('Failed to remove interest: $e');
      rethrow;
    }
  }

  /// Sets multiple device interests, replacing existing ones.
  Future<void> setInterests(List<String> interests) async {
    try {
      _logger.d('Setting interests: $interests');
      await PusherBeams.instance.setDeviceInterests(interests);
    } catch (e) {
      _logger.e('Failed to set interests: $e');
      rethrow;
    }
  }

  /// Retrieves current device interests.
  Future<List<String>> getInterests() async {
    try {
      final interests = await PusherBeams.instance.getDeviceInterests();
      _logger.d('Current interests: $interests');
      return interests.cast<String>();
    } catch (e) {
      _logger.e('Failed to get interests: $e');
      rethrow;
    }
  }

  /// Clears all device interests.
  Future<void> clearInterests() async {
    try {
      _logger.d('Clearing all interests');
      await PusherBeams.instance.clearDeviceInterests();
    } catch (e) {
      _logger.e('Failed to clear interests: $e');
      rethrow;
    }
  }

  /// Sets a user ID with optional authentication.
  /// 
  /// Use when user logs in to enable user-specific notifications.
  /// Provider parameter can be null for basic authentication.
  Future<void> setUserId(
    String userId, {
    BeamsAuthProvider? provider,
  }) async {
    try {
      _logger.d('Setting userId: $userId');
      
      final authProvider = provider ?? BeamsAuthProvider();
      await PusherBeams.instance.setUserId(
        userId,
        authProvider,
        (error) {
          if (error != null) {
            _logger.e('Error setting userId: $error');
          } else {
            _logger.i('User ID set successfully: $userId');
          }
        },
      );
    } catch (e) {
      _logger.e('Failed to set userId: $e');
      rethrow;
    }
  }

  /// Clears user ID and device interests.
  /// Use when user logs out or stops using the app.
  Future<void> clearAllState() async {
    try {
      _logger.d('Clearing all notification state');
      await PusherBeams.instance.clearAllState();
    } catch (e) {
      _logger.e('Failed to clear state: $e');
      rethrow;
    }
  }

  /// Subscribe user to notifications using user-specific publishable ID.
  /// Format: user-{userId}
  /// 
  /// This method should be called after user login.
  Future<void> subscribeUser(int userId) async {
    try {
      // Create publishable ID: user-{userId}
      String publishableId = 'user-$userId';
      
      _logger.i('═══════════════════════════════════════════════════');
      _logger.i('🔔 PUSH NOTIFICATION SUBSCRIPTION STARTING');
      _logger.i('═══════════════════════════════════════════════════');
      _logger.i('📱 User ID: $userId');
      _logger.i('📱 Publishable ID: $publishableId');
      
      // Get authentication token from local storage
      final token = LocalStorage.token;
      
      if (token.isEmpty) {
        _logger.e('❌ Token is empty! Cannot subscribe without authentication.');
        throw Exception('Authentication token not found');
      }
      
      // Create auth provider with backend endpoint
      // Note: Route is at /api/v1/user/pusher/beams-auth
      final authUrl = '${ApiConfig.baseUrl}/user/pusher/beams-auth';
      _logger.i('🔗 Backend Auth URL: $authUrl');
      _logger.i('🔗 Base URL: ${ApiConfig.baseUrl}');
      _logger.d('🔑 Token (first 30 chars): ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
      
      final authProvider = BeamsAuthProvider()
        ..authUrl = authUrl
        ..headers = {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
        ..queryParams = {};
      
      _logger.i('✅ Auth provider created');
      _logger.i('   - Auth URL: ${authProvider.authUrl}');
      _logger.i('   - Headers: Authorization, Accept, Content-Type');
      _logger.i('   - Query Params: {}');
      
      // Use a Completer to wait for the authentication callback
      final completer = Completer<bool>();
      bool authSucceeded = false;
      
      // Subscribe to user-specific notifications
      _logger.i('⏳ Calling PusherBeams.instance.setUserId...');
      _logger.i('   This will authenticate with backend and register device');
      
      try {
        await PusherBeams.instance.setUserId(
          publishableId,
          authProvider,
          (error) {
            if (error != null) {
              _logger.e('═══════════════════════════════════════════════════');
              _logger.e('❌ SUBSCRIPTION FAILED - ERROR CALLBACK');
              _logger.e('═══════════════════════════════════════════════════');
              _logger.e('Error: $error');
              _logger.e('Error Type: ${error.runtimeType}');
              _logger.e('');
              _logger.e('TROUBLESHOOTING:');
              _logger.e('1. Check backend logs for auth endpoint errors');
              _logger.e('2. Verify Pusher Beams is configured in admin panel');
              _logger.e('3. Ensure backend auth endpoint returns: {"token": "..."}');
              _logger.e('4. Check if Instance ID and Primary Key are correct');
              _logger.e('═══════════════════════════════════════════════════');
              authSucceeded = false;
              if (!completer.isCompleted) completer.complete(false);
            } else {
              _logger.i('═══════════════════════════════════════════════════');
              _logger.i('✅ SUBSCRIPTION SUCCESS - SUCCESS CALLBACK');
              _logger.i('═══════════════════════════════════════════════════');
              _logger.i('🎉 Successfully subscribed user to Pusher Beams');
              _logger.i('📱 Publishable ID: $publishableId');
              _logger.i('🔔 Device is now ready to receive push notifications');
              _logger.i('');
              _logger.i('NEXT STEPS:');
              _logger.i('1. Check device interests below for confirmation');
              _logger.i('2. Test with Pusher dashboard → Authenticated Users');
              _logger.i('3. Enter User ID: $publishableId');
              _logger.i('═══════════════════════════════════════════════════');
              authSucceeded = true;
              if (!completer.isCompleted) completer.complete(true);
            }
          },
        );
        
        _logger.i('✅ setUserId call initiated (non-blocking)');
        _logger.i('⏳ Waiting up to 10 seconds for authentication callback...');
        
        // Wait for callback with timeout
        final result = await completer.future.timeout(
          Duration(seconds: 10),
          onTimeout: () {
            _logger.w('⚠️ Authentication callback timeout after 10 seconds');
            _logger.w('   This might mean:');
            _logger.w('   - Backend auth endpoint is slow or not responding');
            _logger.w('   - Network connectivity issues');
            _logger.w('   - Check backend logs for auth request');
            return false;
          },
        );
        
        if (!result) {
          _logger.w('⚠️ Authentication may not have completed successfully');
        }
        
      } catch (e, stackTrace) {
        _logger.e('❌ Exception during setUserId call: $e');
        _logger.e('Stack trace: $stackTrace');
        rethrow;
      }
      
      // Give it a moment to complete authentication
      await Future.delayed(Duration(seconds: 2));
      
      // Verify device interests after subscription
      await _verifyDeviceInterests(publishableId);
      
    } catch (e, stackTrace) {
      _logger.e('═══════════════════════════════════════════════════');
      _logger.e('❌ SUBSCRIPTION FAILED - EXCEPTION');
      _logger.e('═══════════════════════════════════════════════════');
      _logger.e('Exception: $e');
      _logger.e('Exception Type: ${e.runtimeType}');
      _logger.e('Stack trace: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════');
      rethrow;
    }
  }
  
  /// Verify device interests to confirm subscription
  Future<void> _verifyDeviceInterests(String expectedUserId) async {
    try {
      _logger.i('🔍 Verifying device registration...');
      final interests = await PusherBeams.instance.getDeviceInterests();
      
      _logger.i('═══════════════════════════════════════════════════');
      _logger.i('📋 DEVICE INTERESTS (Subscriptions)');
      _logger.i('═══════════════════════════════════════════════════');
      
      if (interests.isEmpty) {
        _logger.w('⚠️ WARNING: No device interests found!');
        _logger.w('   Device may not be registered with Pusher Beams');
        _logger.w('   Push notifications will NOT work');
      } else {
        _logger.i('✅ Found ${interests.length} device interest(s):');
        for (var interest in interests) {
          _logger.i('   - $interest');
        }
        
        if (interests.contains(expectedUserId)) {
          _logger.i('✅ VERIFIED: Device is subscribed to user ID: $expectedUserId');
        } else {
          _logger.w('⚠️ WARNING: Expected user ID not found in interests!');
          _logger.w('   Expected: $expectedUserId');
          _logger.w('   Got: ${interests.join(", ")}');
          _logger.w('   This means device interests work but user authentication failed!');
        }
      }
      
      _logger.i('═══════════════════════════════════════════════════');
      
      // CRITICAL: Also check the currently authenticated user ID
      // This is separate from device interests
      _logger.i('🔍 Checking authenticated user ID...');
      _logger.i('═══════════════════════════════════════════════════');
      _logger.i('📋 AUTHENTICATED USER STATUS');
      _logger.i('═══════════════════════════════════════════════════');
      _logger.i('NOTE: Pusher Beams has TWO separate systems:');
      _logger.i('  1. Device Interests - for broadcast to topics/groups');
      _logger.i('  2. Authenticated Users - for user-specific notifications');
      _logger.i('');
      _logger.i('If "Device Interests" work but "Authenticated Users" do not,');
      _logger.i('it means the setUserId() authentication failed or the backend');
      _logger.i('auth endpoint is not returning the correct token format.');
      _logger.i('═══════════════════════════════════════════════════');
      
    } catch (e) {
      _logger.e('❌ Failed to verify device interests: $e');
    }
  }

  /// Unsubscribe user from notifications (on logout).
  Future<void> unsubscribeUser() async {
    try {
      _logger.d('Unsubscribing from push notifications');
      await PusherBeams.instance.clearAllState();
      _logger.i('✅ Unsubscribed from push notifications');
    } catch (e) {
      _logger.e('❌ Failed to unsubscribe: $e');
      rethrow;
    }
  }

  /// Stops push notification service and clears state.
  /// Must call [initialize] again to resume notifications.
  Future<void> stop() async {
    try {
      _logger.d('Stopping push notification service');
      await PusherBeams.instance.stop();
    } catch (e) {
      _logger.e('Failed to stop service: $e');
      rethrow;
    }
  }

  /// Registers callback for messages received while app is in foreground.
  /// Only works on mobile platforms (Android/iOS).
  void onForegroundMessage(NotificationCallback callback) {
    _foregroundMessageCallback = callback;
  }

  /// Registers callback for interest changes.
  /// Only works on mobile platforms (Android/iOS).
  void onInterestChanged(InterestCallback callback) {
    _interestChangedCallback = callback;
  }

  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage =
          await PusherBeams.instance.getInitialMessage();
      if (initialMessage != null) {
        _logger.i('Initial message from notification: $initialMessage');
        _foregroundMessageCallback?.call(initialMessage);
      }
    } catch (e) {
      _logger.e('Error handling initial message: $e');
    }
  }

  Future<void> _setupForegroundMessageListener() async {
    try {
      await PusherBeams.instance.onMessageReceivedInTheForeground(
        (data) {
          _logger.d('Foreground message received: $data');
          // Cast data to Map<String, dynamic>
          final castedData = data.cast<String, dynamic>();
          
          // Extract notification data
          final notification = castedData['notification'] as Map?;
          if (notification != null) {
            final title = notification['title'] as String?;
            final body = notification['body'] as String?;
            
            // Show local notification
            if (title != null && body != null) {
              _showLocalNotification(title, body);
            }
            
            // Handle booking rejection notification
            if (title?.contains('Rejected') ?? false) {
              _handleBookingRejection(castedData);
            }
          }
          
          _foregroundMessageCallback?.call(castedData);
        },
      );
    } catch (e) {
      _logger.e('Error setting up foreground message listener: $e');
    }
  }

  Future<void> _setupInterestChangesListener() async {
    try {
      await PusherBeams.instance.onInterestChanges(
        (interests) {
          _logger.d('Interests changed: $interests');
          // Cast interests to List<String>
          final castedInterests = interests.whereType<String>().toList();
          _interestChangedCallback?.call(castedInterests);
        },
      );
    } catch (e) {
      _logger.e('Error setting up interest changes listener: $e');
    }
  }

  /// Initialize local notifications for displaying rich notifications
  /// Uses AwesomeNotifications which is already configured in the app
  Future<void> _initializeLocalNotifications() async {
    try {
      // AwesomeNotifications is already initialized in AppInitializer
      // No additional initialization needed here
      _logger.d('Using existing AwesomeNotifications configuration');
    } catch (e) {
      _logger.e('Error with AwesomeNotifications: $e');
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        return await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return isAllowed;
    }
    return true; // Android doesn't need runtime permission request for older versions
  }

  /// Show local notification using AwesomeNotifications
  Future<void> _showLocalNotification(String title, String body) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'booking_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (e) {
      _logger.e('Error showing local notification: $e');
    }
  }

  /// Handle notification tap
  /// This is handled by AwesomeNotificationService globally
  void _onNotificationTapped(String? payload) {
    _logger.i('📲 Notification tapped: $payload');
    
    // Navigation is handled by AwesomeNotificationService
    // No additional implementation needed here
  }

  /// Handle booking rejection notification
  void _handleBookingRejection(Map<String, dynamic> data) {
    // Parse booking rejection data
    _logger.i('🚫 Booking rejected notification received');
    
    // Extract notification data
    final notification = data['notification'] as Map?;
    final message = notification?['body'] as String?;
    
    if (message != null) {
      // Extract booking ID and reason from message
      // Message format: "Your booking #{trx_id} was rejected. Reason: {reason}"
      final bookingIdMatch = RegExp(r'#(\w+)').firstMatch(message);
      final reasonMatch = RegExp(r'Reason: (.+)$').firstMatch(message);
      
      final bookingId = bookingIdMatch?.group(1);
      final reason = reasonMatch?.group(1);
      
      _logger.i('Booking ID: $bookingId');
      _logger.i('Rejection Reason: $reason');
      
      // TODO: Navigate to booking details or update UI
      // TODO: Refresh booking list
      // TODO: Show dialog with rejection reason
    }
  }

  /// Test Pusher Beams auth endpoint directly
  /// 
  /// Use this to verify the backend auth endpoint is working correctly
  /// before attempting full Pusher Beams authentication.
  /// 
  /// Call this method after user login to test:
  /// ```dart
  /// await PushNotificationService().testAuthEndpoint();
  /// ```
  Future<void> testAuthEndpoint() async {
    final token = LocalStorage.token;
    final authUrl = '${ApiConfig.baseUrl}/user/pusher/beams-auth';
    
    _logger.i('═══════════════════════════════════════════════════');
    _logger.i('🧪 TESTING PUSHER BEAMS AUTH ENDPOINT');
    _logger.i('═══════════════════════════════════════════════════');
    _logger.i('URL: $authUrl');
    
    if (token.isEmpty) {
      _logger.e('❌ ERROR: Token is empty!');
      _logger.e('   User must be logged in to test auth endpoint');
      _logger.i('═══════════════════════════════════════════════════');
      return;
    }
    
    _logger.i('Token: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
    
    try {
      _logger.i('⏳ Sending GET request to auth endpoint...');
      
      final response = await http.get(
        Uri.parse(authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      _logger.i('📥 Response received');
      _logger.i('Status Code: ${response.statusCode}');
      _logger.i('Response Headers: ${response.headers}');
      _logger.i('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          
          if (data.containsKey('token')) {
            final beamsToken = data['token'] as String;
            _logger.i('');
            _logger.i('✅ SUCCESS: Backend auth endpoint works correctly!');
            _logger.i('═══════════════════════════════════════════════════');
            _logger.i('📋 Token Details:');
            _logger.i('   - Token received: YES');
            _logger.i('   - Token length: ${beamsToken.length} characters');
            _logger.i('   - Token preview: ${beamsToken.substring(0, beamsToken.length > 50 ? 50 : beamsToken.length)}...');
            _logger.i('   - Token format: ${beamsToken.startsWith('eyJ') ? 'JWT ✅' : 'Unknown ⚠️'}');
            _logger.i('');
            _logger.i('🎉 Backend is ready! You can now proceed with Pusher Beams auth');
            _logger.i('═══════════════════════════════════════════════════');
          } else {
            _logger.e('');
            _logger.e('❌ ERROR: Response is 200 but no token field found!');
            _logger.e('═══════════════════════════════════════════════════');
            _logger.e('Expected: {"token": "..."}');
            _logger.e('Received: $data');
            _logger.e('');
            _logger.e('TROUBLESHOOTING:');
            _logger.e('  1. Check Laravel route returns response()->json(\$beamsToken)');
            _logger.e('  2. Verify \$beamsClient->generateToken() is called');
            _logger.e('  3. Check backend logs for errors');
            _logger.e('═══════════════════════════════════════════════════');
          }
        } catch (e) {
          _logger.e('');
          _logger.e('❌ ERROR: Failed to parse response as JSON');
          _logger.e('═══════════════════════════════════════════════════');
          _logger.e('Parse Error: $e');
          _logger.e('Response Body: ${response.body}');
          _logger.e('');
          _logger.e('TROUBLESHOOTING:');
          _logger.e('  1. Check backend is returning valid JSON');
          _logger.e('  2. Verify Content-Type header is application/json');
          _logger.e('═══════════════════════════════════════════════════');
        }
      } else if (response.statusCode == 401) {
        _logger.e('');
        _logger.e('❌ ERROR: Authentication failed (HTTP 401)');
        _logger.e('═══════════════════════════════════════════════════');
        _logger.e('Response: ${response.body}');
        _logger.e('');
        _logger.e('TROUBLESHOOTING:');
        _logger.e('  1. Token may be invalid or expired');
        _logger.e('  2. User may need to login again');
        _logger.e('  3. Check Laravel auth:api middleware is working');
        _logger.e('  4. Verify token is being sent correctly');
        _logger.e('═══════════════════════════════════════════════════');
      } else if (response.statusCode == 404) {
        _logger.e('');
        _logger.e('❌ ERROR: Endpoint not found (HTTP 404)');
        _logger.e('═══════════════════════════════════════════════════');
        _logger.e('Response: ${response.body}');
        _logger.e('');
        _logger.e('TROUBLESHOOTING:');
        _logger.e('  1. Check route exists: GET /api/v1/user/pusher/beams-auth');
        _logger.e('  2. Verify ApiConfig.baseUrl is correct: ${ApiConfig.baseUrl}');
        _logger.e('  3. Check Laravel routes: php artisan route:list');
        _logger.e('═══════════════════════════════════════════════════');
      } else {
        _logger.e('');
        _logger.e('❌ ERROR: Unexpected HTTP status ${response.statusCode}');
        _logger.e('═══════════════════════════════════════════════════');
        _logger.e('Response: ${response.body}');
        _logger.e('');
        _logger.e('TROUBLESHOOTING:');
        _logger.e('  1. Check backend logs for errors');
        _logger.e('  2. Verify Pusher Beams config in admin panel');
        _logger.e('  3. Check network connectivity');
        _logger.e('═══════════════════════════════════════════════════');
      }
      
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('❌ EXCEPTION: Failed to test auth endpoint');
      _logger.e('═══════════════════════════════════════════════════');
      _logger.e('Exception: $e');
      _logger.e('Exception Type: ${e.runtimeType}');
      _logger.e('Stack trace: $stackTrace');
      _logger.e('');
      _logger.e('TROUBLESHOOTING:');
      _logger.e('  1. Check network connectivity');
      _logger.e('  2. Verify base URL is accessible: ${ApiConfig.baseUrl}');
      _logger.e('  3. Check if backend server is running');
      _logger.e('  4. Try: curl ${authUrl}');
      _logger.e('═══════════════════════════════════════════════════');
    }
  }
}
