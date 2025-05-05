import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../orders/active_orders_screen.dart';
import '../orders/order_history_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';
import '../../../config/routes/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnDuty = false;

  // Changed from instance to static variable to persist across widget rebuilds
  static bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();

    // Only start listening for orders when the screen loads
    context.read<OrderBloc>().add(FetchActiveOrdersEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check authentication only once across all instances of HomeScreen
    if (!_hasCheckedAuth) {
      debugPrint(
          'Performing initial auth check on HomeScreen (first time only)');
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
      _hasCheckedAuth = true;
    } else {
      debugPrint('Skipping redundant auth check on HomeScreen');
    }
  }

  void _toggleDutyStatus() {
    setState(() {
      _isOnDuty = !_isOnDuty;
    });

    // Update user availability in the database
    final userState = context.read<AuthBloc>().state;

    if (userState is AuthAuthenticatedState) {
      // If going on duty, start location updates and check zone
      if (_isOnDuty) {
        context.read<LocationBloc>().add(StartLocationUpdatesEvent());
        // Get current location and assigned zone before checking
        context.read<LocationBloc>().add(FetchAssignedZoneEvent());
        context.read<OrderBloc>().add(StartListeningForNewOrdersEvent());
      } else {
        context.read<LocationBloc>().add(StopLocationUpdatesEvent());
        context.read<OrderBloc>().add(StopListeningForNewOrdersEvent());
      }
    }

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now ${_isOnDuty ? 'Online' : 'Offline'}'),
        backgroundColor: _isOnDuty ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Dashly Delivery',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state is LocationUpdatedState) {
                return Icon(
                  Icons.location_on,
                  color: Colors.white,
                );
              } else if (state is LocationErrorState ||
                  state is LocationPermissionDeniedState ||
                  state is LocationServiceDisabledState) {
                return Icon(
                  Icons.location_off,
                  color: Colors.red,
                );
              }
              return Icon(
                Icons.location_searching,
                color: Colors.white70,
              );
            },
          ),
          const SizedBox(width: 8),
          // Add logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ).then((shouldLogout) {
                if (shouldLogout == true) {
                  // First navigate away, then sign out
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteNames.login,
                      (route) => false,
                    );
                    // Then trigger sign out
                    context.read<AuthBloc>().add(SignOutEvent());
                  }
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Only refresh orders and location data, not auth status
          // This prevents triggering redundant auth checks
          debugPrint('Manual refresh triggered by user');
          context.read<OrderBloc>().add(FetchActiveOrdersEvent());
          context.read<LocationBloc>().add(FetchAssignedZoneEvent());

          // Add a small delay to ensure the refresh indicator is shown
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message with user's phone number
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticatedState) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Welcome, ${state.phoneNumber}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),

                // Duty Status Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duty Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Switch(
                              value: _isOnDuty,
                              onChanged: (value) => _toggleDutyStatus(),
                              activeColor: AppColors.success,
                              activeTrackColor:
                                  AppColors.success.withOpacity(0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOnDuty ? 'You are On Duty' : 'You are Off Duty',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isOnDuty
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOnDuty
                              ? 'You are visible to stores and can receive orders'
                              : 'Go on duty to start receiving orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Grid
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          context,
                          'Active Orders',
                          Icons.delivery_dining,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActiveOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Earnings',
                          Icons.attach_money,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EarningsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Profile',
                          Icons.person,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<OrderBloc, OrderState>(
                          builder: (context, state) {
                            int orderCount = 0;

                            if (state is ActiveOrdersLoadedState) {
                              orderCount = state.orders.length;
                            }

                            return Stack(
                              children: [
                                _buildActionCard(
                                  context,
                                  'Orders History',
                                  Icons.history,
                                  () {
                                    context
                                        .read<OrderBloc>()
                                        .add(FetchOrderHistoryEvent());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OrderHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                                if (orderCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        orderCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Zone Status Card
                BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    return Card(
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
                              'Your Zone',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state is ZonesLoadedState)
                              Text(
                                'Available Zones: ${state.zones.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else if (state is AssignedZoneLoadedState)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You are assigned to ${state.zone.name}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${state.zone.description}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            else if (state is LocationErrorState)
                              Row(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error loading zone: ${state.message}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'No zone assigned yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
