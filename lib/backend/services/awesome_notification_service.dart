import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service to handle Awesome Notifications creation and management
/// Integrates with Pusher Beams for rich notification display
class AwesomeNotificationService {
  
  /// Create a notification from Pusher Beams message
  /// Converts Pusher message format to Awesome Notification format
  static Future<void> createNotificationFromPusher({
    required Map<String, dynamic> pusherData,
    int? notificationId,
  }) async {
    try {
      // Extract notification data from Pusher payload
      final String title = pusherData['title'] ?? 'Durrat Alaseel';
      final String body = pusherData['body'] ?? 'You have a new notification';
      final String? type = pusherData['type'];
      final Map<String, String> payload = _convertPayload(pusherData);
      
      // Determine channel based on notification type
      final String channelKey = _getChannelKeyForType(type);
      final NotificationCategory category = _getCategoryForType(type);
      
      // Generate unique notification ID if not provided
      final int id = notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
      
      // Create notification content
      final notificationContent = NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        category: category,
        wakeUpScreen: type == 'booking' || type == 'payment',
        autoDismissible: true,
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
      );
      
      // Add action buttons based on notification type
      final List<NotificationActionButton>? actionButtons = _getActionButtonsForType(type);
      
      // Create the notification
      await AwesomeNotifications().createNotification(
        content: notificationContent,
        actionButtons: actionButtons,
      );
      
      debugPrint('✅ Awesome Notification created: $title (Channel: $channelKey)');
    } catch (e) {
      debugPrint('❌ Error creating Awesome Notification: $e');
    }
  }
  
  /// Schedule a notification for a specific date/time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelKey = 'scheduled_channel',
    Map<String, String>? payload,
    List<NotificationActionButton>? actionButtons,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: payload,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          autoDismissible: true,
          notificationLayout: NotificationLayout.Default,
        ),
        actionButtons: actionButtons,
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );
      
      debugPrint('✅ Notification scheduled for: $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }
  
  /// Cancel a scheduled notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
  
  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
  
  /// Get channel key based on notification type
  static String _getChannelKeyForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
      case 'trip':
      case 'driver':
      case 'booking-confirmed':
      case 'booking-cancelled':
        return 'booking_channel';
      case 'payment':
      case 'refund':
      case 'wallet_charged':
      case 'wallet_deducted':
      case 'wallet_refund':
        return 'payment_channel';
      case 'chat':
      case 'message':
        return 'chat_channel';
      case 'promo':
      case 'offer':
      case 'discount':
        return 'promo_channel';
      default:
        return 'booking_channel'; // Default to booking for important notifications
    }
  }
  
  /// Get notification category based on type
  static NotificationCategory _getCategoryForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
      case 'trip':
      case 'booking-confirmed':
      case 'booking-cancelled':
        return NotificationCategory.Event;
      case 'payment':
        return NotificationCategory.Service;
      case 'wallet_charged':
      case 'wallet_deducted':
      case 'wallet_refund':
        return NotificationCategory.Service;
      case 'chat':
      case 'message':
        return NotificationCategory.Message;
      case 'promo':
      case 'offer':
        return NotificationCategory.Promo;
      default:
        return NotificationCategory.Service;
    }
  }
  
  /// Get action buttons based on notification type
  static List<NotificationActionButton>? _getActionButtonsForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
      case 'trip':
      case 'booking-confirmed':
      case 'booking-cancelled':
        return [
          NotificationActionButton(
            key: 'VIEW_BOOKING',
            label: 'View Details',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: false,
          ),
        ];
      
      case 'payment':
        return [
          NotificationActionButton(
            key: 'VIEW_PAYMENT',
            label: 'View Payment',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
        ];

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
      
      case 'chat':
      case 'message':
        return [
          NotificationActionButton(
            key: 'REPLY',
            label: 'Reply',
            actionType: ActionType.Default,
            requireInputText: true,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'MARK_READ',
            label: 'Mark as Read',
            actionType: ActionType.SilentAction,
            autoDismissible: true,
          ),
        ];
      
      default:
        return null; // No action buttons for other types
    }
  }
  
  /// Convert Pusher payload to Map<String, String> for Awesome Notifications
  static Map<String, String> _convertPayload(Map<String, dynamic> data) {
    final Map<String, String> payload = {};
    
    data.forEach((key, value) {
      if (value != null) {
        // Convert all values to string
        if (value is String) {
          payload[key] = value;
        } else if (value is Map || value is List) {
          // Convert complex types to JSON string
          payload[key] = jsonEncode(value);
        } else {
          payload[key] = value.toString();
        }
      }
    });
    
    return payload;
  }
  
  /// Handle notification action received
  /// This method is called when user taps notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('🔔 Notification action received: ${receivedAction.actionType}');
    debugPrint('   Action key: ${receivedAction.buttonKeyPressed}');
    debugPrint('   Payload: ${receivedAction.payload}');
    
    final payload = receivedAction.payload ?? {};
    final actionKey = receivedAction.buttonKeyPressed;
    
    // Handle different action types
    switch (actionKey) {
      case 'VIEW_BOOKING':
        await _navigateToBooking(payload);
        break;
      
      case 'VIEW_PAYMENT':
        await _navigateToPayment(payload);
        break;

      case 'VIEW_WALLET':
        await _navigateToWallet();
        break;
      
      case 'REPLY':
        await _handleReply(receivedAction.buttonKeyInput, payload);
        break;
      
      case 'MARK_READ':
        await _markAsRead(payload);
        break;
      
      case 'DISMISS':
        // Just dismiss, no action needed
        break;
      
      default:
        // Default tap on notification body
        await _handleDefaultTap(payload);
    }
  }
  
  /// Navigate to booking details
  static Future<void> _navigateToBooking(Map<String, String?> payload) async {
    final bookingId = payload['booking_id'];
    if (bookingId != null) {
      // Navigate to booking details screen
      // Using Get.toNamed to navigate - adjust route as per your app
      Get.toNamed('/booking-details', arguments: {'id': bookingId});
    }
  }
  
  /// Navigate to payment details
  static Future<void> _navigateToPayment(Map<String, String?> payload) async {
    final paymentId = payload['payment_id'];
    if (paymentId != null) {
      Get.toNamed('/payment-details', arguments: {'id': paymentId});
    }
  }

  static Future<void> _navigateToWallet() async {
    Get.toNamed('/walletScreen');
  }
  
  /// Handle reply action
  static Future<void> _handleReply(String? replyText, Map<String, String?> payload) async {
    if (replyText != null && replyText.isNotEmpty) {
      debugPrint('Reply text: $replyText');
      // TODO: Send reply to backend API
      // Example: await ChatService.sendMessage(replyText, chatId);
    }
  }
  
  /// Mark message as read
  static Future<void> _markAsRead(Map<String, String?> payload) async {
    final messageId = payload['message_id'];
    if (messageId != null) {
      debugPrint('Marking message as read: $messageId');
      // TODO: Call API to mark message as read
    }
  }
  
  /// Handle default notification tap
  static Future<void> _handleDefaultTap(Map<String, String?> payload) async {
    final type = payload['type'];
    
    switch (type?.toLowerCase()) {
      case 'booking':
      case 'trip':
      case 'booking-confirmed':
      case 'booking-cancelled':
        await _navigateToBooking(payload);
        break;

      case 'payment':
        await _navigateToPayment(payload);
        break;

      case 'wallet_charged':
      case 'wallet_deducted':
      case 'wallet_refund':
        await _navigateToWallet();
        break;
      
      case 'chat':
        // Navigate to chat/messages
        Get.toNamed('/chat');
        break;
      
      default:
        // Navigate to notifications list or home
        Get.toNamed('/notifications');
    }
  }
  
  /// Method called when notification is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification
  ) async {
    debugPrint('📬 Notification created: ${receivedNotification.id}');
  }
  
  /// Method called when notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification
  ) async {
    debugPrint('📱 Notification displayed: ${receivedNotification.id}');
  }
  
  /// Method called when notification is dismissed
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction
  ) async {
    debugPrint('🗑️ Notification dismissed: ${receivedAction.id}');
  }
}
