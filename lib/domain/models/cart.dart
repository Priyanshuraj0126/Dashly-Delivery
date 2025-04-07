import 'product.dart';
import 'store.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final Map<String, dynamic>? selectedOptions;
  final List<String>? selectedAddonIds;
  final Map<String, dynamic>? customizations;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedOptions,
    this.selectedAddonIds,
    this.customizations,
    this.specialInstructions,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedOptions: json['selectedOptions'] as Map<String, dynamic>?,
      selectedAddonIds:
          (json['selectedAddonIds'] as List<dynamic>?)?.cast<String>(),
      customizations: json['customizations'] as Map<String, dynamic>?,
      specialInstructions: json['specialInstructions'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'selectedAddonIds': selectedAddonIds,
      'customizations': customizations,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    Map<String, dynamic>? selectedOptions,
    List<String>? selectedAddonIds,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Get total price for this item
  double get totalPrice {
    var price = product.getTotalPriceWithAddons(selectedAddonIds ?? []);
    return price * quantity;
  }

  /// Get formatted total price
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';
}

class Cart {
  final String id;
  final String userId;
  final Store? store;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Cart({
    required this.id,
    required this.userId,
    this.store,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      userId: json['userId'] as String,
      store: json['store'] != null
          ? Store.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
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
      'userId': userId,
      'store': store?.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Cart copyWith({
    String? id,
    String? userId,
    Store? store,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      store: store ?? this.store,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get total number of items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get formatted subtotal
  String get formattedSubtotal => '₹${subtotal.toStringAsFixed(2)}';

  /// Get formatted tax
  String get formattedTax => '₹${tax.toStringAsFixed(2)}';

  /// Get formatted delivery fee
  String get formattedDeliveryFee => '₹${deliveryFee.toStringAsFixed(2)}';

  /// Get formatted total
  String get formattedTotal => '₹${total.toStringAsFixed(2)}';

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items from a specific store
  bool hasItemsFromStore(String storeId) {
    return items.any((item) => item.product.storeId == storeId);
  }

  /// Get items from a specific store
  List<CartItem> getItemsFromStore(String storeId) {
    return items.where((item) => item.product.storeId == storeId).toList();
  }

  /// Calculate subtotal for items from a specific store
  double getSubtotalForStore(String storeId) {
    return getItemsFromStore(storeId)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
