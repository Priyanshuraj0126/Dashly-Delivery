/// User Credentials Model for storing authentication data
class UserCredentials {
  final String userId;
  final String phoneNumber;
  final String? token;
  final DateTime? tokenExpiryTime;
  final bool isProfileComplete;

  UserCredentials({
    required this.userId,
    required this.phoneNumber,
    this.token,
    this.tokenExpiryTime,
    this.isProfileComplete = false,
  });

  /// Create empty credentials
  factory UserCredentials.empty() {
    return UserCredentials(
      userId: '',
      phoneNumber: '',
      isProfileComplete: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'token': token,
      'tokenExpiryTime': tokenExpiryTime?.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Create from JSON
  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      token: json['token'] as String?,
      tokenExpiryTime: json['tokenExpiryTime'] != null
          ? DateTime.parse(json['tokenExpiryTime'] as String)
          : null,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  /// Copy with
  UserCredentials copyWith({
    String? userId,
    String? phoneNumber,
    String? token,
    DateTime? tokenExpiryTime,
    bool? isProfileComplete,
  }) {
    return UserCredentials(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
      tokenExpiryTime: tokenExpiryTime ?? this.tokenExpiryTime,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
