import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing earnings
class Earnings {
  final String id;
  final String deliveryBoyId;
  final double amount;
  final double baseAmount;
  final double bonusAmount;
  final double tipAmount;
  final DateTime date;
  final List<String> orderIds;
  final int orderCount;
  final double totalDistance;
  final int totalTime;
  final Map<String, dynamic>? metadata;

  const Earnings({
    required this.id,
    required this.deliveryBoyId,
    required this.amount,
    required this.baseAmount,
    required this.bonusAmount,
    required this.tipAmount,
    required this.date,
    required this.orderIds,
    required this.orderCount,
    required this.totalDistance,
    required this.totalTime,
    this.metadata,
  });

  /// Create an Earnings object from a Firestore document
  factory Earnings.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Earnings.fromMap(data);
  }

  /// Create an Earnings object from a map
  factory Earnings.fromMap(Map<String, dynamic> data) {
    return Earnings(
      id: data['id'] as String? ?? '',
      deliveryBoyId: data['delivery_boy_id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      baseAmount: (data['base_amount'] as num?)?.toDouble() ?? 0.0,
      bonusAmount: (data['bonus_amount'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (data['tip_amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      orderIds: List<String>.from(data['order_ids'] ?? []),
      orderCount: data['order_count'] as int? ?? 0,
      totalDistance: (data['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalTime: data['total_time'] as int? ?? 0,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert the Earnings object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'delivery_boy_id': deliveryBoyId,
      'amount': amount,
      'base_amount': baseAmount,
      'bonus_amount': bonusAmount,
      'tip_amount': tipAmount,
      'date': Timestamp.fromDate(date),
      'order_ids': orderIds,
      'order_count': orderCount,
      'total_distance': totalDistance,
      'total_time': totalTime,
      'metadata': metadata,
    };
  }

  /// Create a copy of this Earnings object with the given fields replaced
  Earnings copyWith({
    String? id,
    String? deliveryBoyId,
    double? amount,
    double? baseAmount,
    double? bonusAmount,
    double? tipAmount,
    DateTime? date,
    List<String>? orderIds,
    int? orderCount,
    double? totalDistance,
    int? totalTime,
    Map<String, dynamic>? metadata,
  }) {
    return Earnings(
      id: id ?? this.id,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      amount: amount ?? this.amount,
      baseAmount: baseAmount ?? this.baseAmount,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      date: date ?? this.date,
      orderIds: orderIds ?? this.orderIds,
      orderCount: orderCount ?? this.orderCount,
      totalDistance: totalDistance ?? this.totalDistance,
      totalTime: totalTime ?? this.totalTime,
      metadata: metadata ?? this.metadata,
    );
  }
}
