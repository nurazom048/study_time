import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../domain/entities/study_session.dart';

class StudySessionNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    // Fire initial loading
    Future.microtask(() => loadSessions());
    return const [];
  }

  Future<void> loadSessions() async {
    final repo = ref.read(studySessionRepositoryProvider);
    final list = await repo.getAllSessions();
    state = list;
  }

  Future<void> addSession(StudySession session) async {
    final repo = ref.read(studySessionRepositoryProvider);
    await repo.saveSession(session);
    await loadSessions();
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(studySessionRepositoryProvider);
    await repo.deleteSession(id);
    await loadSessions();
  }

  Future<void> clearAll() async {
    final repo = ref.read(studySessionRepositoryProvider);
    await repo.clearAllSessions();
    state = const [];
  }

  Future<void> importSessions(List<StudySession> sessions) async {
    final repo = ref.read(studySessionRepositoryProvider);
    await repo.importSessions(sessions);
    await loadSessions();
  }

  Future<void> markSynced(List<String> ids) async {
    final repo = ref.read(studySessionRepositoryProvider);
    await repo.markSessionsAsSynced(ids);
    await loadSessions();
  }
}

final studySessionControllerProvider =
    NotifierProvider<StudySessionNotifier, List<StudySession>>(
  StudySessionNotifier.new,
);

/// Helper providers for Today's statistics derived from raw sessions
final todaySessionsProvider = Provider<List<StudySession>>((ref) {
  final sessions = ref.watch(studySessionControllerProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return sessions.where((s) {
    final sDay = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
    return sDay == today;
  }).toList();
});

final todayTotalSecondsProvider = Provider<int>((ref) {
  final todaySessions = ref.watch(todaySessionsProvider);
  return todaySessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
});

final todaySessionCountProvider = Provider<int>((ref) {
  return ref.watch(todaySessionsProvider).length;
});

final todayLongestSessionSecondsProvider = Provider<int>((ref) {
  final todaySessions = ref.watch(todaySessionsProvider);
  if (todaySessions.isEmpty) return 0;
  return todaySessions.fold<int>(
    0,
    (max, s) => s.durationSeconds > max ? s.durationSeconds : max,
  );
});
