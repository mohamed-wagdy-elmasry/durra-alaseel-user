class PickupLocation {
  final double latitude;
  final double longitude;
  final String address;

  PickupLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  // Create from JSON
  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    return PickupLocation(
      latitude: json['latitude'] is String
          ? double.parse(json['latitude'])
          : json['latitude'].toDouble(),
      longitude: json['longitude'] is String
          ? double.parse(json['longitude'])
          : json['longitude'].toDouble(),
      address: json['address'] ?? '',
    );
  }

  // Create empty/default instance
  factory PickupLocation.empty() {
    return PickupLocation(
      latitude: 0.0,
      longitude: 0.0,
      address: '',
    );
  }

  // Check if location is valid
  bool get isValid {
    return latitude != 0.0 && longitude != 0.0 && address.isNotEmpty;
  }

  @override
  String toString() {
    return 'PickupLocation(lat: $latitude, lng: $longitude, address: $address)';
  }

  // Copy with method for immutability
  PickupLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return PickupLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}
