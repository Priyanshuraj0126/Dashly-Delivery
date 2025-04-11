import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// A widget that handles authentication state and routes users to appropriate screens
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticatedState) {
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

        return const LoginScreen();
      },
    );
  }
}
