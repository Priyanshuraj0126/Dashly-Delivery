import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation;
  final bool isOutlined;
  final VoidCallback? onTap;
  final bool showShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 0,
    this.isOutlined = false,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isOutlined
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
