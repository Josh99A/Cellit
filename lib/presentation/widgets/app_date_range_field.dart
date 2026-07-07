import 'package:flutter/material.dart';

import '../../core/themes/app_sizes.dart';
import '../../core/utilities/date_time_formatter.dart';

class AppDateRangeField extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTimeRange> onChanged;

  const AppDateRangeField({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  void onTapField(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) onChanged(picked);
  }

  void _onTapPreset(_DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final range = switch (preset) {
      _DateRangePreset.today => DateTimeRange(start: today, end: today),
      _DateRangePreset.thisWeek => DateTimeRange(
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today,
      ),
      _DateRangePreset.thisMonth => DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: today,
      ),
    };

    onChanged(range);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          onTap: () => onTapField(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding,
              vertical: AppSizes.padding / 1.5,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                width: 0.5,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateTimeFormatter.slashDate(startDate.toIso8601String())} - ${DateTimeFormatter.slashDate(endDate.toIso8601String())}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Row(
          children: _DateRangePreset.values.map((preset) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.padding / 2),
              child: ActionChip(
                label: Text(preset.label),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                visualDensity: VisualDensity.compact,
                onPressed: () => _onTapPreset(preset),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum _DateRangePreset {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month');

  final String label;
  const _DateRangePreset(this.label);
}
