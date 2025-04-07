class Vehicle {
  final String id;
  final String userId;
  final String type;
  final String brand;
  final String model;
  final String number;
  final String? color;
  final String? year;
  final String? registrationNumber;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? rcNumber;
  final DateTime? rcExpiry;
  final bool isVerified;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? metadata;

  Vehicle({
    required this.id,
    required this.userId,
    required this.type,
    required this.brand,
    required this.model,
    required this.number,
    this.color,
    this.year,
    this.registrationNumber,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.rcNumber,
    this.rcExpiry,
    required this.isVerified,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.metadata,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      number: json['number'] as String,
      color: json['color'] as String?,
      year: json['year'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      insuranceExpiry: json['insuranceExpiry'] != null
          ? DateTime.parse(json['insuranceExpiry'] as String)
          : null,
      rcNumber: json['rcNumber'] as String?,
      rcExpiry: json['rcExpiry'] != null
          ? DateTime.parse(json['rcExpiry'] as String)
          : null,
      isVerified: json['isVerified'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'brand': brand,
      'model': model,
      'number': number,
      'color': color,
      'year': year,
      'registrationNumber': registrationNumber,
      'insuranceNumber': insuranceNumber,
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'rcNumber': rcNumber,
      'rcExpiry': rcExpiry?.toIso8601String(),
      'isVerified': isVerified,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? type,
    String? brand,
    String? model,
    String? number,
    String? color,
    String? year,
    String? registrationNumber,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? rcNumber,
    DateTime? rcExpiry,
    bool? isVerified,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      number: number ?? this.number,
      color: color ?? this.color,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      rcNumber: rcNumber ?? this.rcNumber,
      rcExpiry: rcExpiry ?? this.rcExpiry,
      isVerified: isVerified ?? this.isVerified,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get vehicle type display name
  String get displayType {
    switch (type.toLowerCase()) {
      case 'bike':
        return 'Bike';
      case 'scooter':
        return 'Scooter';
      case 'car':
        return 'Car';
      case 'van':
        return 'Van';
      case 'truck':
        return 'Truck';
      case 'bicycle':
        return 'Bicycle';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get formatted vehicle number
  String get formattedNumber {
    return number.toUpperCase();
  }

  /// Get formatted vehicle details
  String get formattedDetails {
    final parts = <String>[];
    if (brand.isNotEmpty) parts.add(brand);
    if (model.isNotEmpty) parts.add(model);
    if (year != null) parts.add(year!);
    if (color != null) parts.add(color!);
    return parts.join(' ');
  }

  /// Get verification status text
  String get verificationStatus {
    if (isVerified) return 'Verified';
    if (rejectionReason != null) return 'Rejected';
    return 'Pending Verification';
  }

  /// Get verification status color
  String get statusColor {
    if (isVerified) return '#4CAF50'; // Green
    if (rejectionReason != null) return '#F44336'; // Red
    return '#FFA000'; // Orange
  }

  /// Get vehicle type icon
  String get vehicleTypeIcon {
    switch (type.toLowerCase()) {
      case 'bike':
        return 'motorcycle';
      case 'scooter':
        return 'scooter';
      case 'car':
        return 'directions_car';
      case 'van':
        return 'local_shipping';
      case 'truck':
        return 'local_shipping';
      case 'bicycle':
        return 'pedal_bike';
      default:
        return 'directions_car';
    }
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted verification date
  String? get formattedVerificationDate {
    if (verifiedAt == null) return null;
    return '${verifiedAt!.day}/${verifiedAt!.month}/${verifiedAt!.year}';
  }

  /// Check if insurance is expired
  bool get isInsuranceExpired {
    if (insuranceExpiry == null) return false;
    return DateTime.now().isAfter(insuranceExpiry!);
  }

  /// Check if RC is expired
  bool get isRCExpired {
    if (rcExpiry == null) return false;
    return DateTime.now().isAfter(rcExpiry!);
  }

  /// Get formatted insurance expiry date
  String? get formattedInsuranceExpiry {
    if (insuranceExpiry == null) return null;
    return '${insuranceExpiry!.day}/${insuranceExpiry!.month}/${insuranceExpiry!.year}';
  }

  /// Get formatted RC expiry date
  String? get formattedRCExpiry {
    if (rcExpiry == null) return null;
    return '${rcExpiry!.day}/${rcExpiry!.month}/${rcExpiry!.year}';
  }

  /// Check if vehicle is active
  bool get isActive => isVerified && !isInsuranceExpired && !isRCExpired;

  /// Get vehicle status text
  String get statusText {
    if (!isVerified) return 'Pending Verification';
    if (rejectionReason != null) return 'Rejected';
    if (isInsuranceExpired) return 'Insurance Expired';
    if (isRCExpired) return 'RC Expired';
    return 'Active';
  }

  /// Get vehicle status color
  String get statusTextColor {
    if (!isVerified) return '#FFA000'; // Orange
    if (rejectionReason != null) return '#F44336'; // Red
    if (isInsuranceExpired) return '#F44336'; // Red
    if (isRCExpired) return '#F44336'; // Red
    return '#4CAF50'; // Green
  }
}
