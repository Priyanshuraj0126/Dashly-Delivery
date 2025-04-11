import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/zone.dart';
import '../../data/models/order.dart' as order_model;
import '../../data/models/store.dart' as store_model;

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

  /// Get active orders for the delivery boy
  Future<List<order_model.Order>> getActiveOrders();

  /// Get order by id
  Future<order_model.Order?> getOrderById(String orderId);

  /// Get order history for the delivery boy
  Future<List<order_model.Order>> getOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int limit = 20,
  });

  /// Accept an order
  Future<bool> acceptOrder(String orderId);

  /// Reject an order
  Future<bool> rejectOrder(String orderId, String reason);

  /// Start order pickup
  Future<bool> startOrderPickup(String orderId);

  /// Complete order pickup
  Future<bool> completeOrderPickup(String orderId);

  /// Start order delivery
  Future<bool> startOrderDelivery(String orderId);

  /// Complete order delivery
  Future<bool> completeOrderDelivery(String orderId);

  /// Update delivery boy location
  Future<bool> updateLocation(GeoPoint location);

  /// Check if location is within a specified zone
  Future<bool> isLocationWithinZone(GeoPoint location, String zoneId);

  /// Get store details
  Future<store_model.Store?> getStoreDetails(String storeId);

  /// Get nearby stores
  Future<List<store_model.Store>> getNearbyStores({double radiusInKm = 5.0});

  /// Listen for new orders
  Stream<List<order_model.Order>> listenForNewOrders();

  /// Listen for order updates
  Stream<order_model.Order> listenForOrderUpdates(String orderId);

  /// Get earnings for a specific date range
  Future<Map<String, dynamic>> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get earnings summary
  Future<Map<String, dynamic>> getEarningsSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}
