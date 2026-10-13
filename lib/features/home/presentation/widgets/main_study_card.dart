import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../stopwatch/presentation/controllers/stopwatch_controller.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';

class MainStudyCard extends ConsumerWidget {
  const MainStudyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(stopwatchControllerProvider);
    final stopwatchNotifier = ref.read(stopwatchControllerProvider.notifier);
    final todayTotalSeconds = ref.watch(todayTotalSecondsProvider);

    // If timer is running or paused, display current session elapsed time; otherwise today's total study
    final displaySeconds = (timerState.isRunning || timerState.isPaused)
        ? timerState.elapsedSeconds
        : todayTotalSeconds;

    return InkWell(
      onTap: () {
        context.push('/stopwatch');
      },
      borderRadius: AppShapes.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.cardRadius,
          border: Border.all(
            color: timerState.isRunning ? AppColors.primary : AppColors.border,
            width: timerState.isRunning ? 1.5 : 1.0,
          ),
          boxShadow: timerState.isRunning
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: timerState.isRunning
                            ? AppColors.primaryDark.withValues(alpha: 0.3)
                            : AppColors.surfaceElevated,
                        borderRadius: AppShapes.controlRadius,
                      ),
                      child: Icon(
                        Icons.timer_outlined,
                        color: timerState.isRunning ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timerState.isRunning
                              ? 'Current Session'
                              : "Today's Study",
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        Text(
                          timerState.mode.compactLabel,
                          style: AppTypography.label.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status badge
                _buildStatusBadge(timerState),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Big visually dominant timer display
            Text(
              TimeFormatter.formatDurationHms(displaySeconds),
              style: AppTypography.timerDisplayLarge.copyWith(
                color: timerState.isRunning
                    ? Colors.white
                    : (timerState.isPaused ? AppColors.warning : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timerState.isRunning
                  ? 'Tap card to open full stopwatch'
                  : 'Total tracked today: ${TimeFormatter.formatDurationHm(todayTotalSeconds)}',
              style: AppTypography.label.copyWith(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Control Buttons
            _buildActionButtons(context, timerState, stopwatchNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StopwatchState state) {
    Color dotColor = AppColors.textMuted;
    String label = 'Idle';
    Color bg = AppColors.surfaceElevated;

    if (state.isRunning) {
      dotColor = AppColors.success;
      label = 'Studying';
      bg = AppColors.success.withValues(alpha: 0.15);
    } else if (state.isPaused) {
      dotColor = AppColors.warning;
      label = 'Paused';
      bg = AppColors.warning.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppShapes.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: dotColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    StopwatchState state,
    StopwatchController controller,
  ) {
    if (state.isStopped) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            controller.startTimer();
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('Start Studying'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: AppShapes.controlRadius,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Primary button (Pause or Resume)
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: () {
              if (state.isRunning) {
                controller.pauseTimer();
              } else {
                controller.resumeTimer();
              }
            },
            icon: Icon(
              state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 20,
            ),
            label: Text(state.isRunning ? 'Pause' : 'Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  state.isRunning ? AppColors.primary : AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppShapes.controlRadius,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Secondary Stop button
        InkWell(
          onTap: () async {
            await controller.stopTimer();
          },
          borderRadius: AppShapes.controlRadius,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppShapes.controlRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
