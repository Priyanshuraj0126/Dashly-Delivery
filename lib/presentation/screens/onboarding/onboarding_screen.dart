import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
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
  final _addressController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _previousStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _currentStep == 3 ? 'Complete' : 'Continue',
                        onPressed: _isLoading ? null : _nextStep,
                        isLoading: _isLoading,
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          onPressed: _isLoading ? null : _previousStep,
                          isOutlined: true,
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
                content: _buildPersonalDetailsStep(),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Vehicle Information'),
                content: _buildVehicleInfoStep(),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Documents'),
                content: _buildDocumentsStep(),
                isActive: _currentStep >= 2,
                state:
                    _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Bank Details'),
                content: _buildBankDetailsStep(),
                isActive: _currentStep >= 3,
                state:
                    _currentStep > 3 ? StepState.complete : StepState.indexed,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _addressController,
            label: 'Address',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _vehicleTypeController,
            label: 'Vehicle Type',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your vehicle type';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _vehicleNumberController,
            label: 'Vehicle Registration Number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your vehicle number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: [
        _buildDocumentUploadCard(
          'Aadhar Card',
          Icons.credit_card,
          () {
            // TODO: Implement document upload
          },
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadCard(
          'PAN Card',
          Icons.credit_card,
          () {
            // TODO: Implement document upload
          },
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadCard(
          'Vehicle License',
          Icons.drive_eta,
          () {
            // TODO: Implement document upload
          },
        ),
      ],
    );
  }

  Widget _buildBankDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _bankAccountController,
            label: 'Bank Account Number',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bank account number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _ifscCodeController,
            label: 'IFSC Code',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your IFSC code';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.upload_file),
        onTap: onTap,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_formKey.currentState?.validate() ?? true) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeOnboarding() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement profile completion logic
    // This would typically involve:
    // 1. Uploading documents
    // 2. Saving profile information
    // 3. Updating user status
    // 4. Navigating to home screen

    // For now, we'll just simulate a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }
}
