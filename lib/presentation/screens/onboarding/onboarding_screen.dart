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

  // Step states for visual error indication
  List<StepState> _stepStates = List.filled(4, StepState.indexed);

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

  // Validator functions
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Aadhaar number';
    }
    if (value.trim().length != 12 ||
        !RegExp(r'^[0-9]{12}$').hasMatch(value.trim())) {
      return 'Aadhaar number must be 12 digits';
    }
    return null;
  }

  String? _validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your PAN number';
    }
    // Basic PAN format: ABCDE1234F
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
        .hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid PAN number (e.g., ABCDE1234F)';
    }
    return null;
  }

  String? _validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your vehicle number';
    }
    // Example: MH12AB1234 or MH-12-AB-1234 or MH 12 AB1234
    // This is a basic regex, can be improved for stricter Indian formats
    if (!RegExp(r'^[A-Z]{2}[ -]?[0-9]{1,2}[ -]?[A-Z]{0,3}[ -]?[0-9]{1,4}$')
        .hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid vehicle number';
    }
    return null;
  }

  String? _validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your IFSC code';
    }
    // Basic IFSC format: ABCD0123456 (4 alpha, 1 zero, 6 alphanumeric)
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
        .hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid IFSC code (e.g., ABCD0123456)';
    }
    return null;
  }

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
      if (!mounted) return;

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

  void _nextStep() {
    final isLastStep = _currentStep == 3; // Assuming 4 steps (0, 1, 2, 3)

    // Validate the entire form.
    // For per-step validation, this is a compromise. If validation fails,
    // we check if the current step content has errors.
    bool isValid = _formKey.currentState!.validate();

    List<StepState> newStepStates = List.from(_stepStates);
    if (!isValid) {
      // Mark current step as error if validation fails.
      // This is an approximation for per-step validation with a single FormKey.
      // A more robust solution would involve validating only current step's fields.
      newStepStates[_currentStep] = StepState.error;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors before continuing.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // If valid, ensure current step is not marked as error
      newStepStates[_currentStep] = StepState.complete;
    }

    setState(() {
      _stepStates = newStepStates;
    });

    if (isValid) {
      if (isLastStep) {
        debugPrint('On final step, attempting to submit form');
        _submitForm();
      } else {
        setState(() {
          _currentStep++;
          debugPrint('Advanced to step: $_currentStep');
        });
      }
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        // Optionally reset error state of future steps if user goes back
        for (int i = _currentStep; i < _stepStates.length; i++) {
          _stepStates[i] = StepState.indexed;
        }
      }
    });
  }

  void _submitForm() {
    // Validation should have been handled by _nextStep() before this is called on the final step.
    // A final check can be here for safety if _submitForm could be invoked bypassing _nextStep's validation.
    if (!_formKey.currentState!.validate()) {
      // This path should ideally not be hit if _nextStep is the only way to _submitForm on the last step.
      // If it is hit, individual fields will show their errors due to autovalidateMode.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please ensure all fields are correct before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      // Update step states to reflect errors if any were missed by _nextStep logic somehow
      // This is a general sweep.
      List<StepState> newStepStates = List.from(_stepStates);
      bool anyErrors = false;
      for (int i = 0; i < 4; i++) {
        // Check all steps
        // We can't easily know which step has an error with one form key without iterating fields.
        // So, if the overall form is invalid, we mark any non-complete step as potentially indexed/error.
        // This is imperfect. The primary visual feedback comes from field error texts.
        if (newStepStates[i] != StepState.complete) {
          // newStepStates[i] = StepState.error; // Could be too aggressive
          // For now, rely on field error messages and the snackbar.
        }
      }
      // setState(() { _stepStates = newStepStates; }); // Potentially skip this complex state update here
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String address = _addressController.text.trim();
      final String vehicleType = _vehicleTypeController.text.trim();
      final String vehicleNumber = _vehicleNumberController.text.trim();
      final String bankAccount = _bankAccountController.text.trim();
      final String ifscCode = _ifscCodeController.text.trim();
      final String aadharNumber = _aadharNumberController.text.trim();
      final String panNumber = _panNumberController.text.trim();
      final String drivingLicense = _drivingLicenseController.text.trim();

      debugPrint('Submitting onboarding form with validated data.');

      _storageService.setOnboardingInProgress(false);
      debugPrint('Onboarding in progress flag cleared');

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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stepper(
            currentStep: _currentStep,
            type: StepperType.vertical,
            physics: const ClampingScrollPhysics(),
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
                      validator: (value) =>
                          _validateNotEmpty(value, 'full name'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      maxLines: 3,
                      validator: (value) => _validateNotEmpty(value, 'address'),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _stepStates[0],
              ),
              Step(
                title: const Text('Vehicle Information'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _vehicleTypeController,
                      label: 'Vehicle Type',
                      validator: (value) =>
                          _validateNotEmpty(value, 'vehicle type'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _vehicleNumberController,
                      label: 'Vehicle Number',
                      validator: _validateVehicleNumber,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _drivingLicenseController,
                      label: 'Driving License Number',
                      validator: (value) =>
                          _validateNotEmpty(value, 'driving license number'),
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
                state: _stepStates[1],
              ),
              Step(
                title: const Text('Documents'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _aadharNumberController,
                      label: 'Aadhaar Number',
                      keyboardType: TextInputType.number,
                      validator: _validateAadhaar,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _panNumberController,
                      label: 'PAN Number',
                      validator: _validatePan,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
                state: _stepStates[2],
              ),
              Step(
                title: const Text('Bank Details'),
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _bankAccountController,
                      label: 'Bank Account Number',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateNotEmpty(value, 'bank account number'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _ifscCodeController,
                      label: 'IFSC Code',
                      validator: _validateIfsc,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
                state: _stepStates[3],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
