import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final double elevation;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double selectedFontSize;
  final double unselectedFontSize;
  final FontWeight selectedFontWeight;
  final FontWeight unselectedFontWeight;
  final double iconSize;
  final double height;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.elevation = 8,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedFontSize = 12.0,
    this.unselectedFontSize = 12.0,
    this.selectedFontWeight = FontWeight.w600,
    this.unselectedFontWeight = FontWeight.normal,
    this.iconSize = 24.0,
    this.height = kBottomNavigationBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: ColorUtils.withAlpha(AppColors.shadow, 0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        items: items,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor ?? AppColors.surface,
        selectedItemColor: selectedItemColor ?? AppColors.primary,
        unselectedItemColor: unselectedItemColor ?? AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: selectedFontSize,
          fontWeight: selectedFontWeight,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: unselectedFontSize,
          fontWeight: unselectedFontWeight,
        ),
        iconSize: iconSize,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
