import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/session.dart';

const _cardRadius = 16.0;
const _buttonRadius = BorderRadius.all(Radius.circular(AppRadius.lg));
const _buttonPadding = EdgeInsets.symmetric(vertical: 14);

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    this.showActions = false,
  });

  final Session session;
  final bool showActions;

  Color get _statusBackground => switch (session.status) {
        SessionStatus.upcoming => const Color(0xFFFFF8E1),
        SessionStatus.completed => const Color(0xFFE8F5E9),
        SessionStatus.cancelled => const Color(0xFFFFEBEE),
      };

  Color get _statusForeground => switch (session.status) {
        SessionStatus.upcoming => const Color(0xFFB8860B),
        SessionStatus.completed => AppColors.success,
        SessionStatus.cancelled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        // Gold accent on the right (RTL leading edge = right)
        border: const Border(
          right: BorderSide(color: AppColors.secondary, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        // start = right in RTL context
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(
            label: session.statusLabel,
            background: _statusBackground,
            foreground: _statusForeground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.title,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                session.doctor,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SessionInfoBox(session: session),
          if (showActions) ...[
            const SizedBox(height: AppSpacing.md),
            const _SessionActions(),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SessionInfoBox extends StatelessWidget {
  const _SessionInfoBox({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          // التاريخ — right side visually (first child in RTL)
          Expanded(
            child: _InfoCell(
              icon: Icons.calendar_today_outlined,
              label: 'التاريخ',
              value: Text(
                session.date,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 44, color: AppColors.border),
          // الوقت — left side visually
          Expanded(
            child: _InfoCell(
              icon: Icons.access_time_rounded,
              label: 'الوقت',
              value: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.time,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '(${session.duration})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            value,
          ],
        ),
      ],
    );
  }
}

class _SessionActions extends StatelessWidget {
  const _SessionActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // إعادة جدولة on the right, إلغاء on the left
        Expanded(
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const RoundedRectangleBorder(borderRadius: _buttonRadius),
              padding: _buttonPadding,
            ),
            child: Text(
              'إعادة جدولة',
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: const RoundedRectangleBorder(borderRadius: _buttonRadius),
              padding: _buttonPadding,
            ),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
