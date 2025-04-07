import '../../data/models/order.dart';
import '../../data/models/delivery_boy.dart';
import '../../data/models/store.dart';
import '../../data/models/user.dart';

/// Interface for order-related operations
abstract class OrderRepository {
  /// Get order by id
  Future<Order?> getOrderById(String orderId);

  /// Get active orders for current delivery boy
  Future<List<Order>> getActiveOrders();

  /// Get order history
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

  /// Mark order as picked up
  Future<bool> markOrderAsPickedUp(String orderId);

  /// Mark order as out for delivery
  Future<bool> markOrderAsOutForDelivery(String orderId);

  /// Mark order as delivered
  Future<bool> markOrderAsDelivered(
    String orderId, {
    String? photoUrl,
    String? deliveryNotes,
    bool handedOverDirectly = true,
  });

  /// Complete order
  Future<bool> completeOrder(String orderId);

  /// Confirm cash collection
  Future<bool> confirmCashCollection(String orderId, double amount);

  /// Verify online payment
  Future<bool> verifyOnlinePayment(String orderId);

  /// Get customer details for order
  Future<User?> getCustomerDetails(String orderId);

  /// Get store details for order
  Future<Store?> getStoreDetails(String orderId);

  /// Get order items
  Future<List<OrderItem>> getOrderItems(String orderId);

  /// Start listening for new orders
  Stream<List<Order>> listenForNewOrders();

  /// Start listening for specific order updates
  Stream<Order> listenForOrderUpdates(String orderId);

  /// Report issue with order
  Future<bool> reportOrderIssue(
      String orderId, String issue, String description);

  /// Get estimated delivery time for order
  Future<int> getEstimatedDeliveryTime(String orderId);

  /// Update estimated delivery time for order
  Future<bool> updateEstimatedDeliveryTime(String orderId, int minutes);

  /// Get assigned delivery boy for order
  Future<DeliveryBoy?> getAssignedDeliveryBoy(String orderId);
}
