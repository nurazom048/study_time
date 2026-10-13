import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../controllers/motivation_controller.dart';

class MotivationCard extends ConsumerWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(motivationControllerProvider);

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🕌',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'আজকের অনুপ্রেরণা',
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppShapes.chipRadius,
                ),
                child: Text(
                  item.type.displayName,
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '"${item.text}"',
            style: AppTypography.bengaliMotivation,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${item.source} (${item.reference})',
              style: AppTypography.bengaliSource,
            ),
          ),
        ],
      ),
    );
  }
}
