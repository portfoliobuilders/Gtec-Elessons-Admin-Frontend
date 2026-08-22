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

/// Screen 4.5 · Lesson detail — video preview + lesson info side by side,
/// then description and real Resource management (Phase 4). There is no
/// admin GET-resources endpoint; `AdminLessonModel.resources` already
/// arrives nested inside `GET /admin/chapters/:id/lessons`, so the resource
/// list is whatever the already-loaded lesson carries — no extra fetch.
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
            FlexRow(
              gap: 20,
              items: [
                (62, _VideoPreviewCard(lesson: lesson)),
                (38, _LessonInfoCard(lesson: lesson, duration: duration)),
              ],
            ),
            if (lesson.description != null && lesson.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('DESCRIPTION',
                  style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.4)),
              const SizedBox(height: 8),
              Text(lesson.description!,
                  style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w600, color: AppColors.body, height: 1.6)),
            ],
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

/// Left pane — a YouTube thumbnail preview when a video is set (a static
/// preview image, not an embedded player — this app has no video-player
/// dependency and none is added here), or a clean "no video" state.
class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({required this.lesson});

  final AdminLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final youtubeId = lesson.youtubeId;
    final hasVideo = youtubeId != null && youtubeId.isNotEmpty;

    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppColors.sidebarBg,
          child: hasVideo
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                    Container(color: Colors.black.withValues(alpha: 0.18)),
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Center(
                          child: AppIcon(AppIcons.play, size: 24, color: AppColors.navy, strokeWidth: 1.8),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.play, size: 30, color: AppColors.white.withValues(alpha: 0.5), strokeWidth: 1.6),
                      const SizedBox(height: 10),
                      Text('No video connected',
                          style: AppTextStyles.jakarta(
                              size: 12.5, weight: FontWeight.w700, color: AppColors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Right pane — status + at-a-glance fields, matching the mockup's
/// "LESSON INFORMATION" panel.
class _LessonInfoCard extends StatelessWidget {
  const _LessonInfoCard({required this.lesson, required this.duration});

  final AdminLessonModel lesson;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final hasVideo = lesson.youtubeId != null && lesson.youtubeId!.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LESSON INFORMATION',
              style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.4)),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusBadge.of(lesson.isPublished ? BadgeStatus.live : BadgeStatus.draft),
              if (lesson.isFreePreview) ...[
                const SizedBox(width: 8),
                const StatusBadge('PREVIEW', color: AppColors.navy, background: AppColors.navyChipBg),
              ],
            ],
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Free Preview', value: lesson.isFreePreview ? 'Yes' : 'No'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Duration', value: duration ?? 'Not set'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Order', value: '${lesson.order}'),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.hairline),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'YouTube',
            value: hasVideo ? 'Connected' : 'Not connected',
            valueColor: hasVideo ? AppColors.green : AppColors.grey,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.muted)),
        Text(value,
            style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: valueColor ?? AppColors.ink)),
      ],
    );
  }
}
