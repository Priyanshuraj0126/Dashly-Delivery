import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthenticatedState) {
            final user = state.user;
            return _buildProfileContent(context, user);
          } else if (state is AuthLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () {
                      context.read<AuthBloc>().add(CheckAuthStatusEvent());
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Please login to view your profile'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with Avatar
          Container(
            padding: const EdgeInsets.only(bottom: 24.0),
            color: AppColors.primary,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: user.profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              user.profileImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusItem(
                      context,
                      'Online Status',
                      user.isOnline ? 'Online' : 'Offline',
                      user.isOnline
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const Divider(height: 32),
                    _buildStatusItem(
                      context,
                      'Availability',
                      user.isAvailable ? 'Available' : 'Not Available',
                      user.isAvailable
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const Divider(height: 32),
                    _buildStatusItem(
                      context,
                      'Account Verification',
                      user.isVerified ? 'Verified' : 'Not Verified',
                      user.isVerified ? AppColors.success : AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      context,
                      'Name',
                      user.name ?? 'Not provided',
                      Icons.person,
                    ),
                    const Divider(height: 32),
                    _buildInfoItem(
                      context,
                      'Email',
                      user.email ?? 'Not provided',
                      Icons.email,
                    ),
                    const Divider(height: 32),
                    _buildInfoItem(
                      context,
                      'Phone',
                      user.phoneNumber,
                      Icons.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Vehicle Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      context,
                      'Vehicle Type',
                      user.vehicleType ?? 'Not provided',
                      Icons.directions_bike,
                    ),
                    const Divider(height: 32),
                    _buildInfoItem(
                      context,
                      'Vehicle Number',
                      user.vehicleNumber ?? 'Not provided',
                      Icons.confirmation_number,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      context,
                      'Total Orders Delivered',
                      user.totalOrdersDelivered.toString(),
                      Icons.delivery_dining,
                    ),
                    const Divider(height: 32),
                    _buildStatItem(
                      context,
                      'Rating',
                      user.rating != null
                          ? '${user.rating}/5'
                          : 'No ratings yet',
                      Icons.star,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomButton(
                  text: 'Edit Profile',
                  onPressed: () {
                    // TODO: Navigate to edit profile screen
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Logout',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text(
                          'Are you sure you want to log out of your account?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(LogoutEvent());
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  isOutlined: true,
                  width: double.infinity,
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
