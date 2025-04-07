import 'dart:async';

import '../../data/models/delivery_boy.dart';
import '../../data/models/user_credentials.dart';

/// Repository responsible for authentication and user profile operations
abstract class AuthRepository {
  /// Get the current authenticated user, or null if not authenticated
  DeliveryBoy? getCurrentUser();

  /// Get the user ID of the currently authenticated user, or null if not authenticated
  String? getUserId();

  /// Send a verification code to the provided phone number
  Future<bool> sendOtp(String phoneNumber);

  /// Verify the OTP code submitted by the user
  Future<bool> verifyOtp(String verificationId, String otp);

  /// Sign in with the provided credentials
  Future<DeliveryBoy?> signInWithPhone(String phoneNumber);

  /// Sign out the current user
  Future<bool> signOut();

  /// Check if the current user is authenticated
  Future<bool> isAuthenticated();

  /// Get the current user's profile
  Future<DeliveryBoy?> getUserProfile();

  /// Update the user's profile information
  Future<bool> updateProfile(DeliveryBoy deliveryBoy);

  /// Upload a profile image
  Future<String?> uploadProfileImage(String imagePath);

  /// Upload a document file
  Future<String?> uploadDocument(String documentType, String filePath);

  /// Update FCM token for notifications
  Future<bool> updateFcmToken(String token);

  /// Refresh the authentication token
  Future<bool> refreshToken();

  /// Stream of authentication state changes
  Stream<DeliveryBoy?> get authStateChanges;

  /// Get current user phone number
  Future<String?> getCurrentUserPhone();

  /// Check if user profile is complete
  Future<bool> isProfileComplete();

  /// Save credentials locally
  Future<void> saveCredentials(UserCredentials credentials);

  /// Get saved credentials
  Future<UserCredentials?> getSavedCredentials();

  /// Check if session is expired
  Future<bool> isSessionExpired();
}
