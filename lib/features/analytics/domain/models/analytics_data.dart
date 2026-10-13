import 'daily_study_summary.dart';

class AnalyticsData {
  final int totalStudySeconds;
  final int averageDailySeconds;
  final int totalSessions;
  final DailyStudySummary? bestDay;
  final DailyStudySummary? lowestDay;
  final Map<String, int> timeOfDayDistribution; // Time slot -> seconds studied
  final List<DailyStudySummary> last30DaysTotals;
  final Map<DateTime, int> heatmapIntensities; // Date -> 0..4 intensity
  final double changeVsPreviousPercent;

  AnalyticsData({
    required this.totalStudySeconds,
    required this.averageDailySeconds,
    required this.totalSessions,
    this.bestDay,
    this.lowestDay,
    required this.timeOfDayDistribution,
    required this.last30DaysTotals,
    required this.heatmapIntensities,
    this.changeVsPreviousPercent = 0.0,
  });

  factory AnalyticsData.empty() {
    return AnalyticsData(
      totalStudySeconds: 0,
      averageDailySeconds: 0,
      totalSessions: 0,
      bestDay: null,
      lowestDay: null,
      timeOfDayDistribution: {
        '6 AM – 8 AM': 0,
        '8 AM – 10 AM': 0,
        '10 AM – 12 PM': 0,
        '12 PM – 2 PM': 0,
        '2 PM – 4 PM': 0,
        '4 PM – 6 PM': 0,
        '6 PM – 8 PM': 0,
        '8 PM – 10 PM': 0,
        '10 PM – 12 AM': 0,
      },
      last30DaysTotals: const [],
      heatmapIntensities: const {},
      changeVsPreviousPercent: 0.0,
    );
  }
}
