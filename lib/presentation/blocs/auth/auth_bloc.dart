import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

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

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _checkUserProfile(user.uid);
      } else {
        add(const SignOutEvent());
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    final user = _authService.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticatedState());
      return;
    }

    if (_authService.isSessionExpired()) {
      emit(const AuthUnauthenticatedState());
      return;
    }

    await _checkUserProfile(user.uid);
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final error = await _authService.signInWithPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          emit(AuthOtpSentState(
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ));
        },
        onVerificationFailed: (e) {
          emit(AuthErrorState(e.message ?? 'Verification failed'));
        },
      );

      if (error != null) {
        emit(AuthErrorState(error));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final userCredential = await _authService.verifyOtp(
        event.verificationId,
        event.otp,
      );

      if (userCredential != null) {
        final user = userCredential.user;
        if (user != null) {
          await _storageService.saveUserId(user.uid);
          await _storageService.savePhoneNumber(user.phoneNumber ?? '');
          await _checkUserProfile(user.uid);
        }
      } else {
        emit(const AuthErrorState('Failed to verify OTP'));
      }
    } catch (e) {
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
    emit(const AuthLoadingState());

    try {
      final userId = _storageService.getUserId();
      if (userId == null) {
        emit(const AuthErrorState('User not found'));
        return;
      }

      await _userRepository.completeOnboarding(userId, event.onboardingData);
      await _checkUserProfile(userId);
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _checkUserProfile(String userId) async {
    try {
      final userProfile = await _userRepository.getProfile(userId);
      if (userProfile == null) {
        emit(const AuthUnauthenticatedState());
        return;
      }

      final isProfileComplete = userProfile['isProfileComplete'] ?? false;
      final phoneNumber = userProfile['phoneNumber'] ?? '';

      emit(AuthAuthenticatedState(
        isProfileComplete: isProfileComplete,
        userId: userId,
        phoneNumber: phoneNumber,
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
