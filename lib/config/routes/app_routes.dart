import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/dashboard/home_screen.dart';
import '../../presentation/screens/orders/order_details_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/support/support_screen.dart';
import '../../presentation/screens/earnings/earnings_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/zones/zones_screen.dart';
import '../../presentation/screens/navigation/navigation_screen.dart';
import 'route_names.dart';

/// App routes configuration
class AppRoutes {
  /// Generate routes for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] as String? ?? '',
            verificationId: args?['verificationId'] as String? ?? '',
          ),
        );

      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RouteNames.orderDetails:
        final orderId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderId: orderId ?? ''),
        );

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case RouteNames.support:
        return MaterialPageRoute(builder: (_) => const SupportScreen());

      case RouteNames.earnings:
        return MaterialPageRoute(builder: (_) => const EarningsScreen());

      case RouteNames.zones:
        return MaterialPageRoute(builder: (_) => const ZonesScreen());

      case RouteNames.navigation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NavigationScreen(
            destinationAddress: args?['destinationAddress'] as String? ?? '',
            destinationLatitude: args?['destinationLatitude'] as double? ?? 0.0,
            destinationLongitude:
                args?['destinationLongitude'] as double? ?? 0.0,
          ),
        );

      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
