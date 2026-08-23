import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/widgets/app_text_field.dart';

/// White card-style outlined text field used by the booking form.
///
/// The outer card border is kept intentionally; the inner [AppTextField]
/// has its own borders suppressed so the field blends into the card.
class OutlinedCardField extends StatelessWidget {
  const OutlinedCardField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hintText,
      textDirection: ui.TextDirection.rtl,
      maxLines: maxLines,
      validator: validator,
      fillColor: AppColors.white,
    );
  }
}
