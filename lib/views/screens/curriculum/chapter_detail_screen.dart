import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/curriculum_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/admin/admin_models.dart';
import '../../../routes/app_routes.dart';
import '../../layouts/admin_shell.dart';
import '../../widgets/curriculum/add_resource_dialog.dart';
import '../../widgets/curriculum/cover_image_uploader.dart';
import '../../widgets/curriculum/curriculum_breadcrumb.dart';
import '../../widgets/curriculum/curriculum_form_card.dart';
import '../../widgets/curriculum/curriculum_header.dart';
import '../../widgets/curriculum/curriculum_search_field.dart';
import '../../widgets/curriculum/lesson_card.dart';
import '../../widgets/curriculum/resource_card.dart';
import '../../widgets/nav_presets.dart';
import '../../widgets/shared_widgets.dart';

/// Screen 3.5 · Chapter detail. Shows the real chapter record plus real
/// Lesson management (create/edit/delete/video) — lessons come from a
/// dedicated `GET /admin/chapters/:id/lessons` fetch (not nested in the
/// curriculum tree the way Subjects/Chapters are), loaded on entry.
class ChapterDetailScreen extends StatefulWidget {
  const ChapterDetailScreen({super.key});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  // Local, in-memory filter over the already-loaded `chapterLessons` list —
  // no request is ever made for this; searching never re-fetches lessons.
  String _lessonSearch = '';

  @override
  void initState() {
    super.initState();
    // Deferred to after this frame finishes building — loadChapterLessons()
    // calls notifyListeners() synchronously before its first `await` (from
    // initState(), before this screen's own build() has ever run and
    // registered as a listener). Calling it directly here doesn't crash
    // (unlike the identical pattern in grade_selection_screen.dart), but the
    // later, genuinely-async notifyListeners() once lessons finish loading
    // never reaches this screen either — confirmed live: the widget only
    // rebuilds when something unrelated (e.g. a resize past the desktop
    // breakpoint) forces it. Matches DashboardScreen's own initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CurriculumController>().loadChapterLessons();
    });
  }

  void _goToCurriculum(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculum);

  void _goToGrade(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumGradeDetail);

  void _goToSubject(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumSubjects);

  void _editChapter(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddChapter);

  void _addLesson(BuildContext context) {
    context.read<CurriculumController>().clearSelectedCurriculumLesson();
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddLesson);
  }

  void _openLesson(BuildContext context, AdminLessonModel lesson) {
    context.read<CurriculumController>().selectCurriculumLesson(lesson.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumLessonDetail);
  }

  void _editLesson(BuildContext context, AdminLessonModel lesson) {
    context.read<CurriculumController>().selectCurriculumLesson(lesson.id);
    Navigator.of(context).pushReplacementNamed(AppRoutes.curriculumAddLesson);
  }

  Future<void> _deleteLesson(BuildContext context, AdminLessonModel lesson) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete lesson?',
      message: 'Delete "${lesson.title}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteLesson(lesson.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Lesson deleted.' : controller.lessonError ?? 'Unable to delete lesson.')),
    );
  }

  Future<void> _addStudyMaterial(BuildContext context, String chapterId) async {
    final created = await showAddResourceDialog(context, chapterId: chapterId);
    if (!context.mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Study material added.')));
    }
  }

  Future<void> _deleteStudyMaterial(BuildContext context, String chapterId, AdminResourceModel resource) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete study material?',
      message: 'Delete "${resource.title}"? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;
    final controller = context.read<CurriculumController>();
    final ok = await controller.deleteChapterResource(chapterId, resource.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(ok ? 'Study material deleted.' : controller.chapterResourceError ?? 'Unable to delete study material.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurriculumController>();
    final grade = controller.selectedCurriculumGrade;
    final subject = controller.selectedCurriculumSubject;
    final chapter = controller.selectedCurriculumChapter;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 1,
      user: NavPresets.gtecAdmin,
      titleWidget: CurriculumBreadcrumb(
        segments: [
          CrumbSegment('Curriculum', onTap: () => _goToCurriculum(context)),
          CrumbSegment(grade.name, onTap: () => _goToGrade(context)),
          CrumbSegment(subject.name, onTap: () => _goToSubject(context)),
          CrumbSegment(chapter.name),
        ],
      ),
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => _goToSubject(context)),
        PrimaryButton(label: 'Edit chapter', iconPaths: AppIcons.edit, onTap: () => _editChapter(context)),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumHeader(title: chapter.name, subtitle: '${grade.name} · ${subject.name}'),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (chapter.iconUrl != null) ...[
                        CoverThumbnail(imageUrl: chapter.iconUrl!, size: 40),
                        const SizedBox(width: 12),
                      ],
                      Text('CHAPTER OVERVIEW',
                          style: AppTextStyles.jakarta(
                              size: 12.5, weight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.4)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _InfoStat(label: 'Display order', value: '${chapter.order}'),
                      _InfoStat(label: 'Lessons', value: chapter.lessonCount?.toString() ?? '—'),
                    ],
                  ),
                  if (chapter.description != null && chapter.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.hairline),
                    const SizedBox(height: 16),
                    Text(chapter.description!,
                        style: AppTextStyles.jakarta(
                            size: 13, weight: FontWeight.w600, color: AppColors.muted, height: 1.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Study Materials', style: AppTextStyles.eyebrow),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Study Material',
                  iconPaths: AppIcons.plus,
                  height: 38,
                  fontSize: 12.5,
                  onTap: () => _addStudyMaterial(context, chapter.id),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _StudyMaterialsSection(
              resources: controller.chapterResourcesFor(chapter.id),
              onDeleteResource: (r) => _deleteStudyMaterial(context, chapter.id, r),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Lessons', style: AppTextStyles.eyebrow),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Lesson',
                  iconPaths: AppIcons.plus,
                  height: 38,
                  fontSize: 12.5,
                  onTap: () => _addLesson(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _LessonSection(
              controller: controller,
              searchQuery: _lessonSearch,
              onSearchChanged: (value) => setState(() => _lessonSearch = value),
              onLessonTap: (l) => _openLesson(context, l),
              onEditLesson: (l) => _editLesson(context, l),
              onDeleteLesson: (l) => _deleteLesson(context, l),
              onAddLesson: () => _addLesson(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.controller,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onLessonTap,
    required this.onEditLesson,
    required this.onDeleteLesson,
    required this.onAddLesson,
  });

  final CurriculumController controller;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AdminLessonModel> onLessonTap;
  final ValueChanged<AdminLessonModel> onEditLesson;
  final ValueChanged<AdminLessonModel> onDeleteLesson;
  final VoidCallback onAddLesson;

  @override
  Widget build(BuildContext context) {
    switch (controller.lessonStatus) {
      case CurriculumLoadStatus.initial:
      case CurriculumLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy),
            ),
          ),
        );
      case CurriculumLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load lessons.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.lessonError ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(
                  label: 'Retry',
                  iconPaths: AppIcons.arrowRight,
                  onTap: () => controller.loadChapterLessons(),
                ),
              ],
            ),
          ),
        );
      case CurriculumLoadStatus.loaded:
        if (controller.chapterLessons.isEmpty) {
          return CurriculumEmptyState(
            icon: AppIcons.play,
            title: 'No lessons yet',
            message: 'Add your first lesson to this chapter.',
            actionLabel: 'Add Lesson',
            onAction: onAddLesson,
          );
        }

        // Local, in-memory filter over the already-loaded lesson list — no
        // request is ever made for this.
        final query = searchQuery.trim().toLowerCase();
        final filteredLessons = query.isEmpty
            ? controller.chapterLessons
            : [for (final l in controller.chapterLessons) if (l.title.toLowerCase().contains(query)) l];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurriculumSearchField(hint: 'Search lessons...', onChanged: onSearchChanged),
            const SizedBox(height: 14),
            if (filteredLessons.isEmpty)
              const CurriculumEmptyState(
                icon: AppIcons.play,
                title: 'No lessons found',
                message: 'Try a different search term.',
              )
            else
              LessonList(
                lessons: filteredLessons,
                onLessonTap: onLessonTap,
                onEditLesson: onEditLesson,
                onDeleteLesson: onDeleteLesson,
              ),
          ],
        );
    }
  }
}

/// No loading/error state machine here (unlike [_LessonSection]) — there is
/// no `GET` to load from in the first place, so this always renders
/// synchronously from whatever `CurriculumController` holds locally. See
/// the "Chapter-level Study Materials" comment on the controller for why.
class _StudyMaterialsSection extends StatelessWidget {
  const _StudyMaterialsSection({required this.resources, required this.onDeleteResource});

  final List<AdminResourceModel> resources;
  final ValueChanged<AdminResourceModel> onDeleteResource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resources.isEmpty)
          const InfoBanner(text: 'No study materials yet. Add a note, PYQ, or resource file for this chapter.')
        else
          ResourceList(resources: resources, onDeleteResource: onDeleteResource),
        const SizedBox(height: 10),
        Text(
          'Study materials added here are tracked for this session — the backend does not yet provide a way '
          'to list a chapter\'s existing resources, so they won\'t appear again after a page reload.',
          style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w600, color: AppColors.grey),
        ),
      ],
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
        Text(label.toUpperCase(),
            style: AppTextStyles.jakarta(size: 11, weight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }
}
