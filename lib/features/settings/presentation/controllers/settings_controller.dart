import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../study_mode/domain/study_mode.dart';
import '../../domain/models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> setStudyMode(StudyMode mode) async {
    state = state.copyWith(studyMode: mode);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> setDailyGoalMinutes(int minutes) async {
    state = state.copyWith(dailyGoalMinutes: minutes);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    state = state.copyWith(isDarkMode: enabled);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> updateBackupStatus({
    required DateTime date,
    required String status,
  }) async {
    state = state.copyWith(lastBackupDate: date, lastBackupStatus: status);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
