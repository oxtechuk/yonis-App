import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_text_styles.dart';
import 'primary_button.dart';

/// Sign-in gate shared by login-protected tabs (sessions, profile).
///
/// Shown when there is no usable token: an icon, an already-localized
/// [message], and a full-width button that routes to login via [onLogin].
class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({
    super.key,
    required this.message,
    required this.onLogin,
    required this.loginLabel,
    this.icon = Icons.calendar_month_outlined,
  });

  final String message;
  final VoidCallback onLogin;
  final String loginLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: loginLabel, onPressed: onLogin),
            ),
          ],
        ),
      ),
    );
  }
}
