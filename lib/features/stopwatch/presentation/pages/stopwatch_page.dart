import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/sensor_service.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../study_mode/domain/study_mode.dart';
import '../../../study_mode/presentation/widgets/study_mode_selector_sheet.dart';
import '../controllers/stopwatch_controller.dart';
import '../controllers/study_session_controller.dart';

class StopwatchPage extends ConsumerWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(stopwatchControllerProvider);
    final stopwatchController = ref.read(stopwatchControllerProvider.notifier);
    final todayTotalSeconds = ref.watch(todayTotalSecondsProvider);
    final todaySessions = ref.watch(todaySessionCountProvider);
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Study Stopwatch', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: 12,
          ),
          child: Column(
            children: [
              // Study Mode Pill
              InkWell(
                onTap: () => StudyModeSelectorSheet.show(context),
                borderRadius: AppShapes.chipRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppShapes.chipRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        timerState.mode == StudyMode.manual
                            ? Icons.touch_app_outlined
                            : Icons.sensors,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timerState.mode.compactLabel,
                        style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main Circular Progress Timer Display
              _buildCircularTimer(timerState),
              const SizedBox(height: 32),

              // Action Buttons
              _buildControlButtons(timerState, stopwatchController),
              const SizedBox(height: 32),

              // Sensor Mode Info & Live Status
              if (timerState.mode != StudyMode.manual)
                _buildSensorStatusCard(context, timerState, stopwatchController),
              if (timerState.mode != StudyMode.manual)
                const SizedBox(height: AppSpacing.md),

              // Today's Total and Sessions Row
              Container(
                padding: AppSpacing.cardInsets,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppShapes.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timelapse_rounded,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text("Today's Total", style: AppTypography.label),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeFormatter.formatDurationHm(todayTotalSeconds),
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.view_timeline_outlined,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text('Sessions', style: AppTypography.label),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$todaySessions ${todaySessions == 1 ? 'session' : 'sessions'}',
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Daily Goal info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppShapes.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Today's Goal: ${settings.dailyGoalMinutes ~/ 60}h (${((todayTotalSeconds / (settings.dailyGoalMinutes * 60)) * 100).clamp(0, 100).round()}%)",
                        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularTimer(StopwatchState state) {
    final elapsed = state.elapsedSeconds;
    // Circular seconds sweep progress
    final double sweepProgress = (elapsed % 60) / 60.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer subtle glow ring
          CustomPaint(
            size: const Size(260, 260),
            painter: _StopwatchDialPainter(
              progress: state.isRunning ? sweepProgress : 0.0,
              isActive: state.isRunning,
              isPaused: state.isPaused,
            ),
          ),
          // Timer Text Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeFormatter.formatDurationHms(elapsed),
                style: AppTypography.timerDisplayLarge.copyWith(fontSize: 40),
              ),
              const SizedBox(height: 6),
              Text(
                'Current Session',
                style: AppTypography.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              // Status Indicator Pill
              _buildLiveStatusPill(state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusPill(StopwatchState state) {
    Color dotColor = AppColors.textMuted;
    String text = 'READY';
    Color bg = AppColors.surfaceElevated;

    if (state.isRunning) {
      dotColor = AppColors.success;
      text = 'STUDYING';
      bg = AppColors.success.withValues(alpha: 0.18);
    } else if (state.isPaused) {
      dotColor = AppColors.warning;
      text = 'PAUSED';
      bg = AppColors.warning.withValues(alpha: 0.18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppShapes.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.label.copyWith(
              color: dotColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    StopwatchState state,
    StopwatchController controller,
  ) {
    if (state.isStopped) {
      return SizedBox(
        width: 220,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => controller.startTimer(),
          icon: const Icon(Icons.play_arrow_rounded, size: 24),
          label: const Text('Start Studying'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppShapes.controlRadius,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause or Resume button
        SizedBox(
          width: 170,
          height: 52,
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
              size: 22,
            ),
            label: Text(
              state.isRunning ? 'Pause' : 'Resume',
              style: AppTypography.cardTitle.copyWith(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  state.isRunning ? AppColors.primary : AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppShapes.controlRadius,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Stop button
        InkWell(
          onTap: () async {
            await controller.stopTimer();
          },
          borderRadius: AppShapes.controlRadius,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppShapes.controlRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: AppColors.error,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorStatusCard(
    BuildContext context,
    StopwatchState state,
    StopwatchController controller,
  ) {
    final isFaceUp = state.currentOrientation == DeviceOrientationState.faceUp;
    final isFaceDown = state.currentOrientation == DeviceOrientationState.faceDown;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sensor Detection Active',
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppShapes.chipRadius,
                ),
                child: Text(
                  state.currentOrientation.label,
                  style: AppTypography.label.copyWith(
                    color: isFaceUp || isFaceDown
                        ? AppColors.primaryLight
                        : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.mode == StudyMode.faceUpOnFaceDownOff
                ? 'Mode 2: Screen UP = Studying (Always-on) • Flip DOWN = Paused'
                : 'Mode 3: Flip DOWN = Studying (Screen off) • Screen UP = Paused',
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          // Simulator buttons for testing
          Row(
            children: [
              Text(
                'Test flip:',
                style: AppTypography.label.copyWith(fontSize: 11),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () =>
                    controller.simulateOrientation(DeviceOrientationState.faceUp),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  side: BorderSide(
                    color: isFaceUp ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  'Face UP',
                  style: TextStyle(
                    fontSize: 11,
                    color: isFaceUp ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () =>
                    controller.simulateOrientation(DeviceOrientationState.faceDown),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  side: BorderSide(
                    color: isFaceDown ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  'Face DOWN',
                  style: TextStyle(
                    fontSize: 11,
                    color: isFaceDown ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopwatchDialPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final bool isPaused;

  _StopwatchDialPainter({
    required this.progress,
    required this.isActive,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (isActive || isPaused) {
      final sweepAngle = 2 * pi * (progress == 0 ? 0.05 : progress);
      final activePaint = Paint()
        ..color = isPaused ? AppColors.warning : AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StopwatchDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isPaused != isPaused;
  }
}
