import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// Notification channels configuration for Awesome Notifications
/// Each channel defines different notification behavior and priority
class NotificationChannels {
  
  /// App notification icon resource (vector drawable for Android notifications)
  static const String notificationIcon = 'resource://drawable/ic_notification';
  
  /// Get all notification channels
  static List<NotificationChannel> getAllChannels() {
    return [
      bookingChannel,
      paymentChannel,
      chatChannel,
      promoChannel,
      scheduledChannel,
    ];
  }
  
  /// Get all notification channel groups
  static List<NotificationChannelGroup> getAllChannelGroups() {
    return [
      NotificationChannelGroup(
        channelGroupKey: 'urgent_group',
        channelGroupName: 'Urgent Notifications',
      ),
      NotificationChannelGroup(
        channelGroupKey: 'general_group',
        channelGroupName: 'General Notifications',
      ),
      NotificationChannelGroup(
        channelGroupKey: 'marketing_group',
        channelGroupName: 'Promotions & Offers',
      ),
    ];
  }
  
  /// Channel for booking-related notifications (urgent, high priority)
  /// Used for: Booking confirmations, driver assignments, trip updates
  static NotificationChannel bookingChannel = NotificationChannel(
    channelKey: 'booking_channel',
    channelName: 'Booking Notifications',
    channelDescription: 'Notifications for booking confirmations, driver updates, and trip status',
    channelGroupKey: 'urgent_group',
    importance: NotificationImportance.Max,
    defaultColor: const Color(0xFF9D50DD),
    ledColor: Colors.white,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    criticalAlerts: false,
    defaultRingtoneType: DefaultRingtoneType.Notification,
    icon: notificationIcon,
    channelShowBadge: true,
    onlyAlertOnce: false,
    locked: false,
  );
  
  /// Channel for payment-related notifications (important)
  /// Used for: Payment confirmations, failed payments, refunds
  static NotificationChannel paymentChannel = NotificationChannel(
    channelKey: 'payment_channel',
    channelName: 'Payment Notifications',
    channelDescription: 'Notifications for payment confirmations, failures, and refunds',
    channelGroupKey: 'urgent_group',
    importance: NotificationImportance.High,
    defaultColor: const Color(0xFF4CAF50),
    ledColor: Colors.green,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    criticalAlerts: false,
    icon: notificationIcon,
    channelShowBadge: true,
    onlyAlertOnce: false,
  );
  
  /// Channel for chat/messaging notifications (default priority)
  /// Used for: Customer support messages, driver chat
  static NotificationChannel chatChannel = NotificationChannel(
    channelKey: 'chat_channel',
    channelName: 'Chat Notifications',
    channelDescription: 'Notifications for chat messages from drivers and support',
    channelGroupKey: 'general_group',
    importance: NotificationImportance.Default,
    defaultColor: const Color(0xFF2196F3),
    ledColor: Colors.blue,
    playSound: true,
    enableVibration: true,
    enableLights: false,
    icon: notificationIcon,
    channelShowBadge: true,
    onlyAlertOnce: false,
  );
  
  /// Channel for promotional notifications (low priority)
  /// Used for: Offers, discounts, marketing messages
  static NotificationChannel promoChannel = NotificationChannel(
    channelKey: 'promo_channel',
    channelName: 'Promotions & Offers',
    channelDescription: 'Special offers, discounts, and promotional notifications',
    channelGroupKey: 'marketing_group',
    importance: NotificationImportance.Low,
    defaultColor: const Color(0xFFFF9800),
    ledColor: Colors.orange,
    playSound: false,
    enableVibration: false,
    enableLights: false,
    icon: notificationIcon,
    channelShowBadge: false,
    onlyAlertOnce: true,
  );
  
  /// Channel for scheduled/reminder notifications
  /// Used for: Booking reminders, scheduled alerts
  static NotificationChannel scheduledChannel = NotificationChannel(
    channelKey: 'scheduled_channel',
    channelName: 'Reminders',
    channelDescription: 'Scheduled reminders for bookings and appointments',
    channelGroupKey: 'general_group',
    importance: NotificationImportance.High,
    defaultColor: const Color(0xFF9C27B0),
    ledColor: Colors.purple,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    icon: notificationIcon,
    channelShowBadge: true,
    onlyAlertOnce: false,
  );
}
