import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';

/// Premium horizontal card for one chapter — icon tile, name, lesson
/// count, overflow menu and a floating arrow button. Mirrors [SubjectCard]'s
/// visual language one level down the hierarchy.
///
/// `lessonCount` is only ever populated when this chapter came from the
/// `GET /admin/curriculum` tree (`_count.lessons`) — shown as-is, never
/// fabricated, so it's hidden entirely rather than shown as "0" when null.
class ChapterCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    (tintIndex + 1).toString().padLeft(2, '0'),
                    style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: tint.accent),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.name,
                      style: AppTextStyles.jakarta(
                          size: 15, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
                    ),
                    if (chapter.lessonCount != null) ...[
                      const SizedBox(height: 4),
                      Text('${chapter.lessonCount} Lessons',
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                    ],
                  ],
                ),
              ),
              OverflowMenuButton(onEdit: onEdit, onArchive: onArchive),
              const SizedBox(width: 12),
              CircleArrowButton(onTap: onTap, size: 38),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical stack of [ChapterCard]s.
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
    return Column(
      children: [
        for (int i = 0; i < chapters.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == chapters.length - 1 ? 0 : 14),
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
  }
}
