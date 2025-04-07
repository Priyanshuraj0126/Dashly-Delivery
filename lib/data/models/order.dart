import 'package:cloud_firestore/cloud_firestore.dart';

/// Order status enum
enum OrderStatus {
  pending, // Order placed but not confirmed
  confirmed, // Order confirmed but not assigned to delivery
  assigned, // Order assigned to delivery but not picked up
  pickedUp, // Order picked up but not delivered
  outForDelivery, // Order is out for delivery
  delivered, // Order successfully delivered
  cancelled, // Order cancelled by customer, store, or admin
  failed, // Order delivery failed
}

/// Payment method enum
enum PaymentMethod {
  cash,
  online,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  paid,
  failed,
}

/// Model class representing an order
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final String? deliveryBoyId;
  final String status;
  final List<OrderItem> items;
  final Address pickupAddress;
  final Address deliveryAddress;
  final Payment payment;
  final OrderTimestamps timestamps;
  final Store store;
  final double totalAmount;
  final String? specialInstructions;
  final Map<String, dynamic>? deliveryBoyLocation;
  final Map<String, dynamic>? estimatedTime;
  final Map<String, dynamic>? actualTime;
  final Map<String, dynamic>? ratings;
  final Map<String, dynamic>? issues;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer? _customer; // Private customer field

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    this.deliveryBoyId,
    required this.status,
    required this.items,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.payment,
    required this.timestamps,
    required this.store,
    required this.totalAmount,
    this.specialInstructions,
    this.deliveryBoyLocation,
    this.estimatedTime,
    this.actualTime,
    this.ratings,
    this.issues,
    required this.createdAt,
    required this.updatedAt,
    Customer? customer,
  }) : _customer = customer;

  /// Get customer - if not provided, create a placeholder with delivery address
  Customer get customer =>
      _customer ??
      Customer(
        id: customerId,
        name: 'Customer',
        phoneNumber: '',
        address: deliveryAddress.formattedAddress ??
            '${deliveryAddress.street}, ${deliveryAddress.city}',
      );

  /// Estimate delivery time in minutes
  int? get estimatedTimeMinutes => estimatedTime != null
      ? (estimatedTime!['minutes'] as num?)?.toInt()
      : 30; // Default 30 minutes

  /// Get estimated delivery time string
  String? get estimatedDeliveryTime {
    if (estimatedTime == null) return null;

    final minutes = estimatedTime!['minutes'] as num?;
    if (minutes == null) return null;

    if (minutes < 60) {
      return '$minutes mins';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).toInt();
      return '$hours hr${hours > 1 ? 's' : ''} ${remainingMinutes > 0 ? '$remainingMinutes mins' : ''}';
    }
  }

  /// Create an Order from a Firestore document
  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Parse order items
    List<OrderItem>? parseItems() {
      final itemsData = data['items'] as List<dynamic>?;
      if (itemsData == null) return null;

      return itemsData
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Parse rejected by list
    List<String>? parseRejectedBy() {
      final rejectedByData = data['rejected_by'] as List<dynamic>?;
      if (rejectedByData == null) return null;

      return rejectedByData.map((id) => id as String).toList();
    }

    // Parse customer if available
    Customer? parseCustomer() {
      if (data['customer'] == null) return null;

      try {
        return Customer.fromMap(data['customer'] as Map<String, dynamic>);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }

    return Order(
      id: doc.id,
      customerId: data['customer_id'] as String,
      vendorId: data['store_id'] as String,
      deliveryBoyId: data['delivery_boy_id'] as String?,
      status: data['status'] as String? ?? 'pending',
      items: parseItems() ?? [],
      pickupAddress:
          Address.fromMap(data['pickup_address'] as Map<String, dynamic>),
      deliveryAddress:
          Address.fromMap(data['delivery_address'] as Map<String, dynamic>),
      payment: Payment.fromMap(data['payment'] as Map<String, dynamic>),
      timestamps:
          OrderTimestamps.fromMap(data['timestamps'] as Map<String, dynamic>),
      store: Store.fromMap(data['store'] as Map<String, dynamic>),
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      specialInstructions: data['special_instructions'] as String?,
      deliveryBoyLocation:
          data['delivery_boy_location'] as Map<String, dynamic>?,
      estimatedTime: data['estimated_time'] as Map<String, dynamic>?,
      actualTime: data['actual_time'] as Map<String, dynamic>?,
      ratings: data['ratings'] as Map<String, dynamic>?,
      issues: data['issues'] as Map<String, dynamic>?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customer: parseCustomer(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'customer_id': customerId,
      'store_id': vendorId,
      'delivery_boy_id': deliveryBoyId,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'pickup_address': pickupAddress.toMap(),
      'delivery_address': deliveryAddress.toMap(),
      'payment': payment.toMap(),
      'timestamps': timestamps.toMap(),
      'store': store.toMap(),
      'total_amount': totalAmount,
      'special_instructions': specialInstructions,
      'delivery_boy_location': deliveryBoyLocation,
      'estimated_time': estimatedTime,
      'actual_time': actualTime,
      'ratings': ratings,
      'issues': issues,
      'customer': _customer?.toMap(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  Order copyWith({
    String? id,
    String? customerId,
    String? vendorId,
    String? deliveryBoyId,
    String? status,
    List<OrderItem>? items,
    Address? pickupAddress,
    Address? deliveryAddress,
    Payment? payment,
    OrderTimestamps? timestamps,
    Store? store,
    double? totalAmount,
    String? specialInstructions,
    Map<String, dynamic>? deliveryBoyLocation,
    Map<String, dynamic>? estimatedTime,
    Map<String, dynamic>? actualTime,
    Map<String, dynamic>? ratings,
    Map<String, dynamic>? issues,
    DateTime? createdAt,
    DateTime? updatedAt,
    Customer? customer,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      status: status ?? this.status,
      items: items ?? this.items,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      payment: payment ?? this.payment,
      timestamps: timestamps ?? this.timestamps,
      store: store ?? this.store,
      totalAmount: totalAmount ?? this.totalAmount,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      deliveryBoyLocation: deliveryBoyLocation ?? this.deliveryBoyLocation,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      ratings: ratings ?? this.ratings,
      issues: issues ?? this.issues,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? _customer,
    );
  }

  /// Check if the order is completed
  bool isCompleted() {
    return status == 'completed' || status == 'cancelled' || status == 'failed';
  }

  /// Check if the order is in progress
  bool isInProgress() {
    return [
      'assigned',
      'on_the_way_to_pickup',
      'arrived_at_pickup',
      'picked_up',
      'out_for_delivery',
      'arrived_at_delivery',
    ].contains(status);
  }

  /// Check if the order is cancelable
  bool isCancelable() {
    return [
      'pending',
      'assigned',
      'on_the_way_to_pickup',
    ].contains(status);
  }
}

/// Model class representing an item in an order
class OrderItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String? imageUrl;
  final Map<String, dynamic>? options;
  final Map<String, dynamic>? addons;

  const OrderItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.options,
    this.addons,
  });

  /// Create an OrderItem from a map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['image_url'] as String?,
      options: map['options'] as Map<String, dynamic>?,
      addons: map['addons'] as Map<String, dynamic>?,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'options': options,
      'addons': addons,
    };
  }

  /// Create a copy with updated fields
  OrderItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? imageUrl,
    Map<String, dynamic>? options,
    Map<String, dynamic>? addons,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? this.options,
      addons: addons ?? this.addons,
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? landmark;
  final Map<String, dynamic> location;
  final String? formattedAddress;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.landmark,
    required this.location,
    this.formattedAddress,
  });

  /// Create an Address from a map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? '',
      postalCode: map['postal_code'] as String? ?? '',
      landmark: map['landmark'] as String?,
      location: map['location'] as Map<String, dynamic>,
      formattedAddress: map['formatted_address'] as String?,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'landmark': landmark,
      'location': location,
      'formatted_address': formattedAddress,
    };
  }

  /// Create a copy with updated fields
  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? landmark,
    Map<String, dynamic>? location,
    String? formattedAddress,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      location: location ?? this.location,
      formattedAddress: formattedAddress ?? this.formattedAddress,
    );
  }
}

class Payment {
  final String method;
  final double amount;
  final String status;
  final String? transactionId;
  final String? paymentDetails;
  final DateTime? paidAt;

  const Payment({
    required this.method,
    required this.amount,
    required this.status,
    this.transactionId,
    this.paymentDetails,
    this.paidAt,
  });

  /// Create a Payment from a map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      method: map['method'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? '',
      transactionId: map['transaction_id'] as String?,
      paymentDetails: map['payment_details'] as String?,
      paidAt: map['paid_at'] != null
          ? DateTime.parse(map['paid_at'] as String)
          : null,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'amount': amount,
      'status': status,
      'transaction_id': transactionId,
      'payment_details': paymentDetails,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Payment copyWith({
    String? method,
    double? amount,
    String? status,
    String? transactionId,
    String? paymentDetails,
    DateTime? paidAt,
  }) {
    return Payment(
      method: method ?? this.method,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

class OrderTimestamps {
  final DateTime? created;
  final DateTime? assigned;
  final DateTime? pickedUp;
  final DateTime? delivered;
  final DateTime? completed;
  final DateTime? cancelled;

  const OrderTimestamps({
    this.created,
    this.assigned,
    this.pickedUp,
    this.delivered,
    this.completed,
    this.cancelled,
  });

  /// Create an OrderTimestamps from a map
  factory OrderTimestamps.fromMap(Map<String, dynamic> map) {
    return OrderTimestamps(
      created: map['created'] != null
          ? DateTime.parse(map['created'] as String)
          : null,
      assigned: map['assigned'] != null
          ? DateTime.parse(map['assigned'] as String)
          : null,
      pickedUp: map['picked_up'] != null
          ? DateTime.parse(map['picked_up'] as String)
          : null,
      delivered: map['delivered'] != null
          ? DateTime.parse(map['delivered'] as String)
          : null,
      completed: map['completed'] != null
          ? DateTime.parse(map['completed'] as String)
          : null,
      cancelled: map['cancelled'] != null
          ? DateTime.parse(map['cancelled'] as String)
          : null,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'created': created?.toIso8601String(),
      'assigned': assigned?.toIso8601String(),
      'picked_up': pickedUp?.toIso8601String(),
      'delivered': delivered?.toIso8601String(),
      'completed': completed?.toIso8601String(),
      'cancelled': cancelled?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  OrderTimestamps copyWith({
    DateTime? created,
    DateTime? assigned,
    DateTime? pickedUp,
    DateTime? delivered,
    DateTime? completed,
    DateTime? cancelled,
  }) {
    return OrderTimestamps(
      created: created ?? this.created,
      assigned: assigned ?? this.assigned,
      pickedUp: pickedUp ?? this.pickedUp,
      delivered: delivered ?? this.delivered,
      completed: completed ?? this.completed,
      cancelled: cancelled ?? this.cancelled,
    );
  }
}

class Store {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final Address address;
  final Map<String, dynamic>? location;
  final String? phoneNumber;
  final String? email;
  final bool isOpen;
  final Map<String, dynamic>? operatingHours;
  final double rating;
  final int totalRatings;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? settings;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverUrl,
    required this.address,
    this.location,
    this.phoneNumber,
    this.email,
    this.isOpen = true,
    this.operatingHours,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.categories,
    this.settings,
  });

  /// Create a Store from a map
  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      logoUrl: map['logo_url'] as String?,
      coverUrl: map['cover_url'] as String?,
      address: Address.fromMap(map['address'] as Map<String, dynamic>),
      location: map['location'] as Map<String, dynamic>?,
      phoneNumber: map['phone_number'] as String?,
      email: map['email'] as String?,
      isOpen: map['is_open'] as bool? ?? true,
      operatingHours: map['operating_hours'] as Map<String, dynamic>?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      categories: map['categories'] as Map<String, dynamic>?,
      settings: map['settings'] as Map<String, dynamic>?,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'address': address.toMap(),
      'location': location,
      'phone_number': phoneNumber,
      'email': email,
      'is_open': isOpen,
      'operating_hours': operatingHours,
      'rating': rating,
      'total_ratings': totalRatings,
      'categories': categories,
      'settings': settings,
    };
  }

  /// Create a copy with updated fields
  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverUrl,
    Address? address,
    Map<String, dynamic>? location,
    String? phoneNumber,
    String? email,
    bool? isOpen,
    Map<String, dynamic>? operatingHours,
    double? rating,
    int? totalRatings,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? settings,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isOpen: isOpen ?? this.isOpen,
      operatingHours: operatingHours ?? this.operatingHours,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      categories: categories ?? this.categories,
      settings: settings ?? this.settings,
    );
  }
}

/// Customer class for order information
class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String? email;
  final String? profilePicture;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.email,
    this.profilePicture,
  });

  /// Create a Customer from a map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      address: map['address'] as String,
      email: map['email'] as String?,
      profilePicture: map['profile_picture'] as String?,
    );
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'email': email,
      'profile_picture': profilePicture,
    };
  }

  /// Create a copy with updated fields
  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? email,
    String? profilePicture,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
