import 'package:study_time/features/study_mode/domain/study_mode.dart';

enum SyncStatus {
  local,
  pending,
  synced,
  failed;

  static SyncStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SYNCED':
        return SyncStatus.synced;
      case 'PENDING':
        return SyncStatus.pending;
      case 'FAILED':
        return SyncStatus.failed;
      case 'LOCAL':
      default:
        return SyncStatus.local;
    }
  }

  String toStorageString() {
    switch (this) {
      case SyncStatus.synced:
        return 'SYNCED';
      case SyncStatus.pending:
        return 'PENDING';
      case SyncStatus.failed:
        return 'FAILED';
      case SyncStatus.local:
        return 'LOCAL';
    }
  }
}

class StudySession {
  final String id;
  final String? userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final StudyMode mode;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudySession({
    required this.id,
    this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.mode,
    this.syncStatus = SyncStatus.local,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Date normalized to year, month, day
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  StudySession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    StudyMode? mode,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mode: mode ?? this.mode,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'studyMode': mode.toStorageString(),
      'syncStatus': syncStatus.toStorageString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      mode: StudyMode.fromString(json['studyMode'] as String? ?? 'MANUAL'),
      syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'LOCAL'),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
