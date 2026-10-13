import 'package:flutter_test/flutter_test.dart';
import 'package:study_time/features/analytics/domain/services/analytics_service.dart';
import 'package:study_time/features/stopwatch/domain/entities/study_session.dart';
import 'package:study_time/features/study_mode/domain/study_mode.dart';

void main() {
  test('AnalyticsService calculates study session stats correctly', () {
    final service = AnalyticsService();
    final now = DateTime(2026, 10, 13, 14, 0);

    final sessions = [
      StudySession(
        id: '1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now,
        durationSeconds: 7200, // 2 hours
        mode: StudyMode.manual,
        syncStatus: SyncStatus.synced,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now,
      ),
      StudySession(
        id: '2',
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1)),
        durationSeconds: 10800, // 3 hours
        mode: StudyMode.faceUpOnFaceDownOff,
        syncStatus: SyncStatus.local,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    final analytics = service.calculateLast30Days(sessions, now: now);

    expect(analytics.totalStudySeconds, 18000); // 5 hours total
    expect(analytics.totalSessions, 2);
    expect(analytics.bestDay, isNotNull);
    expect(analytics.bestDay!.totalDurationSeconds, 10800);
  });
}
