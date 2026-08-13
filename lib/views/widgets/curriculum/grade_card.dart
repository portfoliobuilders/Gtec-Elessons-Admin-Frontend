import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/grid_table.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/admin/admin_models.dart';
import 'circle_icon_button.dart';
import 'curriculum_tints.dart';
import 'notched_container.dart';

/// Pulls a short display number out of a grade's free-text `name` (e.g.
/// "Class 10" → "10", "Grade XI" → "XI") — the backend has no dedicated
/// numeric field, so this is purely cosmetic, never sent anywhere.
String gradeDisplayNumber(String name, int fallbackIndex) {
  final digits = RegExp(r'\d+').firstMatch(name);
  if (digits != null) return digits.group(0)!;
  final roman = RegExp(r'\b[IVXLCDM]+\b', caseSensitive: false).firstMatch(name);
  if (roman != null) return roman.group(0)!.toUpperCase();
  return '${fallbackIndex + 1}';
}

/// Premium dashboard tile for one grade — pastel background, a grade-icon
/// badge floating in the top-right notch, and a floating arrow button to
/// open the subject list.
class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.grade,
    required this.tintIndex,
    required this.onTap,
    this.onEdit,
    this.onArchive,
  });

  final AdminGradeModel grade;
  final int tintIndex;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final tint = tintForIndex(tintIndex);
    final int subjectCount = grade.subjects?.length ?? 0;
    final int chapterCount =
        grade.subjects?.fold<int>(0, (sum, s) => sum + (s.chapters?.length ?? 0)) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return NotchedContainer(
              width: constraints.maxWidth,
              height: 208,
              backgroundColor: tint.bg,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              iconBackgroundColor: tint.accent,
              topRightIcon: const AppIcon(AppIcons.book, size: 22, color: AppColors.white, strokeWidth: 1.8),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: OverflowMenuButton(color: tint.accent, onEdit: onEdit, onArchive: onArchive),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              grade.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.jakarta(
                                  size: 16.5, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.3),
                            ),
                          ),
                          StatusBadge.of(grade.isActive ? BadgeStatus.active : BadgeStatus.inactive),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(grade.board,
                          style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w700, color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Text(
                        '$subjectCount Subjects  ·  $chapterCount Chapters',
                        style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.softGrey),
                      ),
                      const Spacer(),
                      Text(
                        gradeDisplayNumber(grade.name, tintIndex),
                        style: AppTextStyles.jakarta(
                            size: 40, weight: FontWeight.w800, color: tint.accent, letterSpacing: -1.5, height: 1),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Responsive 3 → 2 → 1 column grid of [GradeCard]s, ending in a dashed
/// "Add new grade" tile.
class GradeGrid extends StatelessWidget {
  const GradeGrid({
    super.key,
    required this.grades,
    required this.onGradeTap,
    this.onAddGrade,
    this.onEditGrade,
    this.onDeleteGrade,
  });

  final List<AdminGradeModel> grades;
  final ValueChanged<AdminGradeModel> onGradeTap;
  final VoidCallback? onAddGrade;
  final ValueChanged<AdminGradeModel>? onEditGrade;
  final ValueChanged<AdminGradeModel>? onDeleteGrade;

  @override
  Widget build(BuildContext context) {
    final int columns = Responsive.isDesktop(context) ? 3 : (Responsive.isTablet(context) ? 2 : 1);
    const double gap = AppSizes.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (int i = 0; i < grades.length; i++)
              SizedBox(
                width: w,
                child: GradeCard(
                  grade: grades[i],
                  tintIndex: i,
                  onTap: () => onGradeTap(grades[i]),
                  onEdit: onEditGrade == null ? null : () => onEditGrade!(grades[i]),
                  onArchive: onDeleteGrade == null ? null : () => onDeleteGrade!(grades[i]),
                ),
              ),
            SizedBox(width: w, child: _AddGradeTile(onTap: onAddGrade)),
          ],
        );
      },
    );
  }
}

class _AddGradeTile extends StatelessWidget {
  const _AddGradeTile({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          height: 208,
          child: DashedBorder(
            radius: GradeCard._radius,
            background: AppColors.inputBg,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.navyChipBg, shape: BoxShape.circle),
                    child: const Center(
                      child: AppIcon(AppIcons.plus, size: 19, color: AppColors.navy, strokeWidth: 2.2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Add New Grade',
                      style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Create a new grade and manage its subjects',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
