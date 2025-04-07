import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a user
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final List<Address> addresses;
  final Address? defaultAddress;
  final bool isActive;
  final DateTime createdAt;
  final String? fcmToken;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.addresses = const [],
    this.defaultAddress,
    this.isActive = true,
    required this.createdAt,
    this.fcmToken,
  });

  /// Create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Parse addresses
    List<Address> parseAddresses() {
      final addressesData = data['addresses'] as List<dynamic>?;
      if (addressesData == null) return [];

      return addressesData
          .map((addr) => Address.fromMap(addr as Map<String, dynamic>))
          .toList();
    }

    // Parse default address
    Address? parseDefaultAddress() {
      final defaultAddrData = data['default_address'] as Map<String, dynamic>?;
      if (defaultAddrData == null) return null;

      return Address.fromMap(defaultAddrData);
    }

    return User(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      photoUrl: data['photo_url'] as String?,
      addresses: parseAddresses(),
      defaultAddress: parseDefaultAddress(),
      isActive: data['is_active'] as bool? ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data['fcm_token'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'photo_url': photoUrl,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'default_address': defaultAddress?.toMap(),
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'fcm_token': fcmToken,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    List<Address>? addresses,
    Address? defaultAddress,
    bool? isActive,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      addresses: addresses ?? this.addresses,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

/// Model class representing an address
class Address {
  final String id;
  final String label;
  final String fullAddress;
  final String? apartment;
  final String? landmark;
  final GeoPoint location;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.apartment,
    this.landmark,
    required this.location,
    this.isDefault = false,
  });

  /// Create an Address from a map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      fullAddress: map['full_address'] as String? ?? '',
      apartment: map['apartment'] as String?,
      landmark: map['landmark'] as String?,
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      isDefault: map['is_default'] as bool? ?? false,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'full_address': fullAddress,
      'apartment': apartment,
      'landmark': landmark,
      'location': location,
      'is_default': isDefault,
    };
  }

  /// Create a copy with updated fields
  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? apartment,
    String? landmark,
    GeoPoint? location,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
