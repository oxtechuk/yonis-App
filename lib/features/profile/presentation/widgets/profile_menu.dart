import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/localization/locale_direction.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../domain/entities/app_config_links.dart';
import 'language_switcher_sheet.dart';

/// Opens [rawUrl] in the external browser / store app.
/// Shows a generic error only when every launch mode fails.
Future<void> openExternalLink(BuildContext context, String rawUrl) async {
  final url = rawUrl.trim();
  debugPrint('[profile] open link: "$url"');
  if (url.isEmpty) {
    debugPrint('[profile] open link aborted: empty url');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    debugPrint('[profile] open link aborted: invalid uri "$url"');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
    return;
  }
  try {
    // externalApplication first (store / browser app). Some devices /
    // emulators have no handler for it, so fall back to the platform
    // default and finally an in-app web view before giving up.
    var launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    debugPrint('[profile] externalApplication result: $launched');
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      debugPrint('[profile] platformDefault result: $launched');
    }
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      debugPrint('[profile] inAppWebView result: $launched');
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
  } catch (e) {
    debugPrint('[profile] open link failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.onLogout,
    this.configLinks = AppConfigLinks.fallback,
  });

  final VoidCallback onLogout;

  /// Links from `GET /api/config`:
  /// - rateApp -> [AppConfigLinks.appRatingUrl]
  /// - privacyPolicy -> [AppConfigLinks.privacyPolicyUrl]
  /// - dataPrivacy -> [AppConfigLinks.termsDisplayUrl]
  final AppConfigLinks configLinks;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.star_border_rounded,
            label: context.tr(LocaleKeys.profile_rateApp),
            onTap: () => openExternalLink(context, configLinks.appRatingUrl),
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.article_outlined,
            label: context.tr(LocaleKeys.profile_privacyPolicy),
            onTap: () =>
                openExternalLink(context, configLinks.privacyPolicyUrl),
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.menu_book_outlined,
            label: context.tr(LocaleKeys.profile_dataPrivacy),
            onTap: () =>
                openExternalLink(context, configLinks.termsDisplayUrl),
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.language_rounded,
            label: context.tr(LocaleKeys.settings_language),
            onTap: () => showLanguageSwitcherSheet(context),
          ),
          const _MenuDivider(),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: context.tr(LocaleKeys.profile_logout),
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.textPrimary;
    final iColor = iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            // Leading icon — right side visually (first child in RTL)
            Icon(icon, color: iColor, size: 22),
            const SizedBox(width: AppSpacing.sm),
            // Label
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            // Trailing chevron — points toward the trailing edge per locale.
            const Spacer(),
            Icon(
              context.isRtl ? Icons.chevron_left : Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
    );
  }
}
