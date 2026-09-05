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
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethod.values.map((method) {
        final isSelected = method == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => onChanged(method),
            child: AnimatedContainer(
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _RadioDot(selected: isSelected),
                ],
              ),
            ),
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

/// Mini card-network badges (Mastercard / VISA / mada).
class _CardIcons extends StatelessWidget {
  const _CardIcons();

  // Network brand colors — one-off, specific to these badges.
  static const Color _mastercardRed = Color(0xFFEB001B);
  static const Color _visaBlue = Color(0xFF003087);
  static const Color _madaGreen = Color(0xFF00A551);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniCard(color: _mastercardRed),
        const SizedBox(width: 3),
        const _MiniCard(
          color: _visaBlue,
          text: 'VISA',
          textColor: Colors.white,
        ),
        const SizedBox(width: 3),
        const _MiniCard(
          color: _madaGreen,
          text: 'mada',
          textColor: Colors.white,
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.color, this.text, this.textColor});
  final Color color;
  final String? text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: text != null
          ? Center(
              child: Text(
                text!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }
}
