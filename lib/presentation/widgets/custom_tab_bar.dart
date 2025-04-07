import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController controller;
  final bool isScrollable;
  final double indicatorWeight;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final EdgeInsets? labelPadding;
  final EdgeInsets? tabAlignment;
  final double height;
  final Color? backgroundColor;
  final double elevation;
  final bool showDivider;
  final Color? dividerColor;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.isScrollable = false,
    this.indicatorWeight = 3.0,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelFontSize = 14.0,
    this.labelFontWeight = FontWeight.w600,
    this.labelPadding,
    this.tabAlignment,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.elevation = 0,
    this.showDivider = true,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          TabBar(
            controller: controller,
            tabs: tabs,
            isScrollable: isScrollable,
            indicatorWeight: indicatorWeight,
            indicatorColor: indicatorColor ?? AppColors.primary,
            labelColor: labelColor ?? AppColors.primary,
            unselectedLabelColor:
                unselectedLabelColor ?? AppColors.textSecondary,
            labelStyle: TextStyle(
              fontSize: labelFontSize,
              fontWeight: labelFontWeight,
            ),
            labelPadding:
                labelPadding ?? const EdgeInsets.symmetric(horizontal: 16),
            tabAlignment: tabAlignment ?? TabAlignment.start,
          ),
          if (showDivider)
            Divider(
              height: 1,
              color: dividerColor ?? AppColors.border,
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
