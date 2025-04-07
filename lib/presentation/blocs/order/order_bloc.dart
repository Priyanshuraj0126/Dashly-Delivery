import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/delivery_boy.dart';
import '../../../data/models/order.dart';
import '../../../data/models/store.dart';
import '../../../data/models/user.dart' as app_user;
import '../../../domain/repositories/delivery_repository.dart';
import '../../../domain/repositories/order_repository.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class FetchActiveOrdersEvent extends OrderEvent {}

class FetchOrderHistoryEvent extends OrderEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final String? status;

  const FetchOrderHistoryEvent({
    this.startDate,
    this.endDate,
    this.limit = 50,
    this.status,
  });

  @override
  List<Object?> get props => [startDate, endDate, limit, status];
}

class FetchOrderDetailsEvent extends OrderEvent {
  final String orderId;

  const FetchOrderDetailsEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class AcceptOrderEvent extends OrderEvent {
  final String orderId;

  const AcceptOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class RejectOrderEvent extends OrderEvent {
  final String orderId;
  final String reason;

  const RejectOrderEvent({
    required this.orderId,
    required this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class MarkAsPickedUpEvent extends OrderEvent {
  final String orderId;

  const MarkAsPickedUpEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class MarkAsOutForDeliveryEvent extends OrderEvent {
  final String orderId;

  const MarkAsOutForDeliveryEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class MarkAsDeliveredEvent extends OrderEvent {
  final String orderId;
  final String? photoUrl;
  final String? deliveryNotes;
  final bool handedOverDirectly;

  const MarkAsDeliveredEvent({
    required this.orderId,
    this.photoUrl,
    this.deliveryNotes,
    this.handedOverDirectly = true,
  });

  @override
  List<Object?> get props => [
        orderId,
        photoUrl,
        deliveryNotes,
        handedOverDirectly,
      ];
}

class CompleteOrderEvent extends OrderEvent {
  final String orderId;

  const CompleteOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ConfirmCashCollectionEvent extends OrderEvent {
  final String orderId;
  final double amount;

  const ConfirmCashCollectionEvent({
    required this.orderId,
    required this.amount,
  });

  @override
  List<Object?> get props => [orderId, amount];
}

class VerifyOnlinePaymentEvent extends OrderEvent {
  final String orderId;

  const VerifyOnlinePaymentEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ReportOrderIssueEvent extends OrderEvent {
  final String orderId;
  final String issue;
  final String description;

  const ReportOrderIssueEvent({
    required this.orderId,
    required this.issue,
    required this.description,
  });

  @override
  List<Object?> get props => [orderId, issue, description];
}

class UpdateEstimatedTimeEvent extends OrderEvent {
  final String orderId;
  final int minutes;

  const UpdateEstimatedTimeEvent({
    required this.orderId,
    required this.minutes,
  });

  @override
  List<Object?> get props => [orderId, minutes];
}

class StartListeningForNewOrdersEvent extends OrderEvent {}

class StopListeningForNewOrdersEvent extends OrderEvent {}

class ListenForSpecificOrderEvent extends OrderEvent {
  final String orderId;

  const ListenForSpecificOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StopListeningForSpecificOrderEvent extends OrderEvent {
  final String orderId;

  const StopListeningForSpecificOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitialState extends OrderState {}

class OrderLoadingState extends OrderState {}

class OrderErrorState extends OrderState {
  final String message;

  const OrderErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class ActiveOrdersLoadedState extends OrderState {
  final List<Order> orders;

  const ActiveOrdersLoadedState(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryLoadedState extends OrderState {
  final List<Order> orders;
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderHistoryLoadedState({
    required this.orders,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [orders, startDate, endDate];
}

class OrderDetailsLoadedState extends OrderState {
  final Order order;
  final Store? store;
  final User? customer;
  final List<OrderItem> items;

  const OrderDetailsLoadedState({
    required this.order,
    this.store,
    this.customer,
    required this.items,
  });

  @override
  List<Object?> get props => [order, store, customer, items];
}

class OrderStatusUpdatedState extends OrderState {
  final String orderId;
  final String status;

  const OrderStatusUpdatedState({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class OrderCompletedState extends OrderState {
  final String orderId;

  const OrderCompletedState(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CashCollectionConfirmedState extends OrderState {
  final String orderId;
  final double amount;

  const CashCollectionConfirmedState({
    required this.orderId,
    required this.amount,
  });

  @override
  List<Object?> get props => [orderId, amount];
}

class OnlinePaymentVerifiedState extends OrderState {
  final String orderId;

  const OnlinePaymentVerifiedState(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class EstimatedTimeUpdatedState extends OrderState {
  final String orderId;
  final int minutes;

  const EstimatedTimeUpdatedState({
    required this.orderId,
    required this.minutes,
  });

  @override
  List<Object?> get props => [orderId, minutes];
}

class NewOrdersStreamState extends OrderState {
  final List<Order> orders;

  const NewOrdersStreamState(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderUpdatedStreamState extends OrderState {
  final Order order;

  const OrderUpdatedStreamState(this.order);

  @override
  List<Object?> get props => [order];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final DeliveryRepository deliveryRepository;
  StreamSubscription<List<Order>>? _newOrdersSubscription;
  final Map<String, StreamSubscription<Order>> _orderUpdatesSubscriptions = {};

  OrderBloc({
    required this.orderRepository,
    required this.deliveryRepository,
  }) : super(OrderInitialState()) {
    on<FetchActiveOrdersEvent>(_onFetchActiveOrders);
    on<FetchOrderHistoryEvent>(_onFetchOrderHistory);
    on<FetchOrderDetailsEvent>(_onFetchOrderDetails);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<MarkAsPickedUpEvent>(_onMarkAsPickedUp);
    on<MarkAsOutForDeliveryEvent>(_onMarkAsOutForDelivery);
    on<MarkAsDeliveredEvent>(_onMarkAsDelivered);
    on<CompleteOrderEvent>(_onCompleteOrder);
    on<ConfirmCashCollectionEvent>(_onConfirmCashCollection);
    on<VerifyOnlinePaymentEvent>(_onVerifyOnlinePayment);
    on<ReportOrderIssueEvent>(_onReportOrderIssue);
    on<UpdateEstimatedTimeEvent>(_onUpdateEstimatedTime);
    on<StartListeningForNewOrdersEvent>(_onStartListeningForNewOrders);
    on<StopListeningForNewOrdersEvent>(_onStopListeningForNewOrders);
    on<ListenForSpecificOrderEvent>(_onListenForSpecificOrder);
    on<StopListeningForSpecificOrderEvent>(_onStopListeningForSpecificOrder);
  }

  @override
  Future<void> close() {
    _newOrdersSubscription?.cancel();
    _orderUpdatesSubscriptions.forEach((_, subscription) {
      subscription.cancel();
    });
    _orderUpdatesSubscriptions.clear();
    return super.close();
  }

  FutureOr<void> _onFetchActiveOrders(
    FetchActiveOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final orders = await orderRepository.getActiveOrders();
      emit(ActiveOrdersLoadedState(orders));
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onFetchOrderHistory(
    FetchOrderHistoryEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final orders = await orderRepository.getOrderHistory(
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
        limit: event.limit,
      );
      emit(OrderHistoryLoadedState(
        orders: orders,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onFetchOrderDetails(
    FetchOrderDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final order = await orderRepository.getOrderById(event.orderId);

      if (order != null) {
        final items = await orderRepository.getOrderItems(event.orderId);
        final store = await orderRepository.getStoreDetails(event.orderId);
        final customer =
            await orderRepository.getCustomerDetails(event.orderId);

        emit(OrderDetailsLoadedState(
          order: order,
          store: store,
          customer: customer,
          items: items,
        ));
      } else {
        emit(const OrderErrorState('Order not found'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.acceptOrder(event.orderId);

      if (result) {
        final order = await orderRepository.getOrderById(event.orderId);

        if (order != null) {
          // Update delivery boy status
          await deliveryRepository.updateDeliveryBoyStatus(
            'on_delivery',
          );

          // Start listening for this specific order's updates
          add(ListenForSpecificOrderEvent(event.orderId));

          emit(OrderStatusUpdatedState(
            orderId: event.orderId,
            status: order.status,
          ));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after accepting'));
        }
      } else {
        emit(const OrderErrorState('Failed to accept order'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onRejectOrder(
    RejectOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.rejectOrder(
        event.orderId,
        event.reason,
      );

      if (result) {
        // Refresh the active orders list
        add(FetchActiveOrdersEvent());
      } else {
        emit(const OrderErrorState('Failed to reject order'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.updateOrderStatus(
        event.orderId,
        event.status,
      );

      if (result) {
        emit(OrderStatusUpdatedState(
          orderId: event.orderId,
          status: event.status,
        ));
      } else {
        emit(const OrderErrorState('Failed to update order status'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onMarkAsPickedUp(
    MarkAsPickedUpEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.markOrderAsPickedUp(event.orderId);

      if (result) {
        final order = await orderRepository.getOrderById(event.orderId);

        if (order != null) {
          emit(OrderStatusUpdatedState(
            orderId: event.orderId,
            status: order.status,
          ));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after pickup'));
        }
      } else {
        emit(const OrderErrorState('Failed to mark order as picked up'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onMarkAsOutForDelivery(
    MarkAsOutForDeliveryEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result =
          await orderRepository.markOrderAsOutForDelivery(event.orderId);

      if (result) {
        final order = await orderRepository.getOrderById(event.orderId);

        if (order != null) {
          emit(OrderStatusUpdatedState(
            orderId: event.orderId,
            status: order.status,
          ));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after marking as out for delivery'));
        }
      } else {
        emit(const OrderErrorState('Failed to mark order as out for delivery'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onMarkAsDelivered(
    MarkAsDeliveredEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.markOrderAsDelivered(
        event.orderId,
        photoUrl: event.photoUrl,
        deliveryNotes: event.deliveryNotes,
        handedOverDirectly: event.handedOverDirectly,
      );

      if (result) {
        final order = await orderRepository.getOrderById(event.orderId);

        if (order != null) {
          emit(OrderStatusUpdatedState(
            orderId: event.orderId,
            status: order.status,
          ));

          // If this is COD, we need to confirm payment collection
          if (order.paymentMethod == 'COD' && order.totalAmount > 0) {
            // Don't automatically transition, let the user handle it
          }
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after delivery'));
        }
      } else {
        emit(const OrderErrorState('Failed to mark order as delivered'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onCompleteOrder(
    CompleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.completeOrder(event.orderId);

      if (result) {
        // If this was the last active order, update status to online
        final activeOrders = await orderRepository.getActiveOrders();

        if (activeOrders.isEmpty) {
          await deliveryRepository.updateDeliveryBoyStatus('online');
        }

        emit(OrderCompletedState(event.orderId));

        // Stop listening for this order's updates
        add(StopListeningForSpecificOrderEvent(event.orderId));

        // Refresh the active orders list
        add(FetchActiveOrdersEvent());
      } else {
        emit(const OrderErrorState('Failed to complete order'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onConfirmCashCollection(
    ConfirmCashCollectionEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.confirmCashCollection(
        event.orderId,
        event.amount,
      );

      if (result) {
        emit(CashCollectionConfirmedState(
          orderId: event.orderId,
          amount: event.amount,
        ));

        // Complete the order
        add(CompleteOrderEvent(event.orderId));
      } else {
        emit(const OrderErrorState('Failed to confirm cash collection'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onVerifyOnlinePayment(
    VerifyOnlinePaymentEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.verifyOnlinePayment(event.orderId);

      if (result) {
        emit(OnlinePaymentVerifiedState(event.orderId));

        // Complete the order
        add(CompleteOrderEvent(event.orderId));
      } else {
        emit(const OrderErrorState('Failed to verify online payment'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onReportOrderIssue(
    ReportOrderIssueEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.reportOrderIssue(
        event.orderId,
        event.issue,
        event.description,
      );

      if (result) {
        // Refresh the order details
        add(FetchOrderDetailsEvent(event.orderId));
      } else {
        emit(const OrderErrorState('Failed to report order issue'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onUpdateEstimatedTime(
    UpdateEstimatedTimeEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result = await orderRepository.updateEstimatedDeliveryTime(
        event.orderId,
        event.minutes,
      );

      if (result) {
        emit(EstimatedTimeUpdatedState(
          orderId: event.orderId,
          minutes: event.minutes,
        ));
      } else {
        emit(const OrderErrorState('Failed to update estimated delivery time'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onStartListeningForNewOrders(
    StartListeningForNewOrdersEvent event,
    Emitter<OrderState> emit,
  ) {
    try {
      _newOrdersSubscription?.cancel();
      _newOrdersSubscription = orderRepository.listenForNewOrders().listen(
        (orders) {
          emit(NewOrdersStreamState(orders));
        },
        onError: (error) {
          emit(OrderErrorState(error.toString()));
        },
      );
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onStopListeningForNewOrders(
    StopListeningForNewOrdersEvent event,
    Emitter<OrderState> emit,
  ) {
    _newOrdersSubscription?.cancel();
    _newOrdersSubscription = null;
  }

  FutureOr<void> _onListenForSpecificOrder(
    ListenForSpecificOrderEvent event,
    Emitter<OrderState> emit,
  ) {
    try {
      // Cancel previous subscription if exists
      _orderUpdatesSubscriptions[event.orderId]?.cancel();

      // Start new subscription
      _orderUpdatesSubscriptions[event.orderId] =
          orderRepository.listenForOrderUpdates(event.orderId).listen(
        (order) {
          emit(OrderUpdatedStreamState(order));
        },
        onError: (error) {
          emit(OrderErrorState(error.toString()));
        },
      );
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onStopListeningForSpecificOrder(
    StopListeningForSpecificOrderEvent event,
    Emitter<OrderState> emit,
  ) {
    _orderUpdatesSubscriptions[event.orderId]?.cancel();
    _orderUpdatesSubscriptions.remove(event.orderId);
  }
}
