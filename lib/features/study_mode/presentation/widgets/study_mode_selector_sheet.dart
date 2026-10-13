import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/study_mode.dart';

class StudyModeSelectorSheet extends ConsumerWidget {
  const StudyModeSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.bottomSheetRadius,
      ),
      builder: (context) => const StudyModeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(settingsControllerProvider).studyMode;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          bottom: 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  borderRadius: AppShapes.controlRadius,
                ),
                child: const Icon(
                  Icons.sensors,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Modes',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'পড়ার সুবিধানুযায়ী মোড বেছে নিন',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildModeOption(
            context: context,
            ref: ref,
            mode: StudyMode.manual,
            number: '1',
            icon: Icons.touch_app_outlined,
            title: 'Manual Mode',
            bengaliTitle: 'ম্যানুয়াল মোড (নিজে হাতে Start/Stop)',
            description: 'Start and stop manually with on-screen buttons.',
            bengaliDetail: 'পড়া শুরু করলে Start চাপবেন, আর পড়া শেষ হলে Stop চাপবেন।',
            featureBadge: 'সবচেয়ে সহজ ও পরিচিত',
            isSelected: currentMode == StudyMode.manual,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildModeOption(
            context: context,
            ref: ref,
            mode: StudyMode.faceUpOnFaceDownOff,
            number: '2',
            icon: Icons.screen_lock_portrait_outlined,
            title: 'Face-up ON / Face-down OFF',
            bengaliTitle: 'সোজা রাখলে চালু • উল্টো করলে বন্ধ',
            description: 'Screen Up = ON • Flip Down = OFF (Screen stays awake)',
            bengaliDetail: 'স্ক্রিন উপরে থাকলে স্টপওয়াচ চালু, উল্টো করলে বন্ধ। আলো নিভবে না।',
            featureBadge: 'Always-On Display',
            isSelected: currentMode == StudyMode.faceUpOnFaceDownOff,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildModeOption(
            context: context,
            ref: ref,
            mode: StudyMode.flipToOnScreenOff,
            number: '3',
            icon: Icons.phone_android_outlined,
            title: 'Flip to ON / Screen OFF',
            bengaliTitle: 'ফ্লিপ করলে চালু • স্ক্রিন অফ',
            description: 'Flip Down = ON • Screen Up = OFF (Screen can turn off)',
            bengaliDetail: 'ফোন উপুড় করে টেবিল রাখলে পড়াশোনা চালু এবং স্ক্রিনের আলো বন্ধ থাকবে।',
            featureBadge: 'ব্যাটারি সাশ্রয়ী ও গভীর মনোযোগ',
            isSelected: currentMode == StudyMode.flipToOnScreenOff,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Settings থেকেও যেকোনো সময় মোড পরিবর্তন করা যাবে।',
                  style: AppTypography.label.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildModeOption({
    required BuildContext context,
    required WidgetRef ref,
    required StudyMode mode,
    required String number,
    required IconData icon,
    required String title,
    required String bengaliTitle,
    required String description,
    required String bengaliDetail,
    required String featureBadge,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(settingsControllerProvider.notifier).setStudyMode(mode);
        Navigator.pop(context);
      },
      borderRadius: AppShapes.cardRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
          borderRadius: AppShapes.cardRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: AppTypography.statNumber.copyWith(
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.cardTitle.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark.withValues(alpha: 0.4)
                              : AppColors.surfaceElevated,
                          borderRadius: AppShapes.chipRadius,
                        ),
                        child: Text(
                          featureBadge,
                          style: AppTypography.label.copyWith(
                            fontSize: 10,
                            color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bengaliTitle,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bengaliDetail,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

