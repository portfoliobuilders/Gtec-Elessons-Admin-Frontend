import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Central typography. The design uses only two families:
///   • Plus Jakarta Sans 400–800 (all UI text)
///   • JetBrains Mono 400–500 (avatar monograms / codes)
class AppTextStyles {
  AppTextStyles._();

  /// Base builder — every text style in the app goes through this.
  static TextStyle jakarta({
    double size = 13.5,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.body,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.hatchLabel,
  }) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);

  // ── Recurring styles ─────────────────────────────────────────────────────

  /// 18/800 −0.4 — top bar page title.
  static TextStyle get pageTitle => jakarta(
      size: 18, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.4);

  /// 15/800 −0.3 — card title.
  static TextStyle get cardTitle => jakarta(
      size: 15, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.3);

  /// 12/800 +0.6 uppercase — section eyebrow inside cards.
  static TextStyle get eyebrow => jakarta(
      size: 12, weight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.6);

  /// 11.5/800 +0.4 uppercase — table header.
  static TextStyle get tableHeader => jakarta(
      size: 11.5, weight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.4);

  /// 12/700 — form field label.
  static TextStyle get fieldLabel =>
      jakarta(size: 12, weight: FontWeight.w700, color: AppColors.muted);

  /// 27/800 −0.6 — KPI value.
  static TextStyle get kpiValue => jakarta(
      size: 27, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.6, height: 1);

  /// 12.5/600 — KPI caption.
  static TextStyle get kpiCaption =>
      jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey);

  /// 13.5/700 — primary cell / button text.
  static TextStyle get cellStrong =>
      jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink);

  /// 13/600 — regular cell text.
  static TextStyle get cell =>
      jakarta(size: 13, weight: FontWeight.w600, color: AppColors.body);

  /// 11/500 — cell subtitle.
  static TextStyle get cellSub =>
      jakarta(size: 11, weight: FontWeight.w500, color: AppColors.grey);
}
