import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final Curve curve;
  final bool enabled;
  final Widget? loadingWidget;

  const CustomShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
    this.enabled = true,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || !isLoading) return child;

    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.surface,
      highlightColor:
          highlightColor ?? ColorUtils.withAlpha(AppColors.surface, 0.5),
      period: duration,
      child: loadingWidget ?? child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;
  final EdgeInsets? margin;

  const ShimmerContainer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;
  final EdgeInsets? margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;
  final EdgeInsets? margin;

  const ShimmerText({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 4,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
