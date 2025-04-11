part of 'auth_bloc.dart';

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event to send OTP
class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendOtpEvent(this.phoneNumber);
}

/// Event to verify OTP
class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  const VerifyOtpEvent({
    required this.verificationId,
    required this.otp,
  });
}

/// Event to sign out
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfileEvent(this.profileData);
}

/// Event to upload document
class UploadDocumentEvent extends AuthEvent {
  final String documentType;
  final String filePath;

  const UploadDocumentEvent({
    required this.documentType,
    required this.filePath,
  });
}

class UpdateUserDetailsEvent extends AuthEvent {
  final String name;
  final String email;
  final String vehicleType;
  final String vehicleNumber;

  const UpdateUserDetailsEvent({
    required this.name,
    required this.email,
    required this.vehicleType,
    required this.vehicleNumber,
  });

  @override
  List<Object?> get props => [name, email, vehicleType, vehicleNumber];
}

class AuthStateChangedEvent extends AuthEvent {
  final dynamic user;

  const AuthStateChangedEvent({this.user});

  @override
  List<Object?> get props => [user];
}

class TestLoginEvent extends AuthEvent {
  final String testPhoneNumber;

  const TestLoginEvent({
    required this.testPhoneNumber,
  });

  @override
  List<Object?> get props => [testPhoneNumber];
}
