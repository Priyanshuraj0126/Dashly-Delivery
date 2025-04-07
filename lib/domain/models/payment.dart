class Payment {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final String method;
  final String status;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.paymentDetails,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'paymentDetails': paymentDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    String? currency,
    String? method,
    String? status,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted amount
  String get formattedAmount {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }

  /// Check if payment is successful
  bool get isSuccessful => status == 'success';

  /// Check if payment is pending
  bool get isPending => status == 'pending';

  /// Check if payment is failed
  bool get isFailed => status == 'failed';

  /// Check if payment is refunded
  bool get isRefunded => status == 'refunded';

  /// Get payment method display name
  String get displayMethod {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash on Delivery';
      case 'card':
        return 'Card Payment';
      case 'upi':
        return 'UPI';
      case 'netbanking':
        return 'Net Banking';
      case 'wallet':
        return 'Wallet';
      default:
        return method
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get payment status display name
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Success';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get payment status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return '#4CAF50';
      case 'pending':
        return '#FFC107';
      case 'failed':
        return '#F44336';
      case 'refunded':
        return '#9E9E9E';
      default:
        return '#9E9E9E';
    }
  }
}
