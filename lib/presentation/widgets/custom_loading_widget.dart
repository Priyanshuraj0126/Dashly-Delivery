import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final Color? messageColor;
  final double messageFontSize;
  final FontWeight messageFontWeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool centerContent;
  final double borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final bool showShadow;
  final double strokeWidth;
  final bool showBackground;
  final Widget? customIndicator;
  final Widget? customMessage;

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    this.messageColor,
    this.messageFontSize = 16.0,
    this.messageFontWeight = FontWeight.normal,
    this.padding,
    this.margin,
    this.centerContent = true,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.elevation = 0,
    this.showShadow = false,
    this.strokeWidth = 3.0,
    this.showBackground = true,
    this.customIndicator,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (customIndicator != null)
          customIndicator!
        else
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
        if ((message != null || customMessage != null) && size > 0) ...[
          const SizedBox(height: 16),
          if (customMessage != null)
            customMessage!
          else if (message != null)
            Text(
              message!,
              style: TextStyle(
                fontSize: messageFontSize,
                fontWeight: messageFontWeight,
                color: messageColor ?? AppColors.textSecondary,
              ),
              textAlign: centerContent ? TextAlign.center : TextAlign.start,
            ),
        ],
      ],
    );

    if (!showBackground) {
      return Container(
        margin: margin,
        padding: padding,
        child: content,
      );
    }

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: content,
    );
  }
}
