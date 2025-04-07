class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.imageUrl,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'imageUrl': imageUrl,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get notification type display name
  String get displayType {
    switch (type.toLowerCase()) {
      case 'order':
        return 'Order Update';
      case 'payment':
        return 'Payment Update';
      case 'delivery':
        return 'Delivery Update';
      case 'promotion':
        return 'Promotion';
      case 'system':
        return 'System Notification';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get formatted creation time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get formatted read time
  String? get formattedReadTime {
    if (readAt == null) return null;
    return formattedTime;
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours <= 24;
  }

  /// Get notification priority
  int get priority {
    switch (type.toLowerCase()) {
      case 'order':
        return 3;
      case 'payment':
        return 2;
      case 'delivery':
        return 2;
      case 'promotion':
        return 1;
      case 'system':
        return 1;
      default:
        return 0;
    }
  }

  /// Get notification icon based on type
  String get icon {
    switch (type.toLowerCase()) {
      case 'order':
        return 'shopping_bag';
      case 'payment':
        return 'credit_card';
      case 'delivery':
        return 'local_shipping';
      case 'promotion':
        return 'local_offer';
      case 'system':
        return 'info';
      default:
        return 'notifications';
    }
  }

  /// Get notification color based on type
  String get color {
    switch (type.toLowerCase()) {
      case 'order':
        return '#2196F3'; // Blue
      case 'payment':
        return '#4CAF50'; // Green
      case 'delivery':
        return '#FF9800'; // Orange
      case 'promotion':
        return '#E91E63'; // Pink
      case 'system':
        return '#9E9E9E'; // Grey
      default:
        return '#757575'; // Default Grey
    }
  }
}
