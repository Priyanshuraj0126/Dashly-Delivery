import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final User user;

  const ProfileCompletionScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'profile_completion_form');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  String _selectedVehicleType = 'Bicycle';

  final List<String> _vehicleTypes = [
    'Bicycle',
    'Motorcycle',
    'Scooter',
    'Car',
    'Van',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _vehicleNumberController.text.isNotEmpty;
  }

  void _submitForm() {
    if (!_isFormValid()) return;
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            UpdateUserDetailsEvent(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              vehicleType: _selectedVehicleType,
              vehicleNumber: _vehicleNumberController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthAuthenticatedState) {
            // Navigate to home/dashboard after successful profile completion
            // In a real app, we'd use a navigator or route management system
            // to handle this transition
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile completed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Dashly!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please provide the following details to complete your profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Phone number (already provided, just for display)
                    Text(
                      'PHONE NUMBER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.disabled.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.user.phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      prefix: Icon(Icons.person),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefix: Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        // Basic email validation
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Vehicle Type
                    Text(
                      'VEHICLE TYPE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicleType,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items: _vehicleTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedVehicleType = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Number
                    CustomTextField(
                      controller: _vehicleNumberController,
                      label: 'Vehicle Number',
                      prefix: Icon(Icons.directions_car),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your vehicle number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text: 'Complete Profile',
                          onPressed: _submitForm,
                          isLoading: state is UpdatingUserDetailsState,
                          width: double.infinity,
                          height: 52,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
