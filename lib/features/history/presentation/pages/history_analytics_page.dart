import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../analytics/domain/models/analytics_data.dart';
import '../../../analytics/domain/models/daily_study_summary.dart';
import '../../../analytics/presentation/controllers/analytics_controller.dart';
import '../../../analytics/presentation/widgets/daily_study_bar_chart.dart';
import '../../../analytics/presentation/widgets/study_heatmap_widget.dart';
import '../../../analytics/presentation/widgets/time_of_day_distribution_widget.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';
import '../widgets/history_day_card.dart';

class HistoryAnalyticsPage extends ConsumerStatefulWidget {
  const HistoryAnalyticsPage({super.key});

  @override
  ConsumerState<HistoryAnalyticsPage> createState() => _HistoryAnalyticsPageState();
}

class _HistoryAnalyticsPageState extends ConsumerState<HistoryAnalyticsPage> {
  int _selectedTabIndex = 0; // 0: History, 1: Analytics
  DateTime _currentHistoryMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    final analyticsData = ref.watch(analyticsControllerProvider);
    final allSessions = ref.watch(studySessionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('History & Analytics', style: AppTypography.titleLarge.copyWith(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing month: ${TimeFormatter.formatMonthYear(_currentHistoryMonth)}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Control: [ History ] [ Analytics ]
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 8,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppShapes.controlRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton(
                        label: 'History',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _buildSegmentButton(
                        label: 'Analytics',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tab View
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildHistoryView(allSessions)
                  : _buildAnalyticsView(analyticsData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 14,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HISTORY TAB
  // ==========================================
  Widget _buildHistoryView(dynamic allSessions) {
    // Group sessions by day for current selected month
    final monthSessions = (allSessions as List).where((s) {
      return s.startTime.year == _currentHistoryMonth.year &&
          s.startTime.month == _currentHistoryMonth.month;
    }).toList();

    // Map by day
    final Map<int, List<dynamic>> daysMap = {};
    for (final s in monthSessions) {
      daysMap.putIfAbsent(s.startTime.day, () => []).add(s);
    }

    final sortedDays = daysMap.keys.toList()..sort((a, b) => b.compareTo(a)); // Newest day first

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 8,
      ),
      child: Column(
        children: [
          // Month navigation: < October 2026 >
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppShapes.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _currentHistoryMonth = DateTime(
                        _currentHistoryMonth.year,
                        _currentHistoryMonth.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  TimeFormatter.formatMonthYear(_currentHistoryMonth),
                  style: AppTypography.titleMedium.copyWith(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _currentHistoryMonth = DateTime(
                        _currentHistoryMonth.year,
                        _currentHistoryMonth.month + 1,
                        1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (sortedDays.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No study sessions in this month', style: AppTypography.cardTitle),
                  const SizedBox(height: 4),
                  Text('Track sessions from Home or Stopwatch', style: AppTypography.label),
                ],
              ),
            )
          else
            ...sortedDays.map((day) {
              final dayDate = DateTime(
                _currentHistoryMonth.year,
                _currentHistoryMonth.month,
                day,
              );
              final daySessions = daysMap[day]!.cast<dynamic>();
              final summary = DailyStudySummary.fromSessions(dayDate, daySessions.cast());
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HistoryDayCard(summary: summary),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // ANALYTICS TAB
  // ==========================================
  Widget _buildAnalyticsView(AnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Overall Progress - Last 30 Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Overall Progress', style: AppTypography.titleMedium.copyWith(fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppShapes.chipRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      'Last 30 Days',
                      style: AppTypography.label.copyWith(color: AppColors.textPrimary, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 3 Metric Cards: Total Study Time | Sessions | Average / Day
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_rounded,
                  label: 'Total Study Time',
                  value: TimeFormatter.formatDurationHm(data.totalStudySeconds),
                  changeText: '↑ 12%',
                  comparisonLabel: 'vs previous 30 days',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Sessions',
                  value: '${data.totalSessions}',
                  changeText: '↑ 5%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.calendar_view_week_rounded,
                  label: 'Average / Day',
                  value: TimeFormatter.formatDurationHm(data.averageDailySeconds),
                  changeText: '↑ 8%',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bar Chart: Daily Study Time (Last 30 days)
          DailyStudyBarChart(dailySummaries: data.last30DaysTotals),
          const SizedBox(height: AppSpacing.lg),

          // 2 Cards Row: Best Day & Lowest Day
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  title: 'Best Day',
                  value: data.bestDay != null
                      ? TimeFormatter.formatDurationHm(data.bestDay!.totalDurationSeconds)
                      : '0m',
                  subtext: data.bestDay != null
                      ? TimeFormatter.formatDate(data.bestDay!.date)
                      : 'None',
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.warning,
                  iconBg: AppColors.warning.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildHighlightCard(
                  title: 'Lowest Day',
                  value: data.lowestDay != null
                      ? TimeFormatter.formatDurationHm(data.lowestDay!.totalDurationSeconds)
                      : '0m',
                  subtext: data.lowestDay != null
                      ? TimeFormatter.formatDate(data.lowestDay!.date)
                      : 'None',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.error,
                  iconBg: AppColors.error.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Time-of-Day Analysis
          TimeOfDayDistributionWidget(distribution: data.timeOfDayDistribution),
          const SizedBox(height: AppSpacing.lg),

          // 30-Day Study Heatmap
          StudyHeatmapWidget(heatmapIntensities: data.heatmapIntensities),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String changeText,
    String? comparisonLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.statNumber.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                changeText,
                style: AppTypography.label.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (comparisonLabel != null) ...[
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    comparisonLabel,
                    style: AppTypography.label.copyWith(fontSize: 8),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppShapes.controlRadius,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.statNumber.copyWith(fontSize: 15)),
                Text(
                  subtext,
                  style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
