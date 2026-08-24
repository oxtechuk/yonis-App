import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../core/storage/preferences_storage.dart';

Future<void> showLanguageSwitcherSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _LanguageOptionList(),
  );
}

class _LanguageOptionList extends StatelessWidget {
  const _LanguageOptionList();

  @override
  Widget build(BuildContext context) {
    final current = context.locale;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              context.tr(LocaleKeys.settings_language),
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final locale in context.supportedLocales)
            _LanguageOption(
              locale: locale,
              isSelected: current.languageCode == locale.languageCode,
              onTap: () => _selectLanguage(context, locale),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _selectLanguage(BuildContext context, Locale locale) async {
    final navigator = Navigator.of(context);
    if (context.locale.languageCode != locale.languageCode) {
      await context.setLocale(locale);
      await getIt<PreferencesStorage>().setString(
        PreferencesKeys.languageCode,
        locale.languageCode,
      );
    }
    navigator.pop();
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = locale.languageCode == 'ar'
        ? context.tr(LocaleKeys.settings_arabic)
        : context.tr(LocaleKeys.settings_english);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
