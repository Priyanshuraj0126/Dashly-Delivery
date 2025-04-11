import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/earnings_repository.dart';
import '../../../domain/models/earnings.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository _earningsRepository;
  StreamSubscription<List<Earnings>>? _earningsHistorySubscription;

  EarningsBloc(this._earningsRepository) : super(EarningsInitialState()) {
    on<LoadEarningsEvent>(_onLoadEarnings);
    on<LoadEarningsHistoryEvent>(_onLoadEarningsHistory);
    on<UpdateEarningsEvent>(_onUpdateEarnings);
    on<UpdateEarningsBreakdownEvent>(_onUpdateEarningsBreakdown);
    on<UpdateEarningsStatisticsEvent>(_onUpdateEarningsStatistics);
    on<LoadEarningsSummaryEvent>(_onLoadEarningsSummary);
  }

  Future<void> _onLoadEarnings(
    LoadEarningsEvent event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoadingState());

      final earnings = await _earningsRepository.getEarnings(
        event.deliveryPartnerId,
        event.startDate,
        event.endDate,
      );

      if (earnings != null) {
        emit(EarningsLoadedState(earnings));
      } else {
        emit(EarningsNotFoundState());
      }
    } catch (e) {
      emit(EarningsErrorState('Failed to load earnings: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEarningsHistory(
    LoadEarningsHistoryEvent event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoadingState());

      await _earningsHistorySubscription?.cancel();
      _earningsHistorySubscription = _earningsRepository
          .streamEarningsHistory(
            event.deliveryPartnerId,
            startDate: event.startDate,
            endDate: event.endDate,
            limit: event.limit,
          )
          .listen(
            (earnings) => add(UpdateEarningsEvent(earnings.first)),
            onError: (error) => add(
              UpdateEarningsEvent(
                Earnings(
                  id: '',
                  deliveryPartnerId: event.deliveryPartnerId,
                  periodStart: DateTime.now(),
                  periodEnd: DateTime.now(),
                  totalEarnings: 0,
                  baseEarnings: 0,
                  surgeEarnings: 0,
                  tips: 0,
                  incentives: 0,
                  deductions: 0,
                  totalOrders: 0,
                  completedOrders: 0,
                  cancelledOrders: 0,
                  averageOrderValue: 0,
                  averageDeliveryTime: 0,
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          );
    } catch (e) {
      emit(EarningsErrorState(
          'Failed to load earnings history: ${e.toString()}'));
    }
  }

  void _onUpdateEarnings(
    UpdateEarningsEvent event,
    Emitter<EarningsState> emit,
  ) {
    emit(EarningsUpdatedState(event.earnings));
  }

  Future<void> _onUpdateEarningsBreakdown(
    UpdateEarningsBreakdownEvent event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      // Implementation for updating earnings breakdown
      // This would typically involve updating the breakdown in the repository
      // and then emitting a success state
      emit(EarningsBreakdownUpdatedState());
    } catch (e) {
      emit(EarningsErrorState(
          'Failed to update earnings breakdown: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEarningsStatistics(
    UpdateEarningsStatisticsEvent event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      // Implementation for updating earnings statistics
      // This would typically involve updating the statistics in the repository
      // and then emitting a success state
      emit(EarningsStatisticsUpdatedState());
    } catch (e) {
      emit(EarningsErrorState(
          'Failed to update earnings statistics: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEarningsSummary(
    LoadEarningsSummaryEvent event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoadingState());

      final earnings = await _earningsRepository.getEarnings(
        event.deliveryPartnerId,
        event.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        event.endDate ?? DateTime.now(),
      );

      if (earnings != null) {
        final summary = {
          'totalEarnings': earnings.totalEarnings,
          'baseEarnings': earnings.baseEarnings,
          'surgeEarnings': earnings.surgeEarnings,
          'tips': earnings.tips,
          'incentives': earnings.incentives,
          'deductions': earnings.deductions,
          'totalOrders': earnings.totalOrders,
          'completedOrders': earnings.completedOrders,
          'cancelledOrders': earnings.cancelledOrders,
          'averageOrderValue': earnings.averageOrderValue,
          'averageDeliveryTime': earnings.averageDeliveryTime,
          'dailyBreakdown': earnings.dailyBreakdown,
          'weeklyBreakdown': earnings.weeklyBreakdown,
          'monthlyBreakdown': earnings.monthlyBreakdown,
        };
        emit(EarningsSummaryLoadedState(summary));
      } else {
        emit(EarningsNotFoundState());
      }
    } catch (e) {
      emit(EarningsErrorState(
          'Failed to load earnings summary: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _earningsHistorySubscription?.cancel();
    return super.close();
  }
}
