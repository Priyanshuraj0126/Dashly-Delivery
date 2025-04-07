import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../orders/active_orders_screen.dart';
import '../orders/order_history_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';

/// The main screen shown after successful authentication
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();

    // Fetch active orders when screen loads
    context.read<OrderBloc>().add(FetchActiveOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashly Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticatedState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${state.phoneNumber}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusButton(
                  'Online',
                  _isOnline ? AppColors.primary : Colors.grey.shade400,
                  Icons.check_circle,
                  () => _updateStatus(true),
                ),
                _buildStatusButton(
                  'Offline',
                  !_isOnline ? AppColors.error : Colors.grey.shade400,
                  Icons.cancel,
                  () => _updateStatus(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });

    // Update delivery status in the repository
    // This would typically use a dedicated repository method
    // For MVP we'll just show the UI change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now ${isOnline ? 'Online' : 'Offline'}'),
        backgroundColor: isOnline ? AppColors.success : AppColors.error,
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                    builder: (context) => const ActiveOrdersScreen(),
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
                        context.read<OrderBloc>().add(FetchOrderHistoryEvent());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
