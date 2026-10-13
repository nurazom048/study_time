import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';

class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotalSeconds = ref.watch(todayTotalSecondsProvider);
    final settings = ref.watch(settingsControllerProvider);
    final goalSeconds = settings.dailyGoalMinutes * 60;

    final progressRatio = goalSeconds > 0
        ? (todayTotalSeconds / goalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).round();

    final currentHm = TimeFormatter.formatDurationHm(todayTotalSeconds);
    final goalHm = '${settings.dailyGoalMinutes ~/ 60}h';

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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppShapes.controlRadius,
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Daily Goal',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$currentHm / $goalHm',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 7,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressRatio >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
