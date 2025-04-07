import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomSnackBar extends SnackBar {
  final String message;
  final SnackBarType type;
  @override
  final Duration duration;
  @override
  final SnackBarAction? action;
  final VoidCallback? onDismissed;
  @override
  final bool showCloseIcon;
  final double borderRadius;
  @override
  final EdgeInsets? margin;
  @override
  final double elevation;
  @override
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight? fontWeight;

  CustomSnackBar({
    super.key,
    required this.message,
    this.type = SnackBarType.info,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.onDismissed,
    this.showCloseIcon = true,
    this.borderRadius = 8.0,
    this.margin,
    this.elevation = 4,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 14.0,
    this.fontWeight,
  }) : super(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ),
              if (showCloseIcon)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(navigatorKey.currentContext!)
                        .hideCurrentSnackBar();
                  },
                ),
            ],
          ),
          duration: duration,
          action: action,
          onVisible: onDismissed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          margin: margin ?? const EdgeInsets.all(16),
          elevation: elevation,
          backgroundColor: backgroundColor ?? _getBackgroundColor(type),
        );

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppColors.success;
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.warning:
        return AppColors.warning;
      case SnackBarType.info:
        return AppColors.info;
    }
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// Global navigator key for showing snackbars from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
