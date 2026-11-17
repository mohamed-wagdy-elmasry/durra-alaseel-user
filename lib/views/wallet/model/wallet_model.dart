String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    final parsedDouble = double.tryParse(value);
    if (parsedDouble != null) return parsedDouble.toInt();
  }
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

// --- Wallet Balance Model ---

class WalletModel {
  final int walletId;
  final double balance;
  final String currency;
  final String updatedAt;
  final List<WalletTransaction> recentTransactions;

  WalletModel({
    required this.walletId,
    required this.balance,
    required this.currency,
    required this.updatedAt,
    required this.recentTransactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final rawTransactions = data['recent_transactions'] as List?;
    return WalletModel(
      walletId: _asInt(data['wallet_id'], fallback: 0),
      balance: _asDouble(data['balance'], fallback: 0.0),
      currency: _asString(data['currency'], fallback: 'SAR'),
      updatedAt: _asString(data['updated_at']),
      recentTransactions: rawTransactions
              ?.map((e) =>
                  WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// --- Wallet Transaction Model ---

class WalletTransaction {
  final int id;
  final String trxId;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String referenceType;
  final int referenceId;
  final String description;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.trxId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.referenceType,
    required this.referenceId,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _asInt(json['id']),
      trxId: _asString(json['trx_id']),
      type: _asString(json['type']),
      amount: _asDouble(json['amount']),
      balanceBefore: _asDouble(json['balance_before']),
      balanceAfter: _asDouble(json['balance_after']),
      referenceType: _asString(json['reference_type']),
      referenceId: _asInt(json['reference_id']),
      description: _asString(json['description']),
      createdAt: _asString(json['created_at']),
    );
  }

  bool get isCredit => type == 'recharge' || type == 'refund';
}

// --- Wallet Transactions Page Model ---

class WalletTransactionsModel {
  final List<WalletTransaction> transactions;
  final WalletPagination pagination;

  WalletTransactionsModel({
    required this.transactions,
    required this.pagination,
  });

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final rawList = data['transactions'] as List?;
    return WalletTransactionsModel(
      transactions: rawList
              ?.map((e) =>
                  WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: WalletPagination.fromJson(
          (data['pagination'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

// --- Pagination Model ---

class WalletPagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  WalletPagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
      currentPage: _asInt(json['current_page'], fallback: 1),
      total: _asInt(json['total']),
      perPage: _asInt(json['per_page'], fallback: 15),
      lastPage: _asInt(json['last_page'], fallback: 1),
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

// --- Recharge Invoice Model ---

class WalletRechargeModel {
  final String invoiceId;
  final String paymentUrl;
  final String expiresAt;
  final double amount;
  final String currency;

  WalletRechargeModel({
    required this.invoiceId,
    required this.paymentUrl,
    required this.expiresAt,
    required this.amount,
    required this.currency,
  });

  factory WalletRechargeModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return WalletRechargeModel(
      invoiceId: _asString(data['invoice_id']),
      paymentUrl: _asString(data['payment_url']),
      expiresAt: _asString(data['expires_at']),
      amount: _asDouble(data['amount']),
      currency: _asString(data['currency'], fallback: 'SAR'),
    );
  }
}
