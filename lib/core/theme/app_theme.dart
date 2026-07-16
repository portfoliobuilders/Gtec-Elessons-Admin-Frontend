import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Centralized theme — colors, text, buttons, inputs, cards, dialogs,
/// snackbars, shadows, radii and icons. No styles are hard-coded in screens
/// beyond values that exist verbatim in the source design.
class AppTheme {
  AppTheme._();

  /// Card shadow used on every white card:
  /// `box-shadow: 0 10px 24px -18px rgba(20,26,42,0.35)`
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x59141A2A), // rgba(20,26,42,0.35)
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -18,
    ),
  ];

  /// Frame shadow around each screen mock:
  /// `0 40px 80px -30px rgba(15,23,42,0.45)`
  static const List<BoxShadow> frameShadow = [
    BoxShadow(
      color: Color(0x730F172A),
      offset: Offset(0, 40),
      blurRadius: 80,
      spreadRadius: -30,
    ),
  ];

  /// Elevated CTA glow (e.g. "Start live class", "Send broadcast").
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          offset: const Offset(0, 10),
          blurRadius: 22,
          spreadRadius: -8,
        ),
      ];

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.pageBg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.navy,
        secondary: AppColors.red,
        surface: AppColors.white,
        error: AppColors.red,
        onPrimary: AppColors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.navy.withValues(alpha: 0.04),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.body, size: 18),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.body,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.sidebarBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(0), // design hides scrollbars
      ),
    );
  }
}
