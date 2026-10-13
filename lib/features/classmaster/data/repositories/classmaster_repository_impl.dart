import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/classmaster_user.dart';
import '../../domain/repositories/classmaster_repository.dart';
import '../../../stopwatch/domain/entities/study_session.dart';

class ClassMasterRepositoryImpl implements ClassMasterRepository {
  static const String configBoxName = 'classmaster_config_v1';
  static const String defaultBaseUrl = String.fromEnvironment(
    'CLASSMASTER_API_URL',
    defaultValue: 'https://api.classmaster.app/v1',
  );

  final Box _box;
  final String baseUrl;

  ClassMasterRepositoryImpl(this._box, {this.baseUrl = defaultBaseUrl});

  static Future<ClassMasterRepositoryImpl> create() async {
    final box = await Hive.openBox(configBoxName);
    final repo = ClassMasterRepositoryImpl(box);
    // Seed logged-in user matching mockup if not set
    if (!box.containsKey('currentUser')) {
      final defaultUser = ClassMasterUser(
        id: 'usr_cm_9824',
        name: 'Nur Azom',
        email: 'student@classmaster.app',
        studentId: 'CM-2026-88',
        institution: 'ClassMaster Academy',
        lastSyncTime: DateTime.now().subtract(const Duration(minutes: 42)),
      );
      await box.put('currentUser', defaultUser.toJson());
      await box.put('isConnected', true);
    }
    return repo;
  }

  @override
  Future<ClassMasterUser?> getCurrentUser() async {
    final data = _box.get('currentUser');
    if (data != null && data is Map) {
      return ClassMasterUser.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<ClassMasterUser> login(String email, String password) async {
    // In production, performs http.post('$baseUrl/auth/login', ...)
    final user = ClassMasterUser(
      id: 'usr_cm_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      studentId: 'CM-STU-01',
      lastSyncTime: DateTime.now(),
    );
    await _box.put('currentUser', user.toJson());
    await _box.put('isConnected', true);
    return user;
  }

  @override
  Future<void> logout() async {
    await _box.delete('currentUser');
    await _box.put('isConnected', false);
  }

  @override
  Future<bool> uploadStudySessions(List<StudySession> sessions) async {
    try {
      debugPrint('[ClassMaster] Uploading ${sessions.length} sessions to $baseUrl/study-sessions/sync');
      // Network call simulation or real endpoint if backend available
      await Future.delayed(const Duration(milliseconds: 650));
      final user = await getCurrentUser();
      if (user != null) {
        final updatedUser = user.copyWith(lastSyncTime: DateTime.now());
        await _box.put('currentUser', updatedUser.toJson());
      }
      await _box.put('lastBackupDate', DateTime.now().toIso8601String());
      await _box.put('lastBackupStatus', 'Success');
      return true;
    } catch (e) {
      debugPrint('[ClassMaster] Upload failed: $e');
      await _box.put('lastBackupStatus', 'Failed');
      return false;
    }
  }

  @override
  Future<List<StudySession>> fetchStudySessions() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSyncStatus() async {
    final user = await getCurrentUser();
    final lastBackup = _box.get('lastBackupDate') as String?;
    final lastStatus = _box.get('lastBackupStatus') as String? ?? 'Success';
    return {
      'isConnected': user != null,
      'user': user,
      'lastSyncTime': user?.lastSyncTime,
      'lastBackupDate': lastBackup != null ? DateTime.parse(lastBackup) : null,
      'lastBackupStatus': lastStatus,
    };
  }
}
