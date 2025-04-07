import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/bank_details.dart';
import '../../../data/models/delivery_boy.dart';
import '../../../data/models/vehicle.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/delivery_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

class UpdateVehicleEvent extends ProfileEvent {
  final String type;
  final String? make;
  final String? model;
  final String? color;
  final String registrationNumber;
  final String? registrationYear;

  const UpdateVehicleEvent({
    required this.type,
    this.make,
    this.model,
    this.color,
    required this.registrationNumber,
    this.registrationYear,
  });

  @override
  List<Object?> get props => [
        type,
        make,
        model,
        color,
        registrationNumber,
        registrationYear,
      ];
}

class UpdateBankDetailsEvent extends ProfileEvent {
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String ifscCode;
  final String? branchName;
  final String? upiId;

  const UpdateBankDetailsEvent({
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    this.branchName,
    this.upiId,
  });

  @override
  List<Object?> get props => [
        accountHolderName,
        accountNumber,
        bankName,
        ifscCode,
        branchName,
        upiId,
      ];
}

class UploadProfileImageEvent extends ProfileEvent {
  final File imageFile;

  const UploadProfileImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

class UploadDocumentEvent extends ProfileEvent {
  final String documentType;
  final File documentFile;

  const UploadDocumentEvent({
    required this.documentType,
    required this.documentFile,
  });

  @override
  List<Object?> get props => [documentType, documentFile];
}

class UpdateFcmTokenEvent extends ProfileEvent {
  final String token;

  const UpdateFcmTokenEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class LogoutEvent extends ProfileEvent {}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final DeliveryBoy deliveryBoy;

  const ProfileLoadedState({required this.deliveryBoy});

  @override
  List<Object?> get props => [deliveryBoy];
}

class ProfileUpdateSuccessState extends ProfileState {
  final DeliveryBoy deliveryBoy;
  final String message;

  const ProfileUpdateSuccessState({
    required this.deliveryBoy,
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object?> get props => [deliveryBoy, message];
}

class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class DocumentUploadingState extends ProfileState {
  final String documentType;

  const DocumentUploadingState({required this.documentType});

  @override
  List<Object?> get props => [documentType];
}

class DocumentUploadedState extends ProfileState {
  final String documentType;
  final String downloadUrl;

  const DocumentUploadedState({
    required this.documentType,
    required this.downloadUrl,
  });

  @override
  List<Object?> get props => [documentType, downloadUrl];
}

class ProfileImageUploadingState extends ProfileState {}

class ProfileImageUploadedState extends ProfileState {
  final String downloadUrl;

  const ProfileImageUploadedState({required this.downloadUrl});

  @override
  List<Object?> get props => [downloadUrl];
}

class LogoutSuccessState extends ProfileState {}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final DeliveryRepository _deliveryRepository;

  ProfileBloc({
    required AuthRepository authRepository,
    required DeliveryRepository deliveryRepository,
  })  : _authRepository = authRepository,
        _deliveryRepository = deliveryRepository,
        super(ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<UpdateBankDetailsEvent>(_onUpdateBankDetails);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<UpdateFcmTokenEvent>(_onUpdateFcmToken);
    on<LogoutEvent>(_onLogout);
  }

  FutureOr<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final deliveryBoy = await _authRepository.getUserProfile();
      if (deliveryBoy != null) {
        emit(ProfileLoadedState(deliveryBoy: deliveryBoy));
      } else {
        emit(const ProfileErrorState(message: 'Failed to load profile data'));
      }
    } catch (e) {
      emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoadedState) {
      final currentState = state as ProfileLoadedState;
      final currentDeliveryBoy = currentState.deliveryBoy;

      emit(ProfileLoadingState());
      try {
        final updatedDeliveryBoy = currentDeliveryBoy.copyWith(
          name: event.name ?? currentDeliveryBoy.name,
          email: event.email ?? currentDeliveryBoy.email,
          phone: event.phone ?? currentDeliveryBoy.phone,
        );

        final success = await _authRepository.updateProfile(updatedDeliveryBoy);
        if (success) {
          emit(ProfileUpdateSuccessState(
            deliveryBoy: updatedDeliveryBoy,
            message: 'Profile updated successfully',
          ));
        } else {
          emit(const ProfileErrorState(message: 'Failed to update profile'));
        }
      } catch (e) {
        emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
      }
    } else {
      emit(const ProfileErrorState(
          message: 'Cannot update profile before loading it'));
    }
  }

  FutureOr<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoadedState) {
      final currentState = state as ProfileLoadedState;
      final currentDeliveryBoy = currentState.deliveryBoy;

      emit(ProfileLoadingState());
      try {
        final newVehicle = Vehicle(
          type: event.type,
          make: event.make,
          model: event.model,
          color: event.color,
          registrationNumber: event.registrationNumber,
          registrationYear: event.registrationYear,
          isActive: true,
        );

        final updatedDeliveryBoy = currentDeliveryBoy.copyWith(
          vehicle: newVehicle,
        );

        final success = await _authRepository.updateProfile(updatedDeliveryBoy);
        if (success) {
          emit(ProfileUpdateSuccessState(
            deliveryBoy: updatedDeliveryBoy,
            message: 'Vehicle information updated successfully',
          ));
        } else {
          emit(const ProfileErrorState(
              message: 'Failed to update vehicle information'));
        }
      } catch (e) {
        emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
      }
    } else {
      emit(const ProfileErrorState(
          message: 'Cannot update vehicle before loading profile'));
    }
  }

  FutureOr<void> _onUpdateBankDetails(
    UpdateBankDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoadedState) {
      final currentState = state as ProfileLoadedState;
      final currentDeliveryBoy = currentState.deliveryBoy;

      emit(ProfileLoadingState());
      try {
        final newBankDetails = BankDetails(
          accountHolderName: event.accountHolderName,
          accountNumber: event.accountNumber,
          bankName: event.bankName,
          ifscCode: event.ifscCode,
          branchName: event.branchName,
          upiId: event.upiId,
        );

        final updatedDeliveryBoy = currentDeliveryBoy.copyWith(
          bankDetails: newBankDetails,
        );

        final success = await _authRepository.updateProfile(updatedDeliveryBoy);
        if (success) {
          emit(ProfileUpdateSuccessState(
            deliveryBoy: updatedDeliveryBoy,
            message: 'Bank details updated successfully',
          ));
        } else {
          emit(const ProfileErrorState(
              message: 'Failed to update bank details'));
        }
      } catch (e) {
        emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
      }
    } else {
      emit(const ProfileErrorState(
          message: 'Cannot update bank details before loading profile'));
    }
  }

  FutureOr<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileImageUploadingState());
    try {
      final downloadUrl =
          await _authRepository.uploadProfileImage(event.imageFile.path);
      if (downloadUrl != null) {
        emit(ProfileImageUploadedState(downloadUrl: downloadUrl));
        add(LoadProfileEvent()); // Reload profile to reflect changes
      } else {
        emit(
            const ProfileErrorState(message: 'Failed to upload profile image'));
      }
    } catch (e) {
      emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(DocumentUploadingState(documentType: event.documentType));
    try {
      final downloadUrl = await _authRepository.uploadDocument(
          event.documentType, event.documentFile.path);
      if (downloadUrl != null) {
        emit(DocumentUploadedState(
          documentType: event.documentType,
          downloadUrl: downloadUrl,
        ));
        add(LoadProfileEvent()); // Reload profile to reflect changes
      } else {
        emit(const ProfileErrorState(message: 'Failed to upload document'));
      }
    } catch (e) {
      emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateFcmToken(
    UpdateFcmTokenEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final success = await _authRepository.updateFcmToken(event.token);
      if (!success) {
        emit(const ProfileErrorState(
            message: 'Failed to update notification token'));
      }
    } catch (e) {
      emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
    }
  }

  FutureOr<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());
    try {
      final success = await _authRepository.signOut();
      if (success) {
        emit(LogoutSuccessState());
      } else {
        emit(const ProfileErrorState(message: 'Failed to log out'));
      }
    } catch (e) {
      emit(ProfileErrorState(message: 'Error: ${e.toString()}'));
    }
  }
}
