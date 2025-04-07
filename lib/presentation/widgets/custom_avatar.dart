import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final IconData? icon;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final BoxFit? fit;
  final Widget? child;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showShadow;
  final double elevation;
  final VoidCallback? onTap;
  final bool isOnline;
  final Color? onlineColor;
  final double onlineIndicatorSize;
  final EdgeInsets? onlineIndicatorPadding;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = 40.0,
    this.borderRadius = 20.0,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    this.padding,
    this.fit,
    this.child,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.showShadow = false,
    this.elevation = 4.0,
    this.onTap,
    this.isOnline = false,
    this.onlineColor,
    this.onlineIndicatorSize = 12.0,
    this.onlineIndicatorPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? AppColors.border,
                      width: borderWidth,
                    )
                  : null,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: _buildContent(),
            ),
          ),
          if (isOnline)
            Positioned(
              right: onlineIndicatorPadding?.right ?? 0,
              bottom: onlineIndicatorPadding?.bottom ?? 0,
              child: Container(
                width: onlineIndicatorSize,
                height: onlineIndicatorSize,
                decoration: BoxDecoration(
                  color: onlineColor ?? AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (child != null) return child!;
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    if (name != null) {
      return Center(
        child: Text(
          name!.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      );
    }
    if (icon != null) {
      return Icon(
        icon,
        size: size * 0.5,
        color: textColor ?? AppColors.textPrimary,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFallback() {
    if (name != null) {
      return Center(
        child: Text(
          name!.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      );
    }
    if (icon != null) {
      return Icon(
        icon,
        size: size * 0.5,
        color: textColor ?? AppColors.textPrimary,
      );
    }
    return const SizedBox.shrink();
  }
}
