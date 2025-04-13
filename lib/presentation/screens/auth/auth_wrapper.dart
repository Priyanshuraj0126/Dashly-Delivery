import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import '../dashboard/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// A widget that handles authentication state and routes users to appropriate screens
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check auth state and update navigation flag outside of build method
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticatedState && !_isNavigating) {
      debugPrint('Setting navigation flag in didChangeDependencies');
      _isNavigating = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Only rebuild on significant state changes to prevent flickering
        if (_isNavigating) return false;

        if (previous is AuthAuthenticatedState &&
            current is AuthAuthenticatedState) {
          return previous.isProfileComplete != current.isProfileComplete;
        }
        return true;
      },
      builder: (context, state) {
        debugPrint('AuthWrapper building with state: ${state.runtimeType}');

        if (state is AuthLoadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticatedState) {
          debugPrint(
              'AuthWrapper: User authenticated with profile complete: ${state.isProfileComplete}');

          // No setState here - flag is updated in didChangeDependencies

          if (state.isProfileComplete) {
            return const HomeScreen();
          } else {
            // Navigate to onboarding without forcing profile status change
            // This prevents triggering additional auth state changes
            return const OnboardingScreen();
          }
        }

        if (state is AuthOtpSentState) {
          return OtpVerificationScreen(
            phoneNumber: state.phoneNumber,
            verificationId: state.verificationId,
          );
        }

        return const LoginScreen();
      },
    );
  }
}
