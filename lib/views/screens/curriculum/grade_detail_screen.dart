import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/cover_image_uploader.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/subject_card.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Screen 1.5 · Grade detail. Shows the real grade record plus real Subject
/// management (create/edit/delete) — subjects come from the already-loaded
/// `GET /admin/curriculum` tree, no extra request per grade.
class GradeDetailScreen extends StatelessWidget {
  const GradeDetailScreen({super.key});

  void _goToCurriculum(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum);

  void _editGrade(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddGrade);

  Future<void> _deleteGrade(BuildContext context, AdminGradeModel grade) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete grade?',
      message: 'Delete "${grade.name}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteGrade(grade.id);
    if (!context.mounted) return;
    if (ok) {
      _goToCurriculum(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(controller.curriculumError ?? 'Unable to delete grade.')));
    }
  }

  void _addSubject(BuildContext context) {
    context.read<CurriculumController>().clearSelectedCurriculumSubject();
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddSubject);
  }

  void _openSubject(BuildContext context, AdminSubjectModel subject) {
    context.read<CurriculumController>().selectCurriculumSubject(subject.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumSubjects);
  }

  void _editSubject(BuildContext context, AdminSubjectModel subject) {
    context.read<CurriculumController>().selectCurriculumSubject(subject.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddSubject);
  }

  Future<void> _deleteSubject(BuildContext context, AdminSubjectModel subject) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete subject?',
      message: 'Delete "${subject.name}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteSubject(subject.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Subject deleted.' : controller.curriculumError ?? 'Unable to delete subject.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final grade = controller.selectedCurriculumGrade;
    final subjects = grade.subjects ?? const [];

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => _goToCurriculum(context)),
          CrumbSegment(grade.name),
        ],
      ),
      actions: [
        OutlineButtonX(
          label: 'Delete',
          iconPaths: AppIcons.trash,
          color: AppColors.red,
          onTap: () => _deleteGrade(context, grade),
        ),
        PrimaryButton(label: 'Edit grade', iconPaths: AppIcons.edit, onTap: () => _editGrade(context)),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(
              title: grade.name,
              subtitle: grade.syllabus == null ? grade.board : '${grade.board} · ${grade.syllabus}',
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (grade.iconUrl != null) ...[
                        CoverThumbnail(imageUrl: grade.iconUrl!, size: 40),
                        const SizedBox(width: 12),
                      ],
                      Text('Grade details',
                          style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                      const Spacer(),
                      StatusBadge.of(grade.isActive ? BadgeStatus.active : BadgeStatus.inactive),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _InfoStat(label: 'Board', value: grade.board),
                      _InfoStat(label: 'Syllabus', value: grade.syllabus ?? '—'),
                      _InfoStat(label: 'Display order', value: '${grade.order}'),
                      _InfoStat(label: 'Subjects', value: '${subjects.length}'),
                    ],
                  ),
                  if (grade.description != null && grade.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 16),
                    Text(grade.description!,
                        style: AppTextStyles.jakarta(
                            size: 13, weight: FontWeight.w600, color: AppColors.muted, height: 1.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Subjects', style: AppTextStyles.eyebrow),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Subject',
                  iconPaths: AppIcons.plus,
                  height: 38,
                  fontSize: 12.5,
                  onTap: () => _addSubject(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (subjects.isEmpty)
              const InfoBanner(text: 'This grade has no subjects yet. Add one to start building its curriculum.')
            else ...[
              SubjectList(
                subjects: subjects,
                onSubjectTap: (s) => _openSubject(context, s),
                onEditSubject: (s) => _editSubject(context, s),
                onDeleteSubject: (s) => _deleteSubject(context, s),
              ),
              const SizedBox(height: 22),
              const InfoBanner(text: 'Click a subject to manage its chapters.'),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }
}
