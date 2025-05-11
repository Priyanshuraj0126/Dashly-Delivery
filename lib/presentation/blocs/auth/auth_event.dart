part of 'auth_bloc.dart';

// Import for Equatable should be in the main library file (auth_bloc.dart)
// import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event to send OTP
class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event to verify OTP
class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  const VerifyOtpEvent({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object?> get props => [verificationId, otp];
}

/// Event to sign out
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfileEvent(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

/// Event to upload document
class UploadDocumentEvent extends AuthEvent {
  final String documentType;
  final String filePath; // Or File object

  const UploadDocumentEvent({
    required this.documentType,
    required this.filePath,
  });

  @override
  List<Object?> get props => [documentType, filePath];
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
  final dynamic
      user; // Consider using a more specific type if possible (e.g., FirebaseUser)

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

// It seems SendOtpEvent was missing props, added it.
// It seems VerifyOtpEvent was missing props and had commented out verificationId, kept it commented and added props for otp.
// Confirmed other events from search results are present.
