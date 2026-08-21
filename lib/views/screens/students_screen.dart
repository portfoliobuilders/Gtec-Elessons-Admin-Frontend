import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/students_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/admin/admin_models.dart';
import '../../routes/app_routes.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

const List<double> _studentFlexes = [2, 1, 1, 0.9];

/// Derives a 1-2 letter monogram from a name (or email, if name is unset) —
/// presentation only, the backend has no avatar-initial field.
String studentMonogram(String? name, String? email) {
  final source = (name?.trim().isNotEmpty ?? false) ? name!.trim() : (email ?? '?');
  final words = source.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words.first.substring(0, 1) + words.last.substring(0, 1)).toUpperCase();
}

/// 07 · Student Management — real roster via `GET /admin/students`
/// (Phase 6A). No mock fallback: empty/error states are shown as-is.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentsController>().loadStudents();
  }

  Future<void> _openStudent(BuildContext context, StudentListItemModel student) async {
    context.read<StudentsController>().loadStudent(student.id);
    // Student Detail pops(true) after a successful delete — shown here
    // rather than there since its own Scaffold is gone by the time it pops.
    // Untyped `pushNamed` (not `pushNamed<bool>`) — AppRouter.onGenerateRoute
    // returns a plain `Route<dynamic>`, and requesting a `Route<bool>` here
    // forces an internal `as Route<bool>` cast in Navigator that throws.
    final result = await Navigator.of(context).pushNamed(AppRoutes.studentDetail);
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentsController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 4,
      user: NavPresets.gtecAdmin,
      titleWidget: Text.rich(
        TextSpan(
          text: 'Students ',
          style: AppTextStyles.pageTitle,
          children: [
            TextSpan(
              text: '· ${controller.total}',
              style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w600, color: AppColors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop)
          AppSearchField(hint: 'Search name, email or phone…', width: 280, onChanged: controller.setSearch),
        OutlineButtonX(label: 'Refresh', iconPaths: AppIcons.arrowRight, onTap: controller.refreshStudents),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!desktop) ...[
              AppSearchField(hint: 'Search name, email or phone…', onChanged: controller.setSearch),
              const SizedBox(height: 16),
            ],
            _StudentsBody(controller: controller, desktop: desktop, onTap: (s) => _openStudent(context, s)),
          ],
        ),
      ),
    );
  }
}

class _StudentsBody extends StatelessWidget {
  const _StudentsBody({required this.controller, required this.desktop, required this.onTap});

  final StudentsController controller;
  final bool desktop;
  final ValueChanged<StudentListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case StudentsLoadStatus.initial:
      case StudentsLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy),
            ),
          ),
        );
      case StudentsLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load students.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.error ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(
                    label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.loadStudents()),
              ],
            ),
          ),
        );
      case StudentsLoadStatus.loaded:
        if (controller.students.isEmpty) {
          return InfoBanner(
            text: controller.search.trim().isEmpty
                ? 'No students yet.'
                : 'No students match "${controller.search.trim()}".',
          );
        }
        return desktop ? _StudentsTable(students: controller.students, onTap: onTap) : _StudentsCards(students: controller.students, onTap: onTap);
    }
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({required this.students, required this.onTap});

  final List<StudentListItemModel> students;
  final ValueChanged<StudentListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          const GridHeaderRow(
            flexes: _studentFlexes,
            labels: ['Student', 'Phone', 'Grade', 'Status'],
          ),
          for (int i = 0; i < students.length; i++)
            GestureDetector(
              onTap: () => onTap(students[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GridRow(
                  flexes: _studentFlexes,
                  bottomBorder: i != students.length - 1,
                  cells: [
                    EntityCell(
                      monogram: studentMonogram(students[i].name, students[i].email),
                      name: students[i].name ?? 'Unnamed',
                      subtitle: students[i].email,
                    ),
                    Text(students[i].phone ?? '—', style: AppTextStyles.cell),
                    Text(_gradeLabel(students[i]), style: AppTextStyles.cell),
                    StatusBadge.of(students[i].status == 'ACTIVE' ? BadgeStatus.active : BadgeStatus.inactive),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentsCards extends StatelessWidget {
  const _StudentsCards({required this.students, required this.onTap});

  final List<StudentListItemModel> students;
  final ValueChanged<StudentListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < students.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == students.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () => onTap(students[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: EntityCell(
                          monogram: studentMonogram(students[i].name, students[i].email),
                          name: students[i].name ?? 'Unnamed',
                          subtitle: students[i].email,
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusBadge.of(students[i].status == 'ACTIVE' ? BadgeStatus.active : BadgeStatus.inactive),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String _gradeLabel(StudentListItemModel s) {
  if (s.gradeName == null && s.board == null) return '—';
  if (s.gradeName != null && s.board != null) return '${s.gradeName} · ${s.board}';
  return s.gradeName ?? s.board!;
}
