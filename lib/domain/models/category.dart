class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? iconUrl;
  final String? parentId;
  final List<String>? subCategories;
  final bool isActive;
  final int order;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.iconUrl,
    this.parentId,
    this.subCategories,
    required this.isActive,
    required this.order,
    this.settings,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      parentId: json['parentId'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>?)?.cast<String>(),
      isActive: json['isActive'] as bool,
      order: json['order'] as int,
      settings: json['settings'] as Map<String, dynamic>?,
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
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'parentId': parentId,
      'subCategories': subCategories,
      'isActive': isActive,
      'order': order,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconUrl,
    String? parentId,
    List<String>? subCategories,
    bool? isActive,
    int? order,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      parentId: parentId ?? this.parentId,
      subCategories: subCategories ?? this.subCategories,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if category is a parent category
  bool get isParent => subCategories != null && subCategories!.isNotEmpty;

  /// Check if category is a sub category
  bool get isSubCategory => parentId != null;

  /// Get formatted name
  String get displayName {
    if (isSubCategory) {
      return '  $name'; // Indent sub categories
    }
    return name;
  }

  /// Get formatted description
  String get displayDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }

  /// Get category level (0 for parent, 1 for sub category)
  int get level => isSubCategory ? 1 : 0;

  /// Get category icon or placeholder
  String get displayIcon => iconUrl ?? 'assets/icons/category_placeholder.png';

  /// Get category image or placeholder
  String get displayImage =>
      imageUrl ?? 'assets/images/category_placeholder.png';
}
