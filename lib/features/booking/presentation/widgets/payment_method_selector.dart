import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/booking_models.dart';

/// Selectable list of payment methods with brand badges.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.locked = false,
  });

  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod?> onChanged;

  /// When true (a method is confirmed), every non-selected method is
  /// visibly disabled and non-tappable. The selected card stays tappable
  /// so the user can still deselect it.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethod.values.map((method) {
        final isSelected = method == selected;
        final isDisabled = locked && !isSelected;
        final card = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.07)
                : AppColors.white,
            borderRadius: AppRadius.allXl,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _paymentIcon(method),
              const Spacer(),
              Text(
                method.localizedLabel(context),
                style: AppTextStyles.body.copyWith(
                  color: isDisabled
                      ? AppColors.textSecondary.withValues(alpha: 0.6)
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _RadioDot(selected: isSelected),
            ],
          ),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: isDisabled
              ? IgnorePointer(
                  child: Opacity(opacity: 0.45, child: card),
                )
              : GestureDetector(
                  onTap: () => onChanged(isSelected ? null : method),
                  child: card,
                ),
        );
      }).toList(),
    );
  }

  Widget _paymentIcon(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.zaincash => _PayBadge(label: 'Zain Cash', color: Colors.green),
      PaymentMethod.superki => _PayBadge(label: 'SuperKI', color: Colors.blue),
    };
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _PayBadge extends StatelessWidget {
  const _PayBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }
}
