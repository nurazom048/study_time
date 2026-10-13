import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/sensor_service.dart';
import '../core/services/wakelock_service.dart';
import '../core/services/notification_service.dart';
import '../features/analytics/domain/services/analytics_service.dart';
import '../features/classmaster/domain/repositories/classmaster_repository.dart';
import '../features/motivation/data/motivation_repository.dart';
import '../features/settings/data/repositories/settings_repository.dart';
import '../features/stopwatch/domain/repositories/study_session_repository.dart';

/// Singletons & Repositories overridden at startup in main.dart
final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  throw UnimplementedError('studySessionRepositoryProvider not initialized');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider not initialized');
});

final classMasterRepositoryProvider = Provider<ClassMasterRepository>((ref) {
  throw UnimplementedError('classMasterRepositoryProvider not initialized');
});

final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  ref.onDispose(() => service.dispose());
  return service;
});

final wakelockServiceProvider = Provider<WakelockService>((ref) {
  return WakelockService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final motivationRepositoryProvider = Provider<MotivationRepository>((ref) {
  return MotivationRepository();
});
