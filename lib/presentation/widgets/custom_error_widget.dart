import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final double titleFontSize;
  final double messageFontSize;
  final FontWeight titleFontWeight;
  final FontWeight messageFontWeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showRetryButton;
  final bool showIcon;
  final bool centerContent;
  final double borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final bool showShadow;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.iconSize = 48.0,
    this.iconColor,
    this.titleColor,
    this.messageColor,
    this.titleFontSize = 18.0,
    this.messageFontSize = 16.0,
    this.titleFontWeight = FontWeight.w600,
    this.messageFontWeight = FontWeight.normal,
    this.padding,
    this.margin,
    this.onRetry,
    this.retryText,
    this.showRetryButton = true,
    this.showIcon = true,
    this.centerContent = true,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.elevation = 0,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: ColorUtils.withAlpha(AppColors.shadow, 0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (showIcon && icon != null)
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.error,
            ),
          if (showIcon && icon != null) const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
                color: titleColor ?? AppColors.textPrimary,
              ),
              textAlign: centerContent ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: TextStyle(
              fontSize: messageFontSize,
              fontWeight: messageFontWeight,
              color: messageColor ?? AppColors.textSecondary,
            ),
            textAlign: centerContent ? TextAlign.center : TextAlign.start,
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryText ?? 'Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
