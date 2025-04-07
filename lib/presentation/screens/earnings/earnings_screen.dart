import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/theme/app_colors.dart';
import '../../../presentation/blocs/earnings/earnings_event.dart';
import '../../../presentation/blocs/earnings/earnings_state.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../presentation/widgets/loading_indicator.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEarningsData();
  }

  void _loadEarningsData() {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<EarningsBloc>().add(LoadEarningsSummaryEvent(
            deliveryPartnerId: userId,
            startDate: _getStartDate(),
            endDate: _getEndDate(),
          ));
    }
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'Today':
        return DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
      case 'This Week':
        return _selectedDate
            .subtract(Duration(days: _selectedDate.weekday - 1));
      case 'This Month':
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      default:
        return DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
    }
  }

  DateTime _getEndDate() {
    switch (_selectedPeriod) {
      case 'Today':
        return DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, 23, 59, 59);
      case 'This Week':
        return _selectedDate.add(Duration(days: 7 - _selectedDate.weekday));
      case 'This Month':
        return DateTime(
            _selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      default:
        return DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, 23, 59, 59);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoadingState) {
            return const Center(child: LoadingIndicator());
          }

          if (state is EarningsErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: _loadEarningsData,
                    text: 'Retry',
                  ),
                ],
              ),
            );
          }

          if (state is EarningsSummaryLoadedState) {
            return _buildEarningsContent(state.summary);
          }

          return const Center(child: Text('No earnings data available'));
        },
      ),
    );
  }

  Widget _buildEarningsContent(Map<String, dynamic> summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _buildEarningsSummary(summary),
          const SizedBox(height: 24),
          _buildEarningsChart(summary),
          const SizedBox(height: 24),
          _buildEarningsBreakdown(summary),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPeriodButton('Today', _selectedPeriod == 'Today'),
          _buildPeriodButton('This Week', _selectedPeriod == 'This Week'),
          _buildPeriodButton('This Month', _selectedPeriod == 'This Month'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
        _loadEarningsData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹${summary['totalEarnings'].toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Net Earnings: ₹${summary['netEarnings'].toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Orders', summary['totalOrders'].toString()),
              _buildSummaryItem(
                  'Completed', summary['completedOrders'].toString()),
              _buildSummaryItem(
                  'Cancelled', summary['cancelledOrders'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildEarningsChart(Map<String, dynamic> summary) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 0),
                FlSpot(1, summary['totalEarnings']),
                FlSpot(2, summary['netEarnings']),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMetricItem(
            'Average Order Value',
            '₹${summary['averageOrderValue'].toStringAsFixed(2)}',
          ),
          _buildMetricItem(
            'Average Delivery Time',
            '${(summary['averageDeliveryTime'] / 60).toStringAsFixed(1)} mins',
          ),
          _buildMetricItem(
            'Completion Rate',
            '${(summary['completionRate'] * 100).toStringAsFixed(1)}%',
          ),
          _buildMetricItem(
            'Cancellation Rate',
            '${(summary['cancellationRate'] * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEarningsData();
    }
  }
}
