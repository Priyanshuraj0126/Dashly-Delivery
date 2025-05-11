import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final int _sessionDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

  // For development mode testing
  bool _isDebugBypassEnabled = false;
  String? _debugVerificationId;

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

  /// Enable or disable debug bypass for testing
  void setDebugBypass(bool enabled, {String? debugVerificationId}) {
    if (!kReleaseMode) {
      _isDebugBypassEnabled = enabled;
      _debugVerificationId = debugVerificationId;
      debugPrint(
          '[AUTH SERVICE] Debug bypass ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Sign in with phone number
  Future<String?> signInWithPhoneNumber({
    required String phoneNumber,
    required void Function(String, int?) onCodeSent,
    required void Function(FirebaseAuthException) onVerificationFailed,
    int? forceResendingToken,
  }) async {
    try {
      debugPrint(
          '[AUTH SERVICE] Starting phone auth: $phoneNumber, isRelease: $kReleaseMode');

      // Validate phone number format
      if (!phoneNumber.startsWith('+')) {
        debugPrint(
            '[AUTH SERVICE] Phone number does not start with +, adding country code');
        if (!phoneNumber.startsWith('+91')) {
          phoneNumber = '+91$phoneNumber';
        }
      }

      debugPrint('[AUTH SERVICE] Using final phone number: $phoneNumber');

      // In debug mode, offer a bypass for verification issues
      if (!kReleaseMode && _isDebugBypassEnabled) {
        debugPrint('[AUTH SERVICE] Using debug bypass for verification');
        // Generate a fake verification ID
        final fakeVerificationId = _debugVerificationId ??
            'debug-verification-${DateTime.now().millisecondsSinceEpoch}';
        // Simulate a delay
        await Future.delayed(const Duration(milliseconds: 500));
        // Call the onCodeSent callback
        onCodeSent(fakeVerificationId, 123456);
        return null;
      }

      // In release mode, add a short delay to ensure Firebase has fully initialized
      if (kReleaseMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint(
              '[AUTH SERVICE] Auto verification completed for $phoneNumber');
          try {
            await _auth.signInWithCredential(credential);
            debugPrint('[AUTH SERVICE] Auto sign in successful');
          } catch (e) {
            debugPrint('[AUTH SERVICE] Error in auto sign in: $e');
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          debugPrint(
              '[AUTH SERVICE] Verification failed: ${error.message}, code: ${error.code}');

          // Log additional details to help diagnose the issue
          debugPrint('[AUTH SERVICE] Error details: ${error.stackTrace}');

          if (error.code == 'missing-client-identifier' ||
              error.message?.contains('Play Integrity') == true ||
              error.message?.contains('reCAPTCHA') == true) {
            debugPrint(
                '[AUTH SERVICE] App verification issue detected. This typically happens in debug mode or on emulators.');

            // For development, enable debug bypass if we encounter verification issues
            if (!kReleaseMode && !_isDebugBypassEnabled) {
              debugPrint(
                  '[AUTH SERVICE] Enabling debug bypass for future verification attempts');
              _isDebugBypassEnabled = true;
              // Generate a fake verification ID
              final fakeVerificationId =
                  'debug-verification-${DateTime.now().millisecondsSinceEpoch}';
              _debugVerificationId = fakeVerificationId;
              // Call the onCodeSent callback instead of onVerificationFailed
              onCodeSent(fakeVerificationId, 123456);
              return;
            }
          }

          onVerificationFailed(error);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
              '[AUTH SERVICE] Code sent, verificationId: $verificationId, resendToken: $resendToken');
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
              '[AUTH SERVICE] Auto retrieval timeout for verificationId: $verificationId');
        },
        // Increase timeout in release mode to give more time
        timeout: kReleaseMode
            ? const Duration(seconds: 120)
            : const Duration(seconds: 60),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AUTH SERVICE] FirebaseAuthException in signInWithPhoneNumber: ${e.code} - ${e.message}');

      // Handle specific Firebase auth errors
      switch (e.code) {
        case 'app-not-authorized':
          return 'This app is not authorized to use Firebase Authentication with your Firebase project.';
        case 'captcha-check-failed':
          return 'reCAPTCHA verification failed, please try again.';
        case 'invalid-phone-number':
          return 'The phone number is invalid.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again tomorrow.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? e.toString();
      }
    } catch (e) {
      debugPrint('[AUTH SERVICE] General error in signInWithPhoneNumber: $e');
      return e.toString();
    }
  }

  /// Verify OTP with additional debug mode bypass
  Future<UserCredential?> verifyOtp(
    String verificationId,
    String otp,
  ) async {
    // In debug mode with bypass enabled, create a fake user credential
    if (!kReleaseMode &&
        _isDebugBypassEnabled &&
        verificationId.startsWith('debug-verification-')) {
      debugPrint('[AUTH SERVICE] Using debug bypass for OTP verification');

      // Create a temporary anonymous user to simulate successful verification
      try {
        final temporaryUser = await _auth.signInAnonymously();
        debugPrint(
            '[AUTH SERVICE] Created temporary debug user: ${temporaryUser.user?.uid}');
        return temporaryUser;
      } catch (e) {
        debugPrint('[AUTH SERVICE] Error creating temporary user: $e');
        return null;
      }
    }

    // Normal verification flow
    debugPrint(
        '[AUTH SERVICE] Verifying OTP: $otp for verificationId: $verificationId');
    debugPrint('[AUTH SERVICE] isRelease: $kReleaseMode');

    int retryCount = 0;
    const maxRetries = 2;

    Future<UserCredential?> attemptVerification() async {
      try {
        // Introduce a small delay in release mode to ensure Firebase is ready
        if (kReleaseMode) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        debugPrint('[AUTH SERVICE] Creating phone auth credential');
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );

        debugPrint('[AUTH SERVICE] Signing in with credential');
        final result = await _auth.signInWithCredential(credential);
        debugPrint(
            '[AUTH SERVICE] OTP verification successful. User ID: ${result.user?.uid}');

        // Force refresh the user to ensure we have the latest auth state
        if (result.user != null) {
          debugPrint(
              '[AUTH SERVICE] Reloading user to ensure latest auth state');
          await result.user!.reload();
        }

        return result;
      } on FirebaseAuthException catch (e) {
        debugPrint(
            '[AUTH SERVICE] FirebaseAuthException verifying OTP: ${e.code} - ${e.message}');

        // Check if the error is due to invalid verification code
        if (e.code == 'invalid-verification-code') {
          debugPrint('[AUTH SERVICE] Invalid verification code entered');
          return null;
        } else if (e.code == 'invalid-verification-id') {
          debugPrint(
              '[AUTH SERVICE] Invalid verification ID. Session may have expired');

          // In release mode, try waiting longer and retrying if this happens
          if (kReleaseMode && retryCount < maxRetries) {
            retryCount++;
            debugPrint(
                '[AUTH SERVICE] Retrying verification after delay (attempt $retryCount)');
            await Future.delayed(const Duration(seconds: 1));
            return attemptVerification();
          }

          return null;
        } else if (e.code == 'session-expired') {
          debugPrint('[AUTH SERVICE] Verification session expired');
          return null;
        } else if (kReleaseMode && retryCount < maxRetries) {
          // For other errors in release mode, retry a few times
          retryCount++;
          debugPrint(
              '[AUTH SERVICE] Unknown error, retrying verification (attempt $retryCount)');
          await Future.delayed(const Duration(seconds: 1));
          return attemptVerification();
        }

        // For any other error or if we've run out of retries
        debugPrint('[AUTH SERVICE] Auth error: ${e.code} - ${e.message}');
        return null;
      } catch (e) {
        debugPrint('[AUTH SERVICE] General error verifying OTP: $e');

        if (kReleaseMode && retryCount < maxRetries) {
          retryCount++;
          debugPrint(
              '[AUTH SERVICE] General error, retrying verification (attempt $retryCount)');
          await Future.delayed(const Duration(seconds: 1));
          return attemptVerification();
        }

        return null;
      }
    }

    return attemptVerification();
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
