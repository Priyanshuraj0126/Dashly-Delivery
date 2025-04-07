import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

/// Service for handling location-related functionality
class LocationService {
  /// Stream controller for location updates
  final _locationStreamController = StreamController<Position>.broadcast();

  /// Stream of location updates
  Stream<Position> get locationStream => _locationStreamController.stream;

  /// Stream for location updates that can be listened to by clients
  Stream<Position> getLocationStream() => locationStream;

  /// Timer for periodic location updates
  Timer? _locationTimer;

  /// Constructor
  LocationService() {
    // Initialize location updates when service is created
    _initLocationUpdates();
  }

  /// Initialize location updates
  Future<void> _initLocationUpdates() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Check location permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  /// Check if location permissions are granted
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request to enable location service
  Future<bool> requestService() async {
    return await Geolocator.openLocationSettings();
  }

  /// Start periodic location updates
  void startLocationUpdates({int intervalSeconds = 10}) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) async => await _updateCurrentLocation(),
    );

    // Get initial location immediately
    _updateCurrentLocation();
  }

  /// Stop location updates
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Get last known location
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Convert Position to GeoPoint for Firestore
  firestore.GeoPoint positionToGeoPoint(Position position) {
    return firestore.GeoPoint(position.latitude, position.longitude);
  }

  /// Update current location and add to stream
  Future<void> _updateCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationStreamController.add(position);
    } catch (e) {
      // Silently fail - this is a periodic update
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Calculate estimated time of arrival based on distance and speed
  Duration calculateETA(double distanceInKm, double speedInKmh) {
    if (speedInKmh <= 0) return const Duration(minutes: 30); // Default 30 min

    final hours = distanceInKm / speedInKmh;
    return Duration(seconds: (hours * 3600).round());
  }

  /// Dispose resources
  void dispose() {
    _locationTimer?.cancel();
    _locationStreamController.close();
  }
}
