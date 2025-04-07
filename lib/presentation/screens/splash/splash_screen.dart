import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/firebase/firebase_messaging_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../auth/auth_wrapper.dart';

/// The splash screen that appears when the app is first launched
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for a brief moment to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Initialize messaging permissions
    if (mounted) {
      final messagingService = context.read<FirebaseMessagingService>();
      await messagingService.initialize();
    }

    // Check authentication state
    if (mounted) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());

      // Navigate to auth wrapper
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo_white.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.delivery_dining,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'Dashly Delivery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
