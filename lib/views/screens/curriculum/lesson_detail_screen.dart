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
import '../../widgets/curriculum/add_resource_dialog.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/lesson_card.dart';
import '../../widgets/curriculum/resource_card.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Screen 4.5 · Lesson detail — Grade/Subject/Chapter/Lesson info plus real
/// Resource management (Phase 4). There is no admin GET-resources endpoint;
/// `AdminLessonModel.resources` already arrives nested inside
/// `GET /admin/chapters/:id/lessons`, so the resource list is whatever the
/// already-loaded lesson carries — no extra fetch.
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key});

  void _goToCurriculum(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum);

  void _goToGrade(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumGradeDetail);

  void _goToSubject(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumSubjects);

  void _goToChapter(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumChapterDetail);

  void _editLesson(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddLesson);

  Future<void> _addResource(BuildContext context, String lessonId) async {
    final created = await showAddResourceDialog(context, lessonId: lessonId);
    if (!context.mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resource added.')));
    }
  }

  Future<void> _deleteResource(BuildContext context, AdminResourceModel resource) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete resource?',
      message: 'Delete "${resource.title}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteResource(resource.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Resource deleted.' : controller.lessonError ?? 'Unable to delete resource.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final grade = controller.selectedCurriculumGrade;
    final subject = controller.selectedCurriculumSubject;
    final chapter = controller.selectedCurriculumChapter;
    final lesson = controller.selectedCurriculumLesson;
    final duration = formatLessonDuration(lesson.durationSeconds);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => _goToCurriculum(context)),
          CrumbSegment(grade.name, onTap: () => _goToGrade(context)),
          CrumbSegment(subject.name, onTap: () => _goToSubject(context)),
          CrumbSegment(chapter.name, onTap: () => _goToChapter(context)),
          CrumbSegment(lesson.title),
        ],
      ),
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => _goToChapter(context)),
        PrimaryButton(label: 'Edit lesson', iconPaths: AppIcons.edit, onTap: () => _editLesson(context)),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(title: lesson.title, subtitle: '${grade.name} · ${subject.name} · ${chapter.name}'),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Lesson details',
                          style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                      const Spacer(),
                      if (lesson.isFreePreview) ...[
                        const StatusBadge('PREVIEW', color: AppColors.navy, background: AppColors.navyChipBg),
                        const SizedBox(width: 8),
                      ],
                      StatusBadge.of(lesson.isPublished ? BadgeStatus.live : BadgeStatus.draft),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _InfoStat(label: 'Display order', value: '${lesson.order}'),
                      _InfoStat(label: 'Duration', value: duration ?? 'Duration unavailable'),
                      _InfoStat(label: 'YouTube video id', value: lesson.youtubeId ?? 'Not set'),
                      _InfoStat(label: 'Resources', value: '${lesson.resources.length}'),
                    ],
                  ),
                  if (lesson.description != null && lesson.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 16),
                    Text(lesson.description!,
                        style: AppTextStyles.jakarta(
                            size: 13, weight: FontWeight.w600, color: AppColors.muted, height: 1.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Resources', style: AppTextStyles.eyebrow),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Resource',
                  iconPaths: AppIcons.plus,
                  height: 38,
                  fontSize: 12.5,
                  onTap: () => _addResource(context, lesson.id),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (lesson.resources.isEmpty)
              const InfoBanner(text: 'No resources yet. Add a note, PYQ, or resource file for this lesson.')
            else
              ResourceList(
                resources: lesson.resources,
                onDeleteResource: (r) => _deleteResource(context, r),
              ),
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
