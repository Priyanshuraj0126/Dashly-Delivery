import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCloseIcon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? messageColor;
  final double titleFontSize;
  final double messageFontSize;
  final FontWeight titleFontWeight;
  final FontWeight messageFontWeight;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final double elevation;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCloseIcon = true,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.titleColor,
    this.messageColor,
    this.titleFontSize = 18.0,
    this.messageFontSize = 16.0,
    this.titleFontWeight = FontWeight.w600,
    this.messageFontWeight = FontWeight.normal,
    this.contentPadding,
    this.actionsPadding,
    this.elevation = 4,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Padding(
                padding:
                    contentPadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: titleFontWeight,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: messageFontSize,
                        fontWeight: messageFontWeight,
                        color: messageColor ?? AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
          if (confirmText != null || cancelText != null)
            Container(
              padding: actionsPadding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    TextButton(
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(cancelText!),
                    ),
                  if (confirmText != null) ...[
                    if (cancelText != null) const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (onConfirm != null) {
                          onConfirm!();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(confirmText!),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCloseIcon = true,
    double borderRadius = 12.0,
    Color? backgroundColor,
    Color? titleColor,
    Color? messageColor,
    double titleFontSize = 18.0,
    double messageFontSize = 16.0,
    FontWeight titleFontWeight = FontWeight.w600,
    FontWeight messageFontWeight = FontWeight.normal,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    double elevation = 4,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCloseIcon: showCloseIcon,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        titleColor: titleColor,
        messageColor: messageColor,
        titleFontSize: titleFontSize,
        messageFontSize: messageFontSize,
        titleFontWeight: titleFontWeight,
        messageFontWeight: messageFontWeight,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        elevation: elevation,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}
