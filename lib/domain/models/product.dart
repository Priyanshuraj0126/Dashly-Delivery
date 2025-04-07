class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final String imageUrl;
  final List<String>? galleryUrls;
  final String category;
  final List<String>? tags;
  final bool isAvailable;
  final bool isPopular;
  final bool isRecommended;
  final int stock;
  final Map<String, dynamic>? options;
  final List<Map<String, dynamic>>? addons;
  final Map<String, dynamic>? nutritionInfo;
  final Map<String, dynamic>? allergens;
  final Map<String, dynamic>? customization;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.imageUrl,
    this.galleryUrls,
    required this.category,
    this.tags,
    required this.isAvailable,
    required this.isPopular,
    required this.isRecommended,
    required this.stock,
    this.options,
    this.addons,
    this.nutritionInfo,
    this.allergens,
    this.customization,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String,
      galleryUrls: (json['galleryUrls'] as List<dynamic>?)?.cast<String>(),
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isAvailable: json['isAvailable'] as bool,
      isPopular: json['isPopular'] as bool,
      isRecommended: json['isRecommended'] as bool,
      stock: json['stock'] as int,
      options: json['options'] as Map<String, dynamic>?,
      addons: (json['addons'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      nutritionInfo: json['nutritionInfo'] as Map<String, dynamic>?,
      allergens: json['allergens'] as Map<String, dynamic>?,
      customization: json['customization'] as Map<String, dynamic>?,
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
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'category': category,
      'tags': tags,
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isRecommended': isRecommended,
      'stock': stock,
      'options': options,
      'addons': addons,
      'nutritionInfo': nutritionInfo,
      'allergens': allergens,
      'customization': customization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Product copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    String? imageUrl,
    List<String>? galleryUrls,
    String? category,
    List<String>? tags,
    bool? isAvailable,
    bool? isPopular,
    bool? isRecommended,
    int? stock,
    Map<String, dynamic>? options,
    List<Map<String, dynamic>>? addons,
    Map<String, dynamic>? nutritionInfo,
    Map<String, dynamic>? allergens,
    Map<String, dynamic>? customization,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      isRecommended: isRecommended ?? this.isRecommended,
      stock: stock ?? this.stock,
      options: options ?? this.options,
      addons: addons ?? this.addons,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      allergens: allergens ?? this.allergens,
      customization: customization ?? this.customization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get current price (discounted if available)
  double get currentPrice => discountedPrice ?? price;

  /// Get discount percentage
  double? get discountPercentage {
    if (discountedPrice == null) return null;
    return ((price - discountedPrice!) / price) * 100;
  }

  /// Get formatted price
  String get formattedPrice => '₹${currentPrice.toStringAsFixed(2)}';

  /// Get formatted discount
  String? get formattedDiscount {
    if (discountPercentage == null) return null;
    return '${discountPercentage!.toStringAsFixed(0)}% OFF';
  }

  /// Get formatted stock status
  String get stockStatus {
    if (stock <= 0) return 'Out of Stock';
    if (stock <= 5) return 'Only $stock left';
    return 'In Stock';
  }

  /// Get formatted tags
  String? get formattedTags => tags?.join(', ');

  /// Check if product has options
  bool get hasOptions => options != null && options!.isNotEmpty;

  /// Check if product has addons
  bool get hasAddons => addons != null && addons!.isNotEmpty;

  /// Check if product has nutrition info
  bool get hasNutritionInfo =>
      nutritionInfo != null && nutritionInfo!.isNotEmpty;

  /// Check if product has allergens
  bool get hasAllergens => allergens != null && allergens!.isNotEmpty;

  /// Check if product has customization
  bool get hasCustomization =>
      customization != null && customization!.isNotEmpty;

  /// Get total price with addons
  double getTotalPriceWithAddons(List<String> selectedAddonIds) {
    var total = currentPrice;
    if (addons != null && selectedAddonIds.isNotEmpty) {
      for (var addon in addons!) {
        if (selectedAddonIds.contains(addon['id'])) {
          total += (addon['price'] as num).toDouble();
        }
      }
    }
    return total;
  }
}
