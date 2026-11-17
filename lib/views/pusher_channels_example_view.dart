import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../backend/services/pusher_channels_controller.dart';
import '../backend/services/pusher_config.dart';

/// Pusher Channels Demo - Real-time Event Streaming
/// 
/// Features:
/// - Live connection monitoring with auto-reconnect
/// - Event log with real-time updates
/// - Error handling with user-friendly dialogs
/// - Material Design 3 UI
class PusherChannelsExampleView extends StatefulWidget {
  const PusherChannelsExampleView({super.key});

  @override
  State<PusherChannelsExampleView> createState() => _PusherChannelsExampleViewState();
}

class _PusherChannelsExampleViewState extends State<PusherChannelsExampleView> {
  late final PusherChannelsController _controller;
  final List<Map<String, dynamic>> _events = [];
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      _controller = Get.find<PusherChannelsController>();
    } catch (e) {
      _controller = Get.put(PusherChannelsController());
    }
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await _controller.initialize(
        apiKey: PusherChannelsConfig.apiKey,
        cluster: PusherChannelsConfig.cluster,
      );

      await _controller.connect();

      await _controller.subscribeToChannel(
        'test-channel',
        onEvent: _handleEvent,
      );

      await _controller.subscribeToChannel(
        PusherChannelsConfig.bookingUpdatesChannel,
        onEvent: _handleBookingEvent,
      );

      _addEvent(
        type: 'success',
        title: 'Connected',
        message: 'Real-time connection established',
        icon: Icons.check_circle,
      );

      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = e.toString();
      });
      _showErrorDialog('Connection Failed', e.toString());
    }
  }

  void _addEvent({
    required String type,
    required String title,
    required String message,
    required IconData icon,
  }) {
    if (mounted) {
      setState(() {
        _events.insert(0, {
          'type': type,
          'title': title,
          'message': message,
          'icon': icon,
          'time': DateTime.now(),
        });
        if (_events.length > 50) _events.removeLast();
      });
    }
  }

  void _handleEvent(PusherEvent event) {
    _addEvent(
      type: 'event',
      title: event.eventName,
      message: event.data ?? 'No data',
      icon: Icons.notifications_active,
    );
  }

  void _handleBookingEvent(PusherEvent event) {
    _addEvent(
      type: 'booking',
      title: event.eventName,
      message: event.data ?? 'Booking update',
      icon: Icons.directions_car,
    );

    if (event.eventName == PusherChannelsConfig.bookingConfirmedEvent) {
      Get.snackbar(
        'Booking Confirmed',
        'Your booking has been confirmed!',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Check your internet connection and Pusher credentials.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Get.back();
              _initializePusher();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Channels'),
        centerTitle: false,
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(
                    _controller.isConnected.value
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 12,
                    color: _controller.isConnected.value
                        ? Colors.greenAccent
                        : Colors.grey,
                  ),
                  label: Text(
                    _controller.connectionState.value.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _controller.isConnected.value
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
                  side: BorderSide(
                    color: _controller.isConnected.value
                        ? Colors.green.shade200
                        : Colors.grey.shade300,
                  ),
                ),
              )),
        ],
      ),
      body: _isInitializing
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(colorScheme),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connecting to Pusher Channels...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cluster: ${PusherChannelsConfig.cluster}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _initializePusher,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Status Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Channels',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onPrimaryContainer.withAlpha(179),
                          ),
                        ),
                        Obx(() => Text(
                              _controller.subscribedChannels.length.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_events.length} events',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _controller.subscribedChannels
                        .map((channel) => Chip(
                              avatar: Icon(
                                Icons.tag,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                channel,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: colorScheme.outline),
                            ))
                        .toList(),
                  )),
            ],
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => OutlinedButton.icon(
                      onPressed: _controller.isConnected.value
                          ? () => _controller.disconnect()
                          : () => _controller.connect(),
                      icon: Icon(
                        _controller.isConnected.value
                            ? Icons.link_off
                            : Icons.link,
                      ),
                      label: Text(
                        _controller.isConnected.value
                            ? 'Disconnect'
                            : 'Reconnect',
                      ),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _events.isEmpty
                      ? null
                      : () => setState(() => _events.clear()),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Log'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Events List
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Events Yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Waiting for real-time events...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _showTestInstructions,
                        icon: const Icon(Icons.help_outline),
                        label: const Text('How to Test'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _buildEventCard(event, colorScheme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    Map<String, dynamic> event,
    ColorScheme colorScheme,
  ) {
    final type = event['type'] as String;
    final time = event['time'] as DateTime;
    final now = DateTime.now();
    final diff = now.difference(time);
    final timeAgo = diff.inSeconds < 60
        ? '${diff.inSeconds}s ago'
        : diff.inMinutes < 60
            ? '${diff.inMinutes}m ago'
            : '${diff.inHours}h ago';

    Color typeColor = colorScheme.primary;
    if (type == 'success') typeColor = Colors.green;
    if (type == 'booking') typeColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: typeColor.withAlpha(77)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withAlpha(51),
          child: Icon(
            event['icon'] as IconData,
            color: typeColor,
            size: 20,
          ),
        ),
        title: Text(
          event['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event['message'] as String,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showTestInstructions() {
    Get.dialog(
      AlertDialog(
        icon: const Icon(Icons.science, color: Colors.blue, size: 48),
        title: const Text('Test Real-time Events'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Option 1: Pusher Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Visit dashboard.pusher.com\n'
                '2. Select your app (${PusherChannelsConfig.appId})\n'
                '3. Go to "Debug Console"\n'
                '4. Send a test event:\n'
                '   • Channel: test-channel\n'
                '   • Event: my-event\n'
                '   • Data: {"message": "Hello World!"}',
                style: const TextStyle(fontSize: 13),
              ),
              const Divider(height: 24),
              const Text(
                'Option 2: Backend API',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trigger events from your server using Pusher REST API when booking/car status changes occur.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Keep controller alive for global use across app
    // Disconnect will be handled when user explicitly requests it
    super.dispose();
  }
}
