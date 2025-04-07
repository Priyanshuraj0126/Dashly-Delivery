import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomTabBarView extends StatelessWidget {
  final TabController controller;
  final List<Widget> children;
  final bool physics;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final bool isScrollable;
  final ScrollPhysics? scrollPhysics;

  const CustomTabBarView({
    super.key,
    required this.controller,
    required this.children,
    this.physics = true,
    this.padding,
    this.backgroundColor,
    this.showDivider = true,
    this.dividerColor,
    this.dividerHeight = 1.0,
    this.isScrollable = true,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: controller,
              physics: physics
                  ? (scrollPhysics ?? const BouncingScrollPhysics())
                  : const NeverScrollableScrollPhysics(),
              children: children,
            ),
          ),
          if (showDivider)
            Container(
              height: dividerHeight,
              color: dividerColor ?? AppColors.border,
            ),
        ],
      ),
    );
  }
}
