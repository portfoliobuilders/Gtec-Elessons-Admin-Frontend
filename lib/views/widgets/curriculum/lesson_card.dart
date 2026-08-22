import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';
import 'subject_card.dart' show kCurriculumGridBreakpoint;

/// `90` → `1:30`, `754` → `12:34`. Null stays null — a lesson with no
/// duration yet is not the same fact as a zero-second lesson.
String? formatLessonDuration(int? seconds) {
  if (seconds == null) return null;
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

/// Vertical grid tile for one lesson — numbered tile + overflow menu on
/// top, title, duration/resource-count meta, then a Published/Draft (+
/// Free preview) status row at the bottom. Mirrors [ChapterCard]'s visual
/// language one level down the hierarchy.
class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.tintIndex,
    required this.onTap,
    this.onEdit,
    this.onArchive,
  });

  final AdminLessonModel lesson;
  final int tintIndex;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(widget.tintIndex);
    final duration = formatLessonDuration(widget.lesson.durationSeconds);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          border: Border.all(color: _hovering ? AppColors.navy.withValues(alpha: 0.28) : Colors.transparent, width: 1.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        (widget.tintIndex + 1).toString().padLeft(2, '0'),
                        style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: tint.accent),
                      ),
                    ),
                  ),
                  const Spacer(),
                  OverflowMenuButton(onEdit: widget.onEdit, onArchive: widget.onArchive),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.jakarta(size: 15.5, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (duration != null) ...[
                    Text(duration, style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    const SizedBox(width: 8),
                  ],
                  if (widget.lesson.resources.isNotEmpty)
                    Flexible(
                      child: Text('${widget.lesson.resources.length} Resources',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (widget.lesson.isFreePreview) ...[
                    const StatusBadge('PREVIEW', color: AppColors.navy, background: AppColors.navyChipBg),
                    const SizedBox(width: 8),
                  ],
                  StatusBadge.of(widget.lesson.isPublished ? BadgeStatus.live : BadgeStatus.draft),
                  const Spacer(),
                  CircleArrowButton(onTap: widget.onTap, size: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive grid of [LessonCard]s — same behavior as [SubjectList].
class LessonList extends StatelessWidget {
  const LessonList({
    super.key,
    required this.lessons,
    required this.onLessonTap,
    this.onEditLesson,
    this.onDeleteLesson,
  });

  final List<AdminLessonModel> lessons;
  final ValueChanged<AdminLessonModel> onLessonTap;
  final ValueChanged<AdminLessonModel>? onEditLesson;
  final ValueChanged<AdminLessonModel>? onDeleteLesson;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoCols = constraints.maxWidth >= kCurriculumGridBreakpoint;
        const double gap = 16;
        final double cardWidth = twoCols ? (constraints.maxWidth - gap) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (int i = 0; i < lessons.length; i++)
              SizedBox(
                width: cardWidth,
                child: LessonCard(
                  lesson: lessons[i],
                  tintIndex: i,
                  onTap: () => onLessonTap(lessons[i]),
                  onEdit: onEditLesson == null ? null : () => onEditLesson!(lessons[i]),
                  onArchive: onDeleteLesson == null ? null : () => onDeleteLesson!(lessons[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
