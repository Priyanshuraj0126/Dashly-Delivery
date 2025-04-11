import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NavigationScreen extends StatelessWidget {
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;

  const NavigationScreen({
    super.key,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Navigating to:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              destinationAddress,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement open in maps app
              },
              icon: const Icon(Icons.directions),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
