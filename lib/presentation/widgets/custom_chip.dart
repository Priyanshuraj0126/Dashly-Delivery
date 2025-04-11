import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Widget? deleteIcon;
  final VoidCallback? onDeleted;
  final VoidCallback? onSelected;
  final bool selected;
  final bool enabled;
  final bool showCheckmark;
  final bool isOutlined;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? labelColor;
  final Color? selectedLabelColor;
  final Color? deleteIconColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final EdgeInsets? padding;
  final EdgeInsets? labelPadding;
  final EdgeInsets? avatarPadding;
  final EdgeInsets? deleteIconPadding;
  final double elevation;
  final bool showShadow;

  const CustomChip({
    super.key,
    required this.label,
    this.avatar,
    this.deleteIcon,
    this.onDeleted,
    this.onSelected,
    this.selected = false,
    this.enabled = true,
    this.showCheckmark = false,
    this.isOutlined = false,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.selectedColor,
    this.labelColor,
    this.selectedLabelColor,
    this.deleteIconColor,
    this.labelFontSize = 14.0,
    this.labelFontWeight = FontWeight.w500,
    this.padding,
    this.labelPadding,
    this.avatarPadding,
    this.deleteIconPadding,
    this.elevation = 0,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined
            ? Colors.transparent
            : (selected
                ? (selectedColor ?? AppColors.primary)
                : (backgroundColor ?? AppColors.surface)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: isOutlined
            ? Border.all(
                color: selected
                    ? (selectedColor ?? AppColors.primary)
                    : AppColors.border,
                width: 1.5,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onSelected : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar != null) ...[
                  Padding(
                    padding: avatarPadding ?? const EdgeInsets.only(right: 8),
                    child: avatar!,
                  ),
                ],
                if (showCheckmark && selected)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: isOutlined
                          ? (selectedColor ?? AppColors.primary)
                          : Colors.white,
                    ),
                  ),
                Padding(
                  padding:
                      labelPadding ?? const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: labelFontWeight,
                      color: isOutlined
                          ? (selected
                              ? (selectedColor ?? AppColors.primary)
                              : (labelColor ?? AppColors.textPrimary))
                          : (selected
                              ? (selectedLabelColor ?? Colors.white)
                              : (labelColor ?? AppColors.textPrimary)),
                    ),
                  ),
                ),
                if (deleteIcon != null && onDeleted != null)
                  Padding(
                    padding:
                        deleteIconPadding ?? const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: deleteIcon!,
                      onPressed: enabled ? onDeleted : null,
                      color: deleteIconColor ??
                          (isOutlined
                              ? (selected
                                  ? (selectedColor ?? AppColors.primary)
                                  : AppColors.textSecondary)
                              : (selected
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
