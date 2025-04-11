import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../core/services/firebase/firebase_messaging_service.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/delivery_boy.dart';
import '../models/order.dart' as order_model;
import '../models/store.dart' as store_model;
import '../models/user.dart' as app_user;

/// Implementation of the OrderRepository interface
class OrderRepositoryImpl implements OrderRepository {
  final FirebaseService _firebaseService;
  late dynamic _messagingService;
  final FirebaseFunctions _functions;

  /// Constructor
  OrderRepositoryImpl({
    required FirebaseService firebaseService,
    required dynamic messagingService,
  })  : _firebaseService = firebaseService,
        _messagingService = messagingService,
        _functions = FirebaseFunctions.instance;

  /// Update the messaging service reference
  void updateMessagingService(FirebaseMessagingService messagingService) {
    _messagingService = messagingService;
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
  Future<List<order_model.Order>> getActiveOrders() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return [];

      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        value: userId,
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
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'created_at',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
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

      // Get order document
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final orderData = orderDoc.data() as Map<String, dynamic>;
      if (orderData['orderStatus'] != 'WAITING_FOR_DRIVER') return false;

      // Update order with delivery boy assignment
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'deliveryBoyId': userId,
          'orderStatus': AppConstants.orderStatusAssigned,
          'assignedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Notify customer and store about order assignment
      await _notifyOrderAssignment(orderId, orderData);

      return true;
    } catch (e) {
      debugPrint('Error accepting order: $e');
      return false;
    }
  }

  Future<void> _notifyOrderAssignment(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      // Notify customer
      if (orderData['customerId'] != null) {
        final customerDoc = await _firebaseService.getDocument(
          AppConstants.usersCollection,
          orderData['customerId'],
        );

        if (customerDoc.exists) {
          final customerData = customerDoc.data() as Map<String, dynamic>;
          if (customerData['fcmToken'] != null) {
            // Send FCM notification to customer using Cloud Function
            await _functions.httpsCallable('sendNotification').call({
              'token': customerData['fcmToken'],
              'title': 'Order Assigned',
              'body': 'A delivery partner has been assigned to your order',
              'data': {
                'type': 'order_assigned',
                'orderId': orderId,
              },
            });
          }
        }
      }

      // Notify store
      if (orderData['vendorId'] != null) {
        final storeDoc = await _firebaseService.getDocument(
          AppConstants.storesCollection,
          orderData['vendorId'],
        );

        if (storeDoc.exists) {
          final storeData = storeDoc.data() as Map<String, dynamic>;
          if (storeData['fcmToken'] != null) {
            // Send FCM notification to store using Cloud Function
            await _functions.httpsCallable('sendNotification').call({
              'token': storeData['fcmToken'],
              'title': 'Order Assigned',
              'body': 'A delivery partner has been assigned to the order',
              'data': {
                'type': 'order_assigned',
                'orderId': orderId,
              },
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error notifying order assignment: $e');
    }
  }

  @override
  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'rejected_by': FieldValue.arrayUnion([userId]),
          'rejection_reason': reason,
        },
      );

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

      // Get order document
      final orderDoc = await _firebaseService.getDocument(
        AppConstants.ordersCollection,
        orderId,
      );

      if (!orderDoc.exists) return false;

      final orderData = orderDoc.data() as Map<String, dynamic>;
      if (orderData['deliveryBoyId'] != userId) return false;

      // Update order status
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'orderStatus': status,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Notify relevant parties about status update
      await _notifyStatusUpdate(orderId, orderData, status);

      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<void> _notifyStatusUpdate(
    String orderId,
    Map<String, dynamic> orderData,
    String status,
  ) async {
    try {
      final statusMessage = _getStatusMessage(status);

      // Notify customer
      if (orderData['customerId'] != null) {
        final customerDoc = await _firebaseService.getDocument(
          AppConstants.usersCollection,
          orderData['customerId'],
        );

        if (customerDoc.exists) {
          final customerData = customerDoc.data() as Map<String, dynamic>;
          if (customerData['fcmToken'] != null) {
            // Send FCM notification to customer using Cloud Function
            await _functions.httpsCallable('sendNotification').call({
              'token': customerData['fcmToken'],
              'title': 'Order Update',
              'body': statusMessage,
              'data': {
                'type': 'order_status_update',
                'orderId': orderId,
                'status': status,
              },
            });
          }
        }
      }

      // Notify store
      if (orderData['vendorId'] != null) {
        final storeDoc = await _firebaseService.getDocument(
          AppConstants.storesCollection,
          orderData['vendorId'],
        );

        if (storeDoc.exists) {
          final storeData = storeDoc.data() as Map<String, dynamic>;
          if (storeData['fcmToken'] != null) {
            // Send FCM notification to store using Cloud Function
            await _functions.httpsCallable('sendNotification').call({
              'token': storeData['fcmToken'],
              'title': 'Order Update',
              'body': statusMessage,
              'data': {
                'type': 'order_status_update',
                'orderId': orderId,
                'status': status,
              },
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error notifying status update: $e');
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case AppConstants.orderStatusOnTheWayToPickup:
        return 'Delivery partner is on the way to pick up your order';
      case AppConstants.orderStatusArrivedAtPickup:
        return 'Delivery partner has arrived at the store';
      case AppConstants.orderStatusPickedUp:
        return 'Your order has been picked up';
      case AppConstants.orderStatusOutForDelivery:
        return 'Your order is out for delivery';
      case AppConstants.orderStatusArrivedAtDelivery:
        return 'Delivery partner has arrived at your location';
      case AppConstants.orderStatusDelivered:
        return 'Your order has been delivered';
      default:
        return 'Order status has been updated';
    }
  }

  @override
  Future<bool> markOrderAsPickedUp(String orderId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusPickedUp,
          'picked_up_at': FieldValue.serverTimestamp(),
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markOrderAsOutForDelivery(String orderId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusOutForDelivery,
          'out_for_delivery_at': FieldValue.serverTimestamp(),
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> markOrderAsDelivered(
    String orderId, {
    String? photoUrl,
    String? deliveryNotes,
    bool handedOverDirectly = true,
  }) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusDelivered,
          'delivered_at': FieldValue.serverTimestamp(),
          'delivery_photo_url': photoUrl,
          'delivery_notes': deliveryNotes,
          'handed_over_directly': handedOverDirectly,
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeOrder(String orderId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': AppConstants.orderStatusCompleted,
          'completed_at': FieldValue.serverTimestamp(),
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> confirmCashCollection(String orderId, double amount) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'payment_status': AppConstants.paymentStatusCollected,
          'collected_amount': amount,
          'payment_collected_at': FieldValue.serverTimestamp(),
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
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'payment_status': AppConstants.paymentStatusVerified,
          'payment_verified_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<app_user.User?> getCustomerDetails(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.usersCollection,
        order.customerId,
      );

      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<store_model.Store?> getStoreDetails(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.storesCollection,
        order.vendorId,
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
  Future<List<order_model.OrderItem>> getOrderItems(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return [];

      return order.items;
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<order_model.Order>> listenForNewOrders() {
    try {
      // Get orders that are waiting for assignment
      final stream = _firebaseService.collectionStream(
        AppConstants.ordersCollection,
        field: 'status',
        value: 'waiting_for_driver',
      );

      return stream.map((snapshot) => snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc))
          .toList());
    } catch (e) {
      return Stream.value([]);
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
  Future<bool> reportOrderIssue(
      String orderId, String issue, String description) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      // Create an issue report
      await _firebaseService.addDocument(
        'order_issues',
        {
          'order_id': orderId,
          'reported_by': userId,
          'issue': issue,
          'description': description,
          'created_at': FieldValue.serverTimestamp(),
          'status': 'pending',
        },
      );

      // Update order with issue flag
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'has_issues': true,
          'latest_issue': issue,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getEstimatedDeliveryTime(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return 30; // Default 30 minutes

      return order.estimatedTimeMinutes ?? 30;
    } catch (e) {
      return 30; // Default 30 minutes
    }
  }

  @override
  Future<bool> updateEstimatedDeliveryTime(String orderId, int minutes) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'estimated_time_minutes': minutes,
          'estimated_time_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DeliveryBoy?> getAssignedDeliveryBoy(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null || order.deliveryBoyId == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.deliveryBoysCollection,
        order.deliveryBoyId!,
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

  // Helper method to get current user ID
  Future<String?> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
}
