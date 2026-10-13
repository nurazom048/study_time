import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_logo_badge.dart';
import '../../../motivation/presentation/widgets/motivation_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/home_study_mode_card.dart';
import '../widgets/main_study_card.dart';
import '../widgets/today_summary_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Study Clock + Notification Icon (NO greeting text!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogoBadge(size: 34),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Study Clock',
                        style: AppTypography.titleLarge.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Study notifications are active.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 1. Main Study Timer Card
              const MainStudyCard(),
              const SizedBox(height: AppSpacing.lg),

              // 2. Daily Goal
              const DailyGoalCard(),
              const SizedBox(height: AppSpacing.md),

              // 3. Study Mode Selector Row
              const HomeStudyModeCard(),
              const SizedBox(height: AppSpacing.md),

              // 4. Today's Motivation
              const MotivationCard(),
              const SizedBox(height: AppSpacing.md),

              // 5. Today Summary
              const TodaySummaryCard(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
