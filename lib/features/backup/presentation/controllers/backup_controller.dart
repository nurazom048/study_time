import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../stopwatch/domain/entities/study_session.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';

class BackupState {
  final bool isSyncing;
  final String? message;
  final bool isSuccess;

  const BackupState({
    this.isSyncing = false,
    this.message,
    this.isSuccess = true,
  });

  BackupState copyWith({
    bool? isSyncing,
    String? message,
    bool? isSuccess,
  }) {
    return BackupState(
      isSyncing: isSyncing ?? this.isSyncing,
      message: message ?? this.message,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class BackupNotifier extends Notifier<BackupState> {
  @override
  BackupState build() => const BackupState();

  /// Syncs only unsynced sessions to ClassMaster
  Future<bool> backupToClassMaster() async {
    state = state.copyWith(isSyncing: true, message: null);

    final sessionRepo = ref.read(studySessionRepositoryProvider);
    final classMasterRepo = ref.read(classMasterRepositoryProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final sessionNotifier = ref.read(studySessionControllerProvider.notifier);

    try {
      final unsynced = await sessionRepo.getUnsyncedSessions();
      if (unsynced.isEmpty) {
        final now = DateTime.now();
        await settingsNotifier.updateBackupStatus(date: now, status: 'Success');
        state = const BackupState(
          isSyncing: false,
          isSuccess: true,
          message: 'All sessions are already synced with ClassMaster.',
        );
        return true;
      }

      for (final s in unsynced) {
        await sessionRepo.markSessionSyncStatus(s.id, SyncStatus.pending);
      }

      final success = await classMasterRepo.uploadStudySessions(unsynced);
      final now = DateTime.now();

      if (success) {
        await sessionRepo.markSessionsAsSynced(unsynced.map((e) => e.id).toList());
        await sessionNotifier.loadSessions();
        await settingsNotifier.updateBackupStatus(date: now, status: 'Success');
        state = BackupState(
          isSyncing: false,
          isSuccess: true,
          message: 'Synced ${unsynced.length} sessions to ClassMaster successfully!',
        );
        return true;
      } else {
        for (final s in unsynced) {
          await sessionRepo.markSessionSyncStatus(s.id, SyncStatus.failed);
        }
        await settingsNotifier.updateBackupStatus(date: now, status: 'Failed');
        state = const BackupState(
          isSyncing: false,
          isSuccess: false,
          message: 'Failed to sync with ClassMaster. Please retry.',
        );
        return false;
      }
    } catch (e) {
      await settingsNotifier.updateBackupStatus(
        date: DateTime.now(),
        status: 'Failed',
      );
      state = BackupState(
        isSyncing: false,
        isSuccess: false,
        message: 'Sync error: $e',
      );
      return false;
    }
  }

  /// Exports all sessions as a formatted JSON string
  Future<String> exportSessionsJson() async {
    final sessionRepo = ref.read(studySessionRepositoryProvider);
    final all = await sessionRepo.getAllSessions();
    final list = all.map((s) => s.toJson()).toList();
    final data = {
      'app': 'Study Clock',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'sessionsCount': list.length,
      'sessions': list,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restores sessions from a JSON string
  Future<int> restoreFromJson(String jsonContent) async {
    state = state.copyWith(isSyncing: true, message: null);
    final sessionRepo = ref.read(studySessionRepositoryProvider);
    final sessionNotifier = ref.read(studySessionControllerProvider.notifier);

    try {
      final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
      final rawList = decoded['sessions'] as List<dynamic>? ?? [];
      final List<StudySession> sessions = [];
      for (final item in rawList) {
        sessions.add(StudySession.fromJson(Map<String, dynamic>.from(item as Map)));
      }
      await sessionRepo.importSessions(sessions);
      await sessionNotifier.loadSessions();

      state = BackupState(
        isSyncing: false,
        isSuccess: true,
        message: 'Successfully restored ${sessions.length} sessions.',
      );
      return sessions.length;
    } catch (e) {
      state = const BackupState(
        isSyncing: false,
        isSuccess: false,
        message: 'Restore failed: Invalid JSON format.',
      );
      return 0;
    }
  }
}

final backupControllerProvider =
    NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);
