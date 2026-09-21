import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/booking_models.dart';

/// Selectable list of consultation options. The channel icon sits on the
/// leading edge and the price on the trailing edge, mirrored per locale.
/// Options come from the selected backend service.
class SessionTypeSelector extends StatelessWidget {
  const SessionTypeSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<ConsultationOption> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  IconData _iconFor(String? channel) {
    switch (channel) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'voice':
        return Icons.mic_none_rounded;
      case 'video':
        return Icons.videocam_outlined;
      case 'clinic':
        return Icons.local_hospital_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.allXl,
                  border: Border.all(
                    color:
                        i == selectedIndex ? AppColors.primary : AppColors.border,
                    width: i == selectedIndex ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(options[i].channel),
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        localizedOptionLabel(context, options[i].label),
                        textAlign: TextAlign.start,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${options[i].displayPrice} ${options[i].currencySymbol ?? context.tr(LocaleKeys.booking_currency)}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
