import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../core/services/location/location_service.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../models/delivery_boy.dart';
import '../models/order.dart' as order_model;
import '../models/store.dart' as store_model;
import '../models/zone.dart';

/// Implementation of the DeliveryRepository interface
class DeliveryRepositoryImpl implements DeliveryRepository {
  final FirebaseService _firebaseService;
  final LocationService _locationService;
  Timer? _locationUpdateTimer;
  String? _currentOrderId;

  /// Constructor
  DeliveryRepositoryImpl({
    required FirebaseService firebaseService,
    required LocationService locationService,
  })  : _firebaseService = firebaseService,
        _locationService = locationService;

  @override
  Future<bool> updateDeliveryBoyStatus(String status) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Get current position
      final position = await _locationService.getCurrentLocation();

      await _firebaseService.updateDocument(
        AppConstants.deliveryBoysCollection,
        userId,
        {
          'status': status,
          'last_active_at': firestore.FieldValue.serverTimestamp(),
          if (position != null)
            'current_location': _locationService.positionToGeoPoint(position),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Zone>> getActiveZones() async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.zonesCollection)
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Zone.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Zone?> getZoneById(String zoneId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.zonesCollection,
        zoneId,
      );

      if (doc.exists) {
        return Zone.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Zone?> getAssignedZone() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return null;

      final deliveryBoyDoc = await _firebaseService.getDocument(
        AppConstants.deliveryBoysCollection,
        userId,
      );

      if (!deliveryBoyDoc.exists) return null;

      final deliveryBoy = DeliveryBoy.fromFirestore(deliveryBoyDoc);
      if (deliveryBoy.currentZoneId == null) return null;

      return await getZoneById(deliveryBoy.currentZoneId!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateLocation(firestore.GeoPoint location) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      await _firebaseService.updateDocument(
        AppConstants.deliveryBoysCollection,
        userId,
        {
          'current_location': location,
          'last_active_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLocationWithinZone(
      firestore.GeoPoint location, String zoneId) async {
    try {
      final zone = await getZoneById(zoneId);
      if (zone == null) return false;

      return zone.containsLocation(location);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<order_model.Order>> getActiveOrders() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return [];

      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        value: userId,
        orderBy: 'created_at',
        descending: true,
      );

      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .where((order) => !order.isCompleted())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<order_model.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (doc.exists) {
        return order_model.Order.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<order_model.Order>> getOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    String? status,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return [];

      var query = _firebaseService
          .collection(AppConstants.ordersCollection)
          .where('delivery_boy_id', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where(
          'created_at',
          isGreaterThanOrEqualTo: firestore.Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'created_at',
          isLessThanOrEqualTo: firestore.Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> acceptOrder(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Get current order
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != null && order.deliveryBoyId != userId) {
        return false; // Order already assigned to another delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'delivery_boy_id': userId,
          'status': AppConstants.orderStatusAssigned,
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      // Update delivery boy status
      await updateDeliveryBoyStatus(AppConstants.deliveryBoyStatusBusy);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'delivery_boy_id': null, // Remove assignment
          'rejected_by': firestore.FieldValue.arrayUnion([userId]),
          'rejection_reason': reason,
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      // Update delivery boy status
      await updateDeliveryBoyStatus(AppConstants.deliveryBoyStatusOnline);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startOrderPickup(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusOnTheWayToPickup,
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeOrderPickup(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusPickedUp,
          'picked_up_at': firestore.FieldValue.serverTimestamp(),
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startOrderDelivery(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusOutForDelivery,
          'out_for_delivery_at': firestore.FieldValue.serverTimestamp(),
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeOrderDelivery(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = order_model.Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusDelivered,
          'delivered_at': firestore.FieldValue.serverTimestamp(),
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      // Update delivery boy status back to online
      await updateDeliveryBoyStatus(AppConstants.deliveryBoyStatusOnline);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<store_model.Store?> getStoreDetails(String storeId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.storesCollection,
        storeId,
      );

      if (doc.exists) {
        return store_model.Store.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<store_model.Store>> getNearbyStores(
      {double radiusInKm = 5.0}) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return [];

      // Get all stores
      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.storesCollection,
        field: 'is_active',
        value: true,
      );

      // Filter by distance
      final stores = snapshot.docs
          .map((doc) => store_model.Store.fromFirestore(doc))
          .where((store) {
        final distance = _locationService.calculateDistance(
          LatLng(position.latitude, position.longitude),
          LatLng(store.location.latitude, store.location.longitude),
        );
        return distance <= radiusInKm;
      }).toList();

      // Sort by distance
      stores.sort((a, b) {
        final distanceA = _locationService.calculateDistance(
          LatLng(position.latitude, position.longitude),
          LatLng(a.location.latitude, a.location.longitude),
        );
        final distanceB = _locationService.calculateDistance(
          LatLng(position.latitude, position.longitude),
          LatLng(b.location.latitude, b.location.longitude),
        );
        return distanceA.compareTo(distanceB);
      });

      return stores;
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<order_model.Order>> getAvailableOrders() {
    try {
      debugPrint('Getting available orders checking multiple field patterns');

      // Create a StreamController to manage our custom stream
      final controller = StreamController<List<order_model.Order>>();

      // Create a list of possible queries based on different field patterns
      final query1 = _firebaseService
          .collection(AppConstants.ordersCollection)
          .where('availableForDelivery', isEqualTo: true)
          .where('assignedToDeliveryBoy', isNull: true);

      final query2 = _firebaseService
          .collection(AppConstants.ordersCollection)
          .where('orderStatus', isEqualTo: 'WAITING_FOR_DRIVER')
          .where('deliveryBoyId', isNull: true);

      final query3 = _firebaseService
          .collection(AppConstants.ordersCollection)
          .where('status', isEqualTo: 'WAITING_FOR_DRIVER')
          .where('delivery_boy_id', isNull: true);

      // Helper function to fetch and combine orders
      Future<void> fetchAndAddOrders() async {
        try {
          final results1 = await query1.get();
          final results2 = await query2.get();
          final results3 = await query3.get();

          // Process and deduplicate results
          final Map<String, order_model.Order> uniqueOrders = {};

          for (final doc in [
            ...results1.docs,
            ...results2.docs,
            ...results3.docs
          ]) {
            try {
              final order = order_model.Order.fromFirestore(doc);
              uniqueOrders[order.id] = order;
              debugPrint(
                  'FOUND AVAILABLE ORDER: ID=${order.id}, Status=${order.status}, OrderStatus=${doc.data()['orderStatus']}, AvailableForDelivery=${doc.data()['availableForDelivery']}');
            } catch (e) {
              debugPrint('Error parsing order: $e');
            }
          }

          // Add to stream if controller is still active
          if (!controller.isClosed) {
            controller.add(uniqueOrders.values.toList());
          }
        } catch (e) {
          debugPrint('Error fetching orders: $e');
          if (!controller.isClosed) {
            controller.add([]);
          }
        }
      }

      // Fetch immediately
      fetchAndAddOrders();

      // Setup periodic fetching
      final timer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => fetchAndAddOrders(),
      );

      // Close timer when the stream is closed
      controller.onCancel = () {
        timer.cancel();
      };

      return controller.stream;
    } catch (e) {
      debugPrint('Error getting available orders: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<List<order_model.Order>> getCurrentOrders(String userId) async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.ordersCollection)
          .where('delivery_boy_id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateDeliveryLocation(LatLng location) async {
    if (_currentOrderId == null) return;

    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        _currentOrderId!,
        {
          'deliveryBoyLocation': {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
          },
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Stream<order_model.Order> listenForOrderUpdates(String orderId) {
    try {
      final stream = _firebaseService.documentStream(
        AppConstants.ordersCollection,
        orderId,
      );

      return stream
          .map((snapshot) => order_model.Order.fromFirestore(snapshot));
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Future<Map<String, dynamic>> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      final targetStartDate =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final targetEndDate = endDate ?? DateTime.now();

      // Get completed orders for the period
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        value: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(targetStartDate) &&
              order.completedAt!.isBefore(targetEndDate))
          .toList();

      // Calculate earnings
      final totalEarnings = orders.fold<double>(
          0, (sum, order) => sum + (order.deliveryCharges ?? 0));
      final totalDistance =
          orders.fold<double>(0, (sum, order) => sum + (order.distance ?? 0));
      final totalOrders = orders.length;

      return {
        'total_earnings': totalEarnings,
        'total_distance': totalDistance,
        'total_orders': totalOrders,
        'avg_earnings_per_order':
            totalOrders > 0 ? totalEarnings / totalOrders : 0,
        'avg_distance_per_order':
            totalOrders > 0 ? totalDistance / totalOrders : 0,
        'period_start': targetStartDate,
        'period_end': targetEndDate,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getEarningsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      final targetStartDate =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final targetEndDate = endDate ?? DateTime.now();

      // Get completed orders for the period
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        value: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(targetStartDate) &&
              order.completedAt!.isBefore(targetEndDate))
          .toList();

      // Group orders by day
      final dailyEarnings = <String, double>{};
      final dailyOrders = <String, int>{};
      final dailyDistance = <String, double>{};

      for (final order in orders) {
        final day = order.completedAt!.toIso8601String().split('T')[0];
        dailyEarnings[day] =
            (dailyEarnings[day] ?? 0) + (order.deliveryCharges ?? 0);
        dailyOrders[day] = (dailyOrders[day] ?? 0) + 1;
        dailyDistance[day] = (dailyDistance[day] ?? 0) + (order.distance ?? 0);
      }

      return {
        'daily_earnings': dailyEarnings,
        'daily_orders': dailyOrders,
        'daily_distance': dailyDistance,
        'period_start': targetStartDate,
        'period_end': targetEndDate,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<DeliveryBoy?> getDeliveryBoyById(String id) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.deliveryBoysCollection,
        id,
      );

      if (doc.exists) {
        return DeliveryBoy.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> startOrderTracking(String orderId) async {
    _currentOrderId = orderId;

    // Cancel any existing timer
    _locationUpdateTimer?.cancel();

    // Start periodic location updates
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateDeliveryLocation(),
    );

    // Initial location update
    await _updateDeliveryLocation();
  }

  @override
  Future<void> stopOrderTracking() async {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _currentOrderId = null;
  }

  Future<void> _updateDeliveryLocation() async {
    if (_currentOrderId == null) return;

    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return;

      final location = LatLng(position.latitude, position.longitude);

      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        _currentOrderId!,
        {
          'deliveryBoyLocation': {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
          },
        },
      );
    } catch (e) {
      debugPrint('Error updating delivery location: $e');
    }
  }

  @override
  Stream<LatLng?> getDeliveryBoyLocationStream(String orderId) {
    return _firebaseService
        .documentStream(AppConstants.ordersCollection, orderId)
        .map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data() as Map<String, dynamic>;
      final location = data['deliveryBoyLocation'];

      if (location == null) return null;

      return LatLng(
        location['latitude'] as double,
        location['longitude'] as double,
      );
    });
  }

  @override
  Future<void> dispose() async {
    await stopOrderTracking();
  }

  // Helper methods
  Future<String?> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Future<List<Zone>> getAvailableZones() async {
    try {
      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.zonesCollection,
        field: 'is_active',
        value: true,
      );

      return snapshot.docs.map((doc) => Zone.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<order_model.Order>> listenForNewOrders() {
    return getAvailableOrders();
  }

  @override
  Future<Zone> getDefaultZone() async {
    return Zone(
      id: 'default-zone',
      name: 'All Service Areas',
      city: 'All Cities',
      boundaries: const [],
      activeDeliveryBoys: const [],
      center: null,
      radius: null,
      isActive: true,
      description: 'Default delivery zone for MVP',
    );
  }
}
