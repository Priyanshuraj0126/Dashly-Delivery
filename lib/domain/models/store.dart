import 'location.dart';

class Store {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String? coverUrl;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final Location location;
  final String phoneNumber;
  final String? email;
  final bool isOpen;
  final Map<String, String> operatingHours;
  final double rating;
  final int totalRatings;
  final List<String> categories;
  final Map<String, dynamic> settings;
  final bool isVerified;
  final bool isFeatured;
  final double? minimumOrderAmount;
  final double? deliveryFee;
  final int? estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.coverUrl,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.location,
    required this.phoneNumber,
    this.email,
    required this.isOpen,
    required this.operatingHours,
    required this.rating,
    required this.totalRatings,
    required this.categories,
    required this.settings,
    required this.isVerified,
    required this.isFeatured,
    this.minimumOrderAmount,
    this.deliveryFee,
    this.estimatedDeliveryTime,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String,
      coverUrl: json['coverUrl'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      isOpen: json['isOpen'] as bool,
      operatingHours: Map<String, String>.from(json['operatingHours'] as Map),
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
      isVerified: json['isVerified'] as bool,
      isFeatured: json['isFeatured'] as bool,
      minimumOrderAmount: json['minimumOrderAmount'] != null
          ? (json['minimumOrderAmount'] as num).toDouble()
          : null,
      deliveryFee: json['deliveryFee'] != null
          ? (json['deliveryFee'] as num).toDouble()
          : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as int?,
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
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'location': location.toJson(),
      'phoneNumber': phoneNumber,
      'email': email,
      'isOpen': isOpen,
      'operatingHours': operatingHours,
      'rating': rating,
      'totalRatings': totalRatings,
      'categories': categories,
      'settings': settings,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    Location? location,
    String? phoneNumber,
    String? email,
    bool? isOpen,
    Map<String, String>? operatingHours,
    double? rating,
    int? totalRatings,
    List<String>? categories,
    Map<String, dynamic>? settings,
    bool? isVerified,
    bool? isFeatured,
    double? minimumOrderAmount,
    double? deliveryFee,
    int? estimatedDeliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isOpen: isOpen ?? this.isOpen,
      operatingHours: operatingHours ?? this.operatingHours,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      categories: categories ?? this.categories,
      settings: settings ?? this.settings,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted minimum order amount
  String? get formattedMinimumOrderAmount {
    if (minimumOrderAmount == null) return null;
    return '₹${minimumOrderAmount!.toStringAsFixed(2)}';
  }

  /// Get formatted delivery fee
  String? get formattedDeliveryFee {
    if (deliveryFee == null) return null;
    return '₹${deliveryFee!.toStringAsFixed(2)}';
  }

  /// Get formatted estimated delivery time
  String? get formattedEstimatedDeliveryTime {
    if (estimatedDeliveryTime == null) return null;
    if (estimatedDeliveryTime! < 60) {
      return '$estimatedDeliveryTime minutes';
    }
    final hours = estimatedDeliveryTime! ~/ 60;
    final minutes = estimatedDeliveryTime! % 60;
    if (minutes == 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
  }

  /// Get formatted rating
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  /// Get formatted total ratings
  String get formattedTotalRatings {
    if (totalRatings < 1000) return totalRatings.toString();
    if (totalRatings < 1000000) {
      return '${(totalRatings / 1000).toStringAsFixed(1)}K';
    }
    return '${(totalRatings / 1000000).toStringAsFixed(1)}M';
  }

  /// Get formatted categories
  String get formattedCategories {
    return categories.join(', ');
  }

  /// Get formatted address
  String get formattedAddress {
    return '$address, $city, $state, $country, $postalCode';
  }

  /// Get formatted phone number
  String get formattedPhoneNumber {
    return phoneNumber;
  }

  /// Get formatted email
  String? get formattedEmail {
    return email;
  }

  /// Get formatted operating hours
  String get formattedOperatingHours {
    final now = DateTime.now();
    final day = now.weekday;
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final today = _getDayName(day);
    final hours = operatingHours[today] ?? 'Closed';

    return '$today: $hours';
  }

  /// Get store status text
  String get statusText {
    if (!isOpen) return 'Closed';
    if (isFeatured) return 'Featured';
    if (isVerified) return 'Verified';
    return 'Open';
  }

  /// Get store status color
  String get statusColor {
    if (!isOpen) return '#F44336'; // Red
    if (isFeatured) return '#FFC107'; // Amber
    if (isVerified) return '#4CAF50'; // Green
    return '#2196F3'; // Blue
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted last update date
  String? get formattedLastUpdate {
    if (updatedAt == null) return null;
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  /// Check if store is open now
  bool get isOpenNow {
    if (!isOpen) return false;

    final now = DateTime.now();
    final day = now.weekday;
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final today = _getDayName(day);
    final hours = operatingHours[today] ?? 'Closed';

    if (hours == 'Closed') return false;

    final parts = hours.split(' - ');
    if (parts.length != 2) return false;

    return time.compareTo(parts[0]) >= 0 && time.compareTo(parts[1]) <= 0;
  }

  /// Get next opening time
  String? get nextOpeningTime {
    if (isOpen) return null;

    final now = DateTime.now();
    final day = now.weekday;
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Check next 7 days
    for (var i = 0; i < 7; i++) {
      final nextDay = (day + i) % 7;
      final dayName = _getDayName(nextDay);
      final hours = operatingHours[dayName] ?? 'Closed';

      if (hours != 'Closed') {
        final parts = hours.split(' - ');
        if (parts.length == 2) {
          return 'Opens $dayName at ${parts[0]}';
        }
      }
    }

    return null;
  }

  /// Get distance from location
  double distanceFrom(Location other) {
    return location.distanceTo(other);
  }

  /// Check if store is within radius
  bool isWithinRadius(Location other, double radiusInKm) {
    return location.isWithinRadius(other, radiusInKm);
  }

  /// Get formatted distance from location
  String formattedDistanceFrom(Location other) {
    final distance = distanceFrom(other);
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  /// Get day name from weekday number
  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
