import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_radius.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';

/// Elevated white card with a month grid. Sunday-first columns, RTL layout.
/// Days outside the focused month and past days render as plain numbers;
/// the rest are selectable tiles.
class BookingCalendarCard extends StatelessWidget {
  const BookingCalendarCard({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  // RTL order: Sunday … Saturday (right → left visually).
  static const _weekDays = ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  static const _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _monthLabel() =>
      '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

  // Build a rectangular 6-row × 7-col grid, padding the edges with
  // trailing/leading days of adjacent months — matching the design.
  List<_DayCell> _buildCells() {
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final daysInPrevMonth =
        DateTime(focusedMonth.year, focusedMonth.month, 0).day;

    // weekday: Mon=1…Sun=7. We want Sunday as column 0.
    final startCol = firstOfMonth.weekday % 7; // Sun→0, Mon→1 … Sat→6

    final cells = <_DayCell>[];

    for (var i = startCol - 1; i >= 0; i--) {
      cells.add(_DayCell(
        date: DateTime(
          focusedMonth.year,
          focusedMonth.month - 1,
          daysInPrevMonth - i,
        ),
      ));
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, d);
      cells.add(_DayCell(
        date: date,
        isCurrentMonth: true,
        isPast: date.isBefore(todayOnly),
        isToday: date == todayOnly,
      ));
    }

    var trailing = 1;
    while (cells.length % 7 != 0) {
      cells.add(_DayCell(
        date: DateTime(focusedMonth.year, focusedMonth.month + 1, trailing++),
      ));
    }

    return cells;
  }

  bool _isSelected(DateTime d) =>
      selectedDate != null &&
      d.year == selectedDate!.year &&
      d.month == selectedDate!.month &&
      d.day == selectedDate!.day;

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.allXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _monthLabel(),
            style: AppTextStyles.headline.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: _weekDays
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(cells.length ~/ 7, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: List.generate(7, (col) {
                  final cell = cells[row * 7 + col];
                  return Expanded(
                    child: _DayTile(
                      cell: cell,
                      isSelected: _isSelected(cell.date),
                      onTap: (!cell.isCurrentMonth || cell.isPast)
                          ? null
                          : () => onDaySelected(cell.date),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayCell {
  const _DayCell({
    required this.date,
    this.isCurrentMonth = false,
    this.isPast = false,
    this.isToday = false,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isPast;
  final bool isToday;
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.cell,
    required this.isSelected,
    this.onTap,
  });

  final _DayCell cell;
  final bool isSelected;
  final VoidCallback? onTap;

  // Light blue-grey tile background matching the design.
  static const Color _tileBg = Color(0xFFEAEDF5);

  @override
  Widget build(BuildContext context) {
    // Days outside current month / past days: plain grey number, no tile.
    if (!cell.isCurrentMonth || cell.isPast) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '${cell.date.day}',
            style: AppTextStyles.body.copyWith(
              color: !cell.isCurrentMonth
                  ? AppColors.border
                  : AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    // Selectable days — rounded-square tile.
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : _tileBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${cell.date.day}',
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? AppColors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
