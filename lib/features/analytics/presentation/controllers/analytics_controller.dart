import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../stopwatch/presentation/controllers/study_session_controller.dart';
import '../../domain/models/analytics_data.dart';

final analyticsControllerProvider = Provider<AnalyticsData>((ref) {
  final allSessions = ref.watch(studySessionControllerProvider);
  final service = ref.watch(analyticsServiceProvider);

  if (allSessions.isEmpty) {
    return AnalyticsData.empty();
  }

  return service.calculateLast30Days(allSessions);
});
