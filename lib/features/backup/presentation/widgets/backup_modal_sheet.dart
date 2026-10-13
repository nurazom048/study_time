import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/backup_controller.dart';

class BackupModalSheet extends ConsumerStatefulWidget {
  const BackupModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.bottomSheetRadius),
      builder: (context) => const BackupModalSheet(),
    );
  }

  @override
  ConsumerState<BackupModalSheet> createState() => _BackupModalSheetState();
}

class _BackupModalSheetState extends ConsumerState<BackupModalSheet> {
  final TextEditingController _importController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupControllerProvider);
    final backupNotifier = ref.read(backupControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      borderRadius: AppShapes.controlRadius,
                    ),
                    child: const Icon(Icons.cloud_sync_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Backup Your Data', style: AppTypography.titleMedium),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your study records safe by backing up to ClassMaster cloud or exporting locally.',
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Cloud Sync Card
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppShapes.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ClassMaster Cloud Backup', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: settings.lastBackupStatus == 'Success'
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2),
                        borderRadius: AppShapes.chipRadius,
                      ),
                      child: Text(
                        settings.lastBackupStatus,
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          color: settings.lastBackupStatus == 'Success'
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  settings.lastBackupDate != null
                      ? 'Last backup: ${TimeFormatter.formatDateTime(settings.lastBackupDate!)}'
                      : 'Never backed up',
                  style: AppTypography.label.copyWith(fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: backupState.isSyncing
                        ? null
                        : () async {
                            await backupNotifier.backupToClassMaster();
                          },
                    icon: backupState.isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(backupState.isSyncing ? 'Syncing...' : 'Sync to ClassMaster'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Message if any
          if (backupState.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                backupState.message!,
                style: AppTypography.label.copyWith(
                  color: backupState.isSuccess ? AppColors.success : AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),

          // Local Export and Restore Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final json = await backupNotifier.exportSessionsJson();
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup JSON copied to clipboard! Save it securely.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export JSON'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isImporting = !_isImporting;
                    });
                  },
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Restore Data'),
                ),
              ),
            ],
          ),

          if (_isImporting) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _importController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste backup JSON here...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.controlRadius,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_importController.text.trim().isNotEmpty) {
                    final count = await backupNotifier.restoreFromJson(_importController.text.trim());
                    if (count > 0 && context.mounted) {
                      _importController.clear();
                      setState(() => _isImporting = false);
                    }
                  }
                },
                child: const Text('Confirm Restore'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}
