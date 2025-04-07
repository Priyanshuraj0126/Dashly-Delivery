class Review {
  final String id;
  final String userId;
  final String? orderId;
  final String? storeId;
  final String? productId;
  final String? deliveryBoyId;
  final double rating;
  final String? comment;
  final List<String>? images;
  final List<String>? tags;
  final Map<String, dynamic>? ratings;
  final bool isVerified;
  final bool isHelpful;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Review({
    required this.id,
    required this.userId,
    this.orderId,
    this.storeId,
    this.productId,
    this.deliveryBoyId,
    required this.rating,
    this.comment,
    this.images,
    this.tags,
    this.ratings,
    required this.isVerified,
    required this.isHelpful,
    required this.helpfulCount,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orderId: json['orderId'] as String?,
      storeId: json['storeId'] as String?,
      productId: json['productId'] as String?,
      deliveryBoyId: json['deliveryBoyId'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      ratings: json['ratings'] as Map<String, dynamic>?,
      isVerified: json['isVerified'] as bool,
      isHelpful: json['isHelpful'] as bool,
      helpfulCount: json['helpfulCount'] as int,
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
      'orderId': orderId,
      'storeId': storeId,
      'productId': productId,
      'deliveryBoyId': deliveryBoyId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'tags': tags,
      'ratings': ratings,
      'isVerified': isVerified,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? storeId,
    String? productId,
    String? deliveryBoyId,
    double? rating,
    String? comment,
    List<String>? images,
    List<String>? tags,
    Map<String, dynamic>? ratings,
    bool? isVerified,
    bool? isHelpful,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      deliveryBoyId: deliveryBoyId ?? this.deliveryBoyId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      ratings: ratings ?? this.ratings,
      isVerified: isVerified ?? this.isVerified,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get formatted helpful count
  String get formattedHelpfulCount {
    if (helpfulCount >= 1000000) {
      return '${(helpfulCount / 1000000).toStringAsFixed(1)}M';
    } else if (helpfulCount >= 1000) {
      return '${(helpfulCount / 1000).toStringAsFixed(1)}K';
    }
    return helpfulCount.toString();
  }

  /// Get formatted tags
  String? get formattedTags => tags?.join(', ');

  /// Get review type
  String get type {
    if (storeId != null) return 'store';
    if (productId != null) return 'product';
    if (deliveryBoyId != null) return 'delivery';
    return 'general';
  }

  /// Get review type display name
  String get displayType {
    switch (type) {
      case 'store':
        return 'Store Review';
      case 'product':
        return 'Product Review';
      case 'delivery':
        return 'Delivery Review';
      default:
        return 'General Review';
    }
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Get rating color
  String get ratingColor {
    if (rating >= 4.5) return '#4CAF50';
    if (rating >= 4.0) return '#8BC34A';
    if (rating >= 3.0) return '#FFC107';
    if (rating >= 2.0) return '#FF9800';
    return '#F44336';
  }
}
