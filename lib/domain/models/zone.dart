
class Zone {
  final String id;
  final String name;
  final String description;
  final String city;
  final String state;
  final String country;
  final List<String> pincodes;
  final List<String> areas;
  final bool isActive;
  final bool isDefault;
  final double? deliveryFee;
  final double? minimumOrderAmount;
  final double? maximumOrderAmount;
  final int? estimatedDeliveryTime;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.state,
    required this.country,
    required this.pincodes,
    required this.areas,
    required this.isActive,
    required this.isDefault,
    this.deliveryFee,
    this.minimumOrderAmount,
    this.maximumOrderAmount,
    this.estimatedDeliveryTime,
    this.settings,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      pincodes: (json['pincodes'] as List<dynamic>).cast<String>(),
      areas: (json['areas'] as List<dynamic>).cast<String>(),
      isActive: json['isActive'] as bool,
      isDefault: json['isDefault'] as bool,
      deliveryFee: json['deliveryFee'] != null
          ? (json['deliveryFee'] as num).toDouble()
          : null,
      minimumOrderAmount: json['minimumOrderAmount'] != null
          ? (json['minimumOrderAmount'] as num).toDouble()
          : null,
      maximumOrderAmount: json['maximumOrderAmount'] != null
          ? (json['maximumOrderAmount'] as num).toDouble()
          : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as int?,
      settings: json['settings'] as Map<String, dynamic>?,
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
      'city': city,
      'state': state,
      'country': country,
      'pincodes': pincodes,
      'areas': areas,
      'isActive': isActive,
      'isDefault': isDefault,
      'deliveryFee': deliveryFee,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumOrderAmount': maximumOrderAmount,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Zone copyWith({
    String? id,
    String? name,
    String? description,
    String? city,
    String? state,
    String? country,
    List<String>? pincodes,
    List<String>? areas,
    bool? isActive,
    bool? isDefault,
    double? deliveryFee,
    double? minimumOrderAmount,
    double? maximumOrderAmount,
    int? estimatedDeliveryTime,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincodes: pincodes ?? this.pincodes,
      areas: areas ?? this.areas,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumOrderAmount: maximumOrderAmount ?? this.maximumOrderAmount,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted delivery fee
  String? get formattedDeliveryFee {
    if (deliveryFee == null) return null;
    return '₹${deliveryFee!.toStringAsFixed(2)}';
  }

  /// Get formatted minimum order amount
  String? get formattedMinimumOrderAmount {
    if (minimumOrderAmount == null) return null;
    return '₹${minimumOrderAmount!.toStringAsFixed(2)}';
  }

  /// Get formatted maximum order amount
  String? get formattedMaximumOrderAmount {
    if (maximumOrderAmount == null) return null;
    return '₹${maximumOrderAmount!.toStringAsFixed(2)}';
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

  /// Get formatted location
  String get formattedLocation {
    return '$city, $state, $country';
  }

  /// Get formatted areas
  String get formattedAreas {
    return areas.join(', ');
  }

  /// Get formatted pincodes
  String get formattedPincodes {
    return pincodes.join(', ');
  }

  /// Get zone status text
  String get statusText {
    if (!isActive) return 'Inactive';
    if (isDefault) return 'Default Zone';
    return 'Active';
  }

  /// Get zone status color
  String get statusColor {
    if (!isActive) return '#F44336'; // Red
    if (isDefault) return '#4CAF50'; // Green
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

  /// Check if pincode is in zone
  bool hasPincode(String pincode) {
    return pincodes.contains(pincode);
  }

  /// Check if area is in zone
  bool hasArea(String area) {
    return areas.contains(area);
  }

  /// Check if order amount is within limits
  bool isOrderAmountValid(double amount) {
    if (minimumOrderAmount != null && amount < minimumOrderAmount!) {
      return false;
    }
    if (maximumOrderAmount != null && amount > maximumOrderAmount!) {
      return false;
    }
    return true;
  }

  /// Get delivery fee for order amount
  double? getDeliveryFeeForAmount(double amount) {
    if (!isOrderAmountValid(amount)) return null;
    return deliveryFee;
  }

  /// Get formatted delivery fee for order amount
  String? getFormattedDeliveryFeeForAmount(double amount) {
    final fee = getDeliveryFeeForAmount(amount);
    if (fee == null) return null;
    return formattedDeliveryFee;
  }
}
