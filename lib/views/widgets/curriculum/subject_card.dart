import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';

/// A [Subject]/[Chapter]/[Lesson] grid tile is a vertical card below its
/// 2-column grid width; two cards sit side by side above it.
const double kCurriculumGridBreakpoint = 640;

/// Vertical grid tile for one subject — icon tile + overflow menu on top,
/// name, chapter count, then a "Manage chapters" action row at the bottom.
///
/// No status badge — the backend `Subject` entity has no `isActive` field
/// (only `Grade` does), so there's nothing real to show there.
class SubjectCard extends StatefulWidget {
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
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(widget.tintIndex);
    final int chapterCount = widget.subject.chapters?.length ?? 0;

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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: tint.bg, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: AppIcon(AppIcons.book, size: 22, color: tint.accent, strokeWidth: 1.8)),
                  ),
                  const Spacer(),
                  OverflowMenuButton(onEdit: widget.onEdit, onArchive: widget.onArchive),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.jakarta(size: 15.5, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text('$chapterCount Chapters',
                  style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Manage chapters',
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

/// Responsive grid of [SubjectCard]s — 2 columns whenever there's enough
/// width for them, 1 column on narrow phone widths.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoCols = constraints.maxWidth >= kCurriculumGridBreakpoint;
        const double gap = 16;
        final double cardWidth = twoCols ? (constraints.maxWidth - gap) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (int i = 0; i < subjects.length; i++)
              SizedBox(
                width: cardWidth,
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
      },
    );
  }
}
