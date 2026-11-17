import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:logger/logger.dart';

typedef ChannelEventCallback = void Function(PusherEvent event);
typedef ConnectionStateCallback = void Function(String currentState);
typedef ErrorCallback = void Function(String message, int? code, dynamic exception);

/// Service for managing real-time pub/sub messaging using Pusher Channels.
/// 
/// Handles connection management, channel subscriptions, and event broadcasting.
/// Separate from PushNotificationService (Pusher Beams) which handles push notifications.
class PusherChannelsService {
  static final PusherChannelsService _instance = PusherChannelsService._internal();
  static final Logger _logger = Logger();

  PusherChannelsFlutter? _pusher;
  final Map<String, PusherChannel> _channels = {};
  
  ConnectionStateCallback? _onConnectionStateChange;
  ErrorCallback? _onError;

  bool _isInitialized = false;
  String? _currentConnectionState;

  PusherChannelsService._internal();

  factory PusherChannelsService() {
    return _instance;
  }

  /// Initializes Pusher Channels with API key and cluster.
  /// 
  /// [apiKey] - Your Pusher app key from the dashboard
  /// [cluster] - Your Pusher cluster (e.g., 'us2', 'eu', 'ap1')
  /// [onConnectionStateChange] - Optional callback for connection state changes
  /// [onError] - Optional callback for errors
  /// 
  /// Example:
  /// ```dart
  /// await service.initialize(
  ///   apiKey: 'your-app-key',
  ///   cluster: 'us2',
  ///   onConnectionStateChange: (state) => print('Connection: $state'),
  /// );
  /// ```
  Future<void> initialize({
    required String apiKey,
    required String cluster,
    ConnectionStateCallback? onConnectionStateChange,
    ErrorCallback? onError,
  }) async {
    if (_isInitialized) {
      _logger.w('Pusher Channels already initialized');
      return;
    }

    try {
      _logger.i('Initializing Pusher Channels with cluster: $cluster');
      
      _pusher = PusherChannelsFlutter.getInstance();
      _onConnectionStateChange = onConnectionStateChange;
      _onError = onError;

      await _pusher!.init(
        apiKey: apiKey,
        cluster: cluster,
        onConnectionStateChange: _handleConnectionStateChange,
        onError: _handleError,
        onSubscriptionSucceeded: _handleSubscriptionSucceeded,
        onEvent: _handleEvent,
        onSubscriptionError: _handleSubscriptionError,
        onDecryptionFailure: _handleDecryptionFailure,
        onMemberAdded: _handleMemberAdded,
        onMemberRemoved: _handleMemberRemoved,
      );

      _isInitialized = true;
      _logger.i('Pusher Channels initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Pusher Channels: $e');
      rethrow;
    }
  }

  /// Connects to Pusher Channels.
  /// Must be called after [initialize].
  Future<void> connect() async {
    _ensureInitialized();
    
    try {
      _logger.i('Connecting to Pusher Channels...');
      await _pusher!.connect();
    } catch (e) {
      _logger.e('Failed to connect to Pusher Channels: $e');
      rethrow;
    }
  }

  /// Disconnects from Pusher Channels.
  Future<void> disconnect() async {
    if (!_isInitialized) return;

    try {
      _logger.i('Disconnecting from Pusher Channels...');
      await _pusher!.disconnect();
    } catch (e) {
      _logger.e('Failed to disconnect from Pusher Channels: $e');
      rethrow;
    }
  }

  /// Subscribes to a public channel.
  /// 
  /// [channelName] - Name of the channel (e.g., 'my-channel')
  /// [onEvent] - Callback for events on this channel
  /// 
  /// Returns the subscribed [PusherChannel] instance.
  /// 
  /// Example:
  /// ```dart
  /// final channel = await service.subscribe(
  ///   channelName: 'booking-updates',
  ///   onEvent: (event) => print('Event: ${event.eventName}, Data: ${event.data}'),
  /// );
  /// ```
  Future<PusherChannel> subscribe({
    required String channelName,
    ChannelEventCallback? onEvent,
  }) async {
    _ensureInitialized();

    try {
      _logger.i('Subscribing to channel: $channelName');
      
      // Wrap the callback to convert dynamic to PusherEvent
      final wrappedCallback = onEvent != null
          ? (dynamic event) {
              if (event is PusherEvent) {
                onEvent(event);
              }
            }
          : null;
      
      final channel = await _pusher!.subscribe(
        channelName: channelName,
        onEvent: wrappedCallback,
      );

      _channels[channelName] = channel;
      _logger.i('Successfully subscribed to channel: $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to channel $channelName: $e');
      rethrow;
    }
  }

  /// Subscribes to a private channel.
  /// Requires authentication on your backend.
  /// 
  /// [channelName] - Name must start with 'private-'
  /// [onEvent] - Callback for events on this channel
  /// 
  /// Example:
  /// ```dart
  /// final channel = await service.subscribePrivate(
  ///   channelName: 'private-user-123',
  ///   onEvent: (event) => handlePrivateEvent(event),
  /// );
  /// ```
  Future<PusherChannel> subscribePrivate({
    required String channelName,
    ChannelEventCallback? onEvent,
  }) async {
    _ensureInitialized();

    if (!channelName.startsWith('private-')) {
      throw ArgumentError('Private channel names must start with "private-"');
    }

    try {
      _logger.i('Subscribing to private channel: $channelName');
      
      // Wrap the callback to convert dynamic to PusherEvent
      final wrappedCallback = onEvent != null
          ? (dynamic event) {
              if (event is PusherEvent) {
                onEvent(event);
              }
            }
          : null;
      
      final channel = await _pusher!.subscribe(
        channelName: channelName,
        onEvent: wrappedCallback,
      );

      _channels[channelName] = channel;
      _logger.i('Successfully subscribed to private channel: $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to private channel $channelName: $e');
      rethrow;
    }
  }

  /// Subscribes to a presence channel.
  /// Requires authentication and provides member tracking.
  /// 
  /// [channelName] - Name must start with 'presence-'
  /// [onEvent] - Callback for events on this channel
  /// 
  /// Example:
  /// ```dart
  /// final channel = await service.subscribePresence(
  ///   channelName: 'presence-chat-room',
  ///   onEvent: (event) => handleChatEvent(event),
  /// );
  /// ```
  Future<PusherChannel> subscribePresence({
    required String channelName,
    ChannelEventCallback? onEvent,
  }) async {
    _ensureInitialized();

    if (!channelName.startsWith('presence-')) {
      throw ArgumentError('Presence channel names must start with "presence-"');
    }

    try {
      _logger.i('Subscribing to presence channel: $channelName');
      
      // Wrap the callback to convert dynamic to PusherEvent
      final wrappedCallback = onEvent != null
          ? (dynamic event) {
              if (event is PusherEvent) {
                onEvent(event);
              }
            }
          : null;
      
      final channel = await _pusher!.subscribe(
        channelName: channelName,
        onEvent: wrappedCallback,
      );

      _channels[channelName] = channel;
      _logger.i('Successfully subscribed to presence channel: $channelName');
      return channel;
    } catch (e) {
      _logger.e('Failed to subscribe to presence channel $channelName: $e');
      rethrow;
    }
  }

  /// Unsubscribes from a channel.
  Future<void> unsubscribe(String channelName) async {
    _ensureInitialized();

    try {
      _logger.i('Unsubscribing from channel: $channelName');
      await _pusher!.unsubscribe(channelName: channelName);
      _channels.remove(channelName);
    } catch (e) {
      _logger.e('Failed to unsubscribe from channel $channelName: $e');
      rethrow;
    }
  }

  /// Triggers a client event on a private or presence channel.
  /// Client events must be enabled in your Pusher dashboard settings.
  /// Event name must start with 'client-'.
  /// 
  /// [channelName] - The channel to trigger the event on
  /// [eventName] - Must start with 'client-'
  /// [data] - Event data to send
  /// 
  /// Example:
  /// ```dart
  /// await service.trigger(
  ///   channelName: 'private-chat',
  ///   eventName: 'client-typing',
  ///   data: {'userId': '123', 'isTyping': true},
  /// );
  /// ```
  Future<void> trigger({
    required String channelName,
    required String eventName,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();

    if (!eventName.startsWith('client-')) {
      throw ArgumentError('Client event names must start with "client-"');
    }

    if (!channelName.startsWith('private-') && !channelName.startsWith('presence-')) {
      throw ArgumentError('Client events can only be triggered on private or presence channels');
    }

    try {
      _logger.d('Triggering event $eventName on channel $channelName');
      
      final channel = _channels[channelName];
      if (channel == null) {
        throw Exception('Not subscribed to channel: $channelName');
      }

      await channel.trigger(
        PusherEvent(
          channelName: channelName,
          eventName: eventName,
          data: data,
        ),
      );

      _logger.d('Event triggered successfully');
    } catch (e) {
      _logger.e('Failed to trigger event: $e');
      rethrow;
    }
  }

  /// Gets the current connection state.
  String? get connectionState => _currentConnectionState;

  /// Checks if connected to Pusher.
  bool get isConnected => _currentConnectionState == 'CONNECTED';

  /// Gets a subscribed channel by name.
  PusherChannel? getChannel(String channelName) => _channels[channelName];

  /// Gets all subscribed channel names.
  List<String> get subscribedChannels => _channels.keys.toList();

  // Internal event handlers

  void _handleConnectionStateChange(String? currentState, String? previousState) {
    _logger.i('Connection state changed: $previousState -> $currentState');
    _currentConnectionState = currentState;
    _onConnectionStateChange?.call(currentState ?? 'UNKNOWN');
  }

  void _handleError(String message, int? code, dynamic exception) {
    _logger.e('Pusher error: $message (code: $code), exception: $exception');
    _onError?.call(message, code, exception);
  }

  void _handleSubscriptionSucceeded(String channelName, dynamic data) {
    _logger.i('Subscription succeeded for channel: $channelName');
  }

  void _handleEvent(PusherEvent event) {
    _logger.d('Global event received: ${event.eventName} on ${event.channelName}');
  }

  void _handleSubscriptionError(String message, dynamic exception) {
    _logger.e('Subscription error: $message, exception: $exception');
  }

  void _handleDecryptionFailure(String event, String reason) {
    _logger.e('Decryption failure for event $event: $reason');
  }

  void _handleMemberAdded(String channelName, PusherMember member) {
    _logger.d('Member added to $channelName: ${member.userId}');
  }

  void _handleMemberRemoved(String channelName, PusherMember member) {
    _logger.d('Member removed from $channelName: ${member.userId}');
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('Pusher Channels not initialized. Call initialize() first.');
    }
  }

  /// Disposes the service and cleans up resources.
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      _logger.i('Disposing Pusher Channels service...');
      
      // Unsubscribe from all channels
      for (final channelName in _channels.keys.toList()) {
        await unsubscribe(channelName);
      }
      
      await disconnect();
      
      _channels.clear();
      _isInitialized = false;
      _currentConnectionState = null;
      
      _logger.i('Pusher Channels service disposed');
    } catch (e) {
      _logger.e('Error disposing Pusher Channels service: $e');
    }
  }
}
