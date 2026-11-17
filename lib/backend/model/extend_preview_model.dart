double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class ExtendPreviewModel {
  final int extensionDays;
  final double basePrice;
  final double rentalFees;
  final double taxPercentage;
  final double taxAmount;
  final double totalCost;
  final String newReturnDate;
  final String currentReturnDate;
  final bool isAvailable;

  const ExtendPreviewModel({
    required this.extensionDays,
    required this.basePrice,
    required this.rentalFees,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalCost,
    required this.newReturnDate,
    required this.currentReturnDate,
    required this.isAvailable,
  });

  factory ExtendPreviewModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final pricing = (data['pricing'] as Map<String, dynamic>?) ?? {};
    return ExtendPreviewModel(
      extensionDays: (data['extension_days'] as num?)?.toInt() ?? 0,
      basePrice: _toDouble(pricing['base_price']),
      rentalFees: _toDouble(pricing['rental_fees']),
      taxPercentage: _toDouble(pricing['tax_percentage']),
      taxAmount: _toDouble(pricing['tax_amount']),
      totalCost: _toDouble(pricing['total_cost']),
      newReturnDate: data['new_return_date']?.toString() ?? '',
      currentReturnDate: data['current_return_date']?.toString() ?? '',
      isAvailable: data['is_available'] == true,
    );
  }
}
