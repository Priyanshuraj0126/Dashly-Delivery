import 'package:flutter/material.dart';

/// Utility class for color operations
class ColorUtils {
  /// Creates a color with the specified opacity using the new recommended approach
  static Color withAlpha(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}
