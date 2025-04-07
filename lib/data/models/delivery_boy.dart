import 'package:cloud_firestore/cloud_firestore.dart';

import 'vehicle.dart';
import 'bank_details.dart';

/// Model class representing a delivery boy
class DeliveryBoy {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? status;
  final bool isActive;
  final bool isOnboarded;
  final String? currentZoneId;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final String? fcmToken;
  final Vehicle? vehicle;
  final BankDetails? bankDetails;
  final Map<String, String>? documents;
  final Map<String, dynamic>? ratings;
  final double? avgRating;
  final int? totalDeliveries;
  final int? totalEarnings;

  const DeliveryBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.status,
    this.isActive = true,
    this.isOnboarded = false,
    this.currentZoneId,
    this.createdAt,
    this.lastActiveAt,
    this.fcmToken,
    this.vehicle,
    this.bankDetails,
    this.documents,
    this.ratings,
    this.avgRating,
    this.totalDeliveries,
    this.totalEarnings,
  });

  /// Create a minimal delivery boy with just ID and phone
  factory DeliveryBoy.minimal({
    required String id,
    required String phone,
  }) {
    return DeliveryBoy(
      id: id,
      name: '',
      phone: phone,
      isActive: true,
      isOnboarded: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a DeliveryBoy from a Firestore document
  factory DeliveryBoy.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Parse vehicle data
    Vehicle? parseVehicle() {
      final vehicleData = data['vehicle'] as Map<String, dynamic>?;
      if (vehicleData == null) return null;

      return Vehicle.fromMap(vehicleData);
    }

    // Parse bank details
    BankDetails? parseBankDetails() {
      final bankData = data['bank_details'] as Map<String, dynamic>?;
      if (bankData == null) return null;

      return BankDetails.fromMap(bankData);
    }

    // Parse documents
    Map<String, String>? parseDocuments() {
      final docsData = data['documents'] as Map<String, dynamic>?;
      if (docsData == null) return null;

      return docsData.map((key, value) => MapEntry(key, value.toString()));
    }

    // Parse ratings
    Map<String, dynamic>? parseRatings() {
      return data['ratings'] as Map<String, dynamic>?;
    }

    return DeliveryBoy(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      photoUrl: data['photo_url'] as String?,
      status: data['status'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      isOnboarded: data['is_onboarded'] as bool? ?? false,
      currentZoneId: data['current_zone_id'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      lastActiveAt: (data['last_active_at'] as Timestamp?)?.toDate(),
      fcmToken: data['fcm_token'] as String?,
      vehicle: parseVehicle(),
      bankDetails: parseBankDetails(),
      documents: parseDocuments(),
      ratings: parseRatings(),
      avgRating: (data['avg_rating'] as num?)?.toDouble(),
      totalDeliveries: (data['total_deliveries'] as num?)?.toInt(),
      totalEarnings: (data['total_earnings'] as num?)?.toInt(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'photo_url': photoUrl,
      'status': status,
      'is_active': isActive,
      'is_onboarded': isOnboarded,
      'current_zone_id': currentZoneId,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'last_active_at': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : FieldValue.serverTimestamp(),
      'fcm_token': fcmToken,
      'vehicle': vehicle?.toMap(),
      'bank_details': bankDetails?.toMap(),
      'documents': documents,
      'ratings': ratings,
      'avg_rating': avgRating,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
    };
  }

  /// Create a copy with updated fields
  DeliveryBoy copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? status,
    bool? isActive,
    bool? isOnboarded,
    String? currentZoneId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? fcmToken,
    Vehicle? vehicle,
    BankDetails? bankDetails,
    Map<String, String>? documents,
    Map<String, dynamic>? ratings,
    double? avgRating,
    int? totalDeliveries,
    int? totalEarnings,
  }) {
    return DeliveryBoy(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      currentZoneId: currentZoneId ?? this.currentZoneId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      fcmToken: fcmToken ?? this.fcmToken,
      vehicle: vehicle ?? this.vehicle,
      bankDetails: bankDetails ?? this.bankDetails,
      documents: documents ?? this.documents,
      ratings: ratings ?? this.ratings,
      avgRating: avgRating ?? this.avgRating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }

  /// Check if the delivery boy profile is complete
  bool isProfileComplete() {
    // Basic profile must be complete
    if (name.isEmpty || phone.isEmpty) {
      return false;
    }

    // Vehicle details must be provided
    if (vehicle == null) {
      return false;
    }

    // Bank details must be provided
    if (bankDetails == null) {
      return false;
    }

    // Required documents must be provided
    if (documents == null || documents!.isEmpty) {
      return false;
    }

    // Required documents check
    final requiredDocs = [
      'aadhar_card',
      'pan_card',
      'driving_license',
    ];

    for (final doc in requiredDocs) {
      if (!documents!.containsKey(doc) || documents![doc]!.isEmpty) {
        return false;
      }
    }

    return true;
  }
}

/// Statistics for a delivery boy
class Statistics {
  final int totalDeliveries;
  final double avgRating;
  final double totalEarnings;
  final int cancelledOrders;
  final double avgDeliveryTime;

  const Statistics({
    this.totalDeliveries = 0,
    this.avgRating = 0.0,
    this.totalEarnings = 0.0,
    this.cancelledOrders = 0,
    this.avgDeliveryTime = 0.0,
  });

  /// Create from JSON
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      avgDeliveryTime: (json['avg_delivery_time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_deliveries': totalDeliveries,
      'avg_rating': avgRating,
      'total_earnings': totalEarnings,
      'cancelled_orders': cancelledOrders,
      'avg_delivery_time': avgDeliveryTime,
    };
  }

  /// Create a copy with updated fields
  Statistics copyWith({
    int? totalDeliveries,
    double? avgRating,
    double? totalEarnings,
    int? cancelledOrders,
    double? avgDeliveryTime,
  }) {
    return Statistics(
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      avgRating: avgRating ?? this.avgRating,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      avgDeliveryTime: avgDeliveryTime ?? this.avgDeliveryTime,
    );
  }
}
