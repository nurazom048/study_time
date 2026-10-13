import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class StudyClockApp extends ConsumerWidget {
  const StudyClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches settings (can adapt themeMode if needed)
    ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'Study Clock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
