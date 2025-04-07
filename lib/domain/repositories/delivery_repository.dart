import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/delivery_boy.dart';
import '../../data/models/zone.dart';
import '../../data/models/order.dart';
import '../../data/models/store.dart';

/// Interface for delivery-related operations
abstract class DeliveryRepository {
  /// Update delivery boy status (online/offline/on_delivery/on_break)
  Future<bool> updateDeliveryBoyStatus(String status);

  /// Get available zones
  Future<List<Zone>> getAvailableZones();

  /// Get zone by id
  Future<Zone?> getZoneById(String zoneId);

  /// Get assigned zone
  Future<Zone?> getAssignedZone();

  /// Update delivery boy location
  Future<void> updateLocation(GeoPoint location);

  /// Check if location is within assigned zone
  Future<bool> isLocationWithinZone(GeoPoint location, String zoneId);

  /// Get active orders for current delivery boy
  Future<List<Order>> getActiveOrders();

  /// Get order by id
  Future<Order?> getOrderById(String orderId);

  /// Get order history for current delivery boy
  Future<List<Order>> getOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    String? status,
  });

  /// Accept order
  Future<bool> acceptOrder(String orderId);

  /// Reject order
  Future<bool> rejectOrder(String orderId, String reason);

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status);

  /// Complete order
  Future<bool> completeOrder(
    String orderId, {
    String? photoUrl,
    String? deliveryNotes,
    bool handedOverDirectly = true,
  });

  /// Confirm cash collection
  Future<bool> confirmCashCollection(String orderId, double amount);

  /// Verify online payment
  Future<bool> verifyOnlinePayment(String orderId);

  /// Get daily statistics
  Future<Map<String, dynamic>> getDailyStatistics({DateTime? date});

  /// Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStatistics({DateTime? weekStart});

  /// Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStatistics({DateTime? monthStart});

  /// Get store details
  Future<Store?> getStoreDetails(String storeId);

  /// Get delivery boy by id
  Future<DeliveryBoy?> getDeliveryBoyById(String id);

  /// Get nearby stores
  Future<List<Store>> getNearbyStores({double radiusInKm = 5.0});

  /// Start listening for new orders
  Stream<List<Order>> listenForNewOrders();

  /// Start listening for order updates
  Stream<Order> listenForOrderUpdates(String orderId);

  /// Start listening for location updates
  Stream<GeoPoint> listenForLocationUpdates();

  /// Generate earnings report for a period
  Future<Map<String, dynamic>> generateEarningsReport({
    required DateTime startDate,
    required DateTime endDate,
  });
}
