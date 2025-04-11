class Earnings {
  final String id;
  final String deliveryPartnerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalEarnings;
  final double baseEarnings;
  final double surgeEarnings;
  final double tips;
  final double incentives;
  final double deductions;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double averageOrderValue;
  final double averageDeliveryTime;
  final Map<String, dynamic>? dailyBreakdown;
  final Map<String, dynamic>? weeklyBreakdown;
  final Map<String, dynamic>? monthlyBreakdown;
  final DateTime updatedAt;

  Earnings({
    required this.id,
    required this.deliveryPartnerId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalEarnings,
    required this.baseEarnings,
    required this.surgeEarnings,
    required this.tips,
    required this.incentives,
    required this.deductions,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.averageOrderValue,
    required this.averageDeliveryTime,
    this.dailyBreakdown,
    this.weeklyBreakdown,
    this.monthlyBreakdown,
    required this.updatedAt,
  });

  factory Earnings.fromMap(Map<String, dynamic> map, String id) {
    return Earnings(
      id: id,
      deliveryPartnerId: map['deliveryPartnerId'] as String,
      periodStart:
          DateTime.fromMillisecondsSinceEpoch(map['periodStart'] as int),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(map['periodEnd'] as int),
      totalEarnings: (map['totalEarnings'] as num).toDouble(),
      baseEarnings: (map['baseEarnings'] as num).toDouble(),
      surgeEarnings: (map['surgeEarnings'] as num).toDouble(),
      tips: (map['tips'] as num).toDouble(),
      incentives: (map['incentives'] as num).toDouble(),
      deductions: (map['deductions'] as num).toDouble(),
      totalOrders: map['totalOrders'] as int,
      completedOrders: map['completedOrders'] as int,
      cancelledOrders: map['cancelledOrders'] as int,
      averageOrderValue: (map['averageOrderValue'] as num).toDouble(),
      averageDeliveryTime: (map['averageDeliveryTime'] as num).toDouble(),
      dailyBreakdown: map['dailyBreakdown'] as Map<String, dynamic>?,
      weeklyBreakdown: map['weeklyBreakdown'] as Map<String, dynamic>?,
      monthlyBreakdown: map['monthlyBreakdown'] as Map<String, dynamic>?,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deliveryPartnerId': deliveryPartnerId,
      'periodStart': periodStart.millisecondsSinceEpoch,
      'periodEnd': periodEnd.millisecondsSinceEpoch,
      'totalEarnings': totalEarnings,
      'baseEarnings': baseEarnings,
      'surgeEarnings': surgeEarnings,
      'tips': tips,
      'incentives': incentives,
      'deductions': deductions,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'averageOrderValue': averageOrderValue,
      'averageDeliveryTime': averageDeliveryTime,
      'dailyBreakdown': dailyBreakdown,
      'weeklyBreakdown': weeklyBreakdown,
      'monthlyBreakdown': monthlyBreakdown,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
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
    final hours = updatedAt.difference(periodStart).inHours;
    if (hours == 0) return 0.0;
    return totalEarnings / hours;
  }

  /// Get earnings breakdown for a specific date
  Map<String, dynamic>? getDailyEarnings(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyBreakdown?[dateKey];
  }

  /// Get earnings breakdown for a specific week
  Map<String, dynamic>? getWeeklyEarnings(DateTime date) {
    final weekKey = '${date.year}-W${(date.day / 7).ceil()}';
    return weeklyBreakdown?[weekKey];
  }

  /// Get earnings breakdown for a specific month
  Map<String, dynamic>? getMonthlyEarnings(DateTime date) {
    final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return monthlyBreakdown?[monthKey];
  }
}
