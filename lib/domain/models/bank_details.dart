class BankDetails {
  final String id;
  final String userId;
  final String accountNumber;
  final String accountHolderName;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountType;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  BankDetails({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountHolderName,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountType,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      bankName: json['bankName'] as String,
      branchName: json['branchName'] as String,
      ifscCode: json['ifscCode'] as String,
      accountType: json['accountType'] as String,
      isDefault: json['isDefault'] as bool,
      isVerified: json['isVerified'] as bool,
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
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'branchName': branchName,
      'ifscCode': ifscCode,
      'accountType': accountType,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  BankDetails copyWith({
    String? id,
    String? userId,
    String? accountNumber,
    String? accountHolderName,
    String? bankName,
    String? branchName,
    String? ifscCode,
    String? accountType,
    bool? isDefault,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return BankDetails(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get masked account number
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '${'*' * (accountNumber.length - 4)}${accountNumber.substring(accountNumber.length - 4)}';
  }

  /// Get formatted account type
  String get displayAccountType {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'current':
        return 'Current Account';
      case 'salary':
        return 'Salary Account';
      case 'nre':
        return 'NRE Account';
      case 'nro':
        return 'NRO Account';
      default:
        return accountType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get formatted bank name with branch
  String get formattedBankName {
    return '$bankName - $branchName';
  }

  /// Get verification status text
  String get verificationStatus {
    if (isVerified) return 'Verified';
    return 'Pending Verification';
  }

  /// Get default status text
  String get defaultStatus {
    if (isDefault) return 'Default Account';
    return 'Secondary Account';
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted last update date
  String? get formattedLastUpdate {
    if (updatedAt == null) return null;
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  /// Check if account is active
  bool get isActive => isVerified;

  /// Get account status color
  String get statusColor {
    if (isVerified) return '#4CAF50'; // Green
    return '#FFA000'; // Orange
  }

  /// Get account type icon
  String get accountTypeIcon {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'account_balance';
      case 'current':
        return 'account_balance_wallet';
      case 'salary':
        return 'work';
      case 'nre':
        return 'public';
      case 'nro':
        return 'public';
      default:
        return 'account_balance';
    }
  }
}
