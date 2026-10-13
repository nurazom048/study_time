import 'package:study_time/features/study_mode/domain/study_mode.dart';

class AppSettings {
  final StudyMode studyMode;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final DateTime? lastBackupDate;
  final String lastBackupStatus;

  const AppSettings({
    this.studyMode = StudyMode.manual,
    this.dailyGoalMinutes = 360, // 6 hours
    this.notificationsEnabled = true,
    this.isDarkMode = true,
    this.lastBackupDate,
    this.lastBackupStatus = 'Success',
  });

  AppSettings copyWith({
    StudyMode? studyMode,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    bool? isDarkMode,
    DateTime? lastBackupDate,
    String? lastBackupStatus,
  }) {
    return AppSettings(
      studyMode: studyMode ?? this.studyMode,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastBackupStatus: lastBackupStatus ?? this.lastBackupStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studyMode': studyMode.toStorageString(),
      'dailyGoalMinutes': dailyGoalMinutes,
      'notificationsEnabled': notificationsEnabled,
      'isDarkMode': isDarkMode,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'lastBackupStatus': lastBackupStatus,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      studyMode: StudyMode.fromString(json['studyMode'] as String? ?? 'MANUAL'),
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 360,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? true,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
      lastBackupStatus: json['lastBackupStatus'] as String? ?? 'Success',
    );
  }
}
