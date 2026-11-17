/// Pusher Channels Configuration
/// 
/// Credentials source: https://dashboard.pusher.com/
/// App: Durra Alaseel Real-time Channels

class PusherChannelsConfig {
  // Pusher Channels API Credentials
  static const String apiKey = '8c79ed4d2d1c2bfd2b4d';
  static const String cluster = 'ap1';
  static const String appId = '2114386';
  static const String secret = '94c6d4b8da9e5e9514b3';
  
  // Channel names (following Pusher naming conventions)
  static const String bookingUpdatesChannel = 'booking-updates';
  static const String carAvailabilityChannel = 'car-availability';
  static const String userNotificationsChannel = 'user-notifications';
  
  // Private channels (require authentication)
  static String privateUserChannel(String userId) => 'private-user-$userId';
  
  // Presence channels (for real-time user presence)
  static String presenceChatChannel(String roomId) => 'presence-chat-$roomId';
  
  // Event names
  static const String bookingCreatedEvent = 'booking-created';
  static const String bookingConfirmedEvent = 'booking-confirmed';
  static const String bookingCancelledEvent = 'booking-cancelled';
  static const String carStatusChangedEvent = 'car-status-changed';
  static const String newMessageEvent = 'new-message';
  
  // Client events (must start with 'client-')
  static const String clientTypingEvent = 'client-typing';
  static const String clientStoppedTypingEvent = 'client-stopped-typing';
}

/// Pusher Beams Configuration (Push Notifications)
/// Note: Separate service from Channels - used for mobile push notifications
class PusherBeamsConfig {
  // Beams Instance ID (if needed for push notifications)
  static const String instanceId = 'YOUR_BEAMS_INSTANCE_ID';
  
  // Interest categories
  static const String allUsersInterest = 'all-users';
  static const String premiumUsersInterest = 'premium-users';
  
  static String carTypeInterest(String carType) => 'car-type-$carType';
  static String cityInterest(String cityCode) => 'city-$cityCode';
  static String userInterest(String userId) => 'user-$userId';
}
