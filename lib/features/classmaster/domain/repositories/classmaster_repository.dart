import '../../../stopwatch/domain/entities/study_session.dart';
import '../models/classmaster_user.dart';

abstract class ClassMasterRepository {
  Future<ClassMasterUser?> getCurrentUser();
  Future<ClassMasterUser> login(String email, String password);
  Future<void> logout();
  Future<bool> uploadStudySessions(List<StudySession> sessions);
  Future<List<StudySession>> fetchStudySessions();
  Future<Map<String, dynamic>> getSyncStatus();
}
