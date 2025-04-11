import 'address.dart';

class Order {
  final String id;
  final String userId;
  final String storeId;
  final String? deliveryBoyId;
  final List<OrderItem> items;
  final double total;
  final double deliveryCharges;
  final Address deliveryAddress;
  final String deliveryTimeWindow;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final double? distance;
  final Map<String, dynamic>? deliveryBoyLocation;

  Order({
    required this.id,
    required this.userId,
    required this.storeId,
    this.deliveryBoyId,
    required this.items,
    required this.total,
    required this.deliveryCharges,
    required this.deliveryAddress,
    required this.deliveryTimeWindow,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.distance,
    this.deliveryBoyLocation,
  });

  // Create a copy of this order with updated fields
  Order copyWith({
    String? id,
    String? userId,
    String? storeId,
    String? deliveryBoyId,
    List<OrderItem>? items,
    double? total,
    double? deliveryCharges,
    Address? deliveryAddress,
    String? deliveryTimeWindow,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    double? distance,
    Map<String, dynamic>? deliveryBoyLocation,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      items: items ?? this.items,
      total: total ?? this.total,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryTimeWindow: deliveryTimeWindow ?? this.deliveryTimeWindow,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      distance: distance ?? this.distance,
      deliveryBoyLocation: deliveryBoyLocation ?? this.deliveryBoyLocation,
    );
  }

  // Convert Order object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'storeId': storeId,
      'deliveryBoyId': deliveryBoyId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'deliveryCharges': deliveryCharges,
      'deliveryAddress': deliveryAddress.toMap(),
      'deliveryTimeWindow': deliveryTimeWindow,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'distance': distance,
      'deliveryBoyLocation': deliveryBoyLocation,
    };
  }

  // Create Order object from Map
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      storeId: map['storeId'] ?? '',
      deliveryBoyId: map['deliveryBoyId'],
      items: List<OrderItem>.from(
        (map['items'] ?? []).map(
          (item) => OrderItem.fromMap(item),
        ),
      ),
      total: (map['total'] ?? 0.0).toDouble(),
      deliveryCharges: (map['deliveryCharges'] ?? 0.0).toDouble(),
      deliveryAddress: Address.fromMap(map['deliveryAddress'] ?? {}),
      deliveryTimeWindow: map['deliveryTimeWindow'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? 'PENDING',
      orderStatus: map['orderStatus'] ?? 'PLACED',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      distance: map['distance']?.toDouble(),
      deliveryBoyLocation: map['deliveryBoyLocation'],
    );
  }
}

class OrderItem {
  final String name;
  final String description;
  final double price;
  final int quantity;
  final Map<String, dynamic>? customizations;

  OrderItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.customizations,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      customizations: map['customizations'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'customizations': customizations,
    };
  }

  OrderItem copyWith({
    String? name,
    String? description,
    double? price,
    int? quantity,
    Map<String, dynamic>? customizations,
  }) {
    return OrderItem(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }
}
