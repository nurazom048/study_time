import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../controllers/auth_controller.dart';

class ClassMasterAccountSheet extends ConsumerStatefulWidget {
  const ClassMasterAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.bottomSheetRadius),
      builder: (context) => const ClassMasterAccountSheet(),
    );
  }

  @override
  ConsumerState<ClassMasterAccountSheet> createState() =>
      _ClassMasterAccountSheetState();
}

class _ClassMasterAccountSheetState
    extends ConsumerState<ClassMasterAccountSheet> {
  final _emailController = TextEditingController(text: 'student@classmaster.app');
  final _passController = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

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
                      color: AppColors.primary,
                      borderRadius: AppShapes.controlRadius,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('ClassMaster Account', style: AppTypography.titleMedium),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (authState.isConnected && authState.user != null) ...[
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
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          authState.user!.name.isNotEmpty
                              ? authState.user!.name[0]
                              : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user!.name,
                              style: AppTypography.cardTitle.copyWith(fontSize: 15),
                            ),
                            Text(
                              authState.user!.email,
                              style: AppTypography.label.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: AppShapes.chipRadius,
                        ),
                        child: Text(
                          'Connected',
                          style: AppTypography.label.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  _rowInfo('Student ID', authState.user!.studentId ?? 'N/A'),
                  _rowInfo('Institution', authState.user!.institution ?? 'ClassMaster Academy'),
                  _rowInfo(
                    'Last Cloud Sync',
                    authState.user!.lastSyncTime != null
                        ? TimeFormatter.formatDateTime(authState.user!.lastSyncTime!)
                        : 'Never',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authNotifier.logout();
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Disconnect Account'),
              ),
            ),
          ] else ...[
            Text(
              'Sign in with your existing ClassMaster account to sync study sessions automatically.',
              style: AppTypography.label.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.controlRadius,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: AppShapes.controlRadius,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authNotifier.login(
                    _emailController.text.trim(),
                    _passController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Connect with ClassMaster'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.label.copyWith(fontSize: 12)),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
