import '../entities/study_session.dart';

abstract class StudySessionRepository {
  Future<List<StudySession>> getAllSessions();
  Future<void> saveSession(StudySession session);
  Future<void> deleteSession(String id);
  Future<void> clearAllSessions();
  Future<void> importSessions(List<StudySession> sessions);
  Future<List<StudySession>> getUnsyncedSessions();
  Future<void> markSessionsAsSynced(List<String> ids);
  Future<void> markSessionSyncStatus(String id, SyncStatus status);
}
