import 'package:flutter/material.dart';

/// 🎨 Unified App Theme - Black & Green Design System
/// This file contains all design constants for visual consistency across the app

class AppTheme {
  // ==========================================
  // COLOR PALETTE (Black & Green)
  // ==========================================
  static const Color primaryGreen = Color(0xFF3DDC97);
  static const Color backgroundDark = Color(0xFF0E0E0E);
  static const Color surfaceDark = Color(0xFF151E1B);
  static const Color surfaceSecondary = Color(0xFF1C2622);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFFFFFFF); // white70
  static const Color textTertiary = Color(0x8AFFFFFF); // white54
  static const Color errorRed = Colors.redAccent;
  static const Color warningOrange = Colors.orangeAccent;

  // ==========================================
  // TYPOGRAPHY
  // ==========================================
  static const double fontSizeDisplay = 32.0;
  static const double fontSizeHeadline = 24.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeSubtitle = 18.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeBodySmall = 14.0;
  static const double fontSizeCaption = 12.0;
  static const double fontSizeTiny = 10.0;

  static const FontWeight fontWeightBold = FontWeight.bold;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightRegular = FontWeight.w400;

  // ==========================================
  // SPACING & PADDING
  // ==========================================
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;

  static const EdgeInsets paddingCard = EdgeInsets.all(12.0);
  static const EdgeInsets paddingPage = EdgeInsets.all(16.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  // ==========================================
  // BORDER RADIUS
  // ==========================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 18.0;
  static const double radiusXXLarge = 24.0;

  // ==========================================
  // BUTTON STYLES
  // ==========================================
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: paddingButton,
    elevation: 0,
    minimumSize: const Size(0, 48),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: surfaceDark,
    foregroundColor: primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      side: BorderSide(color: primaryGreen, width: 1),
    ),
    padding: paddingButton,
    elevation: 0,
    minimumSize: const Size(0, 48),
  );

  static ButtonStyle get smallButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 0,
    minimumSize: const Size(0, 32),
    textStyle: const TextStyle(fontSize: fontSizeBodySmall, fontWeight: fontWeightSemiBold),
  );

  // ==========================================
  // CARD STYLES
  // ==========================================
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(
      color: primaryGreen.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration get productCardDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(radiusXLarge),
  );

  // ==========================================
  // TEXT STYLES
  // ==========================================
  static const TextStyle textStyleDisplay = TextStyle(
    color: textPrimary,
    fontSize: fontSizeDisplay,
    fontWeight: fontWeightBold,
  );

  static const TextStyle textStyleHeadline = TextStyle(
    color: textPrimary,
    fontSize: fontSizeHeadline,
    fontWeight: fontWeightBold,
  );

  static const TextStyle textStyleTitle = TextStyle(
    color: textPrimary,
    fontSize: fontSizeTitle,
    fontWeight: fontWeightBold,
  );

  static const TextStyle textStyleSubtitle = TextStyle(
    color: textPrimary,
    fontSize: fontSizeSubtitle,
    fontWeight: fontWeightSemiBold,
  );

  static const TextStyle textStyleBody = TextStyle(
    color: textPrimary,
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
  );

  static const TextStyle textStyleBodySecondary = TextStyle(
    color: textSecondary,
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
  );

  static const TextStyle textStyleBodySmall = TextStyle(
    color: textTertiary,
    fontSize: fontSizeBodySmall,
    fontWeight: fontWeightRegular,
  );

  static const TextStyle textStyleCaption = TextStyle(
    color: textTertiary,
    fontSize: fontSizeCaption,
    fontWeight: fontWeightRegular,
  );

  static const TextStyle textStylePrice = TextStyle(
    color: primaryGreen,
    fontSize: fontSizeSubtitle,
    fontWeight: fontWeightSemiBold,
  );

  static const TextStyle textStyleBadge = TextStyle(
    color: primaryGreen,
    fontSize: fontSizeCaption,
    fontWeight: fontWeightSemiBold,
  );

  // ==========================================
  // APP BAR THEME
  // ==========================================
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: backgroundDark,
    elevation: 0,
    iconTheme: IconThemeData(color: primaryGreen),
    titleTextStyle: TextStyle(
      color: primaryGreen,
      fontSize: fontSizeTitle,
      fontWeight: fontWeightBold,
    ),
  );

  // ==========================================
  // INPUT DECORATION
  // ==========================================
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: surfaceSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide(color: primaryGreen.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primaryGreen, width: 2),
    ),
    hintStyle: const TextStyle(color: textTertiary),
    labelStyle: const TextStyle(color: textSecondary),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // ==========================================
  // BADGE STYLES
  // ==========================================
  static BoxDecoration get badgeDecoration => BoxDecoration(
    color: primaryGreen.withOpacity(0.15),
    borderRadius: BorderRadius.circular(radiusSmall),
  );

  // ==========================================
  // ICON SIZES
  // ==========================================
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}

