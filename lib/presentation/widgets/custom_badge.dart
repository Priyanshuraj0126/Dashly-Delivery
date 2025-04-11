import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final double borderRadius;
  final bool isDot;
  final double dotSize;
  final EdgeInsets? offset;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showShadow;
  final double elevation;
  final bool isVisible;

  const CustomBadge({
    super.key,
    required this.child,
    this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.borderRadius = 10.0,
    this.isDot = false,
    this.dotSize = 8.0,
    this.offset,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.showShadow = false,
    this.elevation = 4.0,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: (offset?.top ?? -8) - (isDot ? dotSize / 2 : 0),
          right: (offset?.right ?? -8) - (isDot ? dotSize / 2 : 0),
          child: Container(
            padding: isDot
                ? null
                : (padding ??
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.error,
              shape: isDot ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isDot ? null : BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? AppColors.surface,
                      width: borderWidth,
                    )
                  : null,
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
            child: isDot
                ? SizedBox(
                    width: dotSize,
                    height: dotSize,
                  )
                : label != null
                    ? Text(
                        label!,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: textColor ?? Colors.white,
                        ),
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
