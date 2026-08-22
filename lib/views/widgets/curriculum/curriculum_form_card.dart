import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';

/// Large centered white form card used by every "Add …" screen in the
/// Curriculum flow — capped width so long-form fields stay readable on
/// wide desktop viewports.
class CurriculumFormCard extends StatelessWidget {
  const CurriculumFormCard({super.key, required this.child, this.maxWidth = 960});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: child,
        ),
      ),
    );
  }
}

/// Two-pane desktop composition for every "Add …" Curriculum screen — a
/// wider left column (the main editor fields) and a narrower right column
/// (thumbnail/cover, pricing, publishing/status) — matching the "GTEC ADMIN
/// — Curriculum Redesign" spec's ~65/35 split.
///
/// Deliberately does NOT reuse [FlexRow] (shared_widgets.dart) — that widget
/// switches at the app-wide `Responsive.isDesktop` breakpoint (1100px),
/// while this split is specified to switch at 1200px and collapse into one
/// column down through tablet width too. Using its own `LayoutBuilder`
/// keeps that breakpoint local to the Curriculum "Add" screens rather than
/// changing global responsive behavior used by unrelated screens.
class CurriculumSplitLayout extends StatelessWidget {
  const CurriculumSplitLayout({
    super.key,
    required this.left,
    required this.right,
    this.maxWidth = 1240,
    this.gap = 24,
    this.leftFlex = 65,
    this.rightFlex = 35,
  });

  final Widget left;
  final Widget right;
  final double maxWidth;
  final double gap;
  final int leftFlex;
  final int rightFlex;

  /// Desktop composition switches at 1200px of actual browser viewport
  /// width — below that (tablet & mobile) everything collapses into a
  /// single main column, left section first.
  ///
  /// Deliberately checked against `MediaQuery.sizeOf(context).width` (the
  /// full viewport, same basis as `Responsive.isDesktop`), NOT the
  /// `LayoutBuilder` constraints this widget's content actually gets — that
  /// available width is already reduced by the 240px sidebar and page
  /// padding, so a plain 1440px browser window only leaves ~1140px for
  /// this widget, never reaching a 1200 threshold measured that way and
  /// silently collapsing to one column on every normal desktop window.
  static const double desktopBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= desktopBreakpoint;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: leftFlex, child: left),
                  SizedBox(width: gap),
                  Expanded(flex: rightFlex, child: right),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, SizedBox(height: gap), right],
              ),
      ),
    );
  }
}

/// Empty state shown in place of a Subject/Chapter/Lesson grid when a
/// Grade/Subject/Chapter has no children yet — icon, headline, short
/// instruction, and the same "+ Add …" action already offered by the
/// section header above it, so the action is never hover-only or hidden.
///
/// [actionLabel]/[onAction] are optional — omitted for the "search matched
/// nothing" variant (e.g. "No chapters found" / "Try a different search
/// term."), which has no action of its own beyond adjusting the search box
/// already visible above it.
class CurriculumEmptyState extends StatelessWidget {
  const CurriculumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.navyChipBg, borderRadius: BorderRadius.circular(16)),
              child: Center(child: AppIcon(icon, size: 26, color: AppColors.navy, strokeWidth: 1.8)),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.jakarta(size: 15, weight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              PrimaryButton(label: actionLabel!, iconPaths: AppIcons.plus, onTap: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}
