class DateTimeValidationResult {
  final bool isValid;
  final String dayName;
  final String openTime;
  final String closeTime;
  final String pickupDate;
  final String pickupTime;

  const DateTimeValidationResult({
    required this.isValid,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    required this.pickupDate,
    required this.pickupTime,
  });

  factory DateTimeValidationResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return DateTimeValidationResult(
      isValid: data['is_valid'] as bool? ?? false,
      dayName: data['day_name'] as String? ?? '',
      openTime: data['open_time'] as String? ?? '',
      closeTime: data['close_time'] as String? ?? '',
      pickupDate: data['pickup_date'] as String? ?? '',
      pickupTime: data['pickup_time'] as String? ?? '',
    );
  }
}
