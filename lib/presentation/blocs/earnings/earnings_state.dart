import '../../../domain/models/earnings.dart';

abstract class EarningsState {}

class EarningsInitialState extends EarningsState {}

class EarningsLoadingState extends EarningsState {}

class EarningsLoadedState extends EarningsState {
  final Earnings earnings;

  EarningsLoadedState(this.earnings);
}

class EarningsHistoryLoadedState extends EarningsState {
  final List<Earnings> earningsHistory;

  EarningsHistoryLoadedState(this.earningsHistory);
}

class EarningsNotFoundState extends EarningsState {}

class EarningsUpdatedState extends EarningsState {
  final Earnings earnings;

  EarningsUpdatedState(this.earnings);
}

class EarningsBreakdownUpdatedState extends EarningsState {}

class EarningsStatisticsUpdatedState extends EarningsState {}

class EarningsSummaryLoadedState extends EarningsState {
  final Map<String, dynamic> summary;

  EarningsSummaryLoadedState(this.summary);
}

class EarningsErrorState extends EarningsState {
  final String message;

  EarningsErrorState(this.message);
}
