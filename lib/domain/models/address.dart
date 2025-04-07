import 'location.dart';

class Address {
  final String id;
  final String userId;
  final String type;
  final String name;
  final String phoneNumber;
  final String street;
  final String? apartment;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final Location location;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Address({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.phoneNumber,
    required this.street,
    this.apartment,
    this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.location,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      street: json['street'] as String,
      apartment: json['apartment'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      isDefault: json['isDefault'] as bool,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'apartment': apartment,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'location': location.toJson(),
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? type,
    String? name,
    String? phoneNumber,
    String? street,
    String? apartment,
    String? landmark,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    Location? location,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get full address
  String get fullAddress {
    final parts = [
      street,
      if (apartment != null) apartment,
      if (landmark != null) 'Near $landmark',
      '$city, $state',
      '$country, $postalCode',
    ];
    return parts.where((part) => part != null).join(', ');
  }

  /// Get address type display name
  String get displayType {
    switch (type.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      case 'other':
        return 'Other';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get formatted phone number
  String get formattedPhoneNumber {
    if (phoneNumber.length == 10) {
      return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return phoneNumber;
  }

  /// Calculate distance to another location
  double distanceTo(Location other) {
    return location.distanceTo(other);
  }

  /// Check if address is within a certain radius
  bool isWithinRadius(Location other, double radiusInKm) {
    return location.isWithinRadius(other, radiusInKm);
  }
}
