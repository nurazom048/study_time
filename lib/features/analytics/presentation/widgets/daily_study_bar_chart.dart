import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/models/daily_study_summary.dart';

class DailyStudyBarChart extends StatefulWidget {
  final List<DailyStudySummary> dailySummaries;

  const DailyStudyBarChart({super.key, required this.dailySummaries});

  @override
  State<DailyStudyBarChart> createState() => _DailyStudyBarChartState();
}

class _DailyStudyBarChartState extends State<DailyStudyBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.dailySummaries.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text('No data recorded yet', style: AppTypography.label),
      );
    }

    final maxSeconds = widget.dailySummaries.fold<int>(
      3600 * 4, // Minimum 4 hours axis
      (max, d) => d.totalDurationSeconds > max ? d.totalDurationSeconds : max,
    );
    final maxHours = (maxSeconds / 3600).ceil();

    DailyStudySummary? selectedSummary;
    if (_selectedIndex != null &&
        _selectedIndex! >= 0 &&
        _selectedIndex! < widget.dailySummaries.length) {
      selectedSummary = widget.dailySummaries[_selectedIndex!];
    }

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Daily Study Time', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                ],
              ),
              if (selectedSummary != null)
                Text(
                  '${selectedSummary.date.day} ${_monthName(selectedSummary.date.month)}: ${(selectedSummary.totalDurationSeconds / 3600).toStringAsFixed(1)}h',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${maxHours}h', style: AppTypography.label.copyWith(fontSize: 10)),
                    Text('${(maxHours / 2).round()}h',
                        style: AppTypography.label.copyWith(fontSize: 10)),
                    Text('0h', style: AppTypography.label.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                // Chart bars area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = widget.dailySummaries.length;
                      final availableWidth = constraints.maxWidth;
                      final barWidth = ((availableWidth - (count * 2)) / count).clamp(4.0, 10.0);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(count, (index) {
                          final summary = widget.dailySummaries[index];
                          final heightFactor = maxSeconds > 0
                              ? (summary.totalDurationSeconds / maxSeconds).clamp(0.04, 1.0)
                              : 0.04;
                          final isSelected = _selectedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Tooltip(
                              message:
                                  '${summary.date.day} ${_monthName(summary.date.month)}: ${(summary.totalDurationSeconds / 3600).toStringAsFixed(1)}h',
                              child: Container(
                                width: barWidth,
                                height: constraints.maxHeight * heightFactor,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : (summary.totalDurationSeconds > 0
                                          ? AppColors.primary
                                          : AppColors.surfaceElevated),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis date milestones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20), // Y-axis offset
              Text(
                '${widget.dailySummaries.first.date.day} ${_monthName(widget.dailySummaries.first.date.month)}',
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
              Text(
                '${widget.dailySummaries[widget.dailySummaries.length ~/ 2].date.day} ${_monthName(widget.dailySummaries[widget.dailySummaries.length ~/ 2].date.month)}',
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
              Text(
                '${widget.dailySummaries.last.date.day} ${_monthName(widget.dailySummaries.last.date.month)}',
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}
