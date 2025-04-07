import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a store
class Store {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? banner;
  final String address;
  final GeoPoint location;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final Map<String, dynamic>? openingHours;
  final List<String>? categories;
  final double? rating;
  final int? totalRatings;
  final String? zoneId;

  const Store({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.banner,
    required this.address,
    required this.location,
    this.phone,
    this.email,
    this.website,
    this.isActive = true,
    this.openingHours,
    this.categories,
    this.rating,
    this.totalRatings,
    this.zoneId,
  });

  /// Create a Store from a Firestore document
  factory Store.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Parse categories
    List<String>? parseCategories() {
      final categoriesData = data['categories'] as List<dynamic>?;
      if (categoriesData == null) return null;

      return categoriesData.map((category) => category as String).toList();
    }

    return Store(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      logo: data['logo'] as String?,
      banner: data['banner'] as String?,
      address: data['address'] as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      website: data['website'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      openingHours: data['opening_hours'] as Map<String, dynamic>?,
      categories: parseCategories(),
      rating: (data['rating'] as num?)?.toDouble(),
      totalRatings: (data['total_ratings'] as num?)?.toInt(),
      zoneId: data['zone_id'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'banner': banner,
      'address': address,
      'location': location,
      'phone': phone,
      'email': email,
      'website': website,
      'is_active': isActive,
      'opening_hours': openingHours,
      'categories': categories,
      'rating': rating,
      'total_ratings': totalRatings,
      'zone_id': zoneId,
    };
  }

  /// Create a copy with updated fields
  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? banner,
    String? address,
    GeoPoint? location,
    String? phone,
    String? email,
    String? website,
    bool? isActive,
    Map<String, dynamic>? openingHours,
    List<String>? categories,
    double? rating,
    int? totalRatings,
    String? zoneId,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      address: address ?? this.address,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      openingHours: openingHours ?? this.openingHours,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      zoneId: zoneId ?? this.zoneId,
    );
  }
}
