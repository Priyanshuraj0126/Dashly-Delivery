part of 'auth_bloc.dart';

/// Base class for all authentication states
abstract class AuthState {
  const AuthState();
}

/// Initial state when the app starts
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// State when authentication is in progress
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// State when user is authenticated
class AuthAuthenticatedState extends AuthState {
  final bool isProfileComplete;
  final String userId;
  final String phoneNumber;

  const AuthAuthenticatedState({
    required this.isProfileComplete,
    required this.userId,
    required this.phoneNumber,
  });
}

/// State when OTP has been sent
class AuthOtpSentState extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthOtpSentState({
    required this.verificationId,
    required this.phoneNumber,
  });
}

/// State when there's an authentication error
class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);
}

/// State when user is not authenticated
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

class AuthSendingOtpState extends AuthState {}

class AuthAwaitingOtpState extends AuthState {}

class ProfileIncompleteState extends AuthState {
  final User user;

  const ProfileIncompleteState({required this.user});
}

class UpdatingUserDetailsState extends AuthState {}

class UserDetailsUpdatedState extends AuthState {
  final User user;

  const UserDetailsUpdatedState({required this.user});
}
