import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_text_styles.dart';
import 'country_code.dart';

/// Tappable flag + dial-code prefix for phone fields.
///
/// Tap it to open a searchable bottom-sheet country picker.
/// Pass [selected] and [onChanged] to control the selected country.
class PhoneCountryPicker extends StatelessWidget {
  const PhoneCountryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _showPicker(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: AppSpacing.sm),
            Text(selected.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              selected.dialCode,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
            Container(width: 1, height: 24, color: AppColors.border),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: selected,
        onSelected: (c) {
          Navigator.of(context).pop();
          onChanged(c);
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late List<CountryCode> _filtered;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = kCountryCodes;
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = kCountryCodes
          .where((c) =>
              c.name.toLowerCase().contains(lower) ||
              c.dialCode.contains(lower) ||
              c.localizedName(context).toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _search,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'common.searchCountry'.tr(),
                  hintStyle: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final isSelected = c.isoCode == widget.selected.isoCode;
                  return ListTile(
                    leading: Text(c.flag,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(c.localizedName(context),
                        style: AppTextStyles.body),
                    trailing: Text(
                      c.dialCode,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    selectedTileColor: AppColors.cardTint,
                    onTap: () => widget.onSelected(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
