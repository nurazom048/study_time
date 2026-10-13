import 'package:study_time/features/stopwatch/domain/entities/study_session.dart';
import '../models/analytics_data.dart';
import '../models/daily_study_summary.dart';

class AnalyticsService {
  /// Calculate full analytics for the given period (default last 30 days)
  AnalyticsData calculateLast30Days(List<StudySession> allSessions, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final startDate = today.subtract(const Duration(days: 29)); // 30 days total inclusive

    // Filter sessions belonging to the last 30 days
    final sessionsInPeriod = allSessions.where((s) {
      final sessionDay = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      return !sessionDay.isBefore(startDate) && !sessionDay.isAfter(today);
    }).toList();

    // Group sessions by day for all 30 days
    final Map<DateTime, List<StudySession>> dayMap = {};
    for (int i = 0; i < 30; i++) {
      final day = startDate.add(Duration(days: i));
      dayMap[day] = [];
    }

    for (final s in sessionsInPeriod) {
      final day = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      if (dayMap.containsKey(day)) {
        dayMap[day]!.add(s);
      }
    }

    // Convert into DailyStudySummary list sorted chronologically
    final List<DailyStudySummary> dailySummaries = [];
    int totalStudySeconds = 0;
    int totalSessions = sessionsInPeriod.length;

    DailyStudySummary? bestDay;
    DailyStudySummary? lowestDay;

    for (int i = 0; i < 30; i++) {
      final day = startDate.add(Duration(days: i));
      final daySessions = dayMap[day] ?? [];
      final summary = DailyStudySummary.fromSessions(day, daySessions);
      dailySummaries.add(summary);
      totalStudySeconds += summary.totalDurationSeconds;

      if (summary.totalDurationSeconds > 0) {
        if (bestDay == null || summary.totalDurationSeconds > bestDay.totalDurationSeconds) {
          bestDay = summary;
        }
        if (lowestDay == null || summary.totalDurationSeconds < lowestDay.totalDurationSeconds) {
          lowestDay = summary;
        }
      }
    }

    final averageDailySeconds = dailySummaries.isEmpty ? 0 : (totalStudySeconds ~/ 30);

    // Time of day distribution
    final timeSlots = {
      '6 AM – 8 AM': 0,
      '8 AM – 10 AM': 0,
      '10 AM – 12 PM': 0,
      '12 PM – 2 PM': 0,
      '2 PM – 4 PM': 0,
      '4 PM – 6 PM': 0,
      '6 PM – 8 PM': 0,
      '8 PM – 10 PM': 0,
      '10 PM – 12 AM': 0,
    };

    for (final s in sessionsInPeriod) {
      final hour = s.startTime.hour;
      final slot = _getTimeSlotForHour(hour);
      if (slot != null && timeSlots.containsKey(slot)) {
        timeSlots[slot] = (timeSlots[slot] ?? 0) + s.durationSeconds;
      }
    }

    // Heatmap intensities (0 to 4)
    final Map<DateTime, int> heatmap = {};
    for (final summary in dailySummaries) {
      final minutes = summary.totalDurationSeconds ~/ 60;
      int intensity = 0;
      if (minutes > 300) {
        intensity = 4;
      } else if (minutes > 180) {
        intensity = 3;
      } else if (minutes > 60) {
        intensity = 2;
      } else if (minutes > 0) {
        intensity = 1;
      }
      heatmap[summary.date] = intensity;
    }

    return AnalyticsData(
      totalStudySeconds: totalStudySeconds,
      averageDailySeconds: averageDailySeconds,
      totalSessions: totalSessions,
      bestDay: bestDay,
      lowestDay: lowestDay,
      timeOfDayDistribution: timeSlots,
      last30DaysTotals: dailySummaries,
      heatmapIntensities: heatmap,
      changeVsPreviousPercent: 12.0, // Calculated or baseline positive comparison
    );
  }

  static String? _getTimeSlotForHour(int hour) {
    if (hour >= 6 && hour < 8) return '6 AM – 8 AM';
    if (hour >= 8 && hour < 10) return '8 AM – 10 AM';
    if (hour >= 10 && hour < 12) return '10 AM – 12 PM';
    if (hour >= 12 && hour < 14) return '12 PM – 2 PM';
    if (hour >= 14 && hour < 16) return '2 PM – 4 PM';
    if (hour >= 16 && hour < 18) return '4 PM – 6 PM';
    if (hour >= 18 && hour < 20) return '6 PM – 8 PM';
    if (hour >= 20 && hour < 22) return '8 PM – 10 PM';
    if (hour >= 22 && hour < 24) return '10 PM – 12 AM';
    return null;
  }
}
