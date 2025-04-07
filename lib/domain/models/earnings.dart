class Earnings {
  final String id;
  final String deliveryBoyId;
  final double totalEarnings;
  final double baseEarnings;
  final double tips;
  final double incentives;
  final double deductions;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double averageOrderValue;
  final double averageDeliveryTime;
  final double rating;
  final Map<String, dynamic> dailyBreakdown;
  final Map<String, dynamic> weeklyBreakdown;
  final Map<String, dynamic> monthlyBreakdown;
  final Map<String, dynamic> paymentHistory;
  final Map<String, dynamic> statistics;
  final DateTime createdAt;
  final DateTime updatedAt;

  Earnings({
    required this.id,
    required this.deliveryBoyId,
    required this.totalEarnings,
    required this.baseEarnings,
    required this.tips,
    required this.incentives,
    required this.deductions,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.averageOrderValue,
    required this.averageDeliveryTime,
    required this.rating,
    required this.dailyBreakdown,
    required this.weeklyBreakdown,
    required this.monthlyBreakdown,
    required this.paymentHistory,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      id: json['id'] as String,
      deliveryBoyId: json['deliveryBoyId'] as String,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      baseEarnings: (json['baseEarnings'] as num).toDouble(),
      tips: (json['tips'] as num).toDouble(),
      incentives: (json['incentives'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      completedOrders: json['completedOrders'] as int,
      cancelledOrders: json['cancelledOrders'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      averageDeliveryTime: (json['averageDeliveryTime'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      dailyBreakdown: json['dailyBreakdown'] as Map<String, dynamic>,
      weeklyBreakdown: json['weeklyBreakdown'] as Map<String, dynamic>,
      monthlyBreakdown: json['monthlyBreakdown'] as Map<String, dynamic>,
      paymentHistory: json['paymentHistory'] as Map<String, dynamic>,
      statistics: json['statistics'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryBoyId': deliveryBoyId,
      'totalEarnings': totalEarnings,
      'baseEarnings': baseEarnings,
      'tips': tips,
      'incentives': incentives,
      'deductions': deductions,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'averageOrderValue': averageOrderValue,
      'averageDeliveryTime': averageDeliveryTime,
      'rating': rating,
      'dailyBreakdown': dailyBreakdown,
      'weeklyBreakdown': weeklyBreakdown,
      'monthlyBreakdown': monthlyBreakdown,
      'paymentHistory': paymentHistory,
      'statistics': statistics,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Earnings copyWith({
    String? id,
    String? deliveryBoyId,
    double? totalEarnings,
    double? baseEarnings,
    double? tips,
    double? incentives,
    double? deductions,
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    double? averageOrderValue,
    double? averageDeliveryTime,
    double? rating,
    Map<String, dynamic>? dailyBreakdown,
    Map<String, dynamic>? weeklyBreakdown,
    Map<String, dynamic>? monthlyBreakdown,
    Map<String, dynamic>? paymentHistory,
    Map<String, dynamic>? statistics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Earnings(
      id: id ?? this.id,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      baseEarnings: baseEarnings ?? this.baseEarnings,
      tips: tips ?? this.tips,
      incentives: incentives ?? this.incentives,
      deductions: deductions ?? this.deductions,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      averageDeliveryTime: averageDeliveryTime ?? this.averageDeliveryTime,
      rating: rating ?? this.rating,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      weeklyBreakdown: weeklyBreakdown ?? this.weeklyBreakdown,
      monthlyBreakdown: monthlyBreakdown ?? this.monthlyBreakdown,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate completion rate
  double getCompletionRate() {
    if (totalOrders == 0) return 0.0;
    return completedOrders / totalOrders;
  }

  /// Calculate cancellation rate
  double getCancellationRate() {
    if (totalOrders == 0) return 0.0;
    return cancelledOrders / totalOrders;
  }

  /// Calculate net earnings after deductions
  double getNetEarnings() {
    return totalEarnings - deductions;
  }

  /// Calculate earnings per order
  double getEarningsPerOrder() {
    if (completedOrders == 0) return 0.0;
    return totalEarnings / completedOrders;
  }

  /// Calculate earnings per hour
  double getEarningsPerHour() {
    final hours = updatedAt.difference(createdAt).inHours;
    if (hours == 0) return 0.0;
    return totalEarnings / hours;
  }

  /// Get earnings breakdown for a specific date
  Map<String, dynamic>? getDailyEarnings(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyBreakdown[dateKey];
  }

  /// Get earnings breakdown for a specific week
  Map<String, dynamic>? getWeeklyEarnings(DateTime date) {
    final weekKey = '${date.year}-W${(date.day / 7).ceil()}';
    return weeklyBreakdown[weekKey];
  }

  /// Get earnings breakdown for a specific month
  Map<String, dynamic>? getMonthlyEarnings(DateTime date) {
    final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return monthlyBreakdown[monthKey];
  }
}
