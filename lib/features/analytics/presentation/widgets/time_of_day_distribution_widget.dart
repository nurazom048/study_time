import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';

class TimeOfDayDistributionWidget extends StatelessWidget {
  final Map<String, int> distribution;

  const TimeOfDayDistributionWidget({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = distribution.values.fold<int>(0, (sum, val) => sum + val);
    final maxSlotSeconds = distribution.values.fold<int>(
      1,
      (max, val) => val > max ? val : max,
    );

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
                  const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Time-of-Day Analysis',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
              Text(
                'Total: ${TimeFormatter.formatDurationHm(totalSeconds)}',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...distribution.entries.map((entry) {
            final seconds = entry.value;
            final percentage = totalSeconds > 0
                ? ((seconds / totalSeconds) * 100).round()
                : 0;
            final ratio = maxSlotSeconds > 0 ? (seconds / maxSlotSeconds) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.label.copyWith(
                          color: seconds > 0
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${TimeFormatter.formatDurationHm(seconds)} ($percentage%)',
                        style: AppTypography.label.copyWith(
                          color: seconds > 0
                              ? AppColors.primaryLight
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight:
                              seconds > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(
                            color: AppColors.surfaceElevated,
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio.clamp(0.0, 1.0),
                            child: Container(
                              color: seconds > 0
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
