import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnDuty = false;

  @override
  void initState() {
    super.initState();

    // Check authentication and load user data
    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    // Start listening for orders when the screen loads
    context.read<OrderBloc>().add(FetchActiveOrdersEvent());
  }

  void _toggleDutyStatus() {
    setState(() {
      _isOnDuty = !_isOnDuty;
    });

    // Update user availability in the database
    final userState = context.read<AuthBloc>().state;

    if (userState is AuthAuthenticatedState) {
      final userId = userState.userId;

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
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<OrderBloc>().add(FetchActiveOrdersEvent());
          context.read<LocationBloc>().add(FetchAssignedZoneEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                      Text(
                                        'You are in an active zone',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Zone: ${state.zone.name}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              )
                            else if (state is OutsideZoneState)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: AppColors.warning,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'You are outside delivery zones',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Move to an active zone to receive orders',
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
                                  Text(
                                    'Location error: ${state.message}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Checking your zone...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            CustomButton(
                              text: 'Refresh Zone Status',
                              onPressed: () {
                                context
                                    .read<LocationBloc>()
                                    .add(FetchAssignedZoneEvent());
                              },
                              isOutlined: true,
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Orders Summary Card
                BlocBuilder<OrderBloc, OrderState>(
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
                              'Orders Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state is OrderLoadingState)
                              Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            else if (state is ActiveOrdersLoadedState)
                              state.orders.isEmpty
                                  ? Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 48,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No active orders',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _isOnDuty
                                                ? 'Wait for new orders to come in'
                                                : 'Go on duty to receive orders',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Active Orders',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              '${state.orders.length}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        ...state.orders.take(3).map((order) {
                                          return OrderSummaryItem(
                                            orderId: order.id,
                                            storeName: order.store.name,
                                            status: order.status,
                                            amount: order.totalAmount,
                                            onTap: () {
                                              // Navigate to order details
                                            },
                                          );
                                        }),
                                        if (state.orders.length > 3)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'and ${state.orders.length - 3} more...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                            else if (state is OrderErrorState)
                              Center(
                                child: Text(
                                  'Error: ${state.message}',
                                  style: TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'View All Orders',
                              onPressed: () {
                                // Navigate to orders tab
                                DefaultTabController.of(context).animateTo(1);
                              },
                              width: double.infinity,
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
}

class OrderSummaryItem extends StatelessWidget {
  final String orderId;
  final String storeName;
  final String status;
  final double amount;
  final VoidCallback onTap;

  const OrderSummaryItem({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.amount,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'new':
        return AppColors.orderNew;
      case 'accepted':
        return AppColors.orderAccepted;
      case 'picked up':
        return AppColors.orderPicked;
      case 'out for delivery':
        return AppColors.orderDelivering;
      case 'delivered':
        return AppColors.orderDelivered;
      case 'cancelled':
        return AppColors.orderCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${orderId.substring(0, 6)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
