class CancelBookingModel {
  final int bookingId;
  final String refunded;

  CancelBookingModel({
    required this.bookingId,
    required this.refunded,
  });

  factory CancelBookingModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return CancelBookingModel(
      bookingId: _asInt(data['booking_id']),
      refunded: _asString(data['refunded']),
    );
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _asString(dynamic v) {
  if (v == null) return '0.00';
  if (v is String) return v;
  return v.toString();
}
