import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/repositories/study_session_repository.dart';
import '../../../study_mode/domain/study_mode.dart';

class HiveStudySessionRepository implements StudySessionRepository {
  static const String boxName = 'study_sessions_v1';
  final Box _box;

  HiveStudySessionRepository(this._box);

  static Future<HiveStudySessionRepository> create() async {
    final box = await Hive.openBox(boxName);
    final repo = HiveStudySessionRepository(box);
    // Seed initial realistic sessions if first run so user sees rich charts & history
    if (box.isEmpty) {
      await repo._seedInitialSessionsIfEmpty();
    }
    return repo;
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    final List<StudySession> sessions = [];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        try {
          if (data is Map) {
            sessions.add(StudySession.fromJson(Map<String, dynamic>.from(data)));
          } else if (data is String) {
            sessions.add(StudySession.fromJson(jsonDecode(data) as Map<String, dynamic>));
          }
        } catch (_) {
          // Ignore corrupt record
        }
      }
    }
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime)); // Newest first
    return sessions;
  }

  @override
  Future<void> saveSession(StudySession session) async {
    await _box.put(session.id, session.toJson());
  }

  @override
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearAllSessions() async {
    await _box.clear();
  }

  @override
  Future<void> importSessions(List<StudySession> sessions) async {
    final Map<String, dynamic> map = {};
    for (final s in sessions) {
      map[s.id] = s.toJson();
    }
    await _box.putAll(map);
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    final all = await getAllSessions();
    return all.where((s) => s.syncStatus != SyncStatus.synced).toList();
  }

  @override
  Future<void> markSessionsAsSynced(List<String> ids) async {
    final idSet = ids.toSet();
    for (final key in _box.keys) {
      if (idSet.contains(key.toString())) {
        final data = _box.get(key);
        if (data is Map) {
          final session = StudySession.fromJson(Map<String, dynamic>.from(data));
          final updated = session.copyWith(
            syncStatus: SyncStatus.synced,
            updatedAt: DateTime.now(),
          );
          await _box.put(key, updated.toJson());
        }
      }
    }
  }

  @override
  Future<void> markSessionSyncStatus(String id, SyncStatus status) async {
    final data = _box.get(id);
    if (data is Map) {
      final session = StudySession.fromJson(Map<String, dynamic>.from(data));
      final updated = session.copyWith(
        syncStatus: status,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updated.toJson());
    }
  }

  /// Seeds a realistic 30-day study history on first clean run matching the mockup UI
  Future<void> _seedInitialSessionsIfEmpty() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<StudySession> seeds = [];

    // Today's sessions: 3 sessions total 4h 32m (16320 seconds)
    seeds.add(StudySession(
      id: 'seed-today-1',
      startTime: today.add(const Duration(hours: 6, minutes: 45)),
      endTime: today.add(const Duration(hours: 8, minutes: 55)),
      durationSeconds: 7800, // 2h 10m
      mode: StudyMode.manual,
      syncStatus: SyncStatus.synced,
      createdAt: today.add(const Duration(hours: 6, minutes: 45)),
      updatedAt: today.add(const Duration(hours: 8, minutes: 55)),
    ));
    seeds.add(StudySession(
      id: 'seed-today-2',
      startTime: today.add(const Duration(hours: 10, minutes: 0)),
      endTime: today.add(const Duration(hours: 11, minutes: 30)),
      durationSeconds: 5400, // 1h 30m
      mode: StudyMode.faceUpOnFaceDownOff,
      syncStatus: SyncStatus.synced,
      createdAt: today.add(const Duration(hours: 10, minutes: 0)),
      updatedAt: today.add(const Duration(hours: 11, minutes: 30)),
    ));
    seeds.add(StudySession(
      id: 'seed-today-3',
      startTime: today.add(const Duration(hours: 14, minutes: 30)),
      endTime: today.add(const Duration(hours: 15, minutes: 22)),
      durationSeconds: 3120, // 52m
      mode: StudyMode.flipToOnScreenOff,
      syncStatus: SyncStatus.local,
      createdAt: today.add(const Duration(hours: 14, minutes: 30)),
      updatedAt: today.add(const Duration(hours: 15, minutes: 22)),
    ));

    // Previous 29 days realistic pattern
    final dailyHours = [
      2.25, 1.66, 3.16, 2.08, 0.66, 4.5, 3.2, 5.0, 6.2, 8.25, 4.0, 3.5, 2.0, 5.5,
      6.0, 7.5, 3.8, 4.2, 5.1, 2.5, 4.8, 6.5, 3.0, 4.5, 5.2, 3.9, 4.0, 2.8, 4.2
    ];

    for (int i = 0; i < dailyHours.length; i++) {
      final day = today.subtract(Duration(days: i + 1));
      final hours = dailyHours[i];
      final seconds = (hours * 3600).round();
      final startHour = (8 + (i % 6));

      seeds.add(StudySession(
        id: 'seed-past-$i',
        startTime: day.add(Duration(hours: startHour, minutes: 15)),
        endTime: day.add(Duration(hours: startHour, minutes: 15, seconds: seconds)),
        durationSeconds: seconds,
        mode: i % 3 == 0
            ? StudyMode.manual
            : (i % 3 == 1 ? StudyMode.faceUpOnFaceDownOff : StudyMode.flipToOnScreenOff),
        syncStatus: SyncStatus.synced,
        createdAt: day.add(Duration(hours: startHour, minutes: 15)),
        updatedAt: day.add(Duration(hours: startHour, minutes: 15, seconds: seconds)),
      ));
    }

    await importSessions(seeds);
  }
}
