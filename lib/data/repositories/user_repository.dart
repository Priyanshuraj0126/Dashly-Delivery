import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../core/services/firebase/firebase_service.dart';

class UserRepository {
  final FirebaseService _firebaseService;
  final String _collection = 'delivery_boys';

  UserRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      debugPrint('Fetching user profile for $userId');
      final doc = await _firebaseService.getDocument(
        'delivery_boys',
        userId,
      );

      if (!doc.exists) {
        debugPrint('No profile found for user $userId');
        // Create a basic profile for new users
        final basicProfile = {
          'userId': userId,
          'isProfileComplete': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        try {
          await _firebaseService.setDocument(
            'delivery_boys',
            userId,
            basicProfile,
          );
          return basicProfile;
        } catch (e) {
          debugPrint('Error creating basic profile: $e');
          // Return the basic profile even if we couldn't save it
          // The next profile update will try to save it again
          return basicProfile;
        }
      }

      return doc.data();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Return null instead of throwing to handle permission errors gracefully
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload document for user
  Future<String> uploadDocument(
    String userId,
    String documentType,
    String filePath,
  ) async {
    try {
      final path = 'documents/$userId/$documentType';
      final file = File(filePath);
      final url = await _firebaseService.uploadFile(path, file);

      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'documents.$documentType': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      return url;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Complete user onboarding
  Future<void> completeOnboarding(
    String userId,
    Map<String, dynamic> onboardingData,
  ) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          ...onboardingData,
          'isProfileComplete': true,
          'onboardingCompletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Update user's current location
  Future<void> updateLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'currentLocation': {
            'latitude': latitude,
            'longitude': longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Update user's online status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'isOnline': isOnline,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  /// Update user's assigned zone
  Future<void> updateAssignedZone(String userId, String zoneId) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'zoneId': zoneId,
          'zoneUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update assigned zone: $e');
    }
  }

  /// Update user's FCM token
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Update user's statistics
  Future<void> updateStatistics(
    String userId,
    Map<String, dynamic> statistics,
  ) async {
    try {
      await _firebaseService.updateDocument(
        _collection,
        userId,
        {
          'statistics': statistics,
          'statisticsUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update statistics: $e');
    }
  }

  /// Check if a user's profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return false;

      // Check if profile is marked as complete
      if (profile['isProfileComplete'] == true) {
        // Double check that all required fields are present
        return profile.containsKey('name') &&
            profile['name'] != null &&
            profile['name'].toString().trim().isNotEmpty &&
            profile.containsKey('email') &&
            profile['email'] != null &&
            profile['email'].toString().trim().isNotEmpty &&
            profile.containsKey('address') &&
            profile['address'] != null &&
            profile['address'].toString().trim().isNotEmpty &&
            profile.containsKey('vehicleType') &&
            profile['vehicleType'] != null &&
            profile['vehicleType'].toString().trim().isNotEmpty &&
            profile.containsKey('vehicleNumber') &&
            profile['vehicleNumber'] != null &&
            profile['vehicleNumber'].toString().trim().isNotEmpty;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking profile completion status: $e');
      return false;
    }
  }

  /// Stream user profile changes
  Stream<Map<String, dynamic>?> streamProfile(String userId) {
    return _firebaseService.documentStream(_collection, userId).map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }
}
