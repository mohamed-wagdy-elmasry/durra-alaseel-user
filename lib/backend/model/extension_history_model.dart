class ExtensionRecord {
  final int id;
  final int bookingId;
  final int extensionDays;
  final String previousReturnDate;
  final String newReturnDate;
  final double rentalFees;
  final double taxPercentage;
  final double taxAmount;
  final double totalCost;
  final double dailyRate;
  final DateTime createdAt;

  const ExtensionRecord({
    required this.id,
    required this.bookingId,
    required this.extensionDays,
    required this.previousReturnDate,
    required this.newReturnDate,
    required this.rentalFees,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalCost,
    required this.dailyRate,
    required this.createdAt,
  });

  factory ExtensionRecord.fromJson(Map<String, dynamic> json) {
    return ExtensionRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['car_booking_id'] as num?)?.toInt() ?? 0,
      extensionDays: (json['extension_days'] as num?)?.toInt() ?? 0,
      previousReturnDate: json['previous_return_date']?.toString() ?? '',
      newReturnDate: json['new_return_date']?.toString() ?? '',
      rentalFees: _toDouble(json['rental_fees']),
      taxPercentage: _toDouble(json['tax_percentage']),
      taxAmount: _toDouble(json['tax_amount']),
      totalCost: _toDouble(json['total_cost']),
      dailyRate: _toDouble(json['daily_rate']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ExtensionHistoryModel {
  final List<ExtensionRecord> extensions;

  const ExtensionHistoryModel({required this.extensions});

  factory ExtensionHistoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    List<dynamic> list = [];

    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final inner = raw['extensions'] ?? raw['data'];
      if (inner is List) {
        list = inner;
      }
    }

    return ExtensionHistoryModel(
      extensions: list
          .whereType<Map<String, dynamic>>()
          .map(ExtensionRecord.fromJson)
          .toList(),
    );
  }
}
