import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/app_colors.dart';
import '../styles/app_radius.dart';
import '../styles/app_text_styles.dart';

/// A shared text input field used across all features.
///
/// - [height]: optional fixed height for the input box. When provided the
///   field fills that exact height. When omitted the field sizes itself to
///   its content (default Flutter behaviour).
/// - Border radius: 8 (AppRadius.md)
/// - Accepts optional [prefixWidget] and [suffixWidget]
/// - Supports [validator] for use inside a [Form]
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.label,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixWidget,
    this.suffixWidget,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.fillColor,
    this.height,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? label;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final int? maxLines;
  final int? minLines;
  final FormFieldValidator<String>? validator;
  final Color? fillColor;

  /// Optional fixed height for the input box only (error text is below).
  /// When null the field sizes itself to its content.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: controller?.text ?? '',
      builder: (state) {
        controller?.addListener(() => state.didChange(controller!.text));

        final hasError = state.hasError;

        final activeBorder = OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.primary,
            width: 1.5,
          ),
        );

        final idleBorder = OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.border,
          ),
        );

        // When a fixed height is given: use expands:true so the TextField
        // fills the SizedBox exactly. Otherwise use natural content sizing.
        final bool useFixedHeight = height != null;
        final bool shouldExpand =
            useFixedHeight && !obscureText && (maxLines ?? 1) == 1;

        Widget field = TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textDirection: textDirection,
          textAlign: textAlign,
          inputFormatters: inputFormatters,
          onChanged: (v) {
            state.didChange(v);
            onChanged?.call(v);
          },
          onSubmitted: onSubmitted,
          onTap: onTap,
          expands: shouldExpand,
          maxLines: shouldExpand ? null : (obscureText ? 1 : maxLines),
          minLines: useFixedHeight ? null : minLines,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            labelStyle:
                AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: fillColor ?? AppColors.fieldFill,
            prefixIcon: prefixWidget != null
                ? IntrinsicHeight(child: prefixWidget!)
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixWidget != null
                ? IntrinsicHeight(child: suffixWidget!)
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            isDense: true,
            contentPadding: useFixedHeight
                ? const EdgeInsets.symmetric(horizontal: 14)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: idleBorder,
            enabledBorder: idleBorder,
            focusedBorder: activeBorder,
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.allMd,
              borderSide:
                  BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            errorBorder: idleBorder,
            focusedErrorBorder: activeBorder,
          ),
        );

        if (useFixedHeight) {
          field = SizedBox(height: height, child: field);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field,
            // Always reserve one line for the error so layout never shifts.
            SizedBox(
              height: 18,
              child: hasError
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 2, left: 4, right: 4),
                      child: Text(
                        state.errorText!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
