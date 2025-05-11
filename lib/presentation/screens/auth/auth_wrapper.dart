import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import '../dashboard/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// A widget that handles authentication state and routes users to appropriate screens
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Always rebuild if the type of state changes
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }
        // If both are AuthAuthenticatedState, rebuild only if isProfileComplete changes
        if (previous is AuthAuthenticatedState &&
            current is AuthAuthenticatedState) {
          return previous.isProfileComplete != current.isProfileComplete;
        }
        // For other state types (e.g. AuthErrorState with different messages),
        // allow rebuild if they are not AuthAuthenticatedState.
        // This ensures UI updates for changes like error messages.
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
          if (state.isProfileComplete) {
            return const HomeScreen();
          } else {
            return const OnboardingScreen();
          }
        }

        if (state is AuthOtpSentState) {
          return OtpVerificationScreen(
            phoneNumber: state.phoneNumber,
            verificationId: state.verificationId,
          );
        }

        // Default to LoginScreen for AuthUnauthenticatedState, AuthInitialState, AuthErrorState etc.
        return const LoginScreen();
      },
    );
  }
}
