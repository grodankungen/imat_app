import 'package:flutter/material.dart';

/// Design tokens for the iMat application.
class AppTheme {
  // Padding scale (matches Tailwind p-2..p-8)
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMediumSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingMediumLarge = 20.0;
  static const double paddingLarge = 24.0;
  static const double paddingHuge = 32.0;

  // Brand greens
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green50 = Color(0xFFF0FDF4);

  // Reds (favorite / destructive)
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);

  // Neutrals
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // Layout sizes
  static const double sidebarWidth = 256.0;
  static const double cartWidth = 384.0;
  static const double headerHeight = 73.0;
  static const double productImageHeight = 130.0;

  // Radii
  static const double radiusSm = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: green600,
    primary: green600,
    surface: Colors.white,
  );

  static ThemeData themeData = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: gray50,
    fontFamily: null,
    useMaterial3: true,
  );
}
