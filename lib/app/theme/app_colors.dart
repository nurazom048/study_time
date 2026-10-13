import 'package:flutter/material.dart';

/// ClassMaster Design System Colors for Study Clock
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // Secondary
  static const Color secondary = Color(0xFF4F46E5); // Indigo Accent

  // Status Colors
  static const Color success = Color(0xFF16A34A); // Green (Active studying / success)
  static const Color successDark = Color(0xFF15803D);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626); // Red (Destructive / low-study)
  static const Color errorLight = Color(0xFFFEE2E2);

  // Dark Theme Colors (ClassMaster Dark Navy theme)
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF111827); // Gray 900
  static const Color surfaceVariant = Color(0xFF1E293B); // Slate 800
  static const Color surfaceElevated = Color(0xFF243046);
  static const Color border = Color(0xFF334155); // Slate 700
  static const Color borderLight = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Chart & Heatmap Intensity Colors
  static const Color heatLevel0 = Color(0xFF1E293B);
  static const Color heatLevel1 = Color(0xFF1E3A8A);
  static const Color heatLevel2 = Color(0xFF2563EB);
  static const Color heatLevel3 = Color(0xFF3B82F6);
  static const Color heatLevel4 = Color(0xFF60A5FA);
}
