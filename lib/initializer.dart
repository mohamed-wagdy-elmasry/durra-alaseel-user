import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'backend/services/push_notification_controller.dart';
import 'backend/services/awesome_notification_service.dart';
import 'backend/services/notification_channels.dart';
import 'languages/locale_service.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize storage first
    await GetStorage.init();

    // Initialize screen util
    await ScreenUtil.ensureScreenSize();

    // Initialize locale service (loads saved language from storage)
    await LocaleService.init();

    debugPrint(
      'App initialized with language: ${LocaleService.to.currentLanguageCode}',
    );

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Awesome Notifications first
    await _initializeAwesomeNotifications();

    // Initialize push notifications
    await _initializePushNotifications();
  }

  static Future<void> _initializePushNotifications() async {
    try {
      // Always register PushNotificationController in GetX so Get.find() never fails
      final controller = Get.put(PushNotificationController(), permanent: true);

      // TODO: iOS requires APNs certificate setup in Pusher Beams dashboard
      // Skipping iOS Pusher Beams network connection temporarily until APNs is configured
      if (Platform.isIOS) {
        debugPrint('Push notifications: iOS Pusher Beams skipped (APNs not configured)');
        return;
      }

      // Get this from https://dashboard.pusher.com/beams
      const instanceId = 'f80f6f50-1302-4c1f-b7ba-b64a57fcbd29';

      await controller.initializePushNotifications(instanceId);

      // Request notification permissions
      final permissionsGranted = await controller.requestPermissions();
      if (permissionsGranted) {
        debugPrint('✅ Notification permissions granted');
      } else {
        debugPrint('⚠️ Notification permissions denied');
      }

      debugPrint('Push notifications initialized');
    } catch (e) {
      debugPrint('Failed to initialize push notifications: $e');
      // Continue app initialization even if push notifications fail
    }
  }

  /// Initialize Awesome Notifications for rich notification display
  static Future<void> _initializeAwesomeNotifications() async {
    try {
      // Initialize plugin with notification icon and channels
      // On iOS defaultIcon must be null to use standard app icon; resource://drawable is Android-only
      final isInitialized = await AwesomeNotifications().initialize(
        Platform.isAndroid ? NotificationChannels.notificationIcon : null,
        NotificationChannels.getAllChannels(),
        channelGroups: NotificationChannels.getAllChannelGroups(),
        debug: false,
      );

      if (isInitialized) {
        debugPrint('✅ Awesome Notifications initialized successfully');

        // Set up notification listeners
        AwesomeNotifications().setListeners(
          onActionReceivedMethod: AwesomeNotificationService.onActionReceivedMethod,
          onNotificationCreatedMethod: AwesomeNotificationService.onNotificationCreatedMethod,
          onNotificationDisplayedMethod: AwesomeNotificationService.onNotificationDisplayedMethod,
          onDismissActionReceivedMethod: AwesomeNotificationService.onDismissActionReceivedMethod,
        );

        // Only request upfront notification permissions on Android (Android 13+)
        // On iOS, system alert should not block before UI is ready
        if (Platform.isAndroid) {
          final isAllowed = await AwesomeNotifications().isNotificationAllowed();
          if (!isAllowed) {
            debugPrint('⚠️ Notification permission not granted - requesting now');
            await AwesomeNotifications().requestPermissionToSendNotifications();
          }
        }
      } else {
        debugPrint('❌ Failed to initialize Awesome Notifications');
      }
    } catch (e) {
      debugPrint('❌ Error initializing Awesome Notifications: $e');
      // Continue app initialization even if notification setup fails
    }
  }
}

