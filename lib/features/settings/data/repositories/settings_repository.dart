import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_time/features/settings/domain/models/app_settings.dart';

class SettingsRepository {
  static const String boxName = 'app_settings_box_v1';
  static const String keySettings = 'settings';
  final Box _box;

  SettingsRepository(this._box);

  static Future<SettingsRepository> create() async {
    final box = await Hive.openBox(boxName);
    return SettingsRepository(box);
  }

  AppSettings getSettings() {
    final data = _box.get(keySettings);
    if (data != null && data is Map) {
      try {
        return AppSettings.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {}
    }
    // Default initial settings
    return AppSettings(
      lastBackupDate: DateTime.now().subtract(const Duration(hours: 3)),
      lastBackupStatus: 'Success',
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(keySettings, settings.toJson());
  }
}
