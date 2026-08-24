import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_sizes.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

class ServiceOptionCard extends StatelessWidget {
  const ServiceOptionCard.clinic({
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
    super.key,
  }) : _iconType = _IconType.clinic;

  const ServiceOptionCard.online({
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
    super.key,
  }) : _iconType = _IconType.online;

  final String title;
  final String description;
  final String price;
  final VoidCallback onTap;
  final _IconType _iconType;

  @override
  Widget build(BuildContext context) {
    // Icon size: ~12% of screen width, capped
    final iconSize =
        (MediaQuery.sizeOf(context).width * 0.12).clamp(40.0, 56.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: ui.TextDirection.rtl,
        children: [
          _buildIcon(iconSize),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  textDirection: ui.TextDirection.rtl,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: AppSizes.buttonHeight,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: const StadiumBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr(LocaleKeys.home_bookService_startNow),
                                style: AppTextStyles.button
                                    .copyWith(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      price,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(double size) {
    if (_iconType == _IconType.clinic) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.75),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.expand_more,
            color: AppColors.white, size: size * 0.55),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
      ),
      child: Center(
        child: Container(
          width: size * 0.32,
          height: size * 0.32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

enum _IconType { clinic, online }
