import 'package:flutter/material.dart';

/// App color palette used throughout the application
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Border and divider colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // Disabled state color
  static const Color disabled = Color(0xFFBDBDBD);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color backdrop = Color(0x40000000);

  // Accent colors
  static final Color accent = Color(0xFFFF7043); // Orange-red accent

  // Order status colors
  static final Color orderNew = Color(0xFF673AB7); // Purple
  static final Color orderAccepted = Color(0xFF3F51B5); // Indigo
  static final Color orderPicked = Color(0xFF2196F3); // Blue
  static final Color orderDelivering = Color(0xFFFF9800); // Orange
  static final Color orderDelivered = Color(0xFF4CAF50); // Green
  static final Color orderCancelled = Color(0xFFE53935); // Red

  // Earnings and analytics
  static final Color earningsPositive = Color(0xFF43A047);
  static final Color earningsNegative = Color(0xFFE53935);
  static final Color chartLine = Color(0xFF5C6BC0);
  static final Color chartBackground = Color(0xFFE8EAF6);

  // Map markers and routes
  static final Color mapMarkerPickup = Color(0xFF3F51B5);
  static final Color mapMarkerDropoff = Color(0xFFE53935);
  static final Color mapRoute = Color(0xFF5C6BC0);
  static final Color mapUserLocation = Color(0xFF673AB7);

  // Gradients
  static final List<Color> primaryGradient = [
    Color(0xFF5C6BC0),
    Color(0xFF3949AB),
  ];

  static final List<Color> accentGradient = [
    Color(0xFFFF7043),
    Color(0xFFFF5722),
  ];
}
