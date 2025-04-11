import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsets? margin;
  final bool isVertical;
  final bool showGradient;
  final List<Color>? gradientColors;
  final double gradientOpacity;
  final bool showDashed;
  final double dashWidth;
  final double dashSpace;
  final double dashRadius;

  const CustomDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
    this.margin,
    this.isVertical = false,
    this.showGradient = false,
    this.gradientColors,
    this.gradientOpacity = 0.1,
    this.showDashed = false,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
    this.dashRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.border;
    final effectiveGradientColors = gradientColors ??
        [
          ColorUtils.withAlpha(effectiveColor, gradientOpacity),
          effectiveColor,
          ColorUtils.withAlpha(effectiveColor, gradientOpacity),
        ];

    Widget divider;
    if (showDashed) {
      divider = CustomPaint(
        size: Size(
          isVertical ? thickness : double.infinity,
          isVertical ? double.infinity : thickness,
        ),
        painter: DashedLinePainter(
          color: effectiveColor,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
          dashRadius: dashRadius,
          isVertical: isVertical,
        ),
      );
    } else if (showGradient) {
      divider = Container(
        height: isVertical ? double.infinity : thickness,
        width: isVertical ? thickness : double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveGradientColors,
            begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
            end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
          ),
        ),
      );
    } else {
      divider = Container(
        height: isVertical ? double.infinity : thickness,
        width: isVertical ? thickness : double.infinity,
        color: effectiveColor,
      );
    }

    return Container(
      margin: margin,
      height: isVertical ? double.infinity : height,
      width: isVertical ? height : double.infinity,
      child: divider,
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double dashRadius;
  final bool isVertical;

  DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.dashRadius,
    required this.isVertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    final start = isVertical ? Offset(0, 0) : Offset(0, size.height / 2);
    final end = isVertical
        ? Offset(0, size.height)
        : Offset(size.width, size.height / 2);

    var currentOffset = 0.0;
    while (currentOffset < (isVertical ? size.height : size.width)) {
      canvas.drawLine(
        Offset(
          isVertical ? start.dx : currentOffset,
          isVertical ? currentOffset : start.dy,
        ),
        Offset(
          isVertical ? end.dx : currentOffset + dashWidth,
          isVertical ? currentOffset + dashWidth : end.dy,
        ),
        paint,
      );
      currentOffset += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.dashRadius != dashRadius ||
        oldDelegate.isVertical != isVertical;
  }
}
