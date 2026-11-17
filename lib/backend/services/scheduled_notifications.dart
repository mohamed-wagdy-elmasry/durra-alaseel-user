import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'awesome_notification_service.dart';

/// Helper service for scheduling local notifications
/// Provides common scheduling patterns for different notification types
class ScheduledNotifications {
  
  /// Schedule a booking reminder notification
  /// Shows 1 hour before the scheduled booking time
  static Future<void> scheduleBookingReminder({
    required int bookingId,
    required DateTime bookingDateTime,
    required String carName,
    String? pickupLocation,
  }) async {
    try {
      // Schedule for 1 hour before booking
      final reminderTime = bookingDateTime.subtract(const Duration(hours: 1));
      
      // Don't schedule if reminder time has already passed
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('⏰ Booking reminder time has passed, skipping schedule');
        return;
      }
      
      final notificationId = _generateBookingNotificationId(bookingId);
      
      await AwesomeNotificationService.scheduleNotification(
        id: notificationId,
        title: 'Upcoming Booking Reminder',
        body: 'Your booking for $carName is in 1 hour${pickupLocation != null ? ' at $pickupLocation' : ''}',
        scheduledDate: reminderTime,
        channelKey: 'scheduled_channel',
        payload: {
          'type': 'booking_reminder',
          'booking_id': bookingId.toString(),
          'booking_time': bookingDateTime.toIso8601String(),
        },
        actionButtons: [
          NotificationActionButton(
            key: 'VIEW_BOOKING',
            label: 'View Booking',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'CANCEL_REMINDER',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
          ),
        ],
      );
      
      debugPrint('✅ Booking reminder scheduled for: $reminderTime');
    } catch (e) {
      debugPrint('❌ Error scheduling booking reminder: $e');
    }
  }
  
  /// Schedule a payment reminder notification
  /// For pending payments that need attention
  static Future<void> schedulePaymentReminder({
    required int paymentId,
    required String amount,
    required DateTime dueDate,
  }) async {
    try {
      // Schedule for 1 day before due date at 9 AM
      final reminderDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - 1,
        9, // 9 AM
        0,
      );
      
      if (reminderDate.isBefore(DateTime.now())) {
        debugPrint('⏰ Payment reminder time has passed, skipping schedule');
        return;
      }
      
      final notificationId = _generatePaymentNotificationId(paymentId);
      
      await AwesomeNotificationService.scheduleNotification(
        id: notificationId,
        title: 'Payment Due Soon',
        body: 'Your payment of $amount is due tomorrow',
        scheduledDate: reminderDate,
        channelKey: 'payment_channel',
        payload: {
          'type': 'payment_reminder',
          'payment_id': paymentId.toString(),
          'amount': amount,
          'due_date': dueDate.toIso8601String(),
        },
        actionButtons: [
          NotificationActionButton(
            key: 'VIEW_PAYMENT',
            label: 'Pay Now',
            actionType: ActionType.Default,
            autoDismissible: true,
          ),
        ],
      );
      
      debugPrint('✅ Payment reminder scheduled for: $reminderDate');
    } catch (e) {
      debugPrint('❌ Error scheduling payment reminder: $e');
    }
  }
  
  /// Schedule a daily promotional notification
  /// Shows at a specific time each day
  static Future<void> scheduleDailyPromo({
    required String title,
    required String message,
    int hour = 10, // Default 10 AM
    int minute = 0,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999999, // Fixed ID for daily promo (will be overwritten each time)
          channelKey: 'promo_channel',
          title: title,
          body: message,
          category: NotificationCategory.Promo,
          payload: {'type': 'daily_promo'},
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true, // Repeat daily
        ),
      );
      
      debugPrint('✅ Daily promo scheduled for $hour:$minute every day');
    } catch (e) {
      debugPrint('❌ Error scheduling daily promo: $e');
    }
  }
  
  /// Schedule a weekly reminder (e.g., "Check out new cars")
  /// Shows on a specific day and time each week
  static Future<void> scheduleWeeklyReminder({
    required String title,
    required String message,
    required int weekday, // 1 = Monday, 7 = Sunday
    int hour = 12,
    int minute = 0,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 888888, // Fixed ID for weekly reminder
          channelKey: 'promo_channel',
          title: title,
          body: message,
          category: NotificationCategory.Reminder,
          payload: {'type': 'weekly_reminder'},
        ),
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true,
        ),
      );
      
      final weekdays = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      debugPrint('✅ Weekly reminder scheduled for ${weekdays[weekday]} at $hour:$minute');
    } catch (e) {
      debugPrint('❌ Error scheduling weekly reminder: $e');
    }
  }
  
  /// Cancel a specific booking reminder
  static Future<void> cancelBookingReminder(int bookingId) async {
    final notificationId = _generateBookingNotificationId(bookingId);
    await AwesomeNotificationService.cancelNotification(notificationId);
    debugPrint('🗑️ Cancelled booking reminder for booking: $bookingId');
  }
  
  /// Cancel a specific payment reminder
  static Future<void> cancelPaymentReminder(int paymentId) async {
    final notificationId = _generatePaymentNotificationId(paymentId);
    await AwesomeNotificationService.cancelNotification(notificationId);
    debugPrint('🗑️ Cancelled payment reminder for payment: $paymentId');
  }
  
  /// Cancel all scheduled notifications
  static Future<void> cancelAllScheduled() async {
    await AwesomeNotificationService.cancelAllNotifications();
    debugPrint('🗑️ Cancelled all scheduled notifications');
  }
  
  /// List all active scheduled notifications
  static Future<List<NotificationModel>> listScheduledNotifications() async {
    final scheduled = await AwesomeNotifications().listScheduledNotifications();
    debugPrint('📋 Active scheduled notifications: ${scheduled.length}');
    return scheduled;
  }
  
  /// Generate consistent notification ID for bookings
  /// Uses booking ID + offset to avoid conflicts
  static int _generateBookingNotificationId(int bookingId) {
    return 100000 + bookingId; // Offset to avoid ID conflicts
  }
  
  /// Generate consistent notification ID for payments
  static int _generatePaymentNotificationId(int paymentId) {
    return 200000 + paymentId; // Different offset for payments
  }
}
