import 'package:flutter/material.dart';

/// 8-point spacing system specified by ClassMaster Design System
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Layout standard paddings
  static const double screenHorizontal = 18.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 12.0;

  // Standard EdgeInsets shortcuts
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: lg,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardInsetsCompact = EdgeInsets.all(cardPaddingCompact);
}
