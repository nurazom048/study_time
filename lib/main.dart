import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/theme/app_colors.dart';
import 'features/classmaster/data/repositories/classmaster_repository_impl.dart';
import 'features/settings/data/repositories/settings_repository.dart';
import 'features/stopwatch/data/repositories/hive_study_session_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style to match ClassMaster dark aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline-first Hive storage
  await Hive.initFlutter();

  // Pre-open and prepare repositories
  final sessionRepo = await HiveStudySessionRepository.create();
  final settingsRepo = await SettingsRepository.create();
  final classMasterRepo = await ClassMasterRepositoryImpl.create();

  runApp(
    ProviderScope(
      overrides: [
        studySessionRepositoryProvider.overrideWithValue(sessionRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        classMasterRepositoryProvider.overrideWithValue(classMasterRepo),
      ],
      child: const StudyClockApp(),
    ),
  );
}
