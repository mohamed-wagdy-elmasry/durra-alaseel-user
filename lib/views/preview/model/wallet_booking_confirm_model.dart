class WalletBookingConfirmModel {
  final String messageText;
  final int bookingId;
  final String trxId;
  final double amountDeducted;
  final double newBalance;

  WalletBookingConfirmModel({
    required this.messageText,
    required this.bookingId,
    required this.trxId,
    required this.amountDeducted,
    required this.newBalance,
  });

  factory WalletBookingConfirmModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final msg = json['message'];
    String text = '';
    if (msg is Map) {
      final success = msg['success'];
      if (success is List && success.isNotEmpty) {
        text = success.first.toString();
      }
    } else if (msg is String) {
      text = msg;
    }
    return WalletBookingConfirmModel(
      messageText: text,
      bookingId: _asInt(data['booking_id']),
      trxId: _asString(data['trx_id']),
      amountDeducted: _asDouble(data['amount_deducted']),
      newBalance: _asDouble(data['new_balance']),
    );
  }
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _asString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}
