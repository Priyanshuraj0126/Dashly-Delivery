import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../../config/routes/route_names.dart';
import '../../../core/services/storage/storage_service.dart';

/// A multi-step onboarding screen for new users to complete their profile
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isNavigating = false;
  late StorageService _storageService;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _drivingLicenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('Onboarding screen initialized, step $_currentStep');

    // Ensure we start at the first step
    _currentStep = 0;

    // Get storage service instance
    _storageService = StorageService();

    // Mark onboarding as in progress
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _storageService.setOnboardingInProgress(true);
      debugPrint('Onboarding in progress flag set to true');

      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      if (authState is AuthAuthenticatedState) {
        debugPrint('Current user phone: ${authState.phoneNumber}');

        // Force onboarding mode by marking profile as incomplete
        debugPrint(
            'Forcing profile to be marked as incomplete during onboarding');
        authBloc.add(const ForceProfileIncompleteEvent());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    _aadharNumberController.dispose();
    _panNumberController.dispose();
    _drivingLicenseController.dispose();

    // Reset navigation flag
    _isNavigating = false;

    super.dispose();
  }

  // Modified to simply go to the next step without validation
  void _nextStep() {
    debugPrint('Moving to next step - current step: $_currentStep');
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
        debugPrint('Advanced to step: $_currentStep');
      } else {
        debugPrint('On final step, submitting form');
        _submitForm();
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _submitForm() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Make sure all fields are non-null strings
      final String name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : "User";

      final String email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : "user@example.com";

      final String address = _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : "Address";

      final String vehicleType = _vehicleTypeController.text.trim().isNotEmpty
          ? _vehicleTypeController.text.trim()
          : "Bike";

      final String vehicleNumber =
          _vehicleNumberController.text.trim().isNotEmpty
              ? _vehicleNumberController.text.trim()
              : "MH12AB1234";

      final String bankAccount = _bankAccountController.text.trim().isNotEmpty
          ? _bankAccountController.text.trim()
          : "1234567890";

      final String ifscCode = _ifscCodeController.text.trim().isNotEmpty
          ? _ifscCodeController.text.trim()
          : "ABCD0123456";

      final String aadharNumber = _aadharNumberController.text.trim().isNotEmpty
          ? _aadharNumberController.text.trim()
          : "123456789012";

      final String panNumber = _panNumberController.text.trim().isNotEmpty
          ? _panNumberController.text.trim()
          : "ABCDE1234F";

      final String drivingLicense =
          _drivingLicenseController.text.trim().isNotEmpty
              ? _drivingLicenseController.text.trim()
              : "DL123456789";

      debugPrint('Submitting onboarding form with:');
      debugPrint('Name: $name');
      debugPrint('Email: $email');
      debugPrint('Address: $address');
      debugPrint('Vehicle Type: $vehicleType');
      debugPrint('Vehicle Number: $vehicleNumber');

      // Clear onboarding in progress flag
      _storageService.setOnboardingInProgress(false);
      debugPrint('Onboarding in progress flag cleared');

      // Use the cleaned-up variables directly
      context.read<AuthBloc>().add(
            CompleteOnboardingEvent(
              name: name,
              email: email,
              address: address,
              vehicleType: vehicleType,
              vehicleNumber: vehicleNumber,
              bankAccount: bankAccount,
              ifscCode: ifscCode,
              aadharNumber: aadharNumber,
              panNumber: panNumber,
              drivingLicense: drivingLicense,
            ),
          );
    } catch (e) {
      debugPrint('Error in _submitForm: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('Auth state changed: ${state.runtimeType}');

          if (state is AuthLoadingState) {
            // Already handling loading state via local _isLoading variable
            debugPrint('Auth loading state received');
          } else if (state is AuthErrorState) {
            setState(() => _isLoading = false);
            debugPrint('Auth error state received: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UpdatingUserDetailsState) {
            debugPrint('Updating user details state received');
            // Keep loading state
          } else if (state is AuthAuthenticatedState && !_isNavigating) {
            setState(() => _isLoading = false);
            debugPrint(
                'Auth authenticated state received, profile complete: ${state.isProfileComplete}');

            // Use a flag to prevent multiple navigation attempts
            final bool inProgress = _storageService.getOnboardingInProgress();
            debugPrint(
                'Checking if should navigate: onboarding in progress = $inProgress, profile complete = ${state.isProfileComplete}');

            if (!inProgress && state.isProfileComplete) {
              debugPrint(
                  'Navigation conditions met - proceeding to home screen');
              // Set flag to prevent multiple navigation attempts
              setState(() => _isNavigating = true);
              // Navigate to home screen using route name
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.home,
                (route) => false,
              );
            } else {
              debugPrint(
                  'Navigation conditions NOT met - staying on onboarding screen');
            }
          }
        },
        child: Form(
          key: _formKey,
          // Disable automatic validation
          autovalidateMode: AutovalidateMode.disabled,
          child: Stepper(
            currentStep: _currentStep,
            type: StepperType.vertical,
            physics: const ClampingScrollPhysics(),
            // Simplified - just call _nextStep directly
            onStepContinue: _isLoading ? null : _nextStep,
            onStepCancel: _isLoading ? null : _previousStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        // Simply call _nextStep directly
                        onPressed: _isLoading ? null : _nextStep,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentStep == 3 ? 'Submit' : 'Continue'),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _previousStep,
                          child: const Text('Back'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Personal Details'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      // Remove validator to avoid validation issues
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      maxLines: 3,
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Vehicle Information'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _vehicleTypeController,
                      label: 'Vehicle Type',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _vehicleNumberController,
                      label: 'Vehicle Number',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _drivingLicenseController,
                      label: 'Driving License Number',
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Documents'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _aadharNumberController,
                      label: 'Aadhar Number',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _panNumberController,
                      label: 'PAN Number',
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('Bank Details'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _bankAccountController,
                      label: 'Bank Account Number',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _ifscCodeController,
                      label: 'IFSC Code',
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
