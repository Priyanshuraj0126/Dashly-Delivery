import '../../../domain/models/earnings.dart';

enum BreakdownType { daily, weekly, monthly }

abstract class EarningsEvent {}

class LoadEarningsEvent extends EarningsEvent {
  final String deliveryPartnerId;
  final DateTime startDate;
  final DateTime endDate;

  LoadEarningsEvent({
    required this.deliveryPartnerId,
    required this.startDate,
    required this.endDate,
  });
}

class LoadEarningsHistoryEvent extends EarningsEvent {
  final String deliveryPartnerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  LoadEarningsHistoryEvent({
    required this.deliveryPartnerId,
    this.startDate,
    this.endDate,
    this.limit = 30,
  });
}

class UpdateEarningsEvent extends EarningsEvent {
  final Earnings earnings;

  UpdateEarningsEvent(this.earnings);
}

class UpdateEarningsBreakdownEvent extends EarningsEvent {
  final String earningsId;
  final DateTime date;
  final BreakdownType breakdownType;
  final Map<String, dynamic> breakdown;

  UpdateEarningsBreakdownEvent({
    required this.earningsId,
    required this.date,
    required this.breakdownType,
    required this.breakdown,
  });
}

class UpdateEarningsStatisticsEvent extends EarningsEvent {
  final String earningsId;
  final double? totalEarnings;
  final double? baseEarnings;
  final double? surgeEarnings;
  final double? tips;
  final double? incentives;
  final double? deductions;
  final int? totalOrders;
  final int? completedOrders;
  final int? cancelledOrders;
  final double? averageOrderValue;
  final double? averageDeliveryTime;

  UpdateEarningsStatisticsEvent({
    required this.earningsId,
    this.totalEarnings,
    this.baseEarnings,
    this.surgeEarnings,
    this.tips,
    this.incentives,
    this.deductions,
    this.totalOrders,
    this.completedOrders,
    this.cancelledOrders,
    this.averageOrderValue,
    this.averageDeliveryTime,
  });
}

class LoadEarningsSummaryEvent extends EarningsEvent {
  final String deliveryPartnerId;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadEarningsSummaryEvent({
    required this.deliveryPartnerId,
    this.startDate,
    this.endDate,
  });
}
