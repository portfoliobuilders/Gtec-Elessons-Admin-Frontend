import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';

/// One breadcrumb segment in the Curriculum hierarchy
/// (Curriculum → Grade → Subject → Module → Lesson).
///
/// A segment without [onTap] renders as the current page — bold ink,
/// no hover, not clickable. A segment with [onTap] is a previous level —
/// grey, clickable, highlights on hover.
class CrumbSegment {
  const CrumbSegment(this.label, {this.onTap, this.icon});

  final String label;
  final VoidCallback? onTap;

  /// Optional leading icon, e.g. a home glyph on the root "Curriculum" crumb.
  final String? icon;
}

/// Chevron-separated breadcrumb trail for the Curriculum flow (and any future
/// drill-down flow — Lessons, Assessments, …) that needs the same "always
/// know where you are, always one tap back" navigation.
///
/// Segments are built dynamically by each screen from live controller/route
/// state — this widget only renders them and wires up taps.
class CurriculumBreadcrumb extends StatelessWidget {
  const CurriculumBreadcrumb({super.key, required this.segments});

  final List<CrumbSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          _Crumb(segment: segments[i], isCurrent: i == segments.length - 1),
          if (i != segments.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: AppIcon(AppIcons.chevronRight,
                  size: 13, color: AppColors.chevron, strokeWidth: 2),
            ),
        ],
      ],
    );
  }
}

class _Crumb extends StatefulWidget {
  const _Crumb({required this.segment, required this.isCurrent});

  final CrumbSegment segment;
  final bool isCurrent;

  @override
  State<_Crumb> createState() => _CrumbState();
}

class _CrumbState extends State<_Crumb> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool clickable = !widget.isCurrent && widget.segment.onTap != null;
    final Color color = widget.isCurrent
        ? AppColors.ink
        : (_hovering ? AppColors.navy : AppColors.grey);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.segment.icon != null) ...[
          AppIcon(widget.segment.icon!, size: 14.5, color: color, strokeWidth: 2),
          const SizedBox(width: 6),
        ],
        Text(
          widget.segment.label,
          style: AppTextStyles.jakarta(
            size: 14,
            weight: widget.isCurrent ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    if (!clickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(onTap: widget.segment.onTap, child: content),
    );
  }
}
