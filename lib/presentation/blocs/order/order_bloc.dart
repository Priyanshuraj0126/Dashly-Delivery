import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/order.dart' as order_model;
import '../../../data/models/store.dart' as store_model;
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

class UpdateDeliveryBoyStatusEvent extends OrderEvent {
  final String status;

  const UpdateDeliveryBoyStatusEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class ListenForSpecificOrderEvent extends OrderEvent {
  final String orderId;

  const ListenForSpecificOrderEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class StopListeningForSpecificOrderEvent extends OrderEvent {
  final String orderId;

  const StopListeningForSpecificOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FetchNewOrdersEvent extends OrderEvent {}

// New Events for Delivery Flow
class StartPickupJourneyEvent extends OrderEvent {
  final String orderId;
  const StartPickupJourneyEvent({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class ArrivedAtStoreEvent extends OrderEvent {
  final String orderId;
  const ArrivedAtStoreEvent({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class ArrivedAtCustomerEvent extends OrderEvent {
  final String orderId;
  const ArrivedAtCustomerEvent({required this.orderId});
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
  final List<order_model.Order> orders;

  const ActiveOrdersLoadedState(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryLoadedState extends OrderState {
  final List<order_model.Order> orders;
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
  final order_model.Order order;
  final store_model.Store? store;
  final app_user.User? customer;
  final List<order_model.OrderItem> items;

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
  final bool isAcceptingOrRejecting;

  const OrderStatusUpdatedState({
    required this.orderId,
    required this.status,
    this.isAcceptingOrRejecting = true,
  });

  @override
  List<Object?> get props => [orderId, status, isAcceptingOrRejecting];
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
  final List<order_model.Order> orders;

  const NewOrdersStreamState(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderUpdatedStreamState extends OrderState {
  final order_model.Order order;

  const OrderUpdatedStreamState(this.order);

  @override
  List<Object?> get props => [order];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final DeliveryRepository deliveryRepository;
  StreamSubscription<List<order_model.Order>>? _newOrdersSubscription;
  final Map<String, StreamSubscription<order_model.Order>>
      _orderUpdatesSubscriptions = {};

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
    on<UpdateDeliveryBoyStatusEvent>(_onUpdateDeliveryBoyStatus);
    on<StartPickupJourneyEvent>(_onStartPickupJourney);
    on<ArrivedAtStoreEvent>(_onArrivedAtStore);
    on<ArrivedAtCustomerEvent>(_onArrivedAtCustomer);
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
      // Fetch and emit ONLY active, assigned orders
      final activeOrders = await orderRepository.getActiveOrders();
      debugPrint('Fetched ${activeOrders.length} active/assigned orders');
      emit(ActiveOrdersLoadedState(activeOrders));
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
      emit(OrderErrorState(e.toString()));
    }
  }

  // Helper method to fetch unassigned orders for MVP
  // This method is no longer called by _onFetchActiveOrders.
  // It might still be used by other parts of the bloc or can be removed if confirmed unused.
  Future<List<order_model.Order>> _fetchUnassignedOrders() async {
    try {
      // Get directly from repository's stream method (take just the first result)
      final notifications = await orderRepository.listenForNewOrders().first;
      debugPrint('Found ${notifications.length} unassigned orders from stream');
      return notifications;
    } catch (e) {
      debugPrint('Error fetching unassigned orders: $e');
      return [];
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
      final bool accepted = await orderRepository.acceptOrder(event.orderId);

      if (accepted) {
        emit(OrderStatusUpdatedState(
          orderId: event.orderId,
          status: AppConstants.orderStatusAssigned,
          isAcceptingOrRejecting: false,
        ));
        add(FetchActiveOrdersEvent());
        add(FetchNewOrdersEvent());
      } else {
        emit(const OrderErrorState(
            "Order could not be accepted. It might have been assigned to someone else or is no longer available."));
        add(FetchNewOrdersEvent());
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error accepting order: $e');
        print(stackTrace);
      }
      emit(OrderErrorState("Failed to accept order: ${e.toString()}"));
      add(FetchNewOrdersEvent());
    }
  }

  FutureOr<void> _onRejectOrder(
    RejectOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final bool rejected =
          await orderRepository.rejectOrder(event.orderId, event.reason);

      if (rejected) {
        emit(OrderStatusUpdatedState(
          orderId: event.orderId,
          status: 'rejected',
          isAcceptingOrRejecting: false,
        ));
        add(FetchNewOrdersEvent());
        add(FetchActiveOrdersEvent());
      } else {
        emit(const OrderErrorState(
            "Order could not be rejected. Its status might have changed."));
        add(FetchNewOrdersEvent());
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error rejecting order: $e');
        print(stackTrace);
      }
      emit(OrderErrorState("Failed to reject order: ${e.toString()}"));
      add(FetchNewOrdersEvent());
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
        add(CompleteOrderEvent(orderId: event.orderId));
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
        add(CompleteOrderEvent(orderId: event.orderId));
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
        add(FetchOrderDetailsEvent(orderId: event.orderId));
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
  ) async {
    try {
      debugPrint('Starting to listen for new orders in real-time');

      // Cancel existing subscription if any
      _newOrdersSubscription?.cancel();

      // Subscribe to order updates
      _newOrdersSubscription = orderRepository.listenForNewOrders().listen(
        (orders) {
          if (!emit.isDone) {
            // For MVP: Show all unassigned orders to all delivery boys
            // Only filter based on status, don't check delivery boy ID or zones
            final filteredOrders = orders.where((order) {
              final isValidStatus = order.status == "WAITING_FOR_DRIVER" ||
                  order.status == "PLACED";
              final isNotAssigned =
                  order.deliveryBoyId == null || order.deliveryBoyId!.isEmpty;

              return isValidStatus && isNotAssigned;
            }).toList();

            debugPrint('Returning ${filteredOrders.length} unique orders');

            // Always emit the NewOrdersStreamState for unassigned orders
            emit(NewOrdersStreamState(filteredOrders));
          }
        },
        onError: (error) {
          debugPrint('Error in order stream: $error');
          if (!emit.isDone) {
            emit(OrderErrorState(error.toString()));
          }
        },
      );
    } catch (e) {
      debugPrint('Exception in _onStartListeningForNewOrders: $e');
      if (!emit.isDone) {
        emit(OrderErrorState(e.toString()));
      }
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
  ) async {
    try {
      // Cancel previous subscription if exists
      _orderUpdatesSubscriptions[event.orderId]?.cancel();

      // Start new subscription
      _orderUpdatesSubscriptions[event.orderId] =
          orderRepository.listenForOrderUpdates(event.orderId).listen(
        (order) {
          if (!emit.isDone) {
            emit(OrderUpdatedStreamState(order));
          }
        },
        onError: (error) {
          if (!emit.isDone) {
            emit(OrderErrorState(error.toString()));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(OrderErrorState(e.toString()));
      }
    }
  }

  FutureOr<void> _onStopListeningForSpecificOrder(
    StopListeningForSpecificOrderEvent event,
    Emitter<OrderState> emit,
  ) {
    _orderUpdatesSubscriptions[event.orderId]?.cancel();
    _orderUpdatesSubscriptions.remove(event.orderId);
  }

  FutureOr<void> _onUpdateDeliveryBoyStatus(
    UpdateDeliveryBoyStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final result =
          await deliveryRepository.updateDeliveryBoyStatus(event.status);

      if (result) {
        emit(OrderStatusUpdatedState(
          orderId: '',
          status: event.status,
        ));
      } else {
        emit(const OrderErrorState('Failed to update delivery boy status'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  FutureOr<void> _onStartPickupJourney(
    StartPickupJourneyEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final bool repoResult =
          await deliveryRepository.startOrderPickup(event.orderId);
      if (repoResult) {
        final order_model.Order? fetchedOrder =
            await orderRepository.getOrderById(event.orderId);
        if (fetchedOrder != null) {
          // Explicitly reconstruct to ensure all required fields are present if there's a subtle issue with fetchedOrder
          final reconstructedOrder = order_model.Order(
            id: fetchedOrder.id,
            customerId: fetchedOrder.customerId,
            vendorId: fetchedOrder.vendorId,
            deliveryBoyId: fetchedOrder.deliveryBoyId,
            status: fetchedOrder.status,
            items: fetchedOrder.items, // This is the critical part
            pickupAddress: fetchedOrder.pickupAddress,
            deliveryAddress: fetchedOrder.deliveryAddress,
            payment: fetchedOrder.payment,
            timestamps: fetchedOrder.timestamps,
            store: fetchedOrder.store,
            totalAmount: fetchedOrder.totalAmount,
            specialInstructions: fetchedOrder.specialInstructions,
            deliveryBoyLocation: fetchedOrder.deliveryBoyLocation,
            estimatedTime: fetchedOrder.estimatedTime,
            actualTime: fetchedOrder.actualTime,
            ratings: fetchedOrder.ratings,
            issues: fetchedOrder.issues,
            createdAt: fetchedOrder.createdAt,
            updatedAt: fetchedOrder.updatedAt,
            customer: fetchedOrder.customer, // Accessing the getter
            distance: fetchedOrder.distance,
            deliveryCharges: fetchedOrder.deliveryCharges,
            completedAt: fetchedOrder.completedAt,
            paymentMethod: fetchedOrder.paymentMethod,
            storeId: fetchedOrder.storeId,
          );
          emit(OrderDetailsLoadedState(
              order: reconstructedOrder, items: fetchedOrder.items));
          emit(OrderStatusUpdatedState(
              orderId: event.orderId,
              status: AppConstants.orderStatusOnTheWayToPickup));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after starting pickup journey'));
        }
      } else {
        emit(const OrderErrorState('Failed to start pickup journey'));
      }
    } catch (e) {
      emit(OrderErrorState('Error starting pickup journey: ${e.toString()}'));
    }
  }

  FutureOr<void> _onArrivedAtStore(
    ArrivedAtStoreEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final bool repoResult =
          await deliveryRepository.markAsArrivedAtPickup(event.orderId);
      if (repoResult) {
        final order_model.Order? fetchedOrder =
            await orderRepository.getOrderById(event.orderId);
        if (fetchedOrder != null) {
          final reconstructedOrder = order_model.Order(
            id: fetchedOrder.id,
            customerId: fetchedOrder.customerId,
            vendorId: fetchedOrder.vendorId,
            deliveryBoyId: fetchedOrder.deliveryBoyId,
            status: fetchedOrder.status,
            items: fetchedOrder.items,
            pickupAddress: fetchedOrder.pickupAddress,
            deliveryAddress: fetchedOrder.deliveryAddress,
            payment: fetchedOrder.payment,
            timestamps: fetchedOrder.timestamps,
            store: fetchedOrder.store,
            totalAmount: fetchedOrder.totalAmount,
            specialInstructions: fetchedOrder.specialInstructions,
            deliveryBoyLocation: fetchedOrder.deliveryBoyLocation,
            estimatedTime: fetchedOrder.estimatedTime,
            actualTime: fetchedOrder.actualTime,
            ratings: fetchedOrder.ratings,
            issues: fetchedOrder.issues,
            createdAt: fetchedOrder.createdAt,
            updatedAt: fetchedOrder.updatedAt,
            customer: fetchedOrder.customer,
            distance: fetchedOrder.distance,
            deliveryCharges: fetchedOrder.deliveryCharges,
            completedAt: fetchedOrder.completedAt,
            paymentMethod: fetchedOrder.paymentMethod,
            storeId: fetchedOrder.storeId,
          );
          emit(OrderDetailsLoadedState(
              order: reconstructedOrder, items: fetchedOrder.items));
          emit(OrderStatusUpdatedState(
              orderId: event.orderId,
              status: AppConstants.orderStatusArrivedAtPickup));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after arriving at store'));
        }
      } else {
        emit(const OrderErrorState('Failed to mark as arrived at store'));
      }
    } catch (e) {
      emit(OrderErrorState('Error arriving at store: ${e.toString()}'));
    }
  }

  FutureOr<void> _onArrivedAtCustomer(
    ArrivedAtCustomerEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoadingState());
    try {
      final bool repoResult = await deliveryRepository
          .markAsArrivedAtDeliveryLocation(event.orderId);
      if (repoResult) {
        final order_model.Order? fetchedOrder =
            await orderRepository.getOrderById(event.orderId);
        if (fetchedOrder != null) {
          final reconstructedOrder = order_model.Order(
            id: fetchedOrder.id,
            customerId: fetchedOrder.customerId,
            vendorId: fetchedOrder.vendorId,
            deliveryBoyId: fetchedOrder.deliveryBoyId,
            status: fetchedOrder.status,
            items: fetchedOrder.items,
            pickupAddress: fetchedOrder.pickupAddress,
            deliveryAddress: fetchedOrder.deliveryAddress,
            payment: fetchedOrder.payment,
            timestamps: fetchedOrder.timestamps,
            store: fetchedOrder.store,
            totalAmount: fetchedOrder.totalAmount,
            specialInstructions: fetchedOrder.specialInstructions,
            deliveryBoyLocation: fetchedOrder.deliveryBoyLocation,
            estimatedTime: fetchedOrder.estimatedTime,
            actualTime: fetchedOrder.actualTime,
            ratings: fetchedOrder.ratings,
            issues: fetchedOrder.issues,
            createdAt: fetchedOrder.createdAt,
            updatedAt: fetchedOrder.updatedAt,
            customer: fetchedOrder.customer,
            distance: fetchedOrder.distance,
            deliveryCharges: fetchedOrder.deliveryCharges,
            completedAt: fetchedOrder.completedAt,
            paymentMethod: fetchedOrder.paymentMethod,
            storeId: fetchedOrder.storeId,
          );
          emit(OrderDetailsLoadedState(
              order: reconstructedOrder, items: fetchedOrder.items));
          emit(OrderStatusUpdatedState(
              orderId: event.orderId,
              status: AppConstants.orderStatusArrivedAtDelivery));
        } else {
          emit(const OrderErrorState(
              'Failed to get order details after arriving at customer'));
        }
      } else {
        emit(const OrderErrorState('Failed to mark as arrived at customer'));
      }
    } catch (e) {
      emit(OrderErrorState('Error arriving at customer: ${e.toString()}'));
    }
  }
}
