import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_skeleton.dart';
import '../../domain/entities/time_slot.dart';

/// Section label with a primary accent bar + compact 3-per-row grid of
/// start-time chips (raw API value, e.g. "09:00") in its own 3-row
/// vertical scroller.
///
/// Renders whichever of [isLoading], [errorMessage] or [slots] applies —
/// exactly one of these describes the current fetch state for the selected
/// day.
class BookingTimeSlotsSection extends StatefulWidget {
  const BookingTimeSlotsSection({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final ValueChanged<TimeSlot> onSelected;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  State<BookingTimeSlotsSection> createState() =>
      _BookingTimeSlotsSectionState();
}

class _BookingTimeSlotsSectionState extends State<BookingTimeSlotsSection> {
  static const _columns = 3;
  static const _visibleRows = 3;

  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            Text(
              context.tr(LocaleKeys.timeSlots_title),
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.isLoading) {
      return const TimeSlotsSkeleton();
    }

    if (widget.errorMessage != null) {
      return Column(
        children: [
          Text(
            widget.errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              label: Text(
                context.tr(LocaleKeys.timeSlots_retry),
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      );
    }

    final slots = widget.slots;
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            context.tr(LocaleKeys.timeSlots_empty),
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Compact 3-per-row grid showing the raw start time exactly as the
    // API returns it (e.g. "09:00") — no synthesized start-end range.
    // Own vertical scroller capped at 3 visible rows; extra slots scroll
    // inside the box instead of pushing the page down. A persistent
    // scrollbar thumb + bottom fade/chevron hint (only when more rows
    // exist) signal that the box scrolls.
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight =
            (constraints.maxWidth - 2 * AppSpacing.sm) / _columns / 2.8;
        final height = _visibleRows * rowHeight +
            (_visibleRows - 1) * AppSpacing.sm;
        final hasMore = slots.length > _columns * _visibleRows;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(2),
                child: GridView.count(
                  controller: _scrollController,
                  crossAxisCount: _columns,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.8,
                  children: slots.map((slot) {
                    final isSelected = slot == widget.selected;
                    return GestureDetector(
                      onTap: () => widget.onSelected(slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: AppRadius.allLg,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot.start,
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Scroll hint below the box (never overlapping the chips),
            // only when more rows exist.
            if (hasMore) ...[
              const SizedBox(height: 2),
              const _ScrollHintChevron(),
            ],
          ],
        );
      },
    );
  }
}

/// Bouncing down-chevron pill hinting that more time slots lie below.
class _ScrollHintChevron extends StatefulWidget {
  const _ScrollHintChevron();

  @override
  State<_ScrollHintChevron> createState() => _ScrollHintChevronState();
}

class _ScrollHintChevronState extends State<_ScrollHintChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<Offset> _nudge = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 0.3),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SlideTransition(
        position: _nudge,
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
