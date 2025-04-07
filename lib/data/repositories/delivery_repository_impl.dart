import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../core/services/location/location_service.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../models/delivery_boy.dart';
import '../models/order.dart';
import '../models/store.dart';
import '../models/zone.dart';

/// Implementation of the DeliveryRepository interface
class DeliveryRepositoryImpl implements DeliveryRepository {
  final FirebaseService _firebaseService;
  final LocationService _locationService;

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
  Future<List<Zone>> getAvailableZones() async {
    try {
      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.zonesCollection,
        field: 'is_active',
        isEqualTo: true,
      );

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
  Future<void> updateLocation(firestore.GeoPoint location) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      await _firebaseService.updateDocument(
        AppConstants.deliveryBoysCollection,
        userId,
        {
          'current_location': location,
          'last_active_at': firestore.FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      // Silent error - keep trying
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
  Future<List<Order>> getActiveOrders() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return [];

      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
        orderBy: 'created_at',
        descending: true,
      );

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) => !order.isCompleted())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (doc.exists) {
        return Order.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Order>> getOrderHistory({
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

      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
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

      final order = Order.fromFirestore(orderDoc);
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

      final order = Order.fromFirestore(orderDoc);
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
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': status,
          'status_updated_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeOrder(
    String orderId, {
    String? photoUrl,
    String? deliveryNotes,
    bool handedOverDirectly = true,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusCompleted,
          'completed_at': firestore.FieldValue.serverTimestamp(),
          'delivery_photo_url': photoUrl,
          'delivery_notes': deliveryNotes,
          'handed_over_directly': handedOverDirectly,
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
  Future<bool> confirmCashCollection(String orderId, double amount) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order payment status
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'payment_status': AppConstants.paymentStatusCollected,
          'collected_amount': amount,
          'payment_collected_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyOnlinePayment(String orderId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Check if order belongs to this delivery boy
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final order = Order.fromFirestore(orderDoc);
      if (order.deliveryBoyId != userId) {
        return false; // Not assigned to this delivery boy
      }

      // Update order payment status
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'payment_status': AppConstants.paymentStatusVerified,
          'payment_verified_at': firestore.FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyStatistics({DateTime? date}) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      final targetDate = date ?? DateTime.now();
      final startOfDay =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get completed orders for the day
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(startOfDay) &&
              order.completedAt!.isBefore(endOfDay))
          .toList();

      // Calculate statistics
      final totalOrders = orders.length;
      final totalEarnings = orders.fold<double>(
          0, (sum, order) => sum + (order.deliveryCharges ?? 0));
      final totalDistance =
          orders.fold<double>(0, (sum, order) => sum + (order.distance ?? 0));

      return {
        'date': startOfDay,
        'total_orders': totalOrders,
        'total_earnings': totalEarnings,
        'total_distance': totalDistance,
        'avg_earnings_per_order':
            totalOrders > 0 ? totalEarnings / totalOrders : 0,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyStatistics(
      {DateTime? weekStart}) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      final now = DateTime.now();
      final targetWeekStart =
          weekStart ?? DateTime(now.year, now.month, now.day - now.weekday + 1);
      final weekEnd = targetWeekStart.add(const Duration(days: 7));

      // Get completed orders for the week
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(targetWeekStart) &&
              order.completedAt!.isBefore(weekEnd))
          .toList();

      // Calculate statistics
      final totalOrders = orders.length;
      final totalEarnings = orders.fold<double>(
          0, (sum, order) => sum + (order.deliveryCharges ?? 0));

      // Group orders by day
      final dailyStats = <String, int>{};
      for (final order in orders) {
        final day = order.completedAt!.weekday;
        dailyStats[day.toString()] = (dailyStats[day.toString()] ?? 0) + 1;
      }

      return {
        'week_start': targetWeekStart,
        'week_end': weekEnd,
        'total_orders': totalOrders,
        'total_earnings': totalEarnings,
        'daily_orders': dailyStats,
        'avg_orders_per_day': totalOrders / 7,
        'avg_earnings_per_day': totalEarnings / 7,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlyStatistics(
      {DateTime? monthStart}) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      final now = DateTime.now();
      final targetMonthStart = monthStart ?? DateTime(now.year, now.month, 1);
      final monthEnd =
          DateTime(targetMonthStart.year, targetMonthStart.month + 1, 1);

      // Get completed orders for the month
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(targetMonthStart) &&
              order.completedAt!.isBefore(monthEnd))
          .toList();

      // Calculate statistics
      final totalOrders = orders.length;
      final totalEarnings = orders.fold<double>(
          0, (sum, order) => sum + (order.deliveryCharges ?? 0));

      // Group orders by day of month
      final dailyStats = <String, int>{};
      for (final order in orders) {
        final day = order.completedAt!.day;
        dailyStats[day.toString()] = (dailyStats[day.toString()] ?? 0) + 1;
      }

      // Calculate days in month
      final daysInMonth = monthEnd.difference(targetMonthStart).inDays;

      return {
        'month_start': targetMonthStart,
        'month_end': monthEnd,
        'total_orders': totalOrders,
        'total_earnings': totalEarnings,
        'daily_orders': dailyStats,
        'avg_orders_per_day': totalOrders / daysInMonth,
        'avg_earnings_per_day': totalEarnings / daysInMonth,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Store?> getStoreDetails(String storeId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.storesCollection,
        storeId,
      );

      if (doc.exists) {
        return Store.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
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
  Future<List<Store>> getNearbyStores({double radiusInKm = 5.0}) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) return [];

      // Get all stores
      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.storesCollection,
        field: 'is_active',
        isEqualTo: true,
      );

      // Filter by distance
      final stores =
          snapshot.docs.map((doc) => Store.fromFirestore(doc)).where((store) {
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
  Stream<List<Order>> listenForNewOrders() {
    try {
      // Get orders that are waiting for assignment in the driver's zone
      final stream = _firebaseService.collectionStream(
        AppConstants.ordersCollection,
        field: 'status',
        isEqualTo: 'waiting_for_driver',
      );

      return stream.map((snapshot) => snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) => _isOrderInDriverZone(order))
          .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Stream<Order> listenForOrderUpdates(String orderId) {
    try {
      final stream = _firebaseService.documentStream(
        AppConstants.ordersCollection,
        orderId,
      );

      return stream.map((snapshot) => Order.fromFirestore(snapshot));
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Stream<firestore.GeoPoint> listenForLocationUpdates() {
    try {
      return _locationService.locationStream
          .map((position) => _locationService.positionToGeoPoint(position));
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Future<Map<String, dynamic>> generateEarningsReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return {};

      // Get completed orders for the period
      final ordersSnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
      );

      final orders = ordersSnapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .where((order) =>
              order.completedAt != null &&
              order.completedAt!.isAfter(startDate) &&
              order.completedAt!.isBefore(endDate))
          .toList();

      // Calculate statistics
      final totalOrders = orders.length;
      final totalEarnings = orders.fold<double>(
          0, (sum, order) => sum + (order.deliveryCharges ?? 0));
      final totalDistance =
          orders.fold<double>(0, (sum, order) => sum + (order.distance ?? 0));
      final cashCollected = orders
          .where(
              (order) => order.paymentMethod == AppConstants.paymentMethodCOD)
          .fold<double>(0, (sum, order) => sum + (order.totalAmount ?? 0));

      // Group by payment method
      final ordersByPaymentMethod = <String, int>{};
      for (final order in orders) {
        final method = order.paymentMethod ?? 'unknown';
        ordersByPaymentMethod[method] =
            (ordersByPaymentMethod[method] ?? 0) + 1;
      }

      return {
        'period_start': startDate,
        'period_end': endDate,
        'total_orders': totalOrders,
        'total_earnings': totalEarnings,
        'total_distance': totalDistance,
        'cash_collected': cashCollected,
        'orders_by_payment_method': ordersByPaymentMethod,
        'avg_earning_per_order':
            totalOrders > 0 ? totalEarnings / totalOrders : 0,
        'avg_distance_per_order':
            totalOrders > 0 ? totalDistance / totalOrders : 0,
        'days_in_period': endDate.difference(startDate).inDays,
      };
    } catch (e) {
      return {};
    }
  }

  // Helper methods
  Future<String?> _getUserId() async {
    // Get current user ID from FirebaseAuth
    // This would normally come from AuthRepository, but to avoid circular dependencies,
    // we can implement it directly here
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<bool> _isOrderInDriverZone(Order order) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Get delivery boy zone
      final deliveryBoyDoc = await _firebaseService.getDocument(
        AppConstants.deliveryBoysCollection,
        userId,
      );

      if (!deliveryBoyDoc.exists) return false;

      final deliveryBoy = DeliveryBoy.fromFirestore(deliveryBoyDoc);
      if (deliveryBoy.currentZoneId == null) return false;

      // Check if order's store is in the same zone
      final storeId = order.storeId;
      if (storeId == null) return false;

      final storeDoc = await _firebaseService.getDocument(
        AppConstants.storesCollection,
        storeId,
      );

      if (!storeDoc.exists) return false;

      final store = Store.fromFirestore(storeDoc);

      return store.zoneId == deliveryBoy.currentZoneId;
    } catch (e) {
      return false;
    }
  }
}
