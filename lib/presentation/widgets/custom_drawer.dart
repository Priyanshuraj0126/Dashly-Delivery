import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  final Widget child;
  final double width;
  final double elevation;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool showCloseIcon;
  final double borderRadius;
  final Color? borderColor;
  final bool isScrollable;
  final ScrollController? scrollController;

  const CustomDrawer({
    super.key,
    required this.child,
    this.width = 300,
    this.elevation = 4,
    this.backgroundColor,
    this.padding,
    this.showCloseIcon = true,
    this.borderRadius = 12,
    this.borderColor,
    this.isScrollable = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(borderRadius),
        ),
      ),
      child: Stack(
        children: [
          if (isScrollable)
            SingleChildScrollView(
              controller: scrollController,
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            )
          else
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          if (showCloseIcon)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required Widget child,
    double width = 300,
    double elevation = 4,
    Color? backgroundColor,
    EdgeInsets? padding,
    bool showCloseIcon = true,
    double borderRadius = 12,
    Color? borderColor,
    bool isScrollable = true,
    ScrollController? scrollController,
  }) {
    final drawer = CustomDrawer(
      width: width,
      elevation: elevation,
      backgroundColor: backgroundColor,
      padding: padding,
      showCloseIcon: showCloseIcon,
      borderRadius: borderRadius,
      borderColor: borderColor,
      isScrollable: isScrollable,
      scrollController: scrollController,
      child: child,
    );

    Scaffold.of(context).openDrawer();
    return Future.value();
  }
}
