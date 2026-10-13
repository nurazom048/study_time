import '../../../stopwatch/domain/entities/study_session.dart';

class DailyStudySummary {
  final DateTime date;
  final int totalDurationSeconds;
  final int sessionCount;
  final int longestSessionSeconds;
  final DateTime? firstStudyTime;
  final DateTime? lastStudyTime;
  final List<StudySession> sessions;

  DailyStudySummary({
    required this.date,
    required this.totalDurationSeconds,
    required this.sessionCount,
    required this.longestSessionSeconds,
    this.firstStudyTime,
    this.lastStudyTime,
    required this.sessions,
  });

  factory DailyStudySummary.fromSessions(DateTime date, List<StudySession> daySessions) {
    if (daySessions.isEmpty) {
      return DailyStudySummary(
        date: date,
        totalDurationSeconds: 0,
        sessionCount: 0,
        longestSessionSeconds: 0,
        firstStudyTime: null,
        lastStudyTime: null,
        sessions: const [],
      );
    }

    final sorted = List<StudySession>.from(daySessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    int totalSeconds = 0;
    int longest = 0;

    for (final s in sorted) {
      totalSeconds += s.durationSeconds;
      if (s.durationSeconds > longest) {
        longest = s.durationSeconds;
      }
    }

    return DailyStudySummary(
      date: DateTime(date.year, date.month, date.day),
      totalDurationSeconds: totalSeconds,
      sessionCount: sorted.length,
      longestSessionSeconds: longest,
      firstStudyTime: sorted.first.startTime,
      lastStudyTime: sorted.last.endTime ?? sorted.last.startTime,
      sessions: sorted,
    );
  }
}
