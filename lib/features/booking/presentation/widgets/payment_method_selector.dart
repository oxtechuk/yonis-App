import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/bootstrap_icon_mapper.dart';
import '../../domain/entities/payment_method_option.dart';

/// Selectable list of payment methods, driven entirely by the backend
/// `/api/payment-methods` payload (id, localized name, brand colour, icon).
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selected,
    required this.onChanged,
    this.locked = false,
  });

  final List<PaymentMethodOption> methods;
  final PaymentMethodOption? selected;
  final ValueChanged<PaymentMethodOption?> onChanged;

  /// When true (a method is confirmed), every non-selected method is
  /// visibly disabled and non-tappable. The selected card stays tappable
  /// so the user can still deselect it.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Column(
      children: methods.map((method) {
        final isSelected = method.id == selected?.id;
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
              _PayBadge(method: method),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.nameFor(isArabic),
                      style: AppTextStyles.body.copyWith(
                        color: isDisabled
                            ? AppColors.textSecondary.withValues(alpha: 0.6)
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (method.badge != null &&
                        method.badge!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        method.badge!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
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

/// Brand chip: the method's logo/image when the backend sends one,
/// otherwise its Bootstrap icon tinted with its brand colour.
class _PayBadge extends StatelessWidget {
  const _PayBadge({required this.method});
  final PaymentMethodOption method;

  Color get _color {
    final hex = method.color?.replaceFirst('#', '').trim();
    if (hex != null && (hex.length == 6 || hex.length == 8)) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(hex.length == 6 ? 0xFF000000 | value : value);
      }
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = method.logo?.isNotEmpty == true
        ? method.logo
        : (method.image?.isNotEmpty == true ? method.image : null);
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: AppRadius.allMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => _icon(),
            )
          : _icon(),
    );
  }

  Widget _icon() => Icon(
        bootstrapIconToMaterial(method.iconClass, isClinic: false),
        color: _color,
        size: 22,
      );
}
