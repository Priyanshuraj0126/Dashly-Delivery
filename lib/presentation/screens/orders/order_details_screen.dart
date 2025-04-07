import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/custom_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch order details when screen loads
    context
        .read<OrderBloc>()
        .add(FetchOrderDetailsEvent(orderId: widget.orderId));
    // Listen for changes to this specific order
    context.read<OrderBloc>().add(ListenForSpecificOrderEvent(widget.orderId));
  }

  @override
  void dispose() {
    // Stop listening when screen is closed
    context
        .read<OrderBloc>()
        .add(StopListeningForSpecificOrderEvent(widget.orderId));
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/dir/',
      queryParameters: {
        'api': '1',
        'destination': '$latitude,$longitude',
      },
    );
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Order #${widget.orderId.substring(0, 6)}',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(
                    FetchOrderDetailsEvent(orderId: widget.orderId),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderDetailsLoadedState ||
              state is OrderUpdatedStreamState) {
            // Get the order from the appropriate state
            final order = state is OrderDetailsLoadedState
                ? state.order
                : (state as OrderUpdatedStreamState).order;

            return _buildOrderDetails(context, order);
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
                      context.read<OrderBloc>().add(
                            FetchOrderDetailsEvent(orderId: widget.orderId),
                          );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Order details not available'),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, dynamic order) {
    // Extract order status
    final orderStatus = order.status.toLowerCase();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _getStatusColor(orderStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(orderStatus).withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(orderStatus),
                  ),
                ),
                const SizedBox(height: 8),
                if (order.estimatedDeliveryTime != null)
                  Text(
                    'Estimated delivery by ${order.estimatedDeliveryTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Order Info
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Order ID', '#${order.id}'),
                  const Divider(height: 24),
                  _buildInfoRow('Date', order.createdAt.toString()),
                  const Divider(height: 24),
                  _buildInfoRow('Items', '${order.items.length} items'),
                  const Divider(height: 24),
                  _buildInfoRow('Payment Method', order.paymentMethod),
                  const Divider(height: 24),
                  _buildInfoRow('Payment Status', order.paymentStatus),
                  if (order.paymentMethod.toLowerCase() == 'cash') ...[
                    const Divider(height: 24),
                    _buildInfoRow('Amount to Collect',
                        '₹${order.amount.toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Store Info
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          order.store.name.substring(0, 1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.store.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.store.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Call Store',
                    onPressed: () {
                      _makePhoneCall(order.store.phoneNumber);
                    },
                    icon: Icons.call,
                    isOutlined: true,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Navigate to Store',
                    onPressed: () {
                      _openMap(
                        order.store.latitude,
                        order.store.longitude,
                      );
                    },
                    icon: Icons.directions,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Customer Info
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Name', order.customer.name),
                  const Divider(height: 24),
                  _buildInfoRow('Phone', order.customer.phoneNumber),
                  const Divider(height: 24),
                  _buildInfoRow('Address', order.customer.address),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Call Customer',
                    onPressed: () {
                      _makePhoneCall(order.customer.phoneNumber);
                    },
                    icon: Icons.call,
                    isOutlined: true,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Navigate to Customer',
                    onPressed: () {
                      _openMap(
                        order.customer.latitude,
                        order.customer.longitude,
                      );
                    },
                    icon: Icons.directions,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Order Items
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...order.items.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (item.variation != null)
                                  Text(
                                    item.variation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${order.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${order.deliveryFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '-₹${order.discount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${order.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons based on order status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildActionButtons(context, order, orderStatus),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, dynamic order, String status) {
    // Handle different status with appropriate action buttons
    switch (status) {
      case 'accepted':
        return Column(
          children: [
            CustomButton(
              text: 'Mark as Picked Up',
              onPressed: () {
                context.read<OrderBloc>().add(
                      MarkAsPickedUpEvent(orderId: order.id),
                    );
              },
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Report Issue',
              onPressed: () {
                _showReportIssueDialog(order.id);
              },
              isOutlined: true,
              width: double.infinity,
            ),
          ],
        );

      case 'picked up':
        return Column(
          children: [
            CustomButton(
              text: 'Mark as Out for Delivery',
              onPressed: () {
                context.read<OrderBloc>().add(
                      MarkAsOutForDeliveryEvent(orderId: order.id),
                    );
              },
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Update Estimated Time',
              onPressed: () {
                _showUpdateEtaDialog(order.id);
              },
              isOutlined: true,
              width: double.infinity,
            ),
          ],
        );

      case 'out for delivery':
        return Column(
          children: [
            CustomButton(
              text: 'Mark as Delivered',
              onPressed: () {
                context.read<OrderBloc>().add(
                      MarkAsDeliveredEvent(orderId: order.id),
                    );
              },
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Update Estimated Time',
              onPressed: () {
                _showUpdateEtaDialog(order.id);
              },
              isOutlined: true,
              width: double.infinity,
            ),
          ],
        );

      case 'delivered':
        if (order.paymentMethod.toLowerCase() == 'cash' &&
            order.paymentStatus.toLowerCase() != 'confirmed') {
          return CustomButton(
            text: 'Confirm Cash Collection',
            onPressed: () {
              _showConfirmCashDialog(order.id, order.amount);
            },
            width: double.infinity,
          );
        } else if (order.paymentMethod.toLowerCase() == 'online' &&
            order.paymentStatus.toLowerCase() != 'verified') {
          return CustomButton(
            text: 'Verify Online Payment',
            onPressed: () {
              context.read<OrderBloc>().add(
                    VerifyOnlinePaymentEvent(orderId: order.id),
                  );
            },
            width: double.infinity,
          );
        } else {
          return CustomButton(
            text: 'Complete Order',
            onPressed: () {
              context.read<OrderBloc>().add(
                    CompleteOrderEvent(orderId: order.id),
                  );
            },
            width: double.infinity,
          );
        }

      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  void _showReportIssueDialog(String orderId) {
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report an Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: issueController,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (issueController.text.isNotEmpty) {
                  Navigator.pop(context);
                  context.read<OrderBloc>().add(
                        ReportOrderIssueEvent(
                          orderId: orderId,
                          issue: issueController.text,
                          description: issueController.text,
                        ),
                      );
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateEtaDialog(String orderId) {
    int selectedMinutes = 15;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Estimated Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select estimated delivery time:'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEtaOption(10, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                      _buildEtaOption(15, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                      _buildEtaOption(20, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEtaOption(30, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                      _buildEtaOption(45, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                      _buildEtaOption(60, selectedMinutes, (value) {
                        setState(() => selectedMinutes = value);
                      }),
                    ],
                  ),
                ],
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
                          UpdateEstimatedTimeEvent(
                            orderId: orderId,
                            minutes: selectedMinutes,
                          ),
                        );
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEtaOption(
      int minutes, int selectedMinutes, Function(int) onSelected) {
    final bool isSelected = minutes == selectedMinutes;

    return GestureDetector(
      onTap: () => onSelected(minutes),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$minutes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              'mins',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmCashDialog(String orderId, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cash Collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Did you collect ₹${amount.toStringAsFixed(2)} in cash from the customer?',
                style: TextStyle(fontSize: 16),
              ),
            ],
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
                      ConfirmCashCollectionEvent(
                        orderId: orderId,
                        amount: amount,
                      ),
                    );
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: AppColors.success),
              ),
            ),
          ],
        );
      },
    );
  }
}
