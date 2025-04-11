import 'dart:async';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firebase/firebase_service.dart';
import '../../core/services/storage/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/delivery_boy.dart';
import '../models/user_credentials.dart';

/// Implementation of the AuthRepository interface
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  // Stream controller for authentication state changes
  final StreamController<DeliveryBoy?> _authStateController =
      StreamController<DeliveryBoy?>.broadcast();

  /// Constructor
  AuthRepositoryImpl({
    required AuthService authService,
    required FirebaseService firebaseService,
    required StorageService storageService,
  })  : _authService = authService,
        _firebaseService = firebaseService,
        _storageService = storageService {
    // Initialize auth state listener
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final deliveryBoy = await getUserProfile();
          _authStateController.add(deliveryBoy);
        } catch (e) {
          _authStateController.add(null);
        }
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  DeliveryBoy? getCurrentUser() {
    final credentials = _storageService.getCredentials();
    if (credentials == null) return null;

    try {
      // Return minimal user object from stored credentials
      return DeliveryBoy.minimal(
        id: credentials['userId'] as String? ?? '',
        phone: credentials['phoneNumber'] as String? ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String? getUserId() {
    return _authService.currentUserId;
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    Completer<bool> completer = Completer<bool>();

    try {
      final error = await _authService.signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          // Save the verification ID for later use
          _storageService.saveCredentials({
            'verificationId': verificationId,
            'phoneNumber': phoneNumber,
          });

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onVerificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      if (error != null) {
        return false;
      }

      return await completer.future;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyOtp(String verificationId, String otp) async {
    try {
      final result = await _authService.verifyOtp(verificationId, otp);

      if (result != null) {
        // Save auth token
        final token = await _authService.getIdToken();
        if (token != null) {
          await _storageService.saveAuthToken(token);
        }

        // Save user ID
        final userId = _authService.currentUserId;
        if (userId != null) {
          await _storageService.saveUserId(userId);

          // Get and save phone number
          final credentials = _storageService.getCredentials();
          if (credentials != null && credentials.containsKey('phoneNumber')) {
            final phoneNumber = credentials['phoneNumber'] as String;
            await _storageService.savePhoneNumber(phoneNumber);

            // Update user credentials
            await saveCredentials(UserCredentials(
              userId: userId,
              phoneNumber: phoneNumber,
              token: token,
              tokenExpiryTime: DateTime.now().add(AppConstants.sessionDuration),
              isProfileComplete: false, // Will update after profile check
            ));

            // Update last active timestamp
            await _storageService.updateLastActiveTimestamp();
          }
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DeliveryBoy?> signInWithPhone(String phoneNumber) async {
    try {
      // Check if user exists in Firestore
      final querySnapshot = await _firebaseService.getDocumentsWithQuery(
        AppConstants.deliveryBoysCollection,
        field: 'phone',
        value: phoneNumber,
      );

      if (querySnapshot.docs.isNotEmpty) {
        final document = querySnapshot.docs.first;
        final user = DeliveryBoy.fromFirestore(document);

        // Update FCM token if available
        final credentials = _storageService.getCredentials();
        if (credentials != null && credentials.containsKey('fcmToken')) {
          await updateFcmToken(credentials['fcmToken'] as String);
        }

        return user;
      } else {
        // User does not exist in Firestore yet
        final userId = _authService.currentUserId;
        if (userId == null) return null;

        // Create minimal user entry
        final deliveryBoy = DeliveryBoy.minimal(
          id: userId,
          phone: phoneNumber,
        );

        // Save user to Firestore
        await _firebaseService.setDocument(
          AppConstants.deliveryBoysCollection,
          userId,
          deliveryBoy.toFirestore(),
        );

        return deliveryBoy;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      // Clear local storage
      await _storageService.clearAll();

      // Sign out from Firebase
      await _authService.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    if (!_authService.isAuthenticated) return false;

    // Check if session is expired
    return !(await isSessionExpired());
  }

  @override
  Future<DeliveryBoy?> getUserProfile() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      final doc = await _firebaseService.getDocument(
        AppConstants.deliveryBoysCollection,
        userId,
      );

      if (doc.exists) {
        return DeliveryBoy.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateProfile(DeliveryBoy deliveryBoy) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return false;

      // Make sure we're updating the correct user
      final updatedBoy = deliveryBoy.copyWith(id: userId);

      // Update in Firestore
      await _firebaseService.updateDocument(
        AppConstants.deliveryBoysCollection,
        userId,
        updatedBoy.toFirestore(),
      );

      // Update profile complete status in credentials
      final credentials = _storageService.getCredentials();
      if (credentials != null) {
        final userCred = UserCredentials.fromJson(credentials);
        await saveCredentials(userCred.copyWith(
          isProfileComplete: updatedBoy.isProfileComplete(),
        ));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      final file = File(imagePath);
      final path = '${AppConstants.profileImagesPath}/$userId.jpg';

      // Upload to Firebase Storage
      final downloadUrl = await _firebaseService.uploadFile(
        path,
        file,
        metadata: {'contentType': 'image/jpeg'},
      );

      // Update user profile with new image URL
      final profile = await getUserProfile();
      if (profile != null) {
        await updateProfile(profile.copyWith(photoUrl: downloadUrl));
      }

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> uploadDocument(String documentType, String filePath) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      final file = File(filePath);
      final fileExtension = filePath.split('.').last;
      final path =
          '${AppConstants.documentsPath}/$userId/$documentType.$fileExtension';

      // Upload to Firebase Storage
      final downloadUrl = await _firebaseService.uploadFile(
        path,
        file,
      );

      if (downloadUrl.isNotEmpty) {
        // Update user profile with new document URL
        final profile = await getUserProfile();
        if (profile != null) {
          final updatedDocuments =
              Map<String, String>.from(profile.documents ?? {});
          updatedDocuments[documentType] = downloadUrl;

          await updateProfile(profile.copyWith(documents: updatedDocuments));
        }
      }

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateFcmToken(String token) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return false;

      // Update in Firestore
      await _firebaseService.updateDocument(
        AppConstants.deliveryBoysCollection,
        userId,
        {'fcm_token': token},
      );

      // Save token in credentials
      final credentials = _storageService.getCredentials();
      if (credentials != null) {
        credentials['fcmToken'] = token;
        await _storageService.saveCredentials(credentials);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      // Refresh Firebase token
      final token = await _authService.refreshIdToken();
      if (token == null) return false;

      // Save new token
      await _storageService.saveAuthToken(token);

      // Update token expiry in credentials
      final credentials = _storageService.getCredentials();
      if (credentials != null) {
        final userCred = UserCredentials.fromJson(credentials);
        await saveCredentials(userCred.copyWith(
          token: token,
          tokenExpiryTime: DateTime.now().add(AppConstants.sessionDuration),
        ));
      }

      // Update last active timestamp
      await _storageService.updateLastActiveTimestamp();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<DeliveryBoy?> get authStateChanges => _authStateController.stream;

  @override
  Future<String?> getCurrentUserPhone() async {
    return _storageService.getPhoneNumber();
  }

  @override
  Future<bool> isProfileComplete() async {
    final profile = await getUserProfile();
    return profile?.isProfileComplete() ?? false;
  }

  @override
  Future<void> saveCredentials(UserCredentials credentials) async {
    await _storageService.saveCredentials(credentials.toJson());
  }

  @override
  Future<UserCredentials?> getSavedCredentials() async {
    final credentialsMap = _storageService.getCredentials();
    if (credentialsMap == null) return null;

    try {
      return UserCredentials.fromJson(credentialsMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isSessionExpired() async {
    // Check Firebase session
    if (_authService.isSessionExpired()) return true;

    // Check local session timeout
    return _storageService.isSessionExpired();
  }
}
