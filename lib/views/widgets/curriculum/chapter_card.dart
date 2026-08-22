import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';
import 'subject_card.dart' show kCurriculumGridBreakpoint;

/// Vertical grid tile for one chapter — numbered tile + overflow menu on
/// top, name, lesson count, then a "Manage lessons" action row at the
/// bottom. Mirrors [SubjectCard]'s visual language one level down the
/// hierarchy.
///
/// `lessonCount` is only ever populated when this chapter came from the
/// `GET /admin/curriculum` tree (`_count.lessons`) — shown as-is, never
/// fabricated, so it's hidden entirely rather than shown as "0" when null.
class ChapterCard extends StatefulWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.tintIndex,
    required this.onTap,
    this.onEdit,
    this.onArchive,
  });

  final AdminChapterModel chapter;
  final int tintIndex;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  @override
  State<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(widget.tintIndex);

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
                widget.chapter.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.jakarta(size: 15.5, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
              ),
              if (widget.chapter.lessonCount != null) ...[
                const SizedBox(height: 4),
                Text('${widget.chapter.lessonCount} Lessons',
                    style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Manage lessons',
                      style: AppTextStyles.jakarta(
                          size: 12.5, weight: FontWeight.w700, color: _hovering ? AppColors.navy : AppColors.muted)),
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

/// Responsive grid of [ChapterCard]s — same behavior as [SubjectList].
class ChapterList extends StatelessWidget {
  const ChapterList({
    super.key,
    required this.chapters,
    required this.onChapterTap,
    this.onEditChapter,
    this.onDeleteChapter,
  });

  final List<AdminChapterModel> chapters;
  final ValueChanged<AdminChapterModel> onChapterTap;
  final ValueChanged<AdminChapterModel>? onEditChapter;
  final ValueChanged<AdminChapterModel>? onDeleteChapter;

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
            for (int i = 0; i < chapters.length; i++)
              SizedBox(
                width: cardWidth,
                child: ChapterCard(
                  chapter: chapters[i],
                  tintIndex: i,
                  onTap: () => onChapterTap(chapters[i]),
                  onEdit: onEditChapter == null ? null : () => onEditChapter!(chapters[i]),
                  onArchive: onDeleteChapter == null ? null : () => onDeleteChapter!(chapters[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
