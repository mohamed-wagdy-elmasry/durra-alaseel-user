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
      // TODO: iOS requires APNs certificate setup in Pusher Beams dashboard
      // Skipping iOS temporarily until APNs is configured
      if (Platform.isIOS) {
        debugPrint('Push notifications: iOS initialization skipped (APNs not configured)');
        return;
      }

      // Get this from https://dashboard.pusher.com/beams
      const instanceId = 'f80f6f50-1302-4c1f-b7ba-b64a57fcbd29';

      final controller = Get.put(PushNotificationController());
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
      final isInitialized = await AwesomeNotifications().initialize(
        // Notification icon - using app launcher icon
        NotificationChannels.notificationIcon,
        // Notification channels
        NotificationChannels.getAllChannels(),
        // Channel groups
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

        // Request notification permissions (required for Android 13+)
        final isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isAllowed) {
          debugPrint('⚠️ Notification permission not granted - requesting now');
          // Request permission explicitly (Android 13+ requires user approval)
          await AwesomeNotifications().requestPermissionToSendNotifications();
          final granted = await AwesomeNotifications().isNotificationAllowed();
          if (granted) {
            debugPrint('✅ Notification permissions granted by user');
          } else {
            debugPrint('❌ User denied notification permissions');
          }
        } else {
          debugPrint('✅ Notification permissions already granted');
        }

        // TODO: iOS Setup - Uncomment when APNs is configured
        // if (Platform.isIOS) {
        //   await AwesomeNotifications().requestPermissionToSendNotifications(
        //     channelKey: 'booking_channel',
        //     permissions: [
        //       NotificationPermission.Alert,
        //       NotificationPermission.Sound,
        //       NotificationPermission.Badge,
        //       NotificationPermission.Vibration,
        //     ],
        //   );
        // }
      } else {
        debugPrint('❌ Failed to initialize Awesome Notifications');
      }
    } catch (e) {
      debugPrint('❌ Error initializing Awesome Notifications: $e');
      // Continue app initialization even if notification setup fails
    }
  }
}

