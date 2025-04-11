import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_empty_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement notifications list
    final bool hasNotifications = false; // This would come from a bloc/state

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (hasNotifications)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // TODO: Implement clear all notifications
              },
            ),
        ],
      ),
      body: hasNotifications
          ? ListView.builder(
              itemCount: 0, // This would be the actual count of notifications
              itemBuilder: (context, index) {
                return const ListTile(
                  // TODO: Implement notification item
                );
              },
            )
          : const CustomEmptyWidget(
              message: 'You have no notifications',
              icon: Icons.notifications_off_outlined,
              showActionButton: false,
            ),
    );
  }
} 