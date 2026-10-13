import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionCount = ref.watch(todaySessionCountProvider);
    final totalSeconds = ref.watch(todayTotalSecondsProvider);
    final longestSeconds = ref.watch(todayLongestSessionSecondsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildColumn(
              icon: Icons.calendar_today_outlined,
              label: "Today's Sessions",
              value: '$sessionCount ${sessionCount == 1 ? 'Session' : 'Sessions'}',
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildColumn(
              icon: Icons.timelapse_rounded,
              label: 'Total Study',
              value: TimeFormatter.formatDurationHm(totalSeconds),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildColumn(
              icon: Icons.trending_up_rounded,
              label: 'Longest Session',
              value: TimeFormatter.formatDurationHm(longestSeconds),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTypography.label.copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.statNumber.copyWith(fontSize: 14),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
