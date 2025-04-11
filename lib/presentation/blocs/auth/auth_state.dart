part of 'auth_bloc.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial authentication state
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// Loading authentication state
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// Authenticated state
class AuthAuthenticatedState extends AuthState {
  final bool isProfileComplete;
  final String userId;
  final String phoneNumber;

  const AuthAuthenticatedState({
    required this.isProfileComplete,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [isProfileComplete, userId, phoneNumber];
}

/// Unauthenticated state
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

/// OTP sent state
class AuthOtpSentState extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthOtpSentState({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// Error state
class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when sending OTP
class AuthSendingOtpState extends AuthState {}

class AuthVerifyingOtpState extends AuthState {}

class ProfileIncompleteState extends AuthState {
  final String userId;
  final String phoneNumber;

  const ProfileIncompleteState({
    required this.userId,
    required this.phoneNumber,
  });
}

class UserDetailsUpdatedState extends AuthState {
  final bool isSuccess;
  final String message;

  const UserDetailsUpdatedState({
    required this.isSuccess,
    required this.message,
  });
}

/// State when updating user details
class UpdatingUserDetailsState extends AuthState {
  const UpdatingUserDetailsState();
}
