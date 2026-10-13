import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Colors.white.withValues(alpha: 0.35),
              size: size * 0.65,
            ),
            Icon(
              Icons.access_time_filled_rounded,
              color: Colors.white,
              size: size * 0.52,
            ),
          ],
        ),
      ),
    );
  }
}
