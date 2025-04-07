/// Model class representing a delivery vehicle
class Vehicle {
  final String type;
  final String? make;
  final String? model;
  final String? color;
  final String registrationNumber;
  final String? registrationYear;
  final bool isActive;

  const Vehicle({
    required this.type,
    this.make,
    this.model,
    this.color,
    required this.registrationNumber,
    this.registrationYear,
    this.isActive = true,
  });

  /// Create a Vehicle from a map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      type: map['type'] as String? ?? '',
      make: map['make'] as String?,
      model: map['model'] as String?,
      color: map['color'] as String?,
      registrationNumber: map['registration_number'] as String? ?? '',
      registrationYear: map['registration_year'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'make': make,
      'model': model,
      'color': color,
      'registration_number': registrationNumber,
      'registration_year': registrationYear,
      'is_active': isActive,
    };
  }

  /// Create a copy with updated fields
  Vehicle copyWith({
    String? type,
    String? make,
    String? model,
    String? color,
    String? registrationNumber,
    String? registrationYear,
    bool? isActive,
  }) {
    return Vehicle(
      type: type ?? this.type,
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationYear: registrationYear ?? this.registrationYear,
      isActive: isActive ?? this.isActive,
    );
  }
}
