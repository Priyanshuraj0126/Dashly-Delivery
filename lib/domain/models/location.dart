import 'dart:math' show pi, sin, cos, sqrt, atan2;

class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? placeId;
  final DateTime? timestamp;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final bool? isMocked;
  final Map<String, dynamic>? metadata;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.placeId,
    this.timestamp,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.isMocked,
    this.metadata,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      placeId: json['placeId'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      isMocked: json['isMocked'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'placeId': placeId,
      'timestamp': timestamp?.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'isMocked': isMocked,
      'metadata': metadata,
    };
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? placeId,
    DateTime? timestamp,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    bool? isMocked,
    Map<String, dynamic>? metadata,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      placeId: placeId ?? this.placeId,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      isMocked: isMocked ?? this.isMocked,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted address
  String get formattedAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (country != null) parts.add(country!);
    if (postalCode != null) parts.add(postalCode!);
    return parts.join(', ');
  }

  /// Get formatted coordinates
  String get formattedCoordinates {
    return '$latitude, $longitude';
  }

  /// Get formatted speed
  String? get formattedSpeed {
    if (speed == null) return null;
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  /// Get formatted heading
  String? get formattedHeading {
    if (heading == null) return null;
    return '${heading!.toStringAsFixed(1)}°';
  }

  /// Get formatted accuracy
  String? get formattedAccuracy {
    if (accuracy == null) return null;
    return '${accuracy!.toStringAsFixed(1)}m';
  }

  /// Get formatted altitude
  String? get formattedAltitude {
    if (altitude == null) return null;
    return '${altitude!.toStringAsFixed(1)}m';
  }

  /// Calculate distance to another location in kilometers
  double distanceTo(Location other) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1 = latitude * (pi / 180);
    double lon1 = longitude * (pi / 180);
    double lat2 = other.latitude * (pi / 180);
    double lon2 = other.longitude * (pi / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Check if location is within radius of another location
  bool isWithinRadius(Location other, double radiusInKm) {
    return distanceTo(other) <= radiusInKm;
  }

  /// Get bearing to another location in degrees
  double bearingTo(Location other) {
    double lat1 = latitude * (pi / 180);
    double lon1 = longitude * (pi / 180);
    double lat2 = other.latitude * (pi / 180);
    double lon2 = other.longitude * (pi / 180);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x) * (180 / pi);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Get formatted bearing
  String formattedBearingTo(Location other) {
    double bearing = bearingTo(other);
    String direction;

    if (bearing >= 337.5 || bearing < 22.5) {
      direction = 'N';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      direction = 'NE';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      direction = 'E';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      direction = 'SE';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      direction = 'S';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      direction = 'SW';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      direction = 'W';
    } else {
      direction = 'NW';
    }

    return '$direction (${bearing.toStringAsFixed(1)}°)';
  }
}
