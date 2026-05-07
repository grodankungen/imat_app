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

  // Brand green
  static const Color primary = Color(0xFF16A34A);
  static const Color primarySurface = Color(0xFFF0FDF4);

  // Favorite
  static const Color favorite = Color(0xFFDC2626);
  static const Color favoriteSurface = Color(0xFFFEF2F2);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPrimary = Color(0xFF374151);
  static const Color black = Color(0xFF111827);

  // Layout sizes
  static const double sidebarWidth = 256.0;
  static const double cartWidth = 384.0;
  static const double headerHeight = 73.0;
  static const double productImageHeight = 130.0;

  // Font sizes
  static const double fontSizeXxs  = 12.0; // tiny labels
  static const double fontSizeXs   = 13.0; // small secondary text
  static const double fontSizeXs2  = 14.0; // slightly larger secondary
  static const double fontSizeSm   = 20.0; // category label on card, button text
  static const double fontSizeBase = 16.0; // body / list items
  static const double fontSizeMd   = 25.0; // product name on card
  static const double fontSizeLg   = 18.0; // nav buttons, cart items, search
  static const double fontSizeXl   = 20.0; // prices, sidebar section headers
  static const double fontSize2xl  = 21.0; // quantity button glyphs
  static const double fontSize3xl  = 22.0; // order item totals
  static const double fontSize4xl  = 24.0; // panel / sidebar headers
  static const double fontSize5xl  = 28.0; // modal titles
  static const double fontSize6xl  = 40.0; // product detail name
  static const double fontSize7xl  = 36.0; // product detail price

  // Radii
  static const double radiusSm = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    surface: Colors.white,
  );

  static ThemeData themeData = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    fontFamily: null,
    useMaterial3: true,
  );
}
