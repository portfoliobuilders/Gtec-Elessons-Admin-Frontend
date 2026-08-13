import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';

/// `90` → `1:30`, `754` → `12:34`. Null stays null — a lesson with no
/// duration yet is not the same fact as a zero-second lesson.
String? formatLessonDuration(int? seconds) {
  if (seconds == null) return null;
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

/// Premium horizontal card for one lesson — numbered tile, title, duration,
/// Published/Draft + Free preview status, resource count (only when
/// present), overflow menu and a floating arrow button. Mirrors
/// [ChapterCard]'s visual language one level down the hierarchy.
class LessonCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final duration = formatLessonDuration(lesson.durationSeconds);

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
                      lesson.title,
                      style: AppTextStyles.jakarta(
                          size: 15, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (duration != null) ...[
                          Text(duration,
                              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                          const SizedBox(width: 8),
                        ],
                        if (lesson.resources.isNotEmpty)
                          Text('${lesson.resources.length} Resources',
                              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              if (lesson.isFreePreview) ...[
                const StatusBadge(
                  'PREVIEW',
                  color: AppColors.navy,
                  background: AppColors.navyChipBg,
                ),
                const SizedBox(width: 8),
              ],
              StatusBadge.of(lesson.isPublished ? BadgeStatus.live : BadgeStatus.draft),
              const SizedBox(width: 14),
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

/// Vertical stack of [LessonCard]s.
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
    return Column(
      children: [
        for (int i = 0; i < lessons.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == lessons.length - 1 ? 0 : 14),
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
  }
}
