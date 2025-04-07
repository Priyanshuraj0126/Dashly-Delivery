import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/delivery_boy.dart';
import '../models/order.dart';
import '../models/store.dart';
import '../models/user.dart' as app_user;

/// Implementation of the OrderRepository interface
class OrderRepositoryImpl implements OrderRepository {
  final FirebaseService _firebaseService;

  /// Constructor
  OrderRepositoryImpl({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

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
  Future<List<Order>> getActiveOrders() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return [];

      final snapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.ordersCollection,
        field: 'delivery_boy_id',
        isEqualTo: userId,
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

      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'delivery_boy_id': userId,
          'status': AppConstants.orderStatusAssigned,
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

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
      await _firebaseService.updateDocument(
        AppConstants.ordersCollection,
        orderId,
        {
          'status': status,
          'status_updated_at': FieldValue.serverTimestamp(),
        },
      );

      return true;
    } catch (e) {
      return false;
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
      if (order == null || order.userId == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.usersCollection,
        order.userId!,
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
  Future<Store?> getStoreDetails(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null || order.storeId == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.storesCollection,
        order.storeId!,
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
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null || order.items == null) return [];

      return order.items!;
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Order>> listenForNewOrders() {
    try {
      // Get orders that are waiting for assignment
      final stream = _firebaseService.collectionStream(
        AppConstants.ordersCollection,
        field: 'status',
        isEqualTo: 'waiting_for_driver',
      );

      return stream.map((snapshot) =>
          snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
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
