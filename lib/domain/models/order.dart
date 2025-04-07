class Order {
  final String id;
  final String customerId;
  final String? deliveryPartnerId;
  final String restaurantId;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerPhoneNumber;
  final String customerAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final bool isPaid;
  final String status;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic>? deliveryPartnerLocation;
  final Map<String, dynamic>? restaurantLocation;
  final Map<String, dynamic>? customerLocation;
  final String? assignedZoneId;
  final double? rating;
  final String? feedback;

  Order({
    required this.id,
    required this.customerId,
    this.deliveryPartnerId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.customerPhoneNumber,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
    this.cancellationReason,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.deliveryPartnerLocation,
    this.restaurantLocation,
    this.customerLocation,
    this.assignedZoneId,
    this.rating,
    this.feedback,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerId: map['customerId'] ?? '',
      deliveryPartnerId: map['deliveryPartnerId'],
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      restaurantAddress: map['restaurantAddress'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhoneNumber: map['customerPhoneNumber'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      isPaid: map['isPaid'] ?? false,
      status: map['status'] ?? '',
      cancellationReason: map['cancellationReason'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      acceptedAt: map['acceptedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['acceptedAt'])
          : null,
      pickedUpAt: map['pickedUpAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pickedUpAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'])
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['cancelledAt'])
          : null,
      deliveryPartnerLocation: map['deliveryPartnerLocation'],
      restaurantLocation: map['restaurantLocation'],
      customerLocation: map['customerLocation'],
      assignedZoneId: map['assignedZoneId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'deliveryPartnerId': deliveryPartnerId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'status': status,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'acceptedAt': acceptedAt?.millisecondsSinceEpoch,
      'pickedUpAt': pickedUpAt?.millisecondsSinceEpoch,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'deliveryPartnerLocation': deliveryPartnerLocation,
      'restaurantLocation': restaurantLocation,
      'customerLocation': customerLocation,
      'assignedZoneId': assignedZoneId,
      'rating': rating,
      'feedback': feedback,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? deliveryPartnerId,
    String? restaurantId,
    String? restaurantName,
    String? restaurantAddress,
    String? customerName,
    String? customerPhoneNumber,
    String? customerAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    String? paymentMethod,
    bool? isPaid,
    String? status,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? deliveryPartnerLocation,
    Map<String, dynamic>? restaurantLocation,
    Map<String, dynamic>? customerLocation,
    String? assignedZoneId,
    double? rating,
    String? feedback,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      customerName: customerName ?? this.customerName,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      deliveryPartnerLocation:
          deliveryPartnerLocation ?? this.deliveryPartnerLocation,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      customerLocation: customerLocation ?? this.customerLocation,
      assignedZoneId: assignedZoneId ?? this.assignedZoneId,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
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
