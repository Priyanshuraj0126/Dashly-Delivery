class Coupon {
  final String id;
  final String code;
  final String description;
  final String type;
  final double value;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int? usedCount;
  final int? perUserLimit;
  final List<String>? applicableStores;
  final List<String>? applicableCategories;
  final List<String>? excludedProducts;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderValue,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usedCount,
    this.perUserLimit,
    this.applicableStores,
    this.applicableCategories,
    this.excludedProducts,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minOrderValue: json['minOrderValue'] != null
          ? (json['minOrderValue'] as num).toDouble()
          : null,
      maxDiscount: json['maxDiscount'] != null
          ? (json['maxDiscount'] as num).toDouble()
          : null,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      usageLimit: json['usageLimit'] as int?,
      usedCount: json['usedCount'] as int?,
      perUserLimit: json['perUserLimit'] as int?,
      applicableStores:
          (json['applicableStores'] as List<dynamic>?)?.cast<String>(),
      applicableCategories:
          (json['applicableCategories'] as List<dynamic>?)?.cast<String>(),
      excludedProducts:
          (json['excludedProducts'] as List<dynamic>?)?.cast<String>(),
      isActive: json['isActive'] as bool,
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
      'code': code,
      'description': description,
      'type': type,
      'value': value,
      'minOrderValue': minOrderValue,
      'maxDiscount': maxDiscount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'perUserLimit': perUserLimit,
      'applicableStores': applicableStores,
      'applicableCategories': applicableCategories,
      'excludedProducts': excludedProducts,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Coupon copyWith({
    String? id,
    String? code,
    String? description,
    String? type,
    double? value,
    double? minOrderValue,
    double? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usedCount,
    int? perUserLimit,
    List<String>? applicableStores,
    List<String>? applicableCategories,
    List<String>? excludedProducts,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      perUserLimit: perUserLimit ?? this.perUserLimit,
      applicableStores: applicableStores ?? this.applicableStores,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      excludedProducts: excludedProducts ?? this.excludedProducts,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted value
  String get formattedValue {
    switch (type.toLowerCase()) {
      case 'percentage':
        return '$value%';
      case 'fixed':
        return '₹${value.toStringAsFixed(2)}';
      default:
        return value.toString();
    }
  }

  /// Get formatted minimum order value
  String? get formattedMinOrderValue {
    if (minOrderValue == null) return null;
    return '₹${minOrderValue!.toStringAsFixed(2)}';
  }

  /// Get formatted maximum discount
  String? get formattedMaxDiscount {
    if (maxDiscount == null) return null;
    return '₹${maxDiscount!.toStringAsFixed(2)}';
  }

  /// Check if coupon is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if coupon is not yet started
  bool get isNotStarted => DateTime.now().isBefore(startDate);

  /// Check if coupon is valid
  bool get isValid => isActive && !isExpired && !isNotStarted;

  /// Check if coupon has reached usage limit
  bool get hasReachedUsageLimit {
    if (usageLimit == null) return false;
    return usedCount != null && usedCount! >= usageLimit!;
  }

  /// Get remaining usage count
  int? get remainingUsageCount {
    if (usageLimit == null || usedCount == null) return null;
    return usageLimit! - usedCount!;
  }

  /// Calculate discount for a given order value
  double calculateDiscount(double orderValue) {
    if (!isValid) return 0.0;
    if (minOrderValue != null && orderValue < minOrderValue!) return 0.0;

    double discount;
    if (type.toLowerCase() == 'percentage') {
      discount = (orderValue * value) / 100;
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
    } else {
      discount = value;
    }

    return discount;
  }

  /// Get coupon type display name
  String get displayType {
    switch (type.toLowerCase()) {
      case 'percentage':
        return 'Percentage Off';
      case 'fixed':
        return 'Fixed Amount Off';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get validity period
  String get validityPeriod {
    if (isExpired) return 'Expired';
    if (isNotStarted) return 'Starting ${startDate.toString().split(' ')[0]}';
    return 'Valid till ${endDate.toString().split(' ')[0]}';
  }
}
