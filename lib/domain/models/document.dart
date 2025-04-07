class Document {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;
  final bool isVerified;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? metadata;

  Document({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
    required this.isVerified,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isVerified: json['isVerified'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
      'isVerified': isVerified,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Document copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? description,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? thumbnailUrl,
    bool? isVerified,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isVerified: isVerified ?? this.isVerified,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get document type display name
  String get displayType {
    switch (type.toLowerCase()) {
      case 'aadhar':
        return 'Aadhar Card';
      case 'pan':
        return 'PAN Card';
      case 'driving_license':
        return 'Driving License';
      case 'voter_id':
        return 'Voter ID';
      case 'passport':
        return 'Passport';
      case 'bank_statement':
        return 'Bank Statement';
      case 'address_proof':
        return 'Address Proof';
      case 'profile_picture':
        return 'Profile Picture';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get file type display name
  String get displayFileType {
    switch (fileType.toLowerCase()) {
      case 'image/jpeg':
        return 'JPEG Image';
      case 'image/png':
        return 'PNG Image';
      case 'application/pdf':
        return 'PDF Document';
      case 'application/msword':
        return 'Word Document';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'Word Document';
      case 'application/vnd.ms-excel':
        return 'Excel Spreadsheet';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'Excel Spreadsheet';
      default:
        return fileType.split('/').last.toUpperCase();
    }
  }

  /// Get verification status text
  String get verificationStatus {
    if (isVerified) return 'Verified';
    if (rejectionReason != null) return 'Rejected';
    return 'Pending Verification';
  }

  /// Get verification status color
  String get statusColor {
    if (isVerified) return '#4CAF50'; // Green
    if (rejectionReason != null) return '#F44336'; // Red
    return '#FFA000'; // Orange
  }

  /// Get document type icon
  String get documentTypeIcon {
    switch (type.toLowerCase()) {
      case 'aadhar':
        return 'badge';
      case 'pan':
        return 'credit_card';
      case 'driving_license':
        return 'directions_car';
      case 'voter_id':
        return 'how_to_vote';
      case 'passport':
        return 'public';
      case 'bank_statement':
        return 'account_balance';
      case 'address_proof':
        return 'location_on';
      case 'profile_picture':
        return 'person';
      default:
        return 'description';
    }
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted verification date
  String? get formattedVerificationDate {
    if (verifiedAt == null) return null;
    return '${verifiedAt!.day}/${verifiedAt!.month}/${verifiedAt!.year}';
  }

  /// Check if document is image
  bool get isImage {
    return fileType.toLowerCase().startsWith('image/');
  }

  /// Check if document is PDF
  bool get isPDF {
    return fileType.toLowerCase() == 'application/pdf';
  }

  /// Check if document is document
  bool get isDocument {
    return fileType.toLowerCase().startsWith('application/');
  }

  /// Get file extension
  String get fileExtension {
    return fileType.split('/').last.toUpperCase();
  }
}
