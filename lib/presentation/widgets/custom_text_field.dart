import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A custom text field widget with consistent styling
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsets? contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final double fontSize;
  final FontWeight? fontWeight;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.fontSize = 16.0,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: fontSize - 2,
              fontWeight: FontWeight.w500,
              color: labelColor ?? AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: hintColor ?? AppColors.textSecondary,
            ),
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: backgroundColor ?? AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
          ),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
        ),
      ],
    );
  }
}
