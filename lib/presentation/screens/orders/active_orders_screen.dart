import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/custom_button.dart';
import 'order_details_screen.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _autoRefreshTimer;

  // Define a list of active in-progress statuses
  final List<String> _activeStatuses = [
    AppConstants.orderStatusOnTheWayToPickup,
    AppConstants.orderStatusArrivedAtPickup,
    AppConstants.orderStatusPickedUp,
    AppConstants.orderStatusOutForDelivery,
    AppConstants.orderStatusArrivedAtDelivery,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Debug initialization
    debugPrint(
        'Initializing ActiveOrdersScreen - Starting order fetch and listening');

    // Start auto-refresh timer for every 30 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('Auto-refreshing orders (timer)');
        _refreshOrders();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This is called when the widget is fully built and dependencies are available
    debugPrint('ActiveOrdersScreen: didChangeDependencies called');

    // First stop any existing listeners to avoid duplicates
    context.read<OrderBloc>().add(StopListeningForNewOrdersEvent());

    // Start fresh with the order fetching
    context.read<OrderBloc>().add(FetchActiveOrdersEvent());

    // Start listening for new orders immediately
    context.read<OrderBloc>().add(StartListeningForNewOrdersEvent());
    debugPrint('Started listening for new orders in didChangeDependencies');
  }

  @override
  void dispose() {
    // Stop listening when screen is disposed
    // Safely check if the widget is still mounted before accessing context
    if (mounted) {
      try {
        context.read<OrderBloc>().add(StopListeningForNewOrdersEvent());
        debugPrint('Stopped listening for new orders in dispose');
      } catch (e) {
        debugPrint('Error stopping listener: $e');
      }
    }
    // Cancel auto-refresh timer
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh orders when button is pressed
              context.read<OrderBloc>().add(FetchActiveOrdersEvent());
              context.read<OrderBloc>().add(StartListeningForNewOrdersEvent());

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing orders...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingOrdersTab(),
          _buildActiveOrdersTab(),
          _buildPastOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildUpcomingOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            current is OrderLoadingState ||
            current is ActiveOrdersLoadedState ||
            current is OrderErrorState,
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActiveOrdersLoadedState) {
            final upcomingOrders = state.orders.where((order) {
              return order.status.toLowerCase() ==
                  AppConstants.orderStatusAssigned;
            }).toList();

            if (upcomingOrders.isEmpty) {
              return _buildEmptyState('No upcoming orders assigned to you.');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: upcomingOrders.length,
              itemBuilder: (context, index) =>
                  _buildOrderCard(upcomingOrders[index]),
            );
          } else if (state is OrderErrorState) {
            return _buildErrorState(state.message,
                () => context.read<OrderBloc>().add(FetchActiveOrdersEvent()));
          }
          return _buildEmptyState('No upcoming orders.');
        },
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshOrders(),
      child: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            current is OrderLoadingState ||
            current is ActiveOrdersLoadedState ||
            current is OrderErrorState,
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActiveOrdersLoadedState) {
            final activeInProgressOrders = state.orders.where((order) {
              final status = order.status.toLowerCase();
              return _activeStatuses.contains(status);
            }).toList();

            if (activeInProgressOrders.isEmpty) {
              return _buildEmptyState('No active orders in progress.');
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activeInProgressOrders.length,
              itemBuilder: (context, index) =>
                  _buildOrderCard(activeInProgressOrders[index]),
            );
          } else if (state is OrderErrorState) {
            return _buildErrorState(state.message,
                () => context.read<OrderBloc>().add(FetchActiveOrdersEvent()));
          }
          return _buildEmptyState('No active orders currently.');
        },
      ),
    );
  }

  Widget _buildPastOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchOrderHistoryEvent());
      },
      child: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            current is OrderLoadingState ||
            current is OrderHistoryLoadedState ||
            current is OrderErrorState,
        builder: (context, state) {
          debugPrint('_buildPastOrdersTab: State type = ${state.runtimeType}');

          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderHistoryLoadedState) {
            final orders = state.orders;
            debugPrint('PAST ORDERS: ${orders.length} orders');

            if (orders.isEmpty) {
              return _buildEmptyState('No past orders found');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            );
          } else if (state is OrderErrorState) {
            debugPrint('ORDER ERROR (Past Tab): ${state.message}');
            return _buildErrorState(state.message,
                () => context.read<OrderBloc>().add(FetchOrderHistoryEvent()));
          }

          debugPrint('NO MATCHING STATE TO DISPLAY PAST ORDERS');
          return _buildEmptyState('No past orders available.');
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 240,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNewOrdersSection(),
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Orders will appear here once they are assigned to you',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You may need to wait for a store to place an order in your zone',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Refresh Orders',
              onPressed: () {
                _refreshOrders();
              },
              icon: Icons.refresh,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.work_outline, size: 28),
              label: Text(
                'Make sure you\'re "Online" to receive orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Tips for Getting Orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: Icon(Icons.location_on),
                      minLeadingWidth: 0,
                      title: Text('Stay in high-demand areas'),
                      dense: true,
                    ),
                    const ListTile(
                      leading: Icon(Icons.access_time),
                      minLeadingWidth: 0,
                      title: Text('Be available during peak hours'),
                      dense: true,
                    ),
                    const ListTile(
                      leading: Icon(Icons.battery_charging_full),
                      minLeadingWidth: 0,
                      title: Text('Keep your device charged'),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrdersSection() {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          current is NewOrdersStreamState || current is ActiveOrdersLoadedState,
      builder: (context, state) {
        debugPrint(
            '_buildNewOrdersSection: Building with state type = ${state.runtimeType}');

        List<dynamic> newOrders = [];

        if (state is NewOrdersStreamState) {
          newOrders = state.orders;
          debugPrint(
              '_buildNewOrdersSection: Found ${newOrders.length} orders in NewOrdersStreamState');
        } else if (state is ActiveOrdersLoadedState) {
          newOrders = state.orders.where((order) {
            final isValidStatus = order.status == "WAITING_FOR_DRIVER" ||
                order.status == "PLACED";
            final isNotAssigned =
                order.deliveryBoyId == null || order.deliveryBoyId!.isEmpty;
            return isValidStatus && isNotAssigned;
          }).toList();

          debugPrint(
              '_buildNewOrdersSection: Found ${newOrders.length} unassigned orders in ActiveOrdersLoadedState');
        } else {
          debugPrint(
              '_buildNewOrdersSection: State is not a recognized state with orders: ${state.runtimeType}');
        }

        for (final order in newOrders) {
          debugPrint(
              'Found unassigned order: ${order.id} with status ${order.status}');
        }

        if (newOrders.isNotEmpty) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppColors.success.withOpacity(0.5), width: 2)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active,
                          color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'New Orders Available!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: newOrders.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final order = newOrders[index];
                    return ListTile(
                      title: Text(
                        'Order #${order.id.substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'From: ${order.store.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(orderId: order.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(dynamic order, {bool isPastOrder = false}) {
    final orderStatus = order.status;
    debugPrint('ORDER CARD: ID=${order.id}, Status=$orderStatus');

    final displayStatus =
        (orderStatus == 'PLACED' || orderStatus == 'WAITING_FOR_DRIVER')
            ? 'New'
            : orderStatus;

    Color statusColor;
    switch (displayStatus.toLowerCase()) {
      case 'new':
        statusColor = AppColors.orderNew;
        break;
      case 'accepted':
        statusColor = AppColors.orderAccepted;
        break;
      case 'picked up':
        statusColor = AppColors.orderPicked;
        break;
      case 'out for delivery':
        statusColor = AppColors.orderDelivering;
        break;
      case 'delivered':
        statusColor = AppColors.orderDelivered;
        break;
      case 'cancelled':
        statusColor = AppColors.orderCancelled;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    final isNewOrder =
        orderStatus == 'PLACED' || orderStatus == 'WAITING_FOR_DRIVER';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'From: ${order.store.name}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'To: ${order.customer.address}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated Time: ${order.estimatedDeliveryTime ?? 'Not Available'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          displayStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!isPastOrder) ...[
                        const SizedBox(width: 8),
                        if (isNewOrder)
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showRejectDialog(order.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.error,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: AppColors.error),
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<OrderBloc>().add(
                                        AcceptOrderEvent(orderId: order.id),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Accept'),
                              ),
                            ],
                          )
                        else
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(
                                    orderId: order.id,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: const Text(
          'Are you sure you want to reject this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(
                    RejectOrderEvent(orderId: orderId, reason: ''),
                  );
            },
            child: Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshOrders() {
    if (!mounted) return;

    debugPrint('Refreshing orders manually');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refreshing orders...'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
      ),
    );

    context.read<OrderBloc>().add(StopListeningForNewOrdersEvent());

    context.read<OrderBloc>().add(FetchActiveOrdersEvent());

    context.read<OrderBloc>().add(StartListeningForNewOrdersEvent());
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error: $message',
              style: TextStyle(color: AppColors.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              onPressed: onRetry,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
