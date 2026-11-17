class DeliveryCheckResult {
  final bool allowed;
  final double? distanceKm;
  final double? maxRadius;

  const DeliveryCheckResult({
    required this.allowed,
    this.distanceKm,
    this.maxRadius,
  });

  /// [json] is the full API response envelope containing a `data` key.
  factory DeliveryCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return DeliveryCheckResult(
      allowed: data['allowed'] as bool? ?? false,
      distanceKm: (data['distance_km'] as num?)?.toDouble(),
      maxRadius: (data['max_radius'] as num?)?.toDouble(),
    );
  }

  String get statusMessage {
    if (allowed) return 'Delivery available to this location';
    if (distanceKm == null) return 'Delivery is not available for this branch';
    return 'Location is ${distanceKm!.toStringAsFixed(1)} km away'
        ' (max ${maxRadius!.toStringAsFixed(1)} km)';
  }
}
