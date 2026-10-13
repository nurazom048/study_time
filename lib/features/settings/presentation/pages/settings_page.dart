import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/app_logo_badge.dart';
import '../../../backup/presentation/widgets/backup_modal_sheet.dart';
import '../../../classmaster/presentation/controllers/auth_controller.dart';
import '../../../classmaster/presentation/widgets/classmaster_account_sheet.dart';
import '../../../study_mode/presentation/widgets/study_mode_selector_sheet.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleLarge.copyWith(fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(
              settings.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              settingsNotifier.toggleDarkMode(!settings.isDarkMode);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Branding Card (Matching Image 3 Mockup!)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppShapes.cardRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const AppLogoBadge(size: 44),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Clock',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Study Smarter, Achieve More',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppShapes.chipRadius,
                      ),
                      child: Text(
                        'Version 1.0.0',
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION: ACCOUNT
              _buildSectionHeader('Account'),
              const SizedBox(height: AppSpacing.sm),
              _buildSettingCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppShapes.controlRadius,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    'ClassMaster Integration',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: authState.isConnected
                              ? AppColors.success
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          authState.isConnected
                              ? 'Connected • Last sync: ${authState.user?.lastSyncTime != null ? TimeFormatter.formatDateTime(authState.user!.lastSyncTime!) : 'Recent'}'
                              : 'Not connected',
                          style: AppTypography.label.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => ClassMasterAccountSheet.show(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION: APP PREFERENCES
              _buildSectionHeader('App Preferences'),
              const SizedBox(height: AppSpacing.sm),
              _buildSettingCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                      title: Text(
                        'Study Mode',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        settings.studyMode.displayName,
                        style: AppTypography.label.copyWith(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => StudyModeSelectorSheet.show(context),
                    ),
                    const Divider(indent: 52),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                      title: Text(
                        'Notifications',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Study reminders & alerts',
                        style: AppTypography.label.copyWith(fontSize: 12),
                      ),
                      value: settings.notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        settingsNotifier.toggleNotifications(val);
                      },
                    ),
                    const Divider(indent: 52),
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                      title: Text(
                        'Dark Mode',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Easier on your eyes',
                        style: AppTypography.label.copyWith(fontSize: 12),
                      ),
                      value: settings.isDarkMode,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        settingsNotifier.toggleDarkMode(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION: BACKUP & DATA
              _buildSectionHeader('Backup & Data'),
              const SizedBox(height: AppSpacing.sm),
              _buildSettingCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                      title: Text(
                        'Backup Your Data',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Keep your study data safe. Sync with ClassMaster',
                        style: AppTypography.label.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => BackupModalSheet.show(context),
                    ),
                    const Divider(indent: 52),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_toggle_off_rounded,
                                  size: 20, color: AppColors.textMuted),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Last Backup',
                                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    settings.lastBackupDate != null
                                        ? TimeFormatter.formatDateTime(settings.lastBackupDate!)
                                        : 'Never',
                                    style: AppTypography.label.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: settings.lastBackupStatus == 'Success'
                                  ? AppColors.success.withValues(alpha: 0.18)
                                  : AppColors.error.withValues(alpha: 0.18),
                              borderRadius: AppShapes.chipRadius,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  settings.lastBackupStatus == 'Success'
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  size: 13,
                                  color: settings.lastBackupStatus == 'Success'
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  settings.lastBackupStatus,
                                  style: AppTypography.label.copyWith(
                                    color: settings.lastBackupStatus == 'Success'
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(indent: 52),
                    ListTile(
                      leading: const Icon(Icons.storage_rounded, color: AppColors.primary),
                      title: Text(
                        'Data Management',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Export / import your study data',
                        style: AppTypography.label.copyWith(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => BackupModalSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION: ABOUT
              _buildSectionHeader('About'),
              const SizedBox(height: AppSpacing.sm),
              _buildSettingCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                      title: Text('About', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                      subtitle: Text('App information & help', style: AppTypography.label.copyWith(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(indent: 52),
                    ListTile(
                      leading: const Icon(Icons.star_outline_rounded, color: AppColors.textSecondary),
                      title: Text('Rate & Share', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                      subtitle: Text('Support us with your feedback', style: AppTypography.label.copyWith(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for rating Study Clock! ⭐⭐⭐⭐⭐'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // SECTION: ACCOUNT ACTION (LOG OUT)
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: Text(
                    'Log Out',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Disconnect from ClassMaster',
                    style: AppTypography.label.copyWith(
                      color: AppColors.error.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    await authNotifier.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Disconnected from ClassMaster.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.label.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.0,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppShapes.cardRadius),
          title: Row(
            children: [
              const AppLogoBadge(size: 32),
              const SizedBox(width: AppSpacing.md),
              const Text('Study Clock'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Clock is a student study-time tracking application built for focused learning and academic excellence.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text('Version: 1.0.0 (Production Build)', style: AppTypography.label),
              Text('Powered by ClassMaster Platform', style: AppTypography.label),
              const SizedBox(height: 12),
              Text('Offline-First Architecture with Hive database and sensor mode.',
                  style: AppTypography.label.copyWith(color: AppColors.primaryLight)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
