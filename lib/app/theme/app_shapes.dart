import 'package:flutter/material.dart';

/// ClassMaster corner radius and shape constants
class AppShapes {
  AppShapes._();

  static const double rControl = 8.0;
  static const double rChip = 12.0;
  static const double rCard = 16.0;
  static const double rLarge = 20.0;
  static const double rBottomSheet = 24.0;
  static const double rFull = 999.0;

  // BorderRadius objects
  static final BorderRadius controlRadius = BorderRadius.circular(rControl);
  static final BorderRadius chipRadius = BorderRadius.circular(rChip);
  static final BorderRadius cardRadius = BorderRadius.circular(rCard);
  static final BorderRadius largeRadius = BorderRadius.circular(rLarge);
  static final BorderRadius bottomSheetRadius = const BorderRadius.vertical(
    top: Radius.circular(rBottomSheet),
  );
  static final BorderRadius fullRadius = BorderRadius.circular(rFull);
}
