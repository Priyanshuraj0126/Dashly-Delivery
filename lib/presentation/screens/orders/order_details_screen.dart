import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../../data/models/order.dart' as order_model;
import '../../../data/models/user.dart' as user_model_ns;
import '../../../data/models/store.dart' as store_model_ns;

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
    context
        .read<OrderBloc>()
        .add(ListenForSpecificOrderEvent(orderId: widget.orderId));
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
    try {
      final Uri launchUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/dir/',
        queryParameters: {
          'api': '1',
          'destination': '$latitude,$longitude',
        },
      );

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Widget _buildOrderDetails(BuildContext context, order_model.Order order) {
    final orderStatus = order.status.toLowerCase();

    final paymentMethodDisplay = order.paymentMethod ?? 'N/A';
    final paymentStatusString = order.payment.status;
    final paymentStatusDisplay = (paymentStatusString is String
            ? paymentStatusString
            : (paymentStatusString as dynamic)?.name) ??
        (order.paymentMethod?.toLowerCase() == 'cod' ? 'Pending' : 'Paid');
    final specialInstructionsDisplay = order.specialInstructions ?? 'N/A';
    final landmarkDisplay = order.deliveryAddress.landmark ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
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
                  _buildInfoRow('Payment Method', paymentMethodDisplay),
                  const Divider(height: 24),
                  _buildInfoRow('Payment Status', paymentStatusDisplay),
                  if (order.paymentMethod?.toLowerCase() == 'cash' ||
                      order.paymentMethod?.toLowerCase() == 'cod') ...[
                    const Divider(height: 24),
                    _buildInfoRow('Total Amount',
                        '₹${order.totalAmount.toStringAsFixed(2)}'),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow(
                      'Special Instructions', specialInstructionsDisplay),
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
                              order.store.address.toString(),
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
                      // TODO: Implement fetching full store details to get phone
                      // For now, this button does nothing or could be disabled.
                      // _makePhoneCall(order.store.phone ?? ''); // order.store (from order.dart) has no 'phone'
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Store phone not available in current order data.')),
                        );
                      }
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
                  _buildInfoRow('Name', order.customer.name ?? 'N/A'),
                  const Divider(height: 24),
                  _buildInfoRow('Phone', order.customer.phoneNumber ?? 'N/A'),
                  const Divider(height: 24),
                  _buildInfoRow('Address',
                      order.deliveryAddress.formattedAddress ?? 'N/A'),
                  if (order.deliveryAddress.landmark != null &&
                      order.deliveryAddress.landmark!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow('Landmark', order.deliveryAddress.landmark!),
                  ],
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Call Customer',
                    onPressed: () {
                      _makePhoneCall(order.customer.phoneNumber ?? '');
                    },
                    icon: Icons.call,
                    isOutlined: true,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Navigate to Customer',
                    onPressed: () {
                      // Get delivery address location instead of customer location
                      final latitude = order.deliveryAddress
                              .location['latitude'] as double? ??
                          0.0;
                      final longitude = order.deliveryAddress
                              .location['longitude'] as double? ??
                          0.0;
                      _openMap(latitude, longitude);
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
                                if (item.variation != null &&
                                    item.variation!.isNotEmpty)
                                  Text(
                                    item.variation!,
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
                  }),
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

          _buildActionButtons(context, order),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, order_model.Order order) {
    List<Widget> buttons = [];
    String currentStatus = order.status.toLowerCase();
    final String orderId = order.id;

    Widget paddedButton(
        {required String text,
        required VoidCallback onPressed,
        Color? backgroundColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CustomButton(
          text: text,
          onPressed: onPressed,
          backgroundColor: backgroundColor,
        ),
      );
    }

    if (currentStatus == AppConstants.orderStatusAssigned.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Start Pickup Journey',
        onPressed: () {
          context
              .read<OrderBloc>()
              .add(StartPickupJourneyEvent(orderId: orderId));
        },
      ));
    } else if (currentStatus ==
        AppConstants.orderStatusOnTheWayToPickup.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Arrived at Store',
        onPressed: () {
          context.read<OrderBloc>().add(ArrivedAtStoreEvent(orderId: orderId));
        },
      ));
    } else if (currentStatus ==
        AppConstants.orderStatusArrivedAtPickup.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Confirm & Pick Up Order',
        onPressed: () {
          context.read<OrderBloc>().add(MarkAsPickedUpEvent(orderId: orderId));
        },
      ));
    } else if (currentStatus ==
        AppConstants.orderStatusPickedUp.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Start Delivery to Customer',
        onPressed: () {
          context
              .read<OrderBloc>()
              .add(MarkAsOutForDeliveryEvent(orderId: orderId));
        },
      ));
    } else if (currentStatus ==
        AppConstants.orderStatusOutForDelivery.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Arrived at Customer',
        onPressed: () {
          context
              .read<OrderBloc>()
              .add(ArrivedAtCustomerEvent(orderId: orderId));
        },
      ));
    } else if (currentStatus ==
        AppConstants.orderStatusArrivedAtDelivery.toLowerCase()) {
      buttons.add(paddedButton(
        text: 'Confirm Delivery',
        onPressed: () {
          context.read<OrderBloc>().add(
              MarkAsDeliveredEvent(orderId: orderId, handedOverDirectly: true));
        },
      ));
    } else if (currentStatus ==
            AppConstants.orderStatusDelivered.toLowerCase() ||
        currentStatus == AppConstants.orderStatusCompleted.toLowerCase()) {
      buttons.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text(
                currentStatus == AppConstants.orderStatusDelivered.toLowerCase()
                    ? 'Order Delivered'
                    : 'Order Completed',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success))),
      ));
    }

    final String cancelledStatus =
        order_model.OrderStatus.cancelled.name.toLowerCase();
    final String failedStatus =
        order_model.OrderStatus.failed.name.toLowerCase();

    if (buttons.isEmpty &&
        currentStatus != AppConstants.orderStatusDelivered.toLowerCase() &&
        currentStatus != AppConstants.orderStatusCompleted.toLowerCase() &&
        currentStatus != cancelledStatus &&
        currentStatus != failedStatus) {
      buttons.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text('No actions available for status: ${order.status}',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center)),
      ));
    }
    return Column(children: buttons);
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
}
