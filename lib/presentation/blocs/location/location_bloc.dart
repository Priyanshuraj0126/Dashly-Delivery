import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/location/location_service.dart';
import '../../../data/models/zone.dart';
import '../../../domain/repositories/delivery_repository.dart';

// Events
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class StartLocationUpdatesEvent extends LocationEvent {
  final int interval;

  const StartLocationUpdatesEvent({this.interval = 10});

  @override
  List<Object?> get props => [interval];
}

class StopLocationUpdatesEvent extends LocationEvent {}

class LocationUpdatedEvent extends LocationEvent {
  final Position position;

  const LocationUpdatedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class CheckZoneEvent extends LocationEvent {
  final GeoPoint location;
  final String zoneId;

  const CheckZoneEvent({
    required this.location,
    required this.zoneId,
  });

  @override
  List<Object?> get props => [location, zoneId];
}

class FetchAssignedZoneEvent extends LocationEvent {}

class FetchAvailableZonesEvent extends LocationEvent {}

// States
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitialState extends LocationState {}

class LocationLoadingState extends LocationState {}

class LocationErrorState extends LocationState {
  final String message;

  const LocationErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationPermissionDeniedState extends LocationState {}

class LocationServiceDisabledState extends LocationState {}

class LocationUpdatedState extends LocationState {
  final Position position;
  final LatLng latLng;
  final GeoPoint geoPoint;

  LocationUpdatedState({required this.position})
      : latLng = LatLng(position.latitude, position.longitude),
        geoPoint = GeoPoint(position.latitude, position.longitude);

  @override
  List<Object?> get props => [position, latLng, geoPoint];
}

class ZonesLoadedState extends LocationState {
  final List<Zone> zones;

  const ZonesLoadedState({required this.zones});

  @override
  List<Object?> get props => [zones];
}

class AssignedZoneLoadedState extends LocationState {
  final Zone zone;

  const AssignedZoneLoadedState({required this.zone});

  @override
  List<Object?> get props => [zone];
}

class OutsideZoneState extends LocationState {
  final GeoPoint location;
  final String zoneId;

  const OutsideZoneState({
    required this.location,
    required this.zoneId,
  });

  @override
  List<Object?> get props => [location, zoneId];
}

// Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final DeliveryRepository _deliveryRepository;
  StreamSubscription? _locationSubscription;
  Timer? _locationUpdateTimer;

  LocationBloc({
    required LocationService locationService,
    required DeliveryRepository deliveryRepository,
  })  : _locationService = locationService,
        _deliveryRepository = deliveryRepository,
        super(LocationInitialState()) {
    on<StartLocationUpdatesEvent>(_onStartLocationUpdates);
    on<StopLocationUpdatesEvent>(_onStopLocationUpdates);
    on<LocationUpdatedEvent>(_onLocationUpdated);
    on<CheckZoneEvent>(_onCheckZone);
    on<FetchAssignedZoneEvent>(_onFetchAssignedZone);
    on<FetchAvailableZonesEvent>(_onFetchAvailableZones);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    return super.close();
  }

  FutureOr<void> _onStartLocationUpdates(
    StartLocationUpdatesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());
    try {
      // Check location permissions
      final hasPermission = await _locationService.checkPermission();
      if (!hasPermission) {
        final permissionGranted = await _locationService.requestPermission();
        if (!permissionGranted) {
          emit(LocationPermissionDeniedState());
          return;
        }
      }

      // Check if location service is enabled
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final enabled = await _locationService.requestService();
        if (!enabled) {
          emit(LocationServiceDisabledState());
          return;
        }
      }

      // Start the location service
      _locationService.startLocationUpdates(intervalSeconds: event.interval);

      // Get initial location
      final initialLocation = await _locationService.getCurrentLocation();
      if (initialLocation != null) {
        emit(LocationUpdatedState(position: initialLocation));
      }

      // Start listening for location updates
      _locationSubscription?.cancel();
      _locationSubscription = _locationService.getLocationStream().listen(
        (location) {
          add(LocationUpdatedEvent(location));
        },
        onError: (e) {
          emit(LocationErrorState(message: 'Location error: $e'));
        },
      );

      // Start periodic updates to Firestore
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
        (_) async {
          try {
            final location = await _locationService.getCurrentLocation();
            if (location != null) {
              await _deliveryRepository.updateLocation(
                  _locationService.positionToGeoPoint(location));
            }
          } catch (e) {
            // Silent error, keep trying
          }
        },
      );
    } catch (e) {
      emit(LocationErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onStopLocationUpdates(
    StopLocationUpdatesEvent event,
    Emitter<LocationState> emit,
  ) async {
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _locationService.stopLocationUpdates();
  }

  FutureOr<void> _onLocationUpdated(
    LocationUpdatedEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationUpdatedState(position: event.position));

    // Update location in Firestore
    try {
      await _deliveryRepository
          .updateLocation(_locationService.positionToGeoPoint(event.position));

      // Check if the user is in their assigned zone
      final assignedZone = await _deliveryRepository.getAssignedZone();
      if (assignedZone != null) {
        final isInZone = assignedZone.containsLocation(
            _locationService.positionToGeoPoint(event.position));
        if (!isInZone) {
          emit(OutsideZoneState(
            location: _locationService.positionToGeoPoint(event.position),
            zoneId: assignedZone.id,
          ));
        }
      }
    } catch (e) {
      // Silent error, don't emit anything
    }
  }

  FutureOr<void> _onCheckZone(
    CheckZoneEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());
    try {
      final isInZone = await _deliveryRepository.isLocationWithinZone(
          event.location, event.zoneId);
      if (!isInZone) {
        emit(OutsideZoneState(
          location: event.location,
          zoneId: event.zoneId,
        ));
      } else {
        // Get the zone details
        final zone = await _deliveryRepository.getZoneById(event.zoneId);
        if (zone != null) {
          emit(AssignedZoneLoadedState(zone: zone));
        }
      }
    } catch (e) {
      emit(LocationErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onFetchAssignedZone(
    FetchAssignedZoneEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());
    try {
      final zone = await _deliveryRepository.getAssignedZone();
      if (zone != null) {
        emit(AssignedZoneLoadedState(zone: zone));

        // Check if current location is within zone
        final currentLocation = await _locationService.getCurrentLocation();
        if (currentLocation != null) {
          final isInZone = zone.containsLocation(
              _locationService.positionToGeoPoint(currentLocation));
          if (!isInZone) {
            emit(OutsideZoneState(
              location: _locationService.positionToGeoPoint(currentLocation),
              zoneId: zone.id,
            ));
          }
        }
      } else {
        emit(const LocationErrorState(message: 'No assigned zone found'));
      }
    } catch (e) {
      emit(LocationErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onFetchAvailableZones(
    FetchAvailableZonesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());
    try {
      final zones = await _deliveryRepository.getAvailableZones();
      emit(ZonesLoadedState(zones: zones));
    } catch (e) {
      emit(LocationErrorState(message: 'Error: ${e.toString()}'));
    }
  }
}
