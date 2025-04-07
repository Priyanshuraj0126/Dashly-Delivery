import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/order/order_bloc.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    // Load order history when screen opens
    context.read<OrderBloc>().add(FetchOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrderHistoryLoadedState) {
            final orders = state.orders;

            if (orders.isEmpty) {
              return const Center(
                child: Text('No order history found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order.isCompleted()
                                    ? AppColors.success
                                    : AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${dateFormat.format(order.createdAt ?? DateTime.now())}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Items: ${order.items.length}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () {
                                context.read<OrderBloc>().add(
                                      FetchOrderDetailsEvent(
                                        orderId: order.id,
                                      ),
                                    );
                                // Navigate to order details page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsScreen(
                                      orderId: order.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is OrderErrorState) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          return const Center(
            child: Text('Select a date range to view order history'),
          );
        },
      ),
    );
  }
}
