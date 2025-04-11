import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch orders when screen loads
    context.read<OrderBloc>().add(FetchActiveOrdersEvent());
  }

  @override
  void dispose() {
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrdersTab(),
          _buildUpcomingOrdersTab(),
          _buildPastOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchActiveOrdersEvent());
      },
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ActiveOrdersLoadedState) {
            if (state.orders.isEmpty) {
              return _buildEmptyState('No active orders');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(order);
              },
            );
          } else if (state is OrderErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () {
                      context.read<OrderBloc>().add(FetchActiveOrdersEvent());
                    },
                  ),
                ],
              ),
            );
          }

          return _buildEmptyState('No data available');
        },
      ),
    );
  }

  Widget _buildUpcomingOrdersTab() {
    // For MVP, we are showing just a placeholder for upcoming orders
    return _buildEmptyState('No upcoming orders');
  }

  Widget _buildPastOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchOrderHistoryEvent());
      },
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderHistoryLoadedState) {
            if (state.orders.isEmpty) {
              return _buildEmptyState('No past orders');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(order, isPastOrder: true);
              },
            );
          }

          return _buildEmptyState('No past orders available');
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, {bool isPastOrder = false}) {
    final orderStatus = order.status;

    Color statusColor;
    switch (orderStatus.toLowerCase()) {
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
                      '₹${order.amount.toStringAsFixed(2)}',
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
                          order.status,
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
                        if (orderStatus.toLowerCase() == 'new')
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
}
