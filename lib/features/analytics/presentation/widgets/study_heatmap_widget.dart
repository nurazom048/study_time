import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shapes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class StudyHeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> heatmapIntensities;

  const StudyHeatmapWidget({super.key, required this.heatmapIntensities});

  Color _getColorForLevel(int level) {
    switch (level) {
      case 1:
        return AppColors.heatLevel1;
      case 2:
        return AppColors.heatLevel2;
      case 3:
        return AppColors.heatLevel3;
      case 4:
        return AppColors.heatLevel4;
      case 0:
      default:
        return AppColors.heatLevel0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = heatmapIntensities.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '30-Day Study Heatmap',
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  Text('Less', style: AppTypography.label.copyWith(fontSize: 10)),
                  const SizedBox(width: 4),
                  ...List.generate(5, (index) {
                    return Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: _getColorForLevel(index),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  Text('More', style: AppTypography.label.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid of 30 days (6 columns x 5 rows or 10 cols x 3 rows)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sortedEntries.map((entry) {
              final level = entry.value;
              return Tooltip(
                message:
                    '${entry.key.day}/${entry.key.month}: ${_levelDescription(level)}',
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getColorForLevel(level),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: level > 0
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${entry.key.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: level > 0 ? FontWeight.w600 : FontWeight.w400,
                      color: level >= 2 ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _levelDescription(int level) {
    switch (level) {
      case 4:
        return '5+ hours';
      case 3:
        return '3–5 hours';
      case 2:
        return '1–3 hours';
      case 1:
        return '< 1 hour';
      case 0:
      default:
        return 'No study';
    }
  }
}
