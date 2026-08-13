import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';

/// Premium horizontal card for one subject — icon tile, name, chapter
/// count, overflow menu and a floating arrow button.
///
/// No status badge — the backend `Subject` entity has no `isActive` field
/// (only `Grade` does), so there's nothing real to show there.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.tintIndex,
    required this.onTap,
    this.onEdit,
    this.onArchive,
  });

  final AdminSubjectModel subject;
  final int tintIndex;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final int chapterCount = subject.chapters?.length ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(14)),
                child: Center(child: AppIcon(AppIcons.book, size: 22, color: tint.accent, strokeWidth: 1.8)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: AppTextStyles.jakarta(
                          size: 15, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text('$chapterCount Chapters',
                        style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
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

/// Vertical stack of [SubjectCard]s.
class SubjectList extends StatelessWidget {
  const SubjectList({
    super.key,
    required this.subjects,
    required this.onSubjectTap,
    this.onEditSubject,
    this.onDeleteSubject,
  });

  final List<AdminSubjectModel> subjects;
  final ValueChanged<AdminSubjectModel> onSubjectTap;
  final ValueChanged<AdminSubjectModel>? onEditSubject;
  final ValueChanged<AdminSubjectModel>? onDeleteSubject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < subjects.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == subjects.length - 1 ? 0 : 14),
            child: SubjectCard(
              subject: subjects[i],
              tintIndex: i,
              onTap: () => onSubjectTap(subjects[i]),
              onEdit: onEditSubject == null ? null : () => onEditSubject!(subjects[i]),
              onArchive: onDeleteSubject == null ? null : () => onDeleteSubject!(subjects[i]),
            ),
          ),
      ],
    );
  }
}
