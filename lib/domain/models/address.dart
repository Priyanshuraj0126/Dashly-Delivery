import 'package:cloud_firestore/cloud_firestore.dart';

/// Address type enum
enum AddressType {
  home,
  work,
  other,
}

/// Model class representing an address
class Address {
  final String id;
  final String street;
  final String? apartment;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final AddressType type;
  final String? phoneNumber;
  final GeoPoint location;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.street,
    this.apartment,
    this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.type,
    this.phoneNumber,
    required this.location,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the full address as a string
  String get fullAddress {
    final parts = <String>[];

    if (street.isNotEmpty) parts.add(street);
    if (apartment != null && apartment!.isNotEmpty) parts.add('Apt $apartment');
    if (landmark != null && landmark!.isNotEmpty) parts.add('Near $landmark');

    final cityState = '$city, $state';
    if (cityState.isNotEmpty) parts.add(cityState);

    if (postalCode.isNotEmpty) parts.add(postalCode);
    if (country.isNotEmpty) parts.add(country);

    return parts.join(', ');
  }

  /// Create an Address from a Firestore document
  factory Address.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Address.fromMap(data);
  }

  /// Create an Address from a map
  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'] as String? ?? '',
      street: data['street'] as String? ?? '',
      apartment: data['apartment'] as String?,
      landmark: data['landmark'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      country: data['country'] as String? ?? '',
      postalCode: data['postal_code'] as String? ?? '',
      type: _parseAddressType(data['type'] as String?),
      phoneNumber: data['phone_number'] as String?,
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      isDefault: data['is_default'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the Address to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'street': street,
      'apartment': apartment,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'type': type.name,
      'phone_number': phoneNumber,
      'location': location,
      'is_default': isDefault,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of this Address with the given fields replaced
  Address copyWith({
    String? id,
    String? street,
    String? apartment,
    String? landmark,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    AddressType? type,
    String? phoneNumber,
    GeoPoint? location,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      type: type ?? this.type,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Parse an address type from a string
  static AddressType _parseAddressType(String? type) {
    if (type == null) return AddressType.other;

    switch (type.toLowerCase()) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      default:
        return AddressType.other;
    }
  }
}
