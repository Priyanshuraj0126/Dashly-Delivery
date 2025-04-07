import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Model class representing a delivery zone
class Zone {
  final String id;
  final String name;
  final String city;
  final List<GeoPoint> boundaries;
  final List<String> activeDeliveryBoys;
  final GeoPoint? center;
  final double? radius;
  final bool isActive;
  final String? description;

  const Zone({
    required this.id,
    required this.name,
    required this.city,
    required this.boundaries,
    this.activeDeliveryBoys = const [],
    this.center,
    this.radius,
    this.isActive = true,
    this.description,
  });

  /// Create a Zone from a Firestore document
  factory Zone.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    List<GeoPoint> parseBoundaries() {
      final boundariesData = data['boundaries'] as List<dynamic>?;
      if (boundariesData == null) return [];
      
      return boundariesData
          .map((point) => point as GeoPoint)
          .toList();
    }
    
    List<String> parseActiveDeliveryBoys() {
      final deliveryBoysData = data['active_delivery_boys'] as List<dynamic>?;
      if (deliveryBoysData == null) return [];
      
      return deliveryBoysData
          .map((id) => id as String)
          .toList();
    }
    
    return Zone(
      id: doc.id,
      name: data['name'] as String? ?? '',
      city: data['city'] as String? ?? '',
      boundaries: parseBoundaries(),
      activeDeliveryBoys: parseActiveDeliveryBoys(),
      center: data['center'] as GeoPoint?,
      radius: (data['radius'] as num?)?.toDouble(),
      isActive: data['is_active'] as bool? ?? true,
      description: data['description'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'city': city,
      'boundaries': boundaries,
      'active_delivery_boys': activeDeliveryBoys,
      'center': center,
      'radius': radius,
      'is_active': isActive,
      'description': description,
    };
  }

  /// Check if a location is within this zone
  bool containsLocation(GeoPoint location) {
    // Simple implementation for circular zones
    if (center != null && radius != null) {
      return _isWithinRadius(location, center!, radius!);
    }
    
    // For polygon zones, use point-in-polygon algorithm
    if (boundaries.isNotEmpty) {
      return _isPointInPolygon(location, boundaries);
    }
    
    return false;
  }

  /// Check if location is within radius of center
  bool _isWithinRadius(GeoPoint location, GeoPoint center, double radiusInKm) {
    // Calculate distance using Haversine formula
    const double earthRadius = 6371.0; // Earth radius in kilometers
    final double lat1 = center.latitude * (pi / 180.0);
    final double lon1 = center.longitude * (pi / 180.0);
    final double lat2 = location.latitude * (pi / 180.0);
    final double lon2 = location.longitude * (pi / 180.0);
    
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
                     cos(lat1) * cos(lat2) * 
                     sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    final double distance = earthRadius * c;
    
    return distance <= radiusInKm;
  }

  /// Check if point is inside polygon using ray casting algorithm
  bool _isPointInPolygon(GeoPoint point, List<GeoPoint> polygon) {
    if (polygon.length < 3) return false;
    
    bool isInside = false;
    int i = 0;
    int j = polygon.length - 1;
    
    while (i < polygon.length) {
      if ((polygon[i].latitude > point.latitude) != 
          (polygon[j].latitude > point.latitude) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * 
          (point.latitude - polygon[i].latitude) / 
          (polygon[j].latitude - polygon[i].latitude) + 
          polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i++;
    }
    
    return isInside;
  }

  /// Create a copy with updated fields
  Zone copyWith({
    String? id,
    String? name,
    String? city,
    List<GeoPoint>? boundaries,
    List<String>? activeDeliveryBoys,
    GeoPoint? center,
    double? radius,
    bool? isActive,
    String? description,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      boundaries: boundaries ?? this.boundaries,
      activeDeliveryBoys: activeDeliveryBoys ?? this.activeDeliveryBoys,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
} 