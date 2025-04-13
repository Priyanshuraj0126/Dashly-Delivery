import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CompleteOnboardingEvent extends AuthEvent {
  final String name;
  final String email;
  final String address;
  final String vehicleType;
  final String vehicleNumber;
  final String bankAccount;
  final String ifscCode;
  final String aadharNumber;
  final String panNumber;
  final String drivingLicense;

  const CompleteOnboardingEvent({
    required this.name,
    required this.email,
    required this.address,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.bankAccount,
    required this.ifscCode,
    required this.aadharNumber,
    required this.panNumber,
    required this.drivingLicense,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        address,
        vehicleType,
        vehicleNumber,
        bankAccount,
        ifscCode,
        aadharNumber,
        panNumber,
        drivingLicense,
      ];
}

class ForceProfileIncompleteEvent extends AuthEvent {
  const ForceProfileIncompleteEvent();
}

/// BLoC for handling authentication state and operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;
  final UserRepository _userRepository;

  AuthBloc({
    required AuthService authService,
    required StorageService storageService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _storageService = storageService,
        _userRepository = userRepository,
        super(const AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SignOutEvent>(_onSignOut);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<TestLoginEvent>(_onTestLogin);
    on<ForceProfileIncompleteEvent>(_onForceProfileIncomplete);

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _checkUserProfile(user.uid);
      } else {
        // Don't automatically trigger sign out when auth state changes to null
        // This prevents the circular dependency when signing out
        debugPrint('Auth state changed to null (user signed out)');
        // Just emit the unauthenticated state directly instead of triggering another sign out
        emit(const AuthUnauthenticatedState());
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('Checking auth status...');
    emit(const AuthLoadingState());

    final user = _authService.currentUser;
    debugPrint('Current user: ${user?.uid}');

    if (user == null) {
      debugPrint('No user found, emitting unauthenticated state');
      emit(const AuthUnauthenticatedState());
      return;
    }

    if (_authService.isSessionExpired()) {
      debugPrint('Session expired, emitting unauthenticated state');
      emit(const AuthUnauthenticatedState());
      return;
    }

    debugPrint('Checking user profile...');
    await _checkUserProfile(user.uid);
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('Sending OTP to: ${event.phoneNumber}');
    emit(const AuthLoadingState());

    try {
      final completer = Completer<void>();

      final error = await _authService.signInWithPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          debugPrint('OTP sent successfully. VerificationId: $verificationId');
          if (!emit.isDone) {
            emit(AuthOtpSentState(
              verificationId: verificationId,
              phoneNumber: event.phoneNumber,
            ));
          }
          completer.complete();
        },
        onVerificationFailed: (e) {
          debugPrint('OTP verification failed: ${e.message}');
          if (!emit.isDone) {
            emit(AuthErrorState(e.message ?? 'Verification failed'));
          }
          completer.complete();
        },
      );

      if (error != null) {
        debugPrint('Error sending OTP: $error');
        if (!emit.isDone) {
          emit(AuthErrorState(error));
        }
        return;
      }

      await completer.future;
    } catch (e) {
      debugPrint('Exception sending OTP: $e');
      if (!emit.isDone) {
        emit(AuthErrorState(e.toString()));
      }
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoadingState());
      debugPrint('Verifying OTP...');

      final userCredential = await _authService.verifyOtp(
        event.verificationId,
        event.otp,
      );

      if (userCredential == null || userCredential.user == null) {
        emit(const AuthErrorState('Failed to verify OTP'));
        return;
      }

      final userId = userCredential.user!.uid;
      debugPrint('OTP verified successfully. User ID: $userId');

      // Save auth data first
      await _storageService.saveUserId(userId);
      await _storageService
          .savePhoneNumber(userCredential.user!.phoneNumber ?? '');

      // Wait for Firebase Auth state to be fully updated
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        // Now try to get the user profile
        final userProfile = await _userRepository.getProfile(userId);
        debugPrint('User profile fetched: ${userProfile != null}');

        // Check if this is a new user or an existing user
        final bool isNewUser =
            userProfile?['createdAt'] == userProfile?['updatedAt'];
        debugPrint('Is new user: $isNewUser');

        // For new users, ensure profile is marked as incomplete
        if (isNewUser) {
          debugPrint(
              'New user detected, ensuring profile is marked as incomplete');
          await _storageService.saveProfileCompletionStatus(false);

          // Update the Firebase profile to ensure it's marked as incomplete
          await _userRepository.updateProfile(userId, {
            'isProfileComplete': false,
            'phoneNumber': userCredential.user!.phoneNumber ?? '',
          });

          // Emit authenticated state with isProfileComplete = false for new users
          emit(AuthAuthenticatedState(
            isProfileComplete: false,
            userId: userId,
            phoneNumber: userCredential.user!.phoneNumber ?? '',
          ));
        } else {
          // For existing users, use the profile completion status from database
          final bool isProfileComplete =
              userProfile?['isProfileComplete'] ?? false;
          debugPrint(
              'Existing user with profile completion status: $isProfileComplete');

          emit(AuthAuthenticatedState(
            isProfileComplete: isProfileComplete,
            userId: userId,
            phoneNumber: userCredential.user!.phoneNumber ?? '',
          ));
        }
      } catch (e) {
        debugPrint('Error getting profile after OTP verification: $e');
        // If profile fetch fails, force to onboarding for safety
        emit(AuthAuthenticatedState(
          isProfileComplete: false,
          userId: userId,
          phoneNumber: userCredential.user!.phoneNumber ?? '',
        ));
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      await _authService.signOut();
      await _storageService.clearAll();
      emit(const AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final userId = _storageService.getUserId();
      if (userId == null) {
        emit(const AuthErrorState('User not found'));
        return;
      }

      await _userRepository.updateProfile(userId, event.profileData);
      await _checkUserProfile(userId);
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final userId = _storageService.getUserId();
      if (userId == null) {
        emit(const AuthErrorState('User not found'));
        return;
      }

      await _userRepository.uploadDocument(
        userId,
        event.documentType,
        event.filePath,
      );
      await _checkUserProfile(userId);
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(UpdatingUserDetailsState());

      final userId = _storageService.getUserId();
      if (userId == null) {
        emit(const AuthErrorState('User ID not found'));
        return;
      }

      // Update user profile with onboarding details
      await _userRepository.updateProfile(
        userId,
        {
          'name': event.name,
          'email': event.email,
          'address': event.address,
          'vehicleType': event.vehicleType,
          'vehicleNumber': event.vehicleNumber,
          'bankAccount': event.bankAccount,
          'ifscCode': event.ifscCode,
          'aadharNumber': event.aadharNumber,
          'panNumber': event.panNumber,
          'drivingLicense': event.drivingLicense,
          'isProfileComplete': true,
        },
      );

      // Mark onboarding as complete in storage
      await _storageService.saveProfileCompletionStatus(true);

      // Get updated user profile
      final userProfile = await _userRepository.getProfile(userId);
      if (userProfile != null) {
        emit(AuthAuthenticatedState(
          isProfileComplete: true,
          userId: userId,
          phoneNumber: userProfile['phoneNumber'] as String? ?? '',
        ));
      } else {
        emit(const AuthErrorState('Failed to get updated profile'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onTestLogin(
    TestLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (!kDebugMode) {
      emit(const AuthErrorState('Test login is only available in debug mode'));
      return;
    }

    emit(const AuthLoadingState());
    debugPrint('Attempting test login with phone: ${event.testPhoneNumber}');

    try {
      // Use a completer to handle the async verification process
      final completer = Completer<String>();

      // Start phone number verification
      final error = await _authService.signInWithPhoneNumber(
        phoneNumber: event.testPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          debugPrint('Test verification ID received: $verificationId');
          completer.complete(verificationId);
        },
        onVerificationFailed: (e) {
          debugPrint('Test verification failed: ${e.message}');
          completer.completeError(e);
        },
      );

      if (error != null) {
        throw Exception(error);
      }

      // Wait for verification ID
      final verificationId = await completer.future;

      // For test login, we'll use a fixed OTP code
      const testOtp = '123456';

      // Verify the OTP
      final userCredential = await _authService.verifyOtp(
        verificationId,
        testOtp,
      );

      if (userCredential == null || userCredential.user == null) {
        throw Exception('Failed to verify test OTP');
      }

      final testUserId = userCredential.user!.uid;
      debugPrint('Test user authenticated with ID: $testUserId');

      // Save local storage data
      await _storageService.saveUserId(testUserId);
      await _storageService.savePhoneNumber(event.testPhoneNumber);

      // Create or update test user in Firestore
      await _userRepository.updateProfile(
        testUserId,
        {
          'phoneNumber': event.testPhoneNumber,
          'isProfileComplete': true,
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isTestUser': true, // Flag to identify test users
          'role': 'delivery_boy', // Add role for permissions
          'status': 'active', // Add status
        },
      );

      emit(AuthAuthenticatedState(
        isProfileComplete: true,
        userId: testUserId,
        phoneNumber: event.testPhoneNumber,
      ));

      debugPrint('Test login successful');
    } catch (e) {
      debugPrint('Test login failed: $e');
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onForceProfileIncomplete(
    ForceProfileIncompleteEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userId = _storageService.getUserId();
      if (userId == null) {
        emit(const AuthErrorState('User ID not found'));
        return;
      }

      // Update the Firebase profile to ensure it's marked as incomplete
      await _userRepository.updateProfile(userId, {
        'isProfileComplete': false,
        'phoneNumber': '',
      });

      // Mark onboarding as incomplete in storage
      await _storageService.saveProfileCompletionStatus(false);

      // Get updated user profile
      final userProfile = await _userRepository.getProfile(userId);
      if (userProfile != null) {
        emit(AuthAuthenticatedState(
          isProfileComplete: false,
          userId: userId,
          phoneNumber: '',
        ));
      } else {
        emit(const AuthErrorState('Failed to get updated profile'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _checkUserProfile(String userId) async {
    debugPrint('Fetching user profile for $userId');
    try {
      final userProfile = await _userRepository.getProfile(userId);
      debugPrint('User profile fetched: ${userProfile != null}');

      if (userProfile == null) {
        debugPrint('No profile found, emitting unauthenticated state');
        emit(const AuthUnauthenticatedState());
        return;
      }

      // Check if user is currently in onboarding process
      final bool onboardingInProgress =
          _storageService.getOnboardingInProgress();
      if (onboardingInProgress) {
        debugPrint(
            'Onboarding is in progress, forcing profile to incomplete state');
        emit(AuthAuthenticatedState(
          isProfileComplete: false,
          userId: userId,
          phoneNumber: userProfile['phoneNumber'] as String? ?? '',
        ));
        return;
      }

      // Check if any required fields are missing
      final bool hasAllRequiredFields = userProfile.containsKey('name') &&
          userProfile['name'] != null &&
          userProfile['name'].toString().trim().isNotEmpty &&
          userProfile.containsKey('email') &&
          userProfile['email'] != null &&
          userProfile['email'].toString().trim().isNotEmpty &&
          userProfile.containsKey('address') &&
          userProfile['address'] != null &&
          userProfile['address'].toString().trim().isNotEmpty &&
          userProfile.containsKey('vehicleType') &&
          userProfile['vehicleType'] != null &&
          userProfile['vehicleType'].toString().trim().isNotEmpty &&
          userProfile.containsKey('vehicleNumber') &&
          userProfile['vehicleNumber'] != null &&
          userProfile['vehicleNumber'].toString().trim().isNotEmpty;

      // Get the stored profile completion status
      final bool storedProfileStatus =
          userProfile['isProfileComplete'] ?? false;

      // Profile is only complete if it has all required fields AND is marked as complete
      final bool isProfileComplete =
          hasAllRequiredFields && storedProfileStatus;

      debugPrint(
          'Profile completion check: hasRequiredFields=$hasAllRequiredFields, storedStatus=$storedProfileStatus, final=$isProfileComplete');

      // If the status doesn't match what's stored, update it
      if (isProfileComplete != storedProfileStatus) {
        debugPrint(
            'Updating profile completion status in database to: $isProfileComplete');
        await _userRepository
            .updateProfile(userId, {'isProfileComplete': isProfileComplete});
        await _storageService.saveProfileCompletionStatus(isProfileComplete);
      }

      final phoneNumber = userProfile['phoneNumber'] ?? '';
      debugPrint(
          'Final profile complete status: $isProfileComplete, Phone: $phoneNumber');

      emit(AuthAuthenticatedState(
        isProfileComplete: isProfileComplete,
        userId: userId,
        phoneNumber: phoneNumber,
      ));
    } catch (e) {
      debugPrint('Error checking profile: $e');
      emit(AuthErrorState(e.toString()));
    }
  }
}
