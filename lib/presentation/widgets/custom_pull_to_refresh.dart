import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? color;
  final double strokeWidth;
  final double size;
  final bool showRefreshIndicator;
  final bool showLoadingIndicator;
  final bool showProgressIndicator;
  final double progressIndicatorSize;
  final double progressIndicatorStrokeWidth;
  final Color? progressIndicatorColor;
  final String? loadingText;
  final Color? loadingTextColor;
  final double loadingTextFontSize;
  final FontWeight loadingTextFontWeight;
  final EdgeInsets? loadingTextPadding;
  final bool enableRefresh;
  final bool enableScroll;
  final ScrollPhysics? physics;
  final bool showScrollbar;
  final bool showScrollbarWhenDragging;
  final double scrollbarThickness;
  final Color? scrollbarColor;
  final Color? scrollbarTrackColor;
  final Color? scrollbarTrackBorderColor;
  final double scrollbarTrackBorderWidth;
  final double scrollbarTrackBorderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 2.0,
    this.size = 40.0,
    this.showRefreshIndicator = true,
    this.showLoadingIndicator = true,
    this.showProgressIndicator = true,
    this.progressIndicatorSize = 24.0,
    this.progressIndicatorStrokeWidth = 2.0,
    this.progressIndicatorColor,
    this.loadingText,
    this.loadingTextColor,
    this.loadingTextFontSize = 14.0,
    this.loadingTextFontWeight = FontWeight.normal,
    this.loadingTextPadding,
    this.enableRefresh = true,
    this.enableScroll = true,
    this.physics,
    this.showScrollbar = false,
    this.showScrollbarWhenDragging = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarColor,
    this.scrollbarTrackColor,
    this.scrollbarTrackBorderColor,
    this.scrollbarTrackBorderWidth = 1.0,
    this.scrollbarTrackBorderRadius = 3.0,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    if (margin != null) {
      content = Container(
        margin: margin!,
        child: content,
      );
    }

    if (!enableScroll) {
      return content;
    }

    if (showScrollbar) {
      content = ScrollbarTheme(
        data: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(scrollbarThickness),
          thumbColor: WidgetStateProperty.all(
            scrollbarColor ?? AppColors.primary.withOpacity(0.5),
          ),
          trackColor: WidgetStateProperty.all(
            scrollbarTrackColor ?? AppColors.surface,
          ),
          radius: Radius.circular(scrollbarTrackBorderRadius),
        ),
        child: Scrollbar(
          thickness: scrollbarThickness,
          radius: Radius.circular(scrollbarTrackBorderRadius),
          child: content,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: enableRefresh ? onRefresh : () async {},
      backgroundColor: backgroundColor ?? AppColors.surface,
      color: color ?? AppColors.primary,
      strokeWidth: strokeWidth,
      displacement: size,
      child: content,
    );
  }
}
