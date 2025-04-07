import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double height;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.titleColor,
    this.titleFontSize = 18.0,
    this.titleFontWeight = FontWeight.w600,
    this.height = kToolbarHeight,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: titleFontWeight,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.surface,
      bottom: bottom,
      toolbarHeight: height,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));
}
