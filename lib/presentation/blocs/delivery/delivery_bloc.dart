import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/location/location_service.dart';
import '../../../data/models/order.dart' as order_model;
import '../../../domain/repositories/delivery_repository.dart';

// Events
abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => [];
}

class UpdateLocationEvent extends DeliveryEvent {
  final GeoPoint location;

  const UpdateLocationEvent({required this.location});

  @override
  List<Object?> get props => [location];
}

class UpdateStatusEvent extends DeliveryEvent {
  final String status;

  const UpdateStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

class StartDeliveryEvent extends DeliveryEvent {
  final String orderId;

  const StartDeliveryEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CompleteDeliveryEvent extends DeliveryEvent {
  final String orderId;

  const CompleteDeliveryEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// States
abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitialState extends DeliveryState {}

class DeliveryLoadingState extends DeliveryState {}

class DeliveryErrorState extends DeliveryState {
  final String message;

  const DeliveryErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationUpdatedState extends DeliveryState {
  final GeoPoint location;

  const LocationUpdatedState({required this.location});

  @override
  List<Object?> get props => [location];
}

class StatusUpdatedState extends DeliveryState {
  final String status;

  const StatusUpdatedState({required this.status});

  @override
  List<Object?> get props => [status];
}

class DeliveryStartedState extends DeliveryState {
  final order_model.Order order;

  const DeliveryStartedState({required this.order});

  @override
  List<Object?> get props => [order];
}

class DeliveryCompletedState extends DeliveryState {
  final order_model.Order order;

  const DeliveryCompletedState({required this.order});

  @override
  List<Object?> get props => [order];
}

// Bloc
class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryRepository _deliveryRepository;
  final LocationService _locationService;

  DeliveryBloc({
    required DeliveryRepository deliveryRepository,
    required LocationService locationService,
  })  : _deliveryRepository = deliveryRepository,
        _locationService = locationService,
        super(DeliveryInitialState()) {
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<StartDeliveryEvent>(_onStartDelivery);
    on<CompleteDeliveryEvent>(_onCompleteDelivery);

    // Start location tracking when the bloc is created
    _startLocationTracking();
  }

  // Timer for periodic location updates
  Timer? _locationTimer;

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    return super.close();
  }

  // Start tracking the delivery person's location
  void _startLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        add(UpdateLocationEvent(
            location: _locationService.positionToGeoPoint(position)));
      }
    });
  }

  // Event handlers
  FutureOr<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    try {
      emit(DeliveryLoadingState());
      final success = await _deliveryRepository.updateLocation(event.location);
      if (success) {
        emit(LocationUpdatedState(location: event.location));
      } else {
        emit(const DeliveryErrorState(message: 'Failed to update location'));
      }
    } catch (e) {
      emit(DeliveryErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    try {
      emit(DeliveryLoadingState());
      final success =
          await _deliveryRepository.updateDeliveryBoyStatus(event.status);
      if (success) {
        emit(StatusUpdatedState(status: event.status));
      } else {
        emit(const DeliveryErrorState(message: 'Failed to update status'));
      }
    } catch (e) {
      emit(DeliveryErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onStartDelivery(
    StartDeliveryEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    try {
      emit(DeliveryLoadingState());

      // For MVP, we just get the order and update its status
      final order = await _deliveryRepository.getOrderById(event.orderId);

      if (order != null) {
        final success =
            await _deliveryRepository.startOrderDelivery(event.orderId);
        if (success) {
          emit(DeliveryStartedState(order: order));
        } else {
          emit(const DeliveryErrorState(message: 'Failed to start delivery'));
        }
      } else {
        emit(const DeliveryErrorState(message: 'Order not found'));
      }
    } catch (e) {
      emit(DeliveryErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onCompleteDelivery(
    CompleteDeliveryEvent event,
    Emitter<DeliveryState> emit,
  ) async {
    try {
      emit(DeliveryLoadingState());

      // For MVP, we just complete the delivery without additional checks
      final order = await _deliveryRepository.getOrderById(event.orderId);

      if (order != null) {
        final success =
            await _deliveryRepository.completeOrderDelivery(event.orderId);
        if (success) {
          emit(DeliveryCompletedState(order: order));
        } else {
          emit(
              const DeliveryErrorState(message: 'Failed to complete delivery'));
        }
      } else {
        emit(const DeliveryErrorState(message: 'Order not found'));
      }
    } catch (e) {
      emit(DeliveryErrorState(message: 'Error: ${e.toString()}'));
    }
  }
}
