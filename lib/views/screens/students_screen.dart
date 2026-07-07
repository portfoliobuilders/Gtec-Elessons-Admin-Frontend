import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/students_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 07 · Student Management.
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  static const List<double> _flexes = [2, 1, 1.4, 1, 0.9];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentsController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.opsAdminStudents,
      activeIndex: 1,
      user: NavPresets.karthikAdmin,
      titleWidget: Text.rich(
        TextSpan(
          text: 'Students ',
          style: AppTextStyles.pageTitle,
          children: [
            TextSpan(
              text: '· ${controller.totalCount}',
              style: AppTextStyles.jakarta(
                  size: 14, weight: FontWeight.w600, color: AppColors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop) const AppSearchField(hint: 'Search students…', width: 280),
        const PrimaryButton(label: 'Add student', iconPaths: AppIcons.plus),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter chips.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < controller.filters.length; i++)
                  AppFilterChip(
                    label: controller.filters[i],
                    active: i == controller.activeFilter,
                    onTap: () => controller.setFilter(i),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Table.
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  const GridHeaderRow(
                    flexes: _flexes,
                    gap: 14,
                    labels: [
                      'Student',
                      'Class',
                      'Courses',
                      'Progress',
                      'Status'
                    ],
                  ),
                  for (int i = 0; i < controller.students.length; i++)
                    _StudentRow(
                      student: controller.students[i],
                      isLast: i == controller.students.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pagination.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing 1–5 of ${controller.totalCount}',
                    style: AppTextStyles.jakarta(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: AppColors.grey)),
                Row(
                  children: [
                    const _PageButton(
                        child: AppIcon(AppIcons.chevronLeft,
                            size: 15, color: AppColors.grey, strokeWidth: 2)),
                    const SizedBox(width: 7),
                    _PageButton(
                      active: controller.page == 1,
                      onTap: () => controller.setPage(1),
                      child: Text('1',
                          style: AppTextStyles.jakarta(
                              size: 13,
                              weight: FontWeight.w700,
                              color: controller.page == 1
                                  ? AppColors.white
                                  : AppColors.body)),
                    ),
                    const SizedBox(width: 7),
                    _PageButton(
                      active: controller.page == 2,
                      onTap: () => controller.setPage(2),
                      child: Text('2',
                          style: AppTextStyles.jakarta(
                              size: 13,
                              weight: FontWeight.w700,
                              color: controller.page == 2
                                  ? AppColors.white
                                  : AppColors.body)),
                    ),
                    const SizedBox(width: 7),
                    const _PageButton(
                        child: AppIcon(AppIcons.chevronRight,
                            size: 15, color: AppColors.body, strokeWidth: 2)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.isLast});

  final StudentModel student;
  final bool isLast;

  BadgeStatus get _status => switch (student.status) {
        'ACTIVE' => BadgeStatus.active,
        'EXPIRING' => BadgeStatus.expiring,
        _ => BadgeStatus.inactive,
      };

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: StudentsScreen._flexes,
      gap: 14,
      bottomBorder: !isLast,
      cells: [
        EntityCell(
          monogram: student.monogram,
          name: student.name,
          subtitle: student.location,
          avatarSize: 36,
          avatarRadius: 10,
          monoSize: 10,
        ),
        Text(student.grade, style: AppTextStyles.cell),
        Text(student.courses, style: AppTextStyles.cell),
        Text(student.progress,
            style: AppTextStyles.jakarta(
                size: 13, weight: FontWeight.w800, color: AppColors.navy)),
        StatusBadge.of(_status, fontSize: 11, horizontal: 10),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.child, this.active = false, this.onTap});

  final Widget child;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? AppColors.navy : Colors.transparent,
            border: active
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
