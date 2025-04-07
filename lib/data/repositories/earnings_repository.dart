import '../../domain/models/earnings.dart';
import '../../core/services/firebase/firebase_service.dart';

class EarningsRepository {
  final FirebaseService _firebaseService;
  final String _collection = 'earnings';

  EarningsRepository(this._firebaseService);

  /// Get earnings for a specific period
  Future<Earnings?> getEarnings(
      String deliveryPartnerId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firebaseService
          .collection(_collection)
          .where('deliveryPartnerId', isEqualTo: deliveryPartnerId)
          .where('periodStart', isEqualTo: startDate.millisecondsSinceEpoch)
          .where('periodEnd', isEqualTo: endDate.millisecondsSinceEpoch)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return Earnings.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('Error getting earnings: $e');
      rethrow;
    }
  }

  /// Get earnings history for a delivery partner
  Stream<List<Earnings>> streamEarningsHistory(
    String deliveryPartnerId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
  }) {
    try {
      var query = _firebaseService
          .collection(_collection)
          .where('deliveryPartnerId', isEqualTo: deliveryPartnerId);

      if (startDate != null) {
        query = query.where('periodStart',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch);
      }

      if (endDate != null) {
        query = query.where('periodEnd',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
      }

      query = query.orderBy('periodEnd', descending: true).limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Earnings.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error streaming earnings history: $e');
      rethrow;
    }
  }

  /// Create or update earnings for a period
  Future<void> upsertEarnings(Earnings earnings) async {
    try {
      final data = earnings.toMap();
      await _firebaseService.setDocument(_collection, earnings.id, data);
    } catch (e) {
      print('Error upserting earnings: $e');
      rethrow;
    }
  }

  /// Update earnings breakdown for a specific date
  Future<void> updateDailyBreakdown(
      String earningsId, DateTime date, Map<String, dynamic> breakdown) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await _firebaseService.updateDocument(_collection, earningsId, {
        'dailyBreakdown.$dateKey': breakdown,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating daily breakdown: $e');
      rethrow;
    }
  }

  /// Update earnings breakdown for a specific week
  Future<void> updateWeeklyBreakdown(
      String earningsId, DateTime date, Map<String, dynamic> breakdown) async {
    try {
      final weekKey = '${date.year}-W${(date.day / 7).ceil()}';
      await _firebaseService.updateDocument(_collection, earningsId, {
        'weeklyBreakdown.$weekKey': breakdown,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating weekly breakdown: $e');
      rethrow;
    }
  }

  /// Update earnings breakdown for a specific month
  Future<void> updateMonthlyBreakdown(
      String earningsId, DateTime date, Map<String, dynamic> breakdown) async {
    try {
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      await _firebaseService.updateDocument(_collection, earningsId, {
        'monthlyBreakdown.$monthKey': breakdown,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating monthly breakdown: $e');
      rethrow;
    }
  }

  /// Calculate and update earnings statistics
  Future<void> updateEarningsStatistics(
    String earningsId, {
    double? totalEarnings,
    double? baseEarnings,
    double? surgeEarnings,
    double? tips,
    double? incentives,
    double? deductions,
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    double? averageOrderValue,
    double? averageDeliveryTime,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (totalEarnings != null) updates['totalEarnings'] = totalEarnings;
      if (baseEarnings != null) updates['baseEarnings'] = baseEarnings;
      if (surgeEarnings != null) updates['surgeEarnings'] = surgeEarnings;
      if (tips != null) updates['tips'] = tips;
      if (incentives != null) updates['incentives'] = incentives;
      if (deductions != null) updates['deductions'] = deductions;
      if (totalOrders != null) updates['totalOrders'] = totalOrders;
      if (completedOrders != null) updates['completedOrders'] = completedOrders;
      if (cancelledOrders != null) updates['cancelledOrders'] = cancelledOrders;
      if (averageOrderValue != null) {
        updates['averageOrderValue'] = averageOrderValue;
      }
      if (averageDeliveryTime != null) {
        updates['averageDeliveryTime'] = averageDeliveryTime;
      }

      await _firebaseService.updateDocument(_collection, earningsId, updates);
    } catch (e) {
      print('Error updating earnings statistics: $e');
      rethrow;
    }
  }

  /// Get earnings summary for a delivery partner
  Future<Map<String, dynamic>> getEarningsSummary(
    String deliveryPartnerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firebaseService
          .collection(_collection)
          .where('deliveryPartnerId', isEqualTo: deliveryPartnerId);

      if (startDate != null) {
        query = query.where('periodStart',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch);
      }

      if (endDate != null) {
        query = query.where('periodEnd',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
      }

      final querySnapshot = await query.get();
      final earnings = querySnapshot.docs
          .map((doc) => Earnings.fromMap(doc.data(), doc.id))
          .toList();

      if (earnings.isEmpty) {
        return {
          'totalEarnings': 0.0,
          'netEarnings': 0.0,
          'totalOrders': 0,
          'completedOrders': 0,
          'cancelledOrders': 0,
          'averageOrderValue': 0.0,
          'averageDeliveryTime': 0.0,
          'completionRate': 0.0,
          'cancellationRate': 0.0,
        };
      }

      double totalEarnings = 0.0;
      double totalDeductions = 0.0;
      int totalOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalOrderValue = 0.0;
      double totalDeliveryTime = 0.0;

      for (var earning in earnings) {
        totalEarnings += earning.totalEarnings;
        totalDeductions += earning.deductions;
        totalOrders += earning.totalOrders;
        completedOrders += earning.completedOrders;
        cancelledOrders += earning.cancelledOrders;
        totalOrderValue += earning.averageOrderValue * earning.completedOrders;
        totalDeliveryTime +=
            earning.averageDeliveryTime * earning.completedOrders;
      }

      return {
        'totalEarnings': totalEarnings,
        'netEarnings': totalEarnings - totalDeductions,
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'averageOrderValue':
            completedOrders > 0 ? totalOrderValue / completedOrders : 0.0,
        'averageDeliveryTime':
            completedOrders > 0 ? totalDeliveryTime / completedOrders : 0.0,
        'completionRate': totalOrders > 0 ? completedOrders / totalOrders : 0.0,
        'cancellationRate':
            totalOrders > 0 ? cancelledOrders / totalOrders : 0.0,
      };
    } catch (e) {
      print('Error getting earnings summary: $e');
      rethrow;
    }
  }
}
