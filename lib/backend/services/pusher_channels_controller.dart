import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'pusher_channels_service.dart';

/// Controller for managing Pusher Channels state and interactions.
/// 
/// Extends GetxController for lifecycle management and reactive updates.
/// Provides reactive observable properties for UI state updates.
/// 
/// Example usage:
/// ```dart
/// final controller = Get.find<PusherChannelsController>();
/// await controller.initialize(apiKey: 'your-key', cluster: 'us2');
/// await controller.subscribeToChannel('booking-updates', onEvent: handleBookingEvent);
/// ```
class PusherChannelsController extends GetxController {
  final PusherChannelsService _service = PusherChannelsService();
  final Logger _logger = Logger();

  // Reactive properties
  RxBool isInitialized = false.obs;
  RxBool isConnected = false.obs;
  RxBool isConnecting = false.obs;
  RxString connectionState = 'DISCONNECTED'.obs;
  RxList<String> subscribedChannels = <String>[].obs;
  RxMap<String, PusherEvent> lastEvents = <String, PusherEvent>{}.obs;
  RxString? lastError = RxString('');

  final Map<String, Map<String, List<ChannelEventCallback>>> _eventBindings = {};

  /// Initializes Pusher Channels with API credentials.
  /// 
  /// [apiKey] - Your Pusher app key from dashboard
  /// [cluster] - Your Pusher cluster (e.g., 'us2', 'eu', 'ap1')
  /// 
  /// Should be called once during app startup.
  Future<void> initialize({
    required String apiKey,
    required String cluster,
  }) async {
    if (isInitialized.value) {
      _logger.w('Pusher Channels already initialized');
      return;
    }

    try {
      _logger.i('Initializing Pusher Channels controller...');

      await _service.initialize(
        apiKey: apiKey,
        cluster: cluster,
        onConnectionStateChange: _handleConnectionStateChange,
        onError: _handleError,
      );

      isInitialized.value = true;
      _logger.i('Pusher Channels controller initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Pusher Channels: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Connects to Pusher Channels.
  /// Call after [initialize].
  Future<void> connect() async {
    if (!isInitialized.value) {
      throw Exception('Must initialize before connecting');
    }

    if (isConnected.value) {
      _logger.w('Already connected to Pusher Channels');
      return;
    }

    try {
      isConnecting.value = true;
      await _service.connect();
      _logger.i('Successfully connected to Pusher Channels');
    } catch (e) {
      _logger.e('Failed to connect: $e');
      lastError?.value = e.toString();
      rethrow;
    } finally {
      isConnecting.value = false;
    }
  }

  /// Disconnects from Pusher Channels.
  Future<void> disconnect() async {
    try {
      await _service.disconnect();
      isConnected.value = false;
      connectionState.value = 'DISCONNECTED';
      _logger.i('Disconnected from Pusher Channels');
    } catch (e) {
      _logger.e('Failed to disconnect: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Subscribes to a public channel.
  /// 
  /// [channelName] - Name of the channel
  /// [onEvent] - Optional callback for channel events
  /// 
  /// Example:
  /// ```dart
  /// await controller.subscribeToChannel(
  ///   'booking-updates',
  ///   onEvent: (event) {
  ///     print('Received: ${event.eventName} - ${event.data}');
  ///   },
  /// );
  /// ```
  Future<PusherChannel> subscribeToChannel(
    String channelName, {
    ChannelEventCallback? onEvent,
  }) async {
    try {
      _logger.i('Subscribing to channel: $channelName');
      
      final channel = await _service.subscribe(
        channelName: channelName,
        onEvent: onEvent ?? (event) => _handleChannelEvent(channelName, event),
      );

      _refreshSubscribedChannels();
      _logger.i('Successfully subscribed to $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to $channelName: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Subscribes to a private channel.
  /// Requires authentication endpoint configured on your backend.
  /// 
  /// [channelName] - Must start with 'private-'
  /// [onEvent] - Optional callback for channel events
  /// 
  /// Example:
  /// ```dart
  /// await controller.subscribeToPrivateChannel(
  ///   'private-user-123',
  ///   onEvent: (event) => handlePrivateEvent(event),
  /// );
  /// ```
  Future<PusherChannel> subscribeToPrivateChannel(
    String channelName, {
    ChannelEventCallback? onEvent,
  }) async {
    try {
      _logger.i('Subscribing to private channel: $channelName');
      
      final channel = await _service.subscribePrivate(
        channelName: channelName,
        onEvent: onEvent ?? (event) => _handleChannelEvent(channelName, event),
      );

      _refreshSubscribedChannels();
      _logger.i('Successfully subscribed to private channel $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to private channel $channelName: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Subscribes to a presence channel.
  /// Provides member tracking and requires authentication.
  /// 
  /// [channelName] - Must start with 'presence-'
  /// [onEvent] - Optional callback for channel events
  /// 
  /// Example:
  /// ```dart
  /// await controller.subscribeToPresenceChannel(
  ///   'presence-chat-room',
  ///   onEvent: (event) => handleChatEvent(event),
  /// );
  /// ```
  Future<PusherChannel> subscribeToPresenceChannel(
    String channelName, {
    ChannelEventCallback? onEvent,
  }) async {
    try {
      _logger.i('Subscribing to presence channel: $channelName');
      
      final channel = await _service.subscribePresence(
        channelName: channelName,
        onEvent: onEvent ?? (event) => _handleChannelEvent(channelName, event),
      );

      _refreshSubscribedChannels();
      _logger.i('Successfully subscribed to presence channel $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to presence channel $channelName: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Unsubscribes from a channel.
  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      _logger.i('Unsubscribing from channel: $channelName');
      await _service.unsubscribe(channelName);
      _refreshSubscribedChannels();
      lastEvents.remove(channelName);
      _logger.i('Successfully unsubscribed from $channelName');
    } catch (e) {
      _logger.e('Failed to unsubscribe from $channelName: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Triggers a client event on a private or presence channel.
  /// Client events must be enabled in Pusher dashboard.
  /// 
  /// [channelName] - The channel to trigger on (must be private- or presence-)
  /// [eventName] - Must start with 'client-'
  /// [data] - Event data
  /// 
  /// Example:
  /// ```dart
  /// await controller.triggerClientEvent(
  ///   channelName: 'private-chat',
  ///   eventName: 'client-typing',
  ///   data: {'userId': '123', 'isTyping': true},
  /// );
  /// ```
  Future<void> triggerClientEvent({
    required String channelName,
    required String eventName,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _service.trigger(
        channelName: channelName,
        eventName: eventName,
        data: data,
      );
      _logger.d('Client event triggered: $eventName on $channelName');
    } catch (e) {
      _logger.e('Failed to trigger client event: $e');
      lastError?.value = e.toString();
      rethrow;
    }
  }

  /// Gets a specific channel instance.
  PusherChannel? getChannel(String channelName) {
    return _service.getChannel(channelName);
  }

  /// Binds a listener to a specific event on a channel.
  /// 
  /// [channelName] - The channel to listen on
  /// [eventName] - The event to listen for
  /// [callback] - Function to call when event is received
  /// 
  /// Example:
  /// ```dart
  /// controller.bindToEvent(
  ///   channelName: 'booking-updates',
  ///   eventName: 'booking-confirmed',
  ///   callback: (event) => handleBookingConfirmed(event),
  /// );
  /// ```
  Future<void> bindToEvent({
    required String channelName,
    required String eventName,
    required ChannelEventCallback callback,
  }) async {
    if (_service.getChannel(channelName) == null) {
      throw Exception('Not subscribed to channel: $channelName');
    }

    final channelBindings = _eventBindings.putIfAbsent(channelName, () => {});
    final callbacks = channelBindings.putIfAbsent(eventName, () => []);
    callbacks.add(callback);

    _logger.d('Bound to event $eventName on channel $channelName');
  }

  /// Unbinds a listener from a specific event.
  Future<void> unbindFromEvent({
    required String channelName,
    required String eventName,
  }) async {
    final channelBindings = _eventBindings[channelName];
    if (channelBindings == null) {
      _logger.w('Cannot unbind - no bindings for channel: $channelName');
      return;
    }

    channelBindings.remove(eventName);
    if (channelBindings.isEmpty) {
      _eventBindings.remove(channelName);
    }

    _logger.d('Unbound from event $eventName on channel $channelName');
  }

  // Internal handlers

  void _handleConnectionStateChange(String currentState) {
    connectionState.value = currentState;
    isConnected.value = currentState == 'CONNECTED';
    isConnecting.value = currentState == 'CONNECTING';
    
    _logger.i('Connection state changed to: $currentState');
  }

  void _handleError(String message, int? code, dynamic exception) {
    lastError?.value = 'Error $code: $message';
    _logger.e('Pusher error: $message (code: $code)');
    
    // Optionally show user-facing error
    if (Get.context != null) {
      Get.snackbar(
        'Connection Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handleChannelEvent(String channelName, PusherEvent event) {
    _logger.d('Event on $channelName: ${event.eventName}');
    lastEvents[channelName] = event;

    final channelBindings = _eventBindings[channelName];
    final callbacks = channelBindings?[event.eventName];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback(event);
      }
    }
    
    // You can add global event handling logic here
    // For example, updating UI state, triggering animations, etc.
  }

  void _refreshSubscribedChannels() {
    subscribedChannels.value = _service.subscribedChannels;
  }

  @override
  void onClose() {
    _logger.d('PusherChannelsController disposed');
    _service.dispose();
    _eventBindings.clear();
    super.onClose();
  }
}
