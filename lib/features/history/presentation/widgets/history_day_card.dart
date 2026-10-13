import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../analytics/domain/models/daily_study_summary.dart';
import '../../../stopwatch/domain/entities/study_session.dart';

class HistoryDayCard extends StatelessWidget {
  final DailyStudySummary summary;

  const HistoryDayCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final dayNum = TimeFormatter.formatDayNumber(summary.date);
    final weekday = TimeFormatter.formatWeekday(summary.date);
    final count = summary.sessionCount;
    final totalHm = TimeFormatter.formatDurationHm(summary.totalDurationSeconds);

    return InkWell(
      onTap: () => _showDayDetailSheet(context),
      borderRadius: AppShapes.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left Date Box
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppShapes.controlRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNum,
                    style: AppTypography.statNumber.copyWith(fontSize: 18),
                  ),
                  Text(
                    weekday,
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Middle session summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count ${count == 1 ? 'session' : 'sessions'} • $totalHm',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: summary.totalDurationSeconds > 0
                              ? AppColors.success
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        summary.firstStudyTime != null
                            ? '${TimeFormatter.formatTime(summary.firstStudyTime!)} – ${TimeFormatter.formatTime(summary.lastStudyTime!)}'
                            : 'No sessions',
                        style: AppTypography.label.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right total and chevron
            Row(
              children: [
                Text(
                  totalHm,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 14,
                    color: summary.totalDurationSeconds > 0
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.bottomSheetRadius),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TimeFormatter.formatDate(summary.date),
                      style: AppTypography.titleMedium,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _statChip(
                      'Total Study',
                      TimeFormatter.formatDurationHm(summary.totalDurationSeconds),
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      'Sessions',
                      '${summary.sessionCount}',
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      'Longest',
                      TimeFormatter.formatDurationHm(summary.longestSessionSeconds),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Sessions Breakdown',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (summary.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No sessions recorded for this day',
                        style: AppTypography.label),
                  )
                else
                  ...summary.sessions.map((s) => _buildSessionTile(s)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppShapes.controlRadius,
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.label.copyWith(fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: AppTypography.statNumber.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(StudySession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppShapes.controlRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${TimeFormatter.formatTime(session.startTime)} – ${session.endTime != null ? TimeFormatter.formatTime(session.endTime!) : 'In progress'}',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  ),
                  Text(
                    'Mode: ${session.mode.compactLabel}',
                    style: AppTypography.label.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Text(
            TimeFormatter.formatDurationHm(session.durationSeconds),
            style: AppTypography.statNumber.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
