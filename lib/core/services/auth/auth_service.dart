import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final int _sessionDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Get the current authenticated user
  User? get currentUser {
    final user = _auth.currentUser;
    debugPrint('Current user: ${user?.uid}');
    return user;
  }

  /// Get the current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if a user is currently authenticated
  bool get isAuthenticated {
    final authenticated = _auth.currentUser != null;
    debugPrint('Is authenticated: $authenticated');
    return authenticated;
  }

  /// Check if the current session is expired
  bool isSessionExpired() {
    final lastSignInTime = _auth.currentUser?.metadata.lastSignInTime;
    debugPrint('Last sign in time: $lastSignInTime');

    if (lastSignInTime == null) {
      debugPrint('No last sign in time, session expired');
      return true;
    }

    final now = DateTime.now();
    final difference = now.difference(lastSignInTime).inMilliseconds;
    final expired = difference > _sessionDuration;
    debugPrint('Session expired: $expired (difference: ${difference}ms)');
    return expired;
  }

  /// Sign in with phone number
  Future<String?> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Verify OTP
  Future<UserCredential?> verifyOtp(
    String verificationId,
    String otp,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return null;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Get the current user's ID token
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  /// Refresh ID token
  Future<String?> refreshIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken(true);
    } catch (e) {
      debugPrint('Error refreshing ID token: $e');
      return null;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  /// Update phone number
  Future<void> updatePhoneNumber({
    required String phoneNumber,
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.currentUser?.updatePhoneNumber(credential);
    } catch (e) {
      debugPrint('Error updating phone number: $e');
      rethrow;
    }
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in anonymously for testing purposes
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }
}
