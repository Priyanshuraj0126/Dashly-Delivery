import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

/// A custom button widget with loading state support
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.width,
    this.height = 48.0,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined
              ? Colors.transparent
              : (backgroundColor ?? AppColors.primary),
          foregroundColor: isOutlined
              ? (textColor ?? AppColors.primary)
              : (textColor ?? Colors.white),
          elevation: isOutlined ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isOutlined
                ? BorderSide(
                    color: textColor ?? AppColors.primary,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          disabledBackgroundColor: ColorUtils.withAlpha(AppColors.primary, 0.5),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 4),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
