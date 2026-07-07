import 'package:flutter/material.dart';

/// Every color below is lifted verbatim from the web design's inline styles.
/// Do not introduce new colors — extend this palette instead.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF16244A); // primary / active
  static const Color red = Color(0xFFE63946); // accent
  static const Color sidebarBg = Color(0xFF0E1424); // dark rail

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF141A2A); // headings / strong
  static const Color body = Color(0xFF3B4252); // body text
  static const Color muted = Color(0xFF6B7486); // secondary text
  static const Color grey = Color(0xFF9AA2B1); // labels / captions
  static const Color softGrey = Color(0xFF7A8294); // hint text
  static const Color canvasLabel = Color(0xFF8A92A3);

  // ── Sidebar text ─────────────────────────────────────────────────────────
  static const Color sidebarItem = Color(0xFF9AA3B5);
  static const Color sidebarMuted = Color(0xFF6B7690);
  static const Color sidebarAvatarText = Color(0xFF9FB2E0);
  static const Color roleSuperAdmin = Color(0xFFE08A93);
  static const Color roleAdmin = Color(0xFF9FB2E0);
  static const Color roleTeacher = Color(0xFFC8A86A);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const Color pageBg = Color(0xFFF7F9FC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFFAFBFE);
  static const Color tableHeadBg = Color(0xFFFBFCFE);
  static const Color searchBg = Color(0xFFF4F6FA);
  static const Color chipTrackBg = Color(0xFFF1F3F7);
  static const Color infoBg = Color(0xFFEAEEF6);
  static const Color uploadBg = Color(0xFFFBFCFE);

  // ── Borders / dividers ───────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E4EC);
  static const Color borderLight = Color(0xFFEDF0F5);
  static const Color divider = Color(0xFFF0F2F7);
  static const Color cardBorder = Color(0xFFE0E6F0);
  static const Color dashedBorder = Color(0xFFC8CEDA);
  static const Color hairline = Color(0xFFEFF2F6);
  static const Color chevron = Color(0xFFC2C8D2);
  static const Color radioBorder = Color(0xFFD6DBE5);
  static const Color toggleOff = Color(0xFFE4E8EF);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color green = Color(0xFF1F8A5B);
  static const Color greenBg = Color(0xFFE9F4EF);
  static const Color greenSelBg = Color(0xFFF1F9F5);
  static const Color redBg = Color(0xFFFDECEE);
  static const Color redIconBg = Color(0xFFFDF3F4);
  static const Color amber = Color(0xFF9A6A2A);
  static const Color amberBg = Color(0xFFFBF1E2);
  static const Color navyChipBg = Color(0xFFE7ECF6);
  static const Color greyChipBg = Color(0xFFF0F2F7);

  // ── Hatch avatar stripes ─────────────────────────────────────────────────
  static const Color hatchLight1 = Color(0xFFE6EBF4);
  static const Color hatchLight2 = Color(0xFFEEF2F8);
  static const Color hatchDark1 = Color(0xFF2A3450);
  static const Color hatchDark2 = Color(0xFF1E2740);
  static const Color hatchLabel = Color(0xFF9AA6BE);

  // ── Funnel shades ────────────────────────────────────────────────────────
  static const Color funnel2 = Color(0xFF2A3F73);
  static const Color funnel3 = Color(0xFF4A5E94);
  static const Color funnel4 = Color(0xFF6E80B4);

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const Color notifBody = Color(0xFFC3CDE6);
  static const Color notifMeta = Color(0xFF8FA0C8);
  static const Color reachSub = Color(0xFF5A6B8C);
}
