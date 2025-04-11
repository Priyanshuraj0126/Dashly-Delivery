import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showCloseIcon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final double elevation;
  final bool isScrollControlled;
  final bool enableDrag;
  final bool isDismissible;
  final Color? dragHandleColor;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showCloseIcon = true,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.titleColor,
    this.titleFontSize = 18.0,
    this.titleFontWeight = FontWeight.w600,
    this.contentPadding,
    this.actionsPadding,
    this.elevation = 4,
    this.isScrollControlled = false,
    this.enableDrag = true,
    this.isDismissible = true,
    this.dragHandleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorUtils.withAlpha(AppColors.shadow, 0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enableDrag)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dragHandleColor ?? AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (title != null || actions != null || showCloseIcon)
            Container(
              padding: actionsPadding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: titleFontWeight,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                    ),
                  if (actions != null) ...[
                    ...actions!,
                    if (showCloseIcon) const SizedBox(width: 8),
                  ],
                  if (showCloseIcon)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: contentPadding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showCloseIcon = true,
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? titleColor,
    double titleFontSize = 18.0,
    FontWeight titleFontWeight = FontWeight.w600,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    double elevation = 4,
    bool isScrollControlled = false,
    bool enableDrag = true,
    bool isDismissible = true,
    Color? dragHandleColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: title,
        actions: actions,
        showCloseIcon: showCloseIcon,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        titleColor: titleColor,
        titleFontSize: titleFontSize,
        titleFontWeight: titleFontWeight,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        elevation: elevation,
        isScrollControlled: isScrollControlled,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        dragHandleColor: dragHandleColor,
        child: child,
      ),
    );
  }
}
