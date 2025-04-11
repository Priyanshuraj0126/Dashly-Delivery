import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
        } else {
          _submitForm();
        }
      });
    }
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

    context.read<AuthBloc>().add(
          CompleteOnboardingEvent(
            name: _nameController.text,
            email: _emailController.text,
            address: _addressController.text,
            vehicleType: _vehicleTypeController.text,
            vehicleNumber: _vehicleNumberController.text,
            bankAccount: _bankAccountController.text,
            ifscCode: _ifscCodeController.text,
            aadharNumber: _aadharNumberController.text,
            panNumber: _panNumberController.text,
            drivingLicense: _drivingLicenseController.text,
          ),
        );
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
          if (state is AuthErrorState) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticatedState) {
            setState(() => _isLoading = false);
            // Navigate to home screen
          }
        },
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            type: StepperType.vertical,
            physics: const ClampingScrollPhysics(),
            onStepContinue: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  if (_currentStep < 3) {
                    _currentStep++;
                  } else {
                    _submitForm();
                  }
                });
              }
            },
            onStepCancel: _previousStep,
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
                        onPressed: _isLoading ? null : details.onStepContinue,
                        child: Text(_currentStep == 3 ? 'Submit' : 'Continue'),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : details.onStepCancel,
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
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _vehicleNumberController,
                      label: 'Vehicle Number',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _drivingLicenseController,
                      label: 'Driving License Number',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _panNumberController,
                      label: 'PAN Number',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _ifscCodeController,
                      label: 'IFSC Code',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
