import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final bool dense;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? hoverColor;
  final Color? splashColor;
  final double borderRadius;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final EdgeInsets? margin;

  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.selectedColor,
    this.hoverColor,
    this.splashColor,
    this.borderRadius = 8.0,
    this.showDivider = true,
    this.dividerColor,
    this.dividerHeight = 1.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: margin,
          decoration: BoxDecoration(
            color: selected
                ? (selectedColor ??
                    ColorUtils.withAlpha(AppColors.primary, 0.1))
                : (backgroundColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              onLongPress: enabled ? onLongPress : null,
              borderRadius: BorderRadius.circular(borderRadius),
              hoverColor: hoverColor ?? AppColors.hover,
              splashColor: splashColor ?? AppColors.splash,
              child: Padding(
                padding: contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: dense ? 8 : 12,
                    ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            title!,
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              subtitle!,
                            ],
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 16),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: dividerHeight,
            color: dividerColor ?? AppColors.divider,
          ),
      ],
    );
  }
}
