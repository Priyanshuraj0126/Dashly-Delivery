import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
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
    try {
      // Wait for a brief moment to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check authentication state
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    } catch (e) {
      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to initialize app: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initialize(); // Retry initialization
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState ||
            state is AuthUnauthenticatedState ||
            state is AuthOtpSentState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
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
      ),
    );
  }
}
