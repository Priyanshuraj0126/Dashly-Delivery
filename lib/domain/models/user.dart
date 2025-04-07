import 'package:equatable/equatable.dart';

/// User model representing a delivery partner in the system
class User extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? profileImage;
  final bool isAvailable;
  final bool isVerified;
  final int totalOrdersDelivered;
  final double? rating;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? zoneId;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? documents;
  final Map<String, dynamic>? bankDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImage,
    this.isAvailable = false,
    this.isVerified = false,
    this.totalOrdersDelivered = 0,
    this.rating,
    this.vehicleType,
    this.vehicleNumber,
    this.zoneId,
    this.location,
    this.documents,
    this.bankDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        profileImage,
        isAvailable,
        isVerified,
        totalOrdersDelivered,
        rating,
        vehicleType,
        vehicleNumber,
        zoneId,
        location,
        documents,
        bankDetails,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? profileImage,
    bool? isAvailable,
    bool? isVerified,
    int? totalOrdersDelivered,
    double? rating,
    String? vehicleType,
    String? vehicleNumber,
    String? zoneId,
    Map<String, dynamic>? location,
    Map<String, dynamic>? documents,
    Map<String, dynamic>? bankDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      totalOrdersDelivered: totalOrdersDelivered ?? this.totalOrdersDelivered,
      rating: rating ?? this.rating,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      zoneId: zoneId ?? this.zoneId,
      location: location ?? this.location,
      documents: documents ?? this.documents,
      bankDetails: bankDetails ?? this.bankDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      totalOrdersDelivered: json['totalOrdersDelivered'] as int? ?? 0,
      rating: json['rating'] as double?,
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      zoneId: json['zoneId'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      documents: json['documents'] as Map<String, dynamic>?,
      bankDetails: json['bankDetails'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'totalOrdersDelivered': totalOrdersDelivered,
      'rating': rating,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'zoneId': zoneId,
      'location': location,
      'documents': documents,
      'bankDetails': bankDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
